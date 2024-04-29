--------------------------------------------------------
--  DDL for Package Body CSF_PREVENTIVE_MAINTENANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_PREVENTIVE_MAINTENANCE_PVT" as
/* $Header: csfvpmtb.pls 120.12.12010000.4 2010/02/12 03:45:32 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSF_Preventive_Maintenance_PVT
-- Purpose          : Preventive Maintenace Concurrent Program API.
-- History          : Initial version for release 11.5.9
--		    : Replaced ahl_unit_effectivities_b with ahl_unit_effectivities_app_v
--		      for 11.5.10.
-- NOTE             :
-- End of Comments

G_PKG_NAME     CONSTANT VARCHAR2(30):= 'CSF_Preventive_Maintenance_PVT';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'csfvpmtb.pls';
g_retcode               number := 0;

Procedure Add_Err_Msg Is
l_msg_index_out		  NUMBER;
x_msg_data_temp		  Varchar2(2000);
x_msg_data		  Varchar2(4000);
Begin
If fnd_msg_pub.count_msg > 0 Then
  FOR i IN REVERSE 1..fnd_msg_pub.count_msg Loop
	fnd_msg_pub.get(p_msg_index => i,
		   p_encoded => 'F',
		   p_data => x_msg_data_temp,
		   p_msg_index_out => l_msg_index_out);
	x_msg_data := x_msg_data || x_msg_data_temp;
   End Loop;
   FND_FILE.put_line(FND_FILE.log,x_msg_data);
   fnd_msg_pub.delete_msg;
   g_retcode := 1;
End if;
End;

PROCEDURE Generate_SR_Tasks (
    	errbuf			 OUT  NOCOPY VARCHAR2,
	retcode			 OUT  NOCOPY NUMBER,
    	P_Api_Version_Number     IN   NUMBER,
    	p_period_size 		 IN   NUMBER
    	)
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Generate_SR_Tasks';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_access_flag             VARCHAR2(1);
l_sqlcode 		  Number;
l_sqlerrm 		  Varchar2(2000);

X_Return_Status           VARCHAR2(1);
X_Msg_Count               NUMBER;
X_Msg_Data                VARCHAR2(2000);

Cursor c_ump is
  Select    csi.owner_party_id,
           csi.install_location_id ,
	    csi.instance_id,
	    csi.instance_number,
	    csi.inventory_item_id,
	    csi.last_vld_organization_id,
	    csi.serial_number,
-- get install location only if type code is hz_party_sites or hz_locations
-- for SR validation
	    decode(csi.location_type_code,'HZ_PARTY_SITES',
		csi.location_id,'HZ_LOCATIONS',
		csi.location_id,null) location_id,
		csi.location_type_code,
	    csi.owner_party_account_id,
	    csi.external_reference,
	    csi.system_id,
---  get BILL_TO,SHIP_TO parties
	    csi.owner_party_id billto_party_id,
	    csi.owner_party_id shipto_party_id,
---  get party_site_id of use type BILL_TO and SHIP_TO
	    aueb.unit_effectivity_id,
	    amh.title,
	    aueb.mr_header_id,
	    aueb.program_mr_header_id,
	    aueb.service_line_id contract_service_id,
	    aueb.due_date,
	    aueb.earliest_due_date,
	    aueb.latest_due_date,
 	    amh.description,
	    hp.party_type
 From    ahl_unit_effectivities_app_v aueb,
	 csi_item_instances csi,
	 ahl_mr_headers_vl amh,
	 hz_parties hp
 Where nvl(aueb.earliest_due_date,aueb.due_date) <= trunc(sysdate) + p_period_size
-- Get only the open UMPs and SR not created
 and   (aueb.status_code is NULL or aueb.status_code = 'INIT-DUE')
-- Application_usg_code PM for Preventive Maintenance seeded for CMRO 11.5.10 changes
 and   aueb.application_usg_code = 'PM'
 and   aueb.unit_effectivity_id not in (select object_id
				from cs_incident_links cil
 				where cil.object_type = 'AHL_UMP_EFF'
				and  cil.link_type_id = 6)
-- link_type_id 6 is 'REFERS TO' seeded value
 and   csi.instance_id = aueb.csi_item_instance_id
 and   amh.mr_header_id = aueb.mr_header_id
 and   hp.party_id = csi.owner_party_id
 order by  nvl(aueb.earliest_due_date,aueb.due_date);

Cursor c_route(p_mr_header_id Number) is
Select arb.route_id,
       arb.task_template_group_id
From   ahl_routes_b arb,
       ahl_mr_routes amr
Where amr.mr_header_id = p_mr_header_id
and   arb.route_id = amr.route_id;

cursor c_contacts(p_party_id NUMBER) Is
Select 	hr.party_id,
      	hcp.contact_point_id,
    	hcp.contact_point_type,
    	hcp.primary_flag,
       	decode(primary_flag,'Y','Y',NULL)
	primary_contact,
       	timezone_id
From   Hz_Relationships hr,
       Hz_Parties hp_obj,
       Hz_Parties hp_sub,
       Hz_Contact_points hcp
Where hr.object_id = p_party_id
and   hr.status    = 'A'
and   NVL(hr.start_date, SYSDATE-1) < SYSDATE
and   NVL(hr.end_date, SYSDATE+1) > SYSDATE
and   hp_sub.party_id = hr.subject_id
and   hp_sub.status  = 'A'
and   hp_sub.party_type = 'PERSON'
and   hp_obj.party_id = hr.object_id
and   hp_obj.status  = 'A'
and   hp_obj.party_type = 'ORGANIZATION'
and   hcp.owner_table_id(+) = hr.party_id
and   hcp.owner_table_name(+) = 'HZ_PARTIES'
and   hcp.status(+) = 'A'
and   hr.party_id is not null;

cursor c_billto_shipto(p_billto_party NUMBER,p_shipto_party NUMBER) is
select hr.object_id,max(hr.party_id) party_id
from hz_relationships hr,hz_parties hp
where hr.object_id in (p_billto_party,p_shipto_party)
AND hr.status = 'A'
AND NVL(hr.start_date, SYSDATE-1) < SYSDATE
AND NVL(hr.end_date, SYSDATE+1) > SYSDATE
AND hp.party_id = hr.subject_id
AND hp.party_type  = 'PERSON'
AND hp.status = 'A'
group by hr.object_id;

cursor c_bill_ship_sites(p_party_id number) is
select hps1.party_site_id billto_site_id,
       hps2.party_site_id shipto_site_id
 From  hz_party_sites hps1,
	   hz_party_sites hps2,
	   hz_party_site_uses hpsu1,
	   hz_party_site_uses hpsu2
 Where hps1.party_id = p_party_id
 and   hpsu1.party_site_id = hps1.party_site_id
 and   hpsu1.site_use_type = 'BILL_TO'
 and   hpsu1.status = 'A'
 and   hpsu1.primary_per_type = 'Y'
 and   trunc(SYSDATE) BETWEEN TRUNC(NVL(hpsu1.begin_date,SYSDATE)) and
				TRUNC(NVL(hpsu1.end_date,SYSDATE))
 and   hps2.party_id = p_party_id
 and   hpsu2.party_site_id = hps2.party_site_id
 and   hpsu2.site_use_type = 'SHIP_TO'
 and   hpsu2.status = 'A'
 and   hpsu2.primary_per_type = 'Y'
 and   hps1.status = 'A'
 and   hps2.status = 'A'
 and   trunc(SYSDATE) between TRUNC(NVL(hpsu2.begin_date,SYSDATE)) and
				TRUNC(NVL(hpsu2.end_date,SYSDATE));

TYPE task_type is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
conf_task_id			task_type;
conf_object_version_number	task_type;

l_ump_rec   		c_ump%ROWTYPE;
l_route_rec 		c_route%ROWTYPE;
l_contacts_rec		c_contacts%ROWTYPE;
l_billto_shipto_rec	c_billto_shipto%ROWTYPE;
l_service_request_rec 	cs_servicerequest_pub.service_request_rec_type;
l_notes_table 		cs_servicerequest_pub.notes_table;
l_contacts_table 	cs_servicerequest_pub.contacts_table;
l_link_rec    		cs_incidentlinks_pub.cs_incident_link_rec_type;
l_billto_site_id    number;
l_shipto_site_id    number;
l_msg_index_out 	number;
task_created 		BOOLEAN	:= FALSE;
l_task_id		NUMBER;
l_index 		NUMBER := 0;
l_primary_contact 	VARCHAR2(1);

x_Task_Details_Tbl  	jtf_tasks_pub.task_details_tbl;
x_request_id  		Number;
x_request_number 	Number;
x_interaction_id	Number;
x_workflow_process_id 	Number;
x_individual_owner	Number;
x_group_owner		Number;
x_individual_type	Varchar2(200);
x_object_version_number Number;
x_reciprocal_link_id    Number;
x_link_id	     	Number;
x_pm_conf_reqd		Varchar2(1);


/* rhungund : note
   added the following 2 local variables for ER 3919796 */

