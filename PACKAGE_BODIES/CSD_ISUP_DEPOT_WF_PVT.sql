--------------------------------------------------------
--  DDL for Package Body CSD_ISUP_DEPOT_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_ISUP_DEPOT_WF_PVT" AS
/* $Header: csdviswb.pls 120.4.12010000.3 2008/11/06 10:47:28 subhat ship $ */

/*-----------------------------------------------------------------*/
/* NOTE - This is the new workflow from isupport to depot integration*/
/*-----------------------------------------------------------------*/


/*-----------------------------------------------------------------*/
/*  procedure name: create_ro_wf 						*/
/* description   : Create RO and Logistics for a SR 			*/
/*                                                                 */
/*-----------------------------------------------------------------*/


g_incident_number       VARCHAR2(50);
g_business_process_id   NUMBER;

PROCEDURE check_sr_details_wf(itemtype   in         varchar2,
                            itemkey    in         varchar2,
                            actid      in         number,
                            funcmode   in         varchar2,
                            resultout  out NOCOPY varchar2) is

-- Cursor to get the Business Process id..

cursor get_business_process(p_incident_number in varchar2) is
SELECT cit.business_process_id
FROM cs_incidents_all_b ci,
	 cs_incident_types_b cit
where ci.incident_number = g_incident_number
	and ci.incident_type_id = cit.incident_type_id;

lc_mod_name varchar2(75) := 'csd_plsql_csd_isup_depot_wf_pvt.check_sr_details_wf';

BEGIN

  if  funcmode = 'RUN' then
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(   FND_LOG.LEVEL_PROCEDURE,
                  lc_mod_name||'begin',
                  'Entering Private API check_sr_details_wf');
    END IF;
-- This parameter is coming from Workflow event.
    g_incident_number := wf_engine.GETITEMATTRTEXT
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'REQUEST_NUMBER');

  -- Cursors to get SR detials
 OPEN get_business_process(g_incident_number);
 FETCH get_business_process INTO g_business_process_id;
 CLOSE get_business_process;

-- Check if the business process used is depot repair. If it is depot repair then only continue
-- with creating the RO and default product transaction lines.

 	IF nvl(g_business_process_id,0) = 1002 THEN
		resultout := 'Y';
	ELSE
		resultout := 'N';
	END IF;
END IF;
END check_sr_details_wf;


----------   For creating RO -- Will be called after SR is created for Depot.
-- create RO if the SR created for Depot Repair Business process.

PROCEDURE create_ro_wf (	itemtype   IN         varchar2,
                            itemkey    in         varchar2,
                            actid      in         number,
                            funcmode   in         varchar2,
                            resultout  out NOCOPY varchar2) is

l_incident_id NUMBER;
l_sr_number VARCHAR2(64);
l_repair_type_id NUMBER;

l_inventory_item_id   NUMBER;
l_current_serial_number  VARCHAR2(30);
l_customer_product_id     NUMBER;
l_inv_organization_id NUMBER;
l_unit_of_measure VARCHAR2(10);
l_repair_mode VARCHAR2(15);
l_org_id NUMBER;

--l_calc_resptime_flag VARCHAR2(1) := 'Y';
--l_server_tz_id NUMBER;
--l_business_process_id NUMBER;
--l_subinventory VARCHAR2(30);
--l_contract_line_id NUMBER;
--l_contract_number NUMBER := NULL;
--l_service_line_id NUMBER := NULL;
--l_rowcount NUMBER;
--l_contract_id NUMBER :=null;

l_customer_id NUMBER;
l_bill_to_site_id NUMBER;

--l_system_id NUMBER  :=null;
l_account_id NUMBER;


l_creation_date DATE;
l_incident_severity_id NUMBER;
l_price_list_id NUMBER;


--- For notifying customer

l_wf_role               VARCHAR2(320);
l_wf_role_display_name  VARCHAR2(360);
l_email                 VARCHAR2(2000);
l_contact_name          VARCHAR2(360);
l_serial_number         VARCHAR2(30);
l_item_name             VARCHAR2(40);

-- swai: 12.1.1 bug 7176940 service bulletin check
l_ro_sc_ids_tbl     CSD_RO_BULLETINS_PVT.CSD_RO_SC_IDS_TBL_TYPE;

---- For Notes..
notes_message VARCHAR2(2000);

-- RO notification message.

l_message varchar2(4000);

-- For line status

l_transaction_status VARCHAR2(30);
l_order_number NUMBER;

-- out params.
-- table type to hold the contract details.
--x_ent_contracts OKS_ENTITLEMENTS_PUB.GET_CONTOP_TBL;
x_repair_line_id NUMBER;
x_repair_number VARCHAR2(15);
x_return_status VARCHAR2(1);
x_msg_count NUMBER;
x_msg_data VARCHAR2(2000);
x_JTF_NOTE_ID NUMBER ;