l_product_number VARCHAR2(30);
l_serial_number VARCHAR2(30);


/* rhungund : note
   added the following 2 local variables for ER 3956663 */
l_no_contacts_table 	cs_servicerequest_pub.contacts_table;
l_no_notes_table 		cs_servicerequest_pub.notes_table;



/* rhungund - note
    Adding the cursor to get incident location id given a party site id
    Adding a local variable to hold the location id

    This resolves bug 4012520
*/
CURSOR c_get_hz_location_csr IS
    SELECT location_id from HZ_PARTY_SITES WHERE party_site_id = l_ump_rec.location_id;

l_hz_location_id NUMBER;



/*rhungund - begin - changes to associate access hours to PM tasks */
l_acc_hr_id           NUMBER;
l_acchr_loc_id        NUMBER;
l_acchr_ct_site_id    NUMBER;
l_acchr_ct_id         NUMBER;
l_acchrs_found        BOOLEAN;
l_address_id_to_pass  NUMBER;
l_location_id_to_pass NUMBER;

CURSOR c_acchrs_location_csr IS
	SELECT * from csf_map_access_hours_vl where
	customer_location_id = l_acchr_loc_id;

CURSOR c_acchrs_ctsite_csr IS
	SELECT * from csf_map_access_hours_vl where
	customer_id = l_acchr_ct_id and
	customer_site_id = l_acchr_ct_site_id;

CURSOR c_acchrs_ct_csr IS
	SELECT * from csf_map_access_hours_vl where
	customer_id = l_acchr_ct_id;

l_acchrs_setups_rec   c_acchrs_location_csr%ROWTYPE;

/*rhungund - end - changes to associate access hours to PM tasks */




BEGIN
     retcode := g_retcode;
     -- Standard Start of API savepoint
      SAVEPOINT Generate_SR_Tasks_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list
      FND_MSG_PUB.initialize;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      --
      -- API body
      --

	Open c_ump;
	LOOP
		Fetch c_ump into l_ump_rec;
        	Exit When c_ump%NOTFOUND;
		  --- reuse the savepoint to rollback or commit transaction for each UMP
      		SAVEPOINT Generate_SR_Tasks_PVT;
    FND_FILE.put_line(FND_FILE.log,'MESSAGE: Processing Effectivity==='||l_ump_rec.unit_effectivity_id);

      		l_product_number := l_ump_rec.instance_number;
      		l_serial_number := l_ump_rec.serial_number;


		cs_servicerequest_pub.initialize_rec(l_service_request_rec);
		l_service_request_rec.type_id :=
			fnd_profile.value('csfpm_incident_type');
		l_service_request_rec.status_id  :=
		fnd_profile.value('csfpm_incident_status');


		l_service_request_rec.summary  := l_ump_rec.title;
		l_service_request_rec.caller_type := l_ump_rec.party_type;
		l_service_request_rec.customer_id := l_ump_rec.owner_party_id;
		l_service_request_rec.customer_product_id := l_ump_rec.instance_id;
		l_service_request_rec.inventory_item_id := l_ump_rec.inventory_item_id;
		l_service_request_rec.inventory_org_id := l_ump_rec.last_vld_organization_id;
		l_service_request_rec.current_serial_number := l_ump_rec.serial_number;
		l_service_request_rec.exp_resolution_date := greatest(l_ump_rec.latest_due_date,sysdate);
		--l_service_request_rec.install_site_id := l_ump_rec.location_id;
		l_service_request_rec.account_id   := l_ump_rec.owner_party_account_id;
		l_service_request_rec.contract_service_id :=  l_ump_rec.contract_service_id;
		l_service_request_rec.sr_creation_channel := 'AUTOMATIC';
		l_service_request_rec.external_reference := l_ump_rec.external_reference;
		l_service_request_rec.system_id := l_ump_rec.system_id;
		l_service_request_rec.creation_program_code := 'PMCON'; -- Preventive Maintenance concurrent program seeded value
		l_service_request_rec.last_update_program_code := 'PMCON';
		l_service_request_rec.program_id := fnd_global.conc_program_id;
		l_service_request_rec.program_application_id := fnd_global.prog_appl_id;
		l_service_request_rec.conc_request_id := fnd_global.conc_request_id;
		l_service_request_rec.program_login_id := fnd_global.conc_login_id;

		l_service_request_rec.bill_to_party_id := l_ump_rec.billto_party_id;
		l_service_request_rec.ship_to_party_id := l_ump_rec.shipto_party_id;

FND_FILE.put_line(FND_FILE.log,'MESSAGE: Processing Instance Number='||l_service_request_rec.customer_product_id);
/* rhungund - note
  Adding the following 2 rec parameters to address bug 4379140
*/
		l_service_request_rec.bill_to_account_id   := l_ump_rec.owner_party_account_id;
		l_service_request_rec.ship_to_account_id   := l_ump_rec.owner_party_account_id;


/* rhungund - note
    Adding the incident location id to the service request record if
    item instance's current location type code = HZ_PARTY_SITE

    This resolves bug 4012520
*/
        IF (l_ump_rec.location_type_code is not null and
             l_ump_rec.location_type_code = 'HZ_PARTY_SITES') THEN

             l_service_request_rec.incident_location_id :=l_ump_rec.location_id;
             l_service_request_rec.incident_location_type :='HZ_PARTY_SITE';

        END IF;
/* ibalint bug 5183551 */


        IF (l_ump_rec.location_type_code is not null and
             l_ump_rec.location_type_code = 'HZ_LOCATION') THEN

             --l_service_request_rec.incident_location_id :=l_ump_rec.location_id;
             l_service_request_rec.incident_location_type :='HZ_LOCATION';
             l_service_request_rec.install_site_id := l_ump_rec.install_location_id;



        END IF;

--FND_FILE.put_line(FND_FILE.log,'MESSAGE: install_site_id*='||l_service_request_rec.install_site_id);


        -- Get bill to and ship to sites
        l_billto_site_id := null;
        l_shipto_site_id := null;
        open  c_bill_ship_sites(l_ump_rec.billto_party_id);
        fetch c_bill_ship_sites into l_billto_site_id,l_shipto_site_id;
        close c_bill_ship_sites;
		l_service_request_rec.bill_to_site_id := l_billto_site_id;
		l_service_request_rec.ship_to_site_id := l_shipto_site_id;

		-- Get Billto,Shipto contacts
		l_billto_shipto_rec := NULL;
		open c_billto_shipto(l_service_request_rec.bill_to_party_id,
				l_service_request_rec.ship_to_party_id);
		LOOP
			Fetch c_billto_shipto into l_billto_shipto_rec;
			EXIT WHEN c_billto_shipto%NOTFOUND;
			If l_billto_shipto_rec.object_id = l_service_request_rec.bill_to_party_id Then
				l_service_request_rec.bill_to_contact_id := l_billto_shipto_rec.party_id;
				ElsIf l_billto_shipto_rec.object_id = l_service_request_rec.ship_to_party_id Then
					l_service_request_rec.ship_to_contact_id := l_billto_shipto_rec.party_id;
			End If;
		END LOOP;
		close c_billto_shipto;
		l_service_request_rec.owner_id := NULL;
		l_service_request_rec.time_zone_id := NULL;
		l_contacts_table.DELETE;
		l_primary_contact := NULL;
		l_index := 0;
		l_contacts_rec := NULL;
	 	open c_contacts (l_ump_rec.owner_party_id);
		LOOP
			Fetch c_contacts INTO l_contacts_rec;
			EXIT WHEN c_contacts%NOTFOUND;
			-- Check to ensure that there would only one primary
			-- contact
			If not (nvl(l_primary_contact,'N') = 'Y' and
				nvl(l_contacts_rec.primary_flag,'N') = 'Y') Then
				l_index := l_index + 1;
				l_contacts_table(l_index).party_id := l_contacts_rec.party_id;
				l_contacts_table(l_index).contact_point_id := l_contacts_rec.contact_point_id;
				l_contacts_table(l_index).contact_point_type := l_contacts_rec.contact_point_type;
				l_contacts_table(l_index).contact_type := 'PARTY_RELATIONSHIP';
				l_contacts_table(l_index).primary_flag 	:= l_contacts_rec.primary_flag;
				l_primary_contact := nvl(l_primary_contact,l_contacts_rec.primary_contact);
				l_service_request_rec.time_zone_id := l_contacts_rec.timezone_id;
			End If;
		END LOOP;
		close c_contacts;
		l_index := 0;
/*rhungund : note
    The following IF block is added to address ER 3956663
    If a customer has no primary contact(s), we will not
    pass any contacts while creating the service request.
    This is to cirumvent an existing issue with Create_ServiceRequest() API
    which disallows creation of service request if 'ORG' customer type
    has no primary contacts

    Instead, after creating the SR, we update the SR with the list of contacts.
    Update_ServiceRequest() API has no such restriction as it's create counterpart does.

    The Update_ServiceRequest() API is also newly added to address the same ER.
*/
FND_FILE.put_line(FND_FILE.log,'MESSAGE: before calling cs_servicerequest_pub.Create_ServiceRequest API');

		IF (nvl(l_primary_contact,'N') = 'N') THEN

		cs_servicerequest_pub.Create_ServiceRequest
			( p_api_version		 => 3.0,
			  p_init_msg_list	 => FND_API.G_FALSE,
			  p_commit	         => FND_API.G_FALSE,
			  x_return_status	 => x_return_status,
			  x_msg_count		 => x_msg_count,
			  x_msg_data		 => x_msg_data,
			  p_resp_appl_id         => FND_GLOBAL.RESP_APPL_ID,
			  p_resp_id	         => FND_GLOBAL.RESP_ID,
			  p_user_id		 => fnd_global.user_id,
			  p_login_id		 => fnd_global.conc_login_id,
			  p_org_id		 => fnd_profile.value('ORG_ID'),
			  p_request_id           => null,
			  p_request_number	 => null,
			  p_service_request_rec  => l_service_request_rec,
			  p_notes     		 => l_notes_table,
			  p_contacts  		 => l_no_contacts_table,
			  p_auto_assign		=> 'Y',
			  x_request_id		=>  x_request_id,
			  x_request_number	=> x_request_number,
			  x_interaction_id      => x_interaction_id,
			  x_workflow_process_id => x_workflow_process_id,
			  x_individual_owner    => x_individual_owner,
			  x_group_owner		=> x_group_owner,
			  x_individual_type	=> x_individual_type );


	     ELSE

		cs_servicerequest_pub.Create_ServiceRequest
			( p_api_version		 => 3.0,
			  p_init_msg_list	 => FND_API.G_FALSE,
			  p_commit	         => FND_API.G_FALSE,
			  x_return_status	 => x_return_status,
			  x_msg_count		 => x_msg_count,
			  x_msg_data		 => x_msg_data,
			  p_resp_appl_id         => FND_GLOBAL.RESP_APPL_ID,
			  p_resp_id	         => FND_GLOBAL.RESP_ID,
			  p_user_id		 => fnd_global.user_id,
			  p_login_id		 => fnd_global.conc_login_id,
			  p_org_id		 => fnd_profile.value('ORG_ID'),
			  p_request_id           => null,
			  p_request_number	 => null,
			  p_service_request_rec  => l_service_request_rec,
			  p_notes     		 => l_notes_table,
			  p_contacts  		 => l_contacts_table,
			  p_auto_assign		=> 'Y',
			  x_request_id		=>  x_request_id,
			  x_request_number	=> x_request_number,
			  x_interaction_id      => x_interaction_id,
			  x_workflow_process_id => x_workflow_process_id,
			  x_individual_owner    => x_individual_owner,
			  x_group_owner		=> x_group_owner,
			  x_individual_type	=> x_individual_type );

	     END IF;