-- create repair order exception.

l_ro_exception exception;

-- create logistics exception

l_prod_exception exception;

lc_mod_name varchar2(75) := 'csd_plsql_csd_isup_depot_wf_pvt.create_ro_wf';

---- Cursor to get Repair Mode

cursor get_repair_mode(p_repair_type_id IN  NUMBER ) IS
select REPAIR_MODE
from csd_repair_types_b
where repair_type_id=p_repair_type_id;

-- cursor to get the item details.

CURSOR item_details(p_incident_number IN NUMBER) IS
SELECT cs.incident_id,
    cs.org_id,
    cs.inventory_item_id,
    cs.current_serial_number,
    cs.customer_product_id,
    cs.inv_organization_id,
    cs.customer_id,
    cs.bill_to_site_use_id,
    cs.account_id,
    cs.incident_date,
    cs.incident_severity_id,
    mtl.primary_uom_code
FROM cs_incidents_all_b cs,
    mtl_system_items_b  mtl
WHERE
    cs.inventory_item_id = mtl.inventory_item_id AND
    cs.inv_organization_id = mtl.organization_id AND
    cs.INCIDENT_NUMBER = p_incident_number;


----- RO Attributes for Notifications
Cursor get_ro_attributes (p_repair_line_id IN NUMBER) IS
SELECT sr.cont_email,
       ro.repair_number,
       ro.serial_number,
       ro.item,
       decode(sr.contact_type,'EMPLOYEE',sr.first_name||' '||sr.last_name,sr.full_name) contact_name
FROM csd_incidents_v sr,
     csd_repairs_v ro
WHERE ro.incident_id  = sr.incident_id
AND ro.repair_line_id = p_repair_line_id;

CURSOR get_wf_role (p_repair_line_id IN NUMBER) IS
Select wr.name
from wf_roles wr,
     cs_incidents_v sr,
     csd_repairs    ro
where ro.repair_line_id = p_repair_line_id
and ro.incident_id = sr.incident_id
and wr.orig_system_id = sr.contact_party_id
and wr.orig_system = 'HZ_PARTY'
and nvl(wr.expiration_date,sysdate) >= sysdate
and wr.status = 'ACTIVE';

-- Cursor to Check if the line is booked.

cursor get_line_status(p_repair_line_id IN NUMBER) is
select prod_txn_status,
	  order_number
from csd_product_txns_v
where repair_line_id = p_repair_line_id
	and action_type='RMA';


BEGIN

-- get the default repair type based on the profile value.
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name||'begin',
          'Entering Private API create_ro_wf');
END IF;
 l_repair_type_id :=  fnd_profile.value('CSD_DEFAULT_REPAIR_TYPE');

-- if Profile is not set, set repair type to standard.
 if l_repair_type_id is null then

   l_repair_type_id:=1;

 end if;

 -- get the repair mode
 open get_repair_mode(l_repair_type_id);
 Fetch get_repair_mode into l_repair_mode;
 close get_repair_mode;

 -- fetch the item details.
 OPEN item_details(g_incident_number);
 FETCH item_details INTO
	l_incident_id,
	l_org_id,
	l_inventory_item_id,
	l_current_serial_number,
	l_customer_product_id,
	l_inv_organization_id,
	l_customer_id,
	l_bill_to_site_id,
	l_account_id,
	l_creation_date,
	l_incident_severity_id,
	l_unit_of_measure;
CLOSE item_details;

--notes_message := notes_message || g_incident_number;

-- get the profile value for the default price list.

fnd_profile.get('CSD_DEFAULT_PRICE_LIST',l_price_list_id);

-- set if the multi org security context, if its not already set.
-- without this all the secured apps data may not be visible.

IF mo_global.is_mo_init_done = 'N' THEN
	mo_global.set_policy_context('S',l_org_id);
END IF;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,lc_mod_name||'begin',
                  'calling create repair order public API');