FND_FILE.put_line(FND_FILE.log,'MESSAGE: after calling cs_servicerequest_pub.Create_ServiceRequest API x_return_status='||x_return_status);

       		 If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
			fnd_message.set_name('CSF','CSF_PM_SR_CREATION_ERROR');
		       	fnd_message.set_token('VALUE1',l_ump_rec.unit_effectivity_id);
		       	fnd_message.set_token('VALUE2',l_product_number);
		       	fnd_message.set_token('VALUE3',l_serial_number);
		       	fnd_msg_pub.add;
		       	Add_Err_Msg;
       		 	ElsIf (nvl(x_individual_owner,0) <= 0 and nvl(x_group_owner,0) <= 0) Then
				fnd_message.set_name('CSF','CSF_PM_SR_OWNER_ERROR');
		       		fnd_message.set_token('VALUE1',l_ump_rec.unit_effectivity_id);
		       		fnd_message.set_token('VALUE2',nvl(x_individual_owner,x_group_owner));
		       		fnd_message.set_token('VALUE3',nvl(x_individual_type,'RS_GROUP'));
		       	fnd_message.set_token('VALUE4',l_product_number);
		       	fnd_message.set_token('VALUE5',l_serial_number);
		       		fnd_msg_pub.add;
		       		Add_Err_Msg;
				Else

/* rhungund: note
Calling Update_ServiceRequest() API to update the just created SR
with the list of contacts
*/

	  l_index := l_contacts_table.FIRST;
      IF (nvl(l_primary_contact,'N') = 'N' and l_index is not null) THEN
       CS_ServiceRequest_PUB.Update_ServiceRequest
      (
      p_api_version 	=> 3.0,
      p_init_msg_list	=> fnd_api.g_false,
      p_commit		=> fnd_api.g_false,
      x_return_status	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_request_id		=> x_request_id,
      p_last_updated_by	=> fnd_global.user_id,
      p_last_update_date	=> sysdate,
      p_object_version_number=> x_object_version_number,
	  p_resp_appl_id         => FND_GLOBAL.RESP_APPL_ID,
	  p_resp_id	         => FND_GLOBAL.RESP_ID,
      p_service_request_rec	=> l_service_request_rec,
      p_notes		=> l_no_notes_table,
      p_contacts		=> l_contacts_table,
	  x_interaction_id      => x_interaction_id,
	  x_workflow_process_id => x_workflow_process_id
);

         If x_return_status <> FND_API.G_RET_STS_SUCCESS Then
            fnd_message.set_name('CSF','CSF_PM_SR_UPDATE_ERROR');
			fnd_message.set_token('VALUE1',x_request_id);
		 	fnd_msg_pub.add;
	   		Add_Err_Msg;
        End If;

      END IF;





				--- Create link between UMP and Service Request
				l_link_rec := NULL;
				l_link_rec.subject_id := x_request_id;
				l_link_rec.subject_type := 'SR';
				l_link_rec.object_id := l_ump_rec.unit_effectivity_id;
				l_link_rec.object_number := l_ump_rec.title;
				l_link_rec.object_type := 'AHL_UMP_EFF';
				l_link_rec.link_type_id := 6;
				l_link_rec.request_id := fnd_global.conc_request_id;
				l_link_rec.program_application_id := fnd_global.prog_appl_id;
				l_link_rec.program_id := fnd_global.conc_program_id;
				l_link_rec.program_update_date := sysdate;
				cs_incidentlinks_pub.create_incidentlink(
					p_api_version 	=> 2.0,
					p_init_msg_list => FND_API.G_FALSE,
					p_commit 	=> FND_API.G_FALSE,
					p_resp_appl_id  => FND_GLOBAL.RESP_APPL_ID,
					p_resp_id	=> FND_GLOBAL.RESP_ID,
					p_user_id 	=> FND_GLOBAL.USER_ID,
					p_login_id	=> NULL,
					p_org_id	=> fnd_profile.value('ORG_ID'),
					p_link_rec	=> l_link_rec,
					x_return_status => x_return_status,
					x_msg_count => x_msg_count,
					x_msg_data  => x_msg_data,
					x_object_version_number => x_object_version_number,
					x_reciprocal_link_id => x_reciprocal_link_id,
					x_link_id	     => x_link_id);


       				If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
						fnd_message.set_name('CSF','CSF_PM_SR_LINK_CREATION_ERROR');
						fnd_message.set_token('VALUE1',l_ump_rec.unit_effectivity_id);
		       	fnd_message.set_token('VALUE2',l_product_number);
		       	fnd_message.set_token('VALUE3',l_serial_number);
						fnd_msg_pub.add;
						Add_Err_Msg;
			 	End If;
	         End If;


 		 If nvl(x_link_id,0) > 0 Then
			Open c_route(l_ump_rec.mr_header_id);
			Loop
				Fetch c_route into l_route_rec;
				Exit When c_route%NOTFOUND;
				x_task_details_tbl.delete;
				task_created := FALSE;
				If l_route_rec.task_template_group_id is not null
				Then

                                   --decide if we pass p_address_id or p_location_id
                                   IF (l_ump_rec.location_type_code is not null and
                                       l_ump_rec.location_type_code = 'HZ_PARTY_SITES') Then

                                            l_address_id_to_pass := l_ump_rec.location_id;
                                            l_location_id_to_pass := null;
                                   END IF;
                                   IF (l_ump_rec.location_type_code is not null and
                                       l_ump_rec.location_type_code = 'HZ_LOCATIONS') Then

                                            l_address_id_to_pass := null;
                                            l_location_id_to_pass := l_ump_rec.location_id;
                                   END IF;

					jtf_tasks_pub.create_task_from_template (
						p_api_version               => 1.0,
						p_init_msg_list             => FND_API.G_FALSE,
						p_commit                    => FND_API.G_FALSE,
						p_task_template_group_id     => l_route_rec.task_template_group_id,
						p_owner_type_code            => nvl(x_individual_type,'RS_GROUP'),
						p_owner_id                   => nvl(x_individual_owner,x_group_owner),
						p_source_object_id           => x_request_id,
						p_source_object_name         => x_request_number,
						x_return_status              => x_return_status,
						x_msg_count                  => x_msg_count,
						x_msg_data                   => x_msg_data,
						x_task_details_tbl           => x_task_details_tbl,
						p_customer_id                => l_ump_rec.owner_party_id,
						p_address_id                 => l_address_id_to_pass, --l_ump_rec.install_location_id,--l_ump_rec.location_id,
                                    p_location_id                => l_location_id_to_pass,
						p_planned_start_date         => nvl(l_ump_rec.earliest_due_date,l_ump_rec.due_date),
						p_planned_end_date           => to_date(nvl(l_ump_rec.latest_due_date,l_ump_rec.due_date)
|| ' 23:59:59', 'dd-mon-yy hh24:mi:ss'),
						p_timezone_id                => l_service_request_rec.time_zone_id);
						FND_FILE.put_line(FND_FILE.log,'MESSAGE:after create task x_return_status !='||x_return_status);
					If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
						fnd_message.set_name('CSF','CSF_PM_TASK_CREATION_ERROR');
						fnd_message.set_token('VALUE1',l_ump_rec.unit_effectivity_id);
						fnd_message.set_token('VALUE2',l_route_rec.route_id);
						fnd_message.set_token('VALUE3',x_individual_owner);
						fnd_message.set_token('VALUE4',x_individual_type);
		       	fnd_message.set_token('VALUE5',l_product_number);
		       	fnd_message.set_token('VALUE6',l_serial_number);
						fnd_msg_pub.add;
						Add_Err_Msg;
					   Else
						task_created := TRUE;
						If l_ump_rec.location_id is Null then
	                                --If l_ump_rec.install_location_id is Null then							fnd_message.set_name('CSF','CSF_PM_TASK_ADDRESS_MSG');
							fnd_message.set_token('VALUE1',x_request_number);
		       	fnd_message.set_token('VALUE2',l_product_number);
		       	fnd_message.set_token('VALUE3',l_serial_number);
							 fnd_msg_pub.add;
							 Add_Err_Msg;
						End If;
					End If;
			   Else
				fnd_message.set_name('CSF','CSF_PM_TASK_TEMPLATE_INVALID');
				fnd_message.set_token('VALUE1',l_ump_rec.unit_effectivity_id);
				fnd_message.set_token('VALUE2',l_route_rec.route_id);
		       	fnd_message.set_token('VALUE3',l_product_number);
		       	fnd_message.set_token('VALUE4',l_serial_number);
				fnd_msg_pub.add;
				Add_Err_Msg;
			 End If;
	       End Loop;
	       Close c_route;
	   End If;
	-- Commit the transaction or Rollback the transaction if no tasks are created for the service request.

        If task_created Then
      --	If 1=1 Then
	  COMMIT WORK;
	  FND_FILE.put_line(FND_FILE.log,'MESSAGE:after commit');
	-- Customer confirmation process
	-- Get customer cofirmation flag from contracts
       	  oks_pm_entitlements_pub.Get_PM_Confirmation
    			(p_api_version          => 1.0
 			,p_init_msg_list        => FND_API.G_FALSE
	 		,p_service_line_id     	=> l_ump_rec.contract_service_id
			,p_program_id	        => l_ump_rec.program_mr_header_id
			,p_Activity_id 	       => l_ump_rec.mr_header_id
 			,x_return_status      	=> x_return_status
 			,x_msg_count          	=> x_msg_count
			,x_msg_data             => x_msg_data
			,x_pm_conf_reqd         => x_pm_conf_reqd);

       	  If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
		Add_Err_Msg;
			Else
			-- If customer conformation required then update all
			-- the tasks statuses to CONFIRM status from profile option
			-- csfpm_task_confirm_status
				If x_pm_conf_reqd = 'Y' Then
      	  				SAVEPOINT Generate_SR_Tasks_PVT;

					SELECT task_id,object_version_number
					BULK COLLECT INTO conf_task_id,conf_object_version_number
					FROM jtf_tasks_b
					WHERE source_object_id = x_request_id;

					FOR i in 1..conf_task_id.COUNT Loop
                                     csf_tasks_pub.update_cust_confirmation(
                                           p_api_version   =>1.0
                                         , p_init_msg_list => FND_API.G_FALSE
                                         , p_commit        => FND_API.G_FALSE
                                         , x_return_status => x_return_status
                                         , x_msg_count     => x_msg_count
                                         , x_msg_data      => x_msg_data
                                         , p_task_id       => conf_task_id(i)
                                         , p_object_version_number => conf_object_version_number(i)
                                         , p_action      => csf_tasks_pub.g_action_conf_to_required
                                         , p_initiated   => csf_tasks_pub.g_dispatcher_initiated
                                        );

						If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
							fnd_message.set_name('CSF','CSF_PM_TASK_UPDATE_ERROR');
							fnd_message.set_token('VALUE1',x_request_number);
							fnd_message.set_token('VALUE2',conf_task_id(i));
		       	fnd_message.set_token('VALUE3',l_product_number);
		       	fnd_message.set_token('VALUE4',l_serial_number);
							fnd_msg_pub.add;
							Add_Err_Msg;
						End If;


       					END LOOP;
					COMMIT WORK;

					ELSE /* if cust confirmation is not required by contracts, check at the task templ level */
null;
       				End If; /* End of If x_pm_conf_reqd = 'Y'  */
		End If;


/* rhungund - begin - changes to associate access hours to the PM tasks */
	If task_created Then