END IF;
-- API call to create the repair orders.

   CSD_REPAIRS_GRP.Create_Repair_Order
      (p_init_msg_list => 'T',
      p_commit => 'F',
      p_repair_line_id =>null,
      p_repair_number => null,
      p_incident_id => l_incident_id,
      p_inventory_item_id => l_inventory_item_id,
      p_customer_product_id => l_customer_product_id,
      p_unit_of_measure => l_unit_of_measure,
      p_repair_type_id =>l_repair_type_id,
      p_resource_id => null,
      p_resource_group => null,
      p_project_id => null,
      p_task_id => null,
      p_unit_number => null,
      p_contract_line_id => null,
      p_auto_process_rma => 'Y' ,
      p_repair_mode => l_repair_mode,
      p_object_version_number => null,
      p_item_revision => null,
      p_instance_id => null,
      p_status => 'O',
      p_status_reason_code => null,
      p_date_closed => null,
      p_approval_required_flag => 'Y',
      p_approval_status =>null,
      p_serial_number => l_current_serial_number,
      p_promise_date => null,
      p_attribute_category => null,
      p_attribute1 => null,
      p_attribute2 => null,
      p_attribute3 => null,
      p_attribute4 => null,
      p_attribute5 => null,
      p_attribute6 => null,
      p_attribute7 => null,
      p_attribute8 => null,
      p_attribute9 => null,
      p_attribute10 => null,
      p_attribute11 => null,
      p_attribute12 => null,
      p_attribute13 => null,
      p_attribute14 => null,
      p_attribute15 => null,
      p_attribute16 => null, -- bug#7497907, 12.1 FP, subhat
      p_attribute17 => null,
      p_attribute18 => null,
      p_attribute19 => null,
      p_attribute20 => null,
      p_attribute21 => null,
      p_attribute22 => null,
      p_attribute23 => null,
      p_attribute24 => null,
      p_attribute25 => null,
      p_attribute26 => null,
      p_attribute27 => null,
      p_attribute28 => null,
      p_attribute29 => null,
      p_attribute30 => null,
      p_quantity => 1,
      p_quantity_in_wip => null,
      p_quantity_rcvd =>null,
      p_quantity_shipped =>null,
      p_currency_code => 'USD' ,
      p_default_po_num => null,
      p_repair_group_id            => null,
      p_ro_txn_status              => null,
      p_order_line_id              => null,
      p_original_source_reference  => null,
      p_original_source_header_id  => null,
      p_original_source_line_id    => null,
      p_price_list_header_id       => l_price_list_id,
      p_inventory_org_id           => l_inv_organization_id,
      p_problem_description        => null,
      p_ro_priority_code           => null,
      p_resolve_by_date		   => null,
      x_repair_line_id => x_repair_line_id,
      x_repair_number => x_repair_number,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);

      if x_return_status <> 'S' then
        raise l_ro_exception;
      end if;

    --notes_message := notes_message||' is '||x_repair_number;

  -- Calling create RO logistics lines.


--call create Logistics procedure if repair id is not standard

 if l_repair_type_id <> 1 then
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,lc_mod_name||'begin',
                  'calling create default product transactions API');
   END IF;

  csd_process_pvt.create_default_prod_txn
  (p_api_version      => 1.0,
   p_commit           => fnd_api.g_false,
   p_init_msg_list    => fnd_api.g_true,
   p_validation_level => fnd_api.g_valid_level_full,
   p_repair_line_id   => x_repair_line_id,
   x_return_status    => x_return_status,
   x_msg_count        => x_msg_count,
   x_msg_data         => x_msg_data);

  if x_return_status <> 'S' then
    raise l_prod_exception;
  end if;

 end if;

 -- swai: 12.1.1 bug 7176940 - check service bulletins after RO creation
 IF (nvl(fnd_profile.value('CSD_AUTO_CHECK_BULLETINS'),'N') = 'Y') THEN
    CSD_RO_BULLETINS_PVT.LINK_BULLETINS_TO_RO(
       p_api_version_number         => 1.0,
       p_init_msg_list              => Fnd_Api.G_FALSE,
       p_commit                     => Fnd_Api.G_TRUE,
       p_validation_level           => Fnd_Api.G_VALID_LEVEL_FULL,
       p_repair_line_id             => x_repair_line_id,
       px_ro_sc_ids_tbl             => l_ro_sc_ids_tbl,
       x_return_status              => x_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data
    );
    -- ignore return status for now.
 END IF;

open get_line_status(x_repair_line_id);
fetch get_line_status into l_transaction_status,l_order_number;
close get_line_status;
    -- get the notes message and replace the binds.
    fnd_message.set_name('CSD','CSD_RO_CREATED_WF_NOTE');
    fnd_message.set_token('SERVICE_REQUEST',g_incident_number);
    fnd_message.set_token('REPAIR_NUMBER',x_repair_number);
if upper(l_transaction_status)='BOOKED' then
  --notes_message := notes_message||' RMA number is  '||l_order_number;
  fnd_message.set_token('RMA_NUMBER',l_order_number);
else
  fnd_message.set_token('RMA_NUMBER','not booked');
end if;

notes_message := fnd_message.get;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,lc_mod_name||'begin','calling create JTF Notes API');
END IF;

JTF_NOTES_PUB.Create_note
       (
          p_api_version           => 1.0,
          p_init_msg_list         => FND_API.G_FALSE,
          p_commit                => FND_API.G_FALSE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
	        P_NOTE_STATUS	          => 'E',
	        p_source_object_id      => l_incident_id,
          p_source_object_code    => 'SR',
          p_notes                 => notes_message,
          p_entered_date          => sysdate,
	        p_note_type	            => 'GENERAL',
          x_jtf_note_id           => x_JTF_NOTE_ID
       );