/*
1) Check if access hours setups are done for the location
2) Else, check if access hours setups are done for the ct + ct site combination
3) Else, check if access hours setups are done for the ct
4) Create access hours for the task, if acc hrs setups are found for the just created task
*/

		l_acchr_ct_id := l_ump_rec.owner_party_id;

		IF (l_ump_rec.location_type_code = 'HZ_LOCATIONS') THEN
			l_acchr_loc_id := l_ump_rec.location_id;
			OPEN c_acchrs_location_csr;
			FETCH c_acchrs_location_csr INTO l_acchrs_setups_rec;
			IF (c_acchrs_location_csr%NOTFOUND) THEN
				OPEN c_acchrs_ct_csr;
				FETCH c_acchrs_ct_csr INTO l_acchrs_setups_rec;
				IF (c_acchrs_ct_csr%NOTFOUND) THEN
					l_acchrs_found := false;
				ELSE
					l_acchrs_found := true;
				END IF;
                                close c_acchrs_ct_csr;
			ELSE
				l_acchrs_found := true;
			END IF;
                        close c_acchrs_location_csr;

		ELSIF(l_ump_rec.location_type_code = 'HZ_PARTY_SITES') THEN
			l_acchr_ct_site_id := l_ump_rec.location_id;

			OPEN c_acchrs_ctsite_csr;
			FETCH c_acchrs_ctsite_csr INTO l_acchrs_setups_rec;
			IF (c_acchrs_ctsite_csr%NOTFOUND) THEN
				OPEN c_acchrs_ct_csr;
				FETCH c_acchrs_ct_csr INTO l_acchrs_setups_rec;
				IF (c_acchrs_ct_csr%NOTFOUND) THEN
					l_acchrs_found := false;
				ELSE
					l_acchrs_found := true;
				END IF;
                               close c_acchrs_ct_csr;
			ELSE
				l_acchrs_found := true;
			END IF;
                        close c_acchrs_ctsite_csr;
		END IF;

	IF (l_acchrs_found = true) THEN

		SELECT task_id,object_version_number
		BULK COLLECT INTO conf_task_id,conf_object_version_number
		FROM jtf_tasks_b
		WHERE source_object_id = x_request_id;


		FOR i in 1..conf_task_id.COUNT Loop
      CSF_ACCESS_HOURS_PUB.CREATE_ACCESS_HOURS(
          x_ACCESS_HOUR_ID => l_acc_hr_id,
	      p_API_VERSION => 1.0 ,
	      p_init_msg_list => NULL,
          p_TASK_ID => conf_task_id(i),
          p_ACCESS_HOUR_REQD => l_acchrs_setups_rec.accesshour_required,
          p_AFTER_HOURS_FLAG => l_acchrs_setups_rec.after_hours_flag,
          p_MONDAY_FIRST_START => l_acchrs_setups_rec.MONDAY_FIRST_START,
          p_MONDAY_FIRST_END => l_acchrs_setups_rec.MONDAY_FIRST_END,
          p_MONDAY_SECOND_START => l_acchrs_setups_rec.MONDAY_SECOND_START,
          p_MONDAY_SECOND_END => l_acchrs_setups_rec.MONDAY_SECOND_END,
          p_TUESDAY_FIRST_START => l_acchrs_setups_rec.TUESDAY_FIRST_START,
          p_TUESDAY_FIRST_END => l_acchrs_setups_rec.TUESDAY_FIRST_END,
          p_TUESDAY_SECOND_START => l_acchrs_setups_rec.TUESDAY_SECOND_START,
          p_TUESDAY_SECOND_END => l_acchrs_setups_rec.TUESDAY_SECOND_END,
          p_WEDNESDAY_FIRST_START => l_acchrs_setups_rec.WEDNESDAY_FIRST_START,
          p_WEDNESDAY_FIRST_END => l_acchrs_setups_rec.WEDNESDAY_FIRST_END,
          p_WEDNESDAY_SECOND_START => l_acchrs_setups_rec.WEDNESDAY_SECOND_START,
          p_WEDNESDAY_SECOND_END => l_acchrs_setups_rec.WEDNESDAY_SECOND_END,
          p_THURSDAY_FIRST_START => l_acchrs_setups_rec.THURSDAY_FIRST_START,
          p_THURSDAY_FIRST_END => l_acchrs_setups_rec.THURSDAY_FIRST_END,
          p_THURSDAY_SECOND_START => l_acchrs_setups_rec.THURSDAY_SECOND_START,
          p_THURSDAY_SECOND_END => l_acchrs_setups_rec.THURSDAY_SECOND_END,
          p_FRIDAY_FIRST_START => l_acchrs_setups_rec.FRIDAY_FIRST_START,
          p_FRIDAY_FIRST_END => l_acchrs_setups_rec.FRIDAY_FIRST_END,
          p_FRIDAY_SECOND_START => l_acchrs_setups_rec.FRIDAY_SECOND_START,
          p_FRIDAY_SECOND_END => l_acchrs_setups_rec.FRIDAY_SECOND_END,
          p_SATURDAY_FIRST_START => l_acchrs_setups_rec.SATURDAY_FIRST_START,
          p_SATURDAY_FIRST_END => l_acchrs_setups_rec.SATURDAY_FIRST_END,
          p_SATURDAY_SECOND_START => l_acchrs_setups_rec.SATURDAY_SECOND_START,
          p_SATURDAY_SECOND_END => l_acchrs_setups_rec.SATURDAY_SECOND_END,
          p_SUNDAY_FIRST_START => l_acchrs_setups_rec.SUNDAY_FIRST_START,
          p_SUNDAY_FIRST_END => l_acchrs_setups_rec.SUNDAY_FIRST_END,
          p_SUNDAY_SECOND_START => l_acchrs_setups_rec.SUNDAY_SECOND_START,
          p_SUNDAY_SECOND_END => l_acchrs_setups_rec.SUNDAY_SECOND_END,
          p_DESCRIPTION => l_acchrs_setups_rec.DESCRIPTION,
          px_object_version_number => x_object_version_number,
          p_CREATED_BY    => null,
          p_CREATION_DATE   => null,
          p_LAST_UPDATED_BY  => null,
          p_LAST_UPDATE_DATE => null,
          p_LAST_UPDATE_LOGIN =>  null,
		  x_return_status        => x_return_status,
		  x_msg_count            => x_msg_count,
		  x_msg_data             => x_msg_data );



      	  If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
				fnd_message.set_name('CSF','CSF_PM_TASK_UPDATE_ERROR');
				fnd_message.set_token('VALUE1',x_request_number);
				fnd_message.set_token('VALUE2',conf_task_id(i));
		       	fnd_message.set_token('VALUE3',l_product_number);
		       	fnd_message.set_token('VALUE4',l_serial_number);
			    fnd_msg_pub.add;
				Add_Err_Msg;
   		  End If;


       	  END LOOP;


       		  COMMIT WORK;
    		END IF;

	END IF;
/* rhungund - end - changes to associate access hours to the PM tasks */






	 Else


		  ROLLBACK to Generate_SR_Tasks_PVT;
	End If;


  	END LOOP;
       FND_FILE.put_line(FND_FILE.log,'MESSAGE: End of loop of UMPs !!! ');

  	If not fnd_profile.save('CSFPM_LAST_RUN_DATE',trunc(sysdate),'SITE') Then


	    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
 	End If;
	COMMIT WORK;

      --
      -- End of API body
      --

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      retcode := g_retcode;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            FND_FILE.put_line(FND_FILE.log,'MESSAGE: Inside exception 1');
	      retcode := 1;
	      errbuf := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            FND_FILE.put_line(FND_FILE.log,'MESSAGE: Inside exception 2');
	      retcode := 1;
	      errbuf := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
            FND_FILE.put_line(FND_FILE.log,'MESSAGE: Inside exception 3');
	      retcode := 1;
	      errbuf := X_Msg_Data;
	      l_sqlcode := SQLCODE;
	      l_sqlerrm := SQLERRM;
              /*  JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
	  	  ,P_SQLCODE	=> l_sqlcode
	  	  ,P_SQLERRM    => l_sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS); */
End Generate_SR_Tasks;



PROCEDURE update_ump (
    errbuf			 OUT  NOCOPY VARCHAR2,
    retcode			 OUT  NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_UMP';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_access_flag             VARCHAR2(1);
l_sqlcode 		  Number;
l_sqlerrm 		  Varchar2(2000);
l_Rollback		  Varchar2(1) := 'Y';

X_Return_Status           VARCHAR2(1);
X_Msg_Count               NUMBER;
X_Msg_Data                VARCHAR2(2000);

Cursor c_ump is
  Select aueb.unit_effectivity_id,
	 cil.subject_id incident_id,
	 csi.close_date,
	 csi.customer_product_id,
	 cccv.counter_id,
	 cccv.counter_name,
	 nvl(cccv.net_reading,0) net_reading
  From   ahl_unit_effectivities_app_v aueb,
	 cs_incident_links cil,
	 cs_incidents_all_b csi,
	 csi_cp_counters_v cccv
 Where   (aueb.status_code is NULL
	or aueb.status_code =  'INIT-DUE')
-- Application_usg_code PM for Preventive Maintenance seeded for CMRO 11.5.10 changes
 and   aueb.application_usg_code = 'PM'
 and   cil.object_id = aueb.unit_effectivity_id
 and   cil.object_type = 'AHL_UMP_EFF'
 and   cil.link_type_id = 6
 and   csi.incident_id = cil.subject_id
 and   csi.status_flag = 'C'
 and   cccv.customer_product_id(+) = aueb.csi_item_instance_id
 order by aueb.unit_effectivity_id;

l_unit_effectivity_tbl 	ahl_ump_unitmaint_pvt.unit_effectivity_tbl_type;
l_unit_threshold_tbl  	ahl_ump_unitmaint_pvt.Unit_Threshold_tbl_type;
l_unit_accomplish_tbl 	ahl_ump_unitmaint_pvt.unit_accomplish_tbl_type;
l_count 		Number := 0;
l_index 		Number := 0;
l_prev_effectivity_id 	Number := -1;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_ump_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      FND_MSG_PUB.initialize;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      FOR ump_rec in c_ump LOOP
		IF l_prev_effectivity_id <> ump_rec.unit_effectivity_id THEN
	   	-- Values to update AHL_UNIT_EFFECTIVITIES_B table.This
           	-- check is to Record only unique values of unit_effectivity_id
		   	l_index := l_index + 1;
  			l_unit_effectivity_tbl(l_index).UNIT_EFFECTIVITY_ID 	:= ump_rec.unit_effectivity_id;
       			l_unit_effectivity_tbl(l_index).STATUS_CODE     	:= 'ACCOMPLISHED';
        		l_unit_effectivity_tbl(l_index).ACCOMPLISHED_DATE 	:= ump_rec.close_date;
			l_prev_effectivity_id 	:= ump_rec.unit_effectivity_id;
		END IF;
		If ump_rec.counter_id is not null Then
       		-- Counter values to update the ahl_unit_accomplishmnts table
       		-- for accomplished UMPs. A product instance can have more than one
       		-- counter
	  		l_count := l_count + 1;
	  		l_unit_accomplish_tbl(l_count).unit_effectivity_id := ump_rec.unit_effectivity_id;
	  		l_unit_accomplish_tbl(l_count).counter_id := ump_rec.counter_id;
	  		l_unit_accomplish_tbl(l_count).counter_name := ump_rec.counter_name;
	  		l_unit_accomplish_tbl(l_count).counter_value := ump_rec.net_reading;
	  		l_unit_accomplish_tbl(l_count).operation_flag := 'C';
		End If;
     END LOOP;
     ahl_ump_unitmaint_pub.capture_mr_updates
			(p_api_version => 1.0,
			 p_init_msg_list => FND_API.G_FALSE,
			 p_commit => FND_API.G_FALSE,
			 p_validation_level => FND_API.G_VALID_LEVEL_FULL,
			 p_unit_effectivity_tbl => l_unit_effectivity_tbl,
			 p_x_unit_threshold_tbl => l_unit_threshold_tbl,
			 p_x_unit_accomplish_tbl => l_unit_accomplish_tbl,
			 x_return_status => x_return_status,
			 x_msg_count => x_msg_count,
			 x_msg_data => x_msg_data);
      If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
		Add_Err_Msg;
	 	Raise FND_API.G_EXC_UNEXPECTED_ERROR;
      End If;

      COMMIT WORK;

      --
      -- End of API body
      --

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      retcode := g_retcode;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
	      retcode := 2;
	      errbuf := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      retcode := 2;
	      errbuf := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
	      retcode := 2;
	      errbuf := X_Msg_Data;
	      l_sqlcode := SQLCODE;
	      l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
	  	  ,P_SQLCODE	=> l_sqlcode
	  	  ,P_SQLERRM    => l_sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End update_ump;

PROCEDURE update_sr_tasks (
    errbuf			 OUT  NOCOPY VARCHAR2,
    retcode			 OUT  NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'update_sr_tasks';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_access_flag             VARCHAR2(1);
l_sqlcode 		  Number;
l_sqlerrm 		  Varchar2(2000);

X_Return_Status           VARCHAR2(1);
X_Msg_Count               NUMBER;
X_Msg_Data                VARCHAR2(2000);

Cursor c_incidents is
  Select aueb.unit_effectivity_id,
	 cil.subject_id ,
	 cil.link_id,
	 csi.close_date,
	 csi.customer_product_id,
	 csi.object_version_number,
	 jtb.task_id,
	 jtb.planned_start_date,
	 jtb.planned_end_date,
	 jtb.scheduled_start_date,
	 jtb.scheduled_end_date,
	 jtb.actual_start_date,
	 jtb.actual_end_date,
	 jtb.object_version_number tasks_object_version
  From   ahl_unit_effectivities_app_v aueb,
	 cs_incident_links cil,
	 cs_incidents_all_b csi,
	 jtf_tasks_b jtb
 Where aueb.status_code in ('TERMINATED','EXCEPTION')
-- Application_usg_code PM for Preventive Maintenance seeded for CMRO 11.5.10 changes
 and   aueb.application_usg_code = 'PM'
 and   cil.object_id = aueb.unit_effectivity_id
 and   cil.object_type = 'AHL_UMP_EFF'
 and   cil.link_type_id = 6
 and   csi.incident_id = cil.subject_id
 and   jtb.source_object_id = cil.subject_id
 order by cil.subject_id;

l_prev_rec   c_incidents%ROWTYPE;
incident_rec c_incidents%ROWTYPE;
sr_update_success BOOLEAN;

x_interaction_id Number;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_sr_tasks_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      FND_MSG_PUB.initialize;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

	open c_incidents;
	LOOP
		Fetch c_incidents into incident_rec;
		EXIT WHEN c_incidents%NOTFOUND;
		If nvl(l_prev_rec.subject_id,-1) <> incident_rec.subject_id Then
			COMMIT WORK;
      			SAVEPOINT update_sr_tasks_pvt;
			l_prev_rec := incident_rec;
			sr_update_success := FALSE;
			cs_servicerequest_pub.Update_Status
				(p_api_version		=> 2.0,
  		  		p_init_msg_list		=> FND_API.G_FALSE,
  		  		p_commit		=> FND_API.G_FALSE,
  		  		x_return_status		=> x_return_status,
  		  		x_msg_count		=> x_msg_count,
  		  		x_msg_data		=> x_msg_data,
  		  		p_resp_appl_id		=> FND_GLOBAL.RESP_APPL_ID,
  		  		p_resp_id		=> FND_GLOBAL.RESP_ID,
  		  		p_user_id		=> FND_GLOBAL.USER_ID,
  		  		p_login_id		=> fnd_global.conc_login_id,
  		  		p_request_id		=> incident_rec.subject_id,
  		  		p_request_number	=> NULL,
  		  		p_object_version_number	=> incident_rec.object_version_number,
	 	  		-- status code CLOSED seeded in cs_incident_statuses
  		  		p_status_id		=> 4,
  		  		p_status		=> 'CLOSED',
  		  		x_interaction_id  	=> x_interaction_id);
		      		If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
					fnd_message.set_name('CSF','CSF_PM_SR_UPDATE_ERROR');
				 	fnd_message.set_token('VALUE1',incident_rec.subject_id);
				 	fnd_msg_pub.add;
			   		Add_Err_Msg;
					ROLLBACK TO update_sr_tasks_pvt;
					Else
						cs_incidentlinks_pub.DELETE_INCIDENTLINK 						(
				   			P_API_VERSION	=> 2.0,
				   			P_INIT_MSG_LIST => FND_API.G_FALSE,
				   			P_COMMIT	=> FND_API.G_FALSE,
				   			P_RESP_APPL_ID 	=> NULL,
				   			P_RESP_ID	=> NULL,
				   			P_USER_ID	=> NULL,
				   			P_LOGIN_ID	=> FND_GLOBAL.CONC_LOGIN_ID,
				   			P_ORG_ID	=> NULL,
				   			P_LINK_ID	=> incident_rec.link_id,
				  			X_RETURN_STATUS => x_return_status,
				   			X_MSG_COUNT     => x_msg_count,
				   			X_MSG_DATA      => x_msg_data);
			      				If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
								fnd_message.set_name('CSF','CSF_PM_SR_LINK_DELETE_ERROR');
							 	fnd_message.set_token('VALUE1',incident_rec.subject_id);
							 	fnd_msg_pub.add;
								Add_Err_Msg;
								ROLLBACK TO update_sr_tasks_pvt;
							Else
								sr_update_success := TRUE;
							End If;
				End If;
		End If;
		If sr_update_success Then
			csf_tasks_pub.Update_Task
				(p_api_version         	=> 1.0,
			 	p_init_msg_list       	=> FND_API.G_FALSE,
			 	p_commit    		=> fnd_api.g_false,
			 	p_task_id             	=> incident_rec.task_id,
			 	p_object_version_number => incident_rec.tasks_object_version,
			 	p_planned_start_date    => incident_rec.planned_start_date,
			 	p_planned_end_date      => incident_rec.planned_end_date,
			 	p_scheduled_start_date  => incident_rec.scheduled_start_date,
			 	p_scheduled_end_date    => incident_rec.scheduled_end_date,
			 	p_actual_start_date     => incident_rec.actual_start_date,
			 	p_actual_end_date       => incident_rec.actual_end_date,
			 	p_task_status_id        => fnd_profile.value('csf_default_task_cancelled_status'), -- Task cancelled status
			 	x_return_status        => x_return_status,
			 	x_msg_count            => x_msg_count,
			 	x_msg_data             => x_msg_data );
			If X_Return_status <> FND_API.G_RET_STS_SUCCESS Then
				fnd_message.set_name('CSF','CSF_PM_TASK_UPDATE_ERROR');
		 		fnd_message.set_token('VALUE1',incident_rec.subject_id);
		 		fnd_message.set_token('VALUE2',incident_rec.task_id);
		 		fnd_msg_pub.add;
				Add_Err_Msg;
				ROLLBACK TO update_sr_tasks_pvt;
			End If;
		End if;
	END LOOP;
	COMMIT WORK;
      --
      -- End of API body
      --

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      retcode := g_retcode;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
	      retcode := 2;
	      errbuf := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      retcode := 2;
	      errbuf := X_Msg_Data;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
	      retcode := 2;
	      errbuf := X_Msg_Data;
	      l_sqlcode := SQLCODE;
	      l_sqlerrm := SQLERRM;
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
	  	  ,P_SQLCODE		=> l_sqlcode
	  	  ,P_SQLERRM 	     => l_sqlerrm
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End update_sr_tasks;

End CSF_Preventive_Maintenance_PVT;


/