if x_return_status = 'S' then

 -- Derive the wf roles for the Contact id
    Open get_wf_role (x_repair_line_id);
    Fetch get_wf_role into l_wf_role;
    Close get_wf_role;

    Open get_ro_attributes (x_repair_line_id);
    Fetch get_ro_attributes into l_email,x_repair_number,l_serial_number,
                                l_item_name,l_contact_name;
    Close get_ro_attributes;

    -- derive the notification message.
    fnd_message.set_name('CSD','CSD_RO_WF_NTF_MSG');
    fnd_message.set_token('CONTACT_NAME',l_contact_name);
    fnd_message.set_token('REPAIR_ORDER',x_repair_number);
    fnd_message.set_token('SERVICE_REQUEST',g_incident_number);
    fnd_message.set_token('RMA_NUMBER',l_order_number);

    l_message := fnd_message.get;

-- If role does not exist the create adhoc wf role

    if ( l_wf_role is null ) then

         wf_directory.CreateAdHocRole
                     (role_name               => l_wf_role,
                      role_display_name       => l_wf_role_display_name,
                      language                => 'AMERICAN',
                      territory               => 'AMERICA',
                      role_description        => 'CSD: Notify RO Details - Adhoc role',
                      notification_preference => 'MAILTEXT',
                      role_users              => null,
                      email_address           => l_email,
                      fax                     => null,
                      status                  => 'ACTIVE',
                      expiration_date         => add_months(sysdate,36),
                      parent_orig_system      => null,
                      parent_orig_system_id   => null,
                      owner_tag               => null);

     end if;

    if ( l_wf_role is not null ) then

      wf_engine.setItemAttrText
       (itemtype   =>  itemtype,
        itemkey    =>  itemkey,
        aname      =>  'RECEIVER',
        avalue     =>  l_wf_role);

      /*wf_engine.setItemAttrText
       (itemtype   =>  itemtype,
        itemkey    =>  itemkey,
        aname      =>  'CONTACT_NAME',
        avalue     =>  l_contact_name);

      wf_engine.setItemAttrText
       (itemtype   =>  itemtype,
        itemkey    =>  itemkey,
        aname      =>  'SERVICE_REQUEST',
        avalue     =>  g_incident_number);

      wf_engine.setItemAttrText
       (itemtype   =>  itemtype,
        itemkey    =>  itemkey,
        aname      =>  'REPAIR_ORDER',
        avalue     =>  x_repair_number); */

      wf_engine.setItemAttrText
       (itemtype   =>  itemtype,
        itemkey    =>  itemkey,
        aname      =>  'ITEM_NAME',
        avalue     =>  l_item_name);

      wf_engine.setItemAttrText
       (itemtype   =>  itemtype,
        itemkey    =>  itemkey,
        aname      =>  'SERIAL_NUMBER',
        avalue     =>  l_serial_number);

      wf_engine.setItemAttrText
       (itemtype   => itemtype,
        itemkey    => itemkey,
        aname      => 'MESSAGE',
        avalue     => l_message);

	/*if upper(l_transaction_status)='BOOKED' then

			wf_engine.setItemAttrText
	   (itemtype   =>  itemtype,
			itemkey    =>  itemkey,
			aname      =>  'RMA_NUMBER',
			avalue     =>  l_order_number);

	end if; -- end if transaction is booked. */

end if; -- end if RO created.

	resultout := 'Y';

else

	resultout := 'N';

end if;
COMMIT WORK;

EXCEPTION
	WHEN l_ro_exception THEN
	 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,lc_mod_name||'exception','Error '||x_msg_data);
  END IF;
  WF_CORE.CONTEXT ('CSD_ISUP_DEPOT_WF_PVT','create_ro_wf', itemtype,itemkey, to_char(actid),funcmode);
  ROLLBACK;
  RAISE;
  WHEN l_prod_exception THEN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,lc_mod_name||'exception','Error '||x_msg_data);
  END IF;
  WF_CORE.CONTEXT ('CSD_ISUP_DEPOT_WF_PVT','create_ro_wf', itemtype,itemkey, to_char(actid),funcmode);
  ROLLBACK;
  RAISE;
  WHEN OTHERS THEN
     WF_CORE.CONTEXT ('CSD_ISUP_DEPOT_WF_PVT','create_ro_wf', itemtype,itemkey,       to_char(actid),funcmode);
     RAISE;
     ROLLBACK;
end create_ro_wf;

END CSD_ISUP_DEPOT_WF_PVT;

/
