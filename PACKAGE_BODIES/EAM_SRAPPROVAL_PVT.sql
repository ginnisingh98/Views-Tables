--------------------------------------------------------
--  DDL for Package Body EAM_SRAPPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SRAPPROVAL_PVT" AS
/*$Header: EAMVSRAB.pls 120.5 2005/10/11 17:31:27 sraval ship $ */

function service_request_created(
                        p_subscription_guid in	   raw,
                        p_event		   in out NOCOPY wf_event_t
                      ) return varchar2
is
	L_EVENT_NAME varchar2(240);
	L_EVENT_KEY  varchar2(240);
	itemtype            	        varchar2(30);
	itemkey  	        varchar2(30) ;
	l_application_id NUMBER;
	l_application_code varchar2(32);
	l_incident_number cs_incidents_all_b.incident_number%type;
	l_incident_id cs_incidents_all_b.incident_id%type;

	l_owning_department_id cs_incidents_all_b.owning_department_id%type;
	l_owning_department_code bom_departments.department_code%type;
	l_owning_department_role varchar2(80);
	l_inventory_item_id cs_incidents_all_b.inventory_item_id%type;
	l_maintenance_flag varchar2(1);
	l_concatenated_segments mtl_system_items_kfv.concatenated_segments%type;
	l_conc_segments_description mtl_system_items.description%type;

	l_role_name varchar2(80);

	l_organization_code org_organization_definitions.organization_code%type;
	l_responsibility_id varchar2(80);
	l_responsibility_appl_id varchar2(30);
	l_resp_string varchar2(30);
	l_display_name varchar2(80);
	l_incident_date date;
	l_expected_resolution_date date;
	l_default_department_id wip_eam_parameters.default_department_id%type;
	l_return_status varchar2(240);
	l_incident_status_id cs_incidents_all_b.incident_status_id%type;
	l_incident_severity_id cs_incidents_all_b.incident_severity_id%type;
	l_customer_id cs_incidents_all_b.customer_id%type;
	l_service_rec cs_servicerequest_pub.service_request_rec_type;
	l_sr_user_id number;
	l_sr_resp_id number;
	l_sr_resp_appl_id number;
	l_notes_rec cs_servicerequest_pub.notes_table;
	l_contacts_rec cs_servicerequest_pub.contacts_table;
	l_sr_api_version number;
	l_object_version_number number;
	l_sr_return_status varchar2(1);
	l_sr_msg_count number;
	l_sr_msg_data varchar2(2000);
	l_sr_workflow_process_id number;
	l_sr_interaction_id number;
	l_workflow_process varchar2(30);
	l_instance_id	number;
	l_instance_number	varchar2(30);
	l_instance_description csi_item_instances.instance_description%type;
	l_maint_organization_id	cs_incidents_all_b.maint_organization_id%type;
begin

	itemtype := 'EAMSRAPR';
	l_sr_api_version := 3.0;
	l_workflow_process := 'EAMSRAPR_PROCESS';


	-- get the service request number from the event message
	l_incident_number := wf_event.getValueForParameter('REQUEST_NUMBER',p_event.Parameter_List);
	l_sr_user_id	  := wf_event.getValueForParameter('USER_ID',p_event.Parameter_List);
	l_sr_resp_id := wf_event.getValueForParameter('RESP_ID',p_event.Parameter_List);
	l_sr_resp_appl_id := wf_event.getValueForParameter('RESP_APPL_ID',p_event.Parameter_List);

	-- get the service request id and service request type

	begin
		select
		cia.incident_id,cia.owning_department_id,cia.inventory_item_id
		,cia.maint_organization_id,cia.incident_date, cia.expected_resolution_date,cit.maintenance_flag
		,cia.incident_status_id,cia.incident_severity_id,cia.customer_id,cia.object_version_number
		,cia.customer_product_id
		into
		l_incident_id,l_owning_department_id,l_inventory_item_id
		,l_maint_organization_id, l_incident_date, l_expected_resolution_date,l_maintenance_flag
		,l_incident_status_id,l_incident_severity_id,l_customer_id,l_object_version_number
		,l_instance_id
		from cs_incidents_vl_sec cia, cs_incident_types_vl_sec cit
		where cia.incident_number = l_incident_number
		and cia.incident_type_id = cit.incident_type_id;
	exception
		when others then
			return 'WARNING';
	end;

	itemkey := l_incident_id;


	-- if service request type is maintenance, then proceed  else terminate
	if (l_maintenance_flag is not null AND l_maintenance_flag = 'Y') then
		-- if Asset Number is specified on Service Request
		if (l_instance_id is not null) then
			select instance_number,instance_description,concatenated_segments,msi.description
			into l_instance_number,l_instance_description,l_concatenated_segments,l_conc_segments_description
			from csi_item_instances cii, mtl_system_items_kfv msik, mtl_system_items msi
			where cii.last_vld_organization_id = msi.organization_id
			and cii.inventory_item_id = msi.inventory_item_id
			and msi.organization_id = msik.organization_id
			and msi.inventory_item_id = msik.inventory_item_id
			and cii.instance_id = l_instance_id
			;

		-- if only Asset Group is specified and asset number is not
		elsif (l_instance_id is null AND l_inventory_item_id is not null) then
			select msik.concatenated_segments,msik.description
			into l_concatenated_segments,l_conc_segments_description
			from mtl_system_items_kfv msik, mtl_system_items msi
			where msi.organization_id = msik.organization_id
			and msi.inventory_item_id = msik.inventory_item_id
			and msi.inventory_item_id = l_inventory_item_id
			and msi.organization_id = l_maint_organization_id;
		-- if asset number is specified and asset group is not
		-- dont know if this can be possible though
		elsif (l_instance_id is not null AND l_inventory_item_id is null) then
			null;
		end if;

		-- if owning department is not specified on Service Request
		if (l_owning_department_id is null) then
			-- get default department id for organization
			select default_department_id
			into l_default_department_id
			from wip_eam_parameters
			where organization_id = l_maint_organization_id;

			if (l_default_department_id is not null) then
				-- update the service request owning department id
				l_owning_department_id  := l_default_department_id;

				select department_code
				into l_owning_department_code
				from bom_departments
				where department_id = l_owning_department_id
				and organization_id = l_maint_organization_id;

				-- call service request update API to update the owning dept on Service Request
				-- fnd_global.apps_initialize is required as Service Request have a security access.
				-- As suggested by Service team, we need to set the responsibility and user before Service Request can be updated.
				fnd_global.apps_initialize(
					user_id => l_sr_user_id,
					resp_id => l_sr_resp_id,
    					resp_appl_id => l_sr_resp_appl_id
				);
				cs_servicerequest_pub.initialize_rec(l_service_rec);
				l_service_rec.owning_department_id := l_owning_department_id;
				cs_servicerequest_pub.update_serviceRequest(
					p_api_version => l_sr_api_version
					,p_request_id => l_incident_id
					,p_service_request_rec => l_service_rec
					,p_object_version_number => l_object_version_number
					,p_notes => l_notes_rec
					,p_contacts => l_contacts_rec
					,p_last_updated_by => l_sr_user_id
					,p_last_update_date => sysdate
					,p_resp_appl_id => l_sr_resp_appl_id
					,p_resp_id => l_sr_resp_id
					,x_return_status => l_sr_return_status
					,x_msg_count => l_sr_msg_count
					,x_msg_data => l_sr_msg_data
					,x_workflow_process_id => l_sr_workflow_process_id
					,x_interaction_id => l_sr_interaction_id
				);

				if (l_sr_return_status <> FND_API.G_RET_STS_SUCCESS) then
					return 'WARNING';
				end if;
			end if;
		else
			select department_code
			into l_owning_department_code
			from bom_departments
			where department_id = l_owning_department_id
			and organization_id = l_maint_organization_id;

		end if;

		if (l_owning_department_id is not null) then

			-- get responsibility from dept. approvers
			select beda.responsibility_id,beda.responsibility_application_id
			into l_responsibility_id, l_responsibility_appl_id
			from   bom_eam_dept_approvers beda
			where
			beda.dept_id = l_owning_department_id
			and beda.organization_id = l_maint_organization_id;

			l_resp_string := 'FND_RESP';

			-- get role from dept-responsibility combinations
			l_responsibility_appl_id := l_resp_string || l_responsibility_appl_id;
			wf_directory.GetRoleName(l_responsibility_appl_id ,l_responsibility_id,l_role_name,l_display_name);
		end if;

		wf_engine.SetItemAttrNumber( itemtype => itemtype,
					     itemkey  => itemkey,
					     aname    => 'ORGANIZATION_ID',
					     avalue   =>  l_maint_organization_id);

		wf_engine.SetItemAttrText(itemtype => itemtype,
					     itemkey  => itemkey,
					     aname    => 'ORGANIZATION_CODE',
					     avalue   => l_organization_code);

		wf_engine.SetItemAttrText(itemtype => itemtype,
					     itemkey  => itemkey,
					     aname    => 'ASSET_GROUP_SEGMENTS',
					     avalue   => l_concatenated_segments);

		wf_engine.SetItemAttrText(itemtype => itemtype,
					     itemkey  => itemkey,
					     aname    => 'ASSET_NUMBER',
					     avalue   => l_instance_number);

		wf_engine.SetItemAttrText(itemtype => itemtype,
					     itemkey  => itemkey,
					     aname    => 'DEPARTMENT_CODE',
					     avalue   => l_owning_department_code);


		wf_engine.SetItemAttrDate( itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'EXPECTED_RESOLUTION_DATE',
						avalue   => l_expected_resolution_date);

		wf_engine.SetItemAttrDate( itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'INCIDENT_DATE',
						avalue   => l_incident_date);


		-- set the department responsibility to the approver role
		wf_engine.SetItemAttrText(itemtype=>itemtype,
						itemkey =>itemkey,
						aname=> 'DEPT_RESPONSIBILTY',
						avalue=> l_role_name);

		wf_engine.SetItemAttrNumber( itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'INCIDENT_SEVERITY_ID',
						avalue   =>  l_incident_severity_id);

		wf_engine.SetItemAttrNumber( itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'INCIDENT_STATUS_ID',
						avalue   =>  l_incident_status_id);

		wf_engine.SetItemAttrNumber( itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'CUSTOMER_ID',
						avalue   =>  l_customer_id);

		/*call Workflow default Rule function */
		l_return_status:=WF_RULE.DEFAULT_RULE(p_subscription_guid=>p_subscription_guid,p_event=>p_event);



	end if;
	return 'SUCCESS';
exception
	when others then
		wf_core.context('EAM_SRAPPROVAL_PVT','service_request_created',
					p_event.getEventName(),p_subscription_guid);
		wf_event.setErrorInfo(p_event,'WARNING');
		return 'WARNING';

end;



--
function Service_Request_Updated(
                        p_subscription_guid in	   raw,
                        p_event		   in out NOCOPY wf_event_t
                      ) return varchar2
is
	L_EVENT_NAME varchar2(240);
	L_EVENT_KEY  varchar2(240);
	itemtype            	        varchar2(30);
	itemkey  	        varchar2(30) ;
	l_application_id NUMBER;
	l_application_code varchar2(32);
	l_incident_number cs_incidents_all_b.incident_number%type;
	l_incident_id cs_incidents_all_b.incident_id%type;

	l_owning_department_id cs_incidents_all_b.owning_department_id%type;
	l_owning_department_code bom_departments.department_code%type;
	l_owning_department_role varchar2(80);
	l_inventory_item_id cs_incidents_all_b.inventory_item_id%type;
	l_maintenance_flag varchar2(1);
	l_concatenated_segments mtl_system_items_kfv.concatenated_segments%type;
	l_conc_segments_description mtl_system_items.description%type ;

	l_role_name varchar2(80);

	l_organization_code org_organization_definitions.organization_code%type;
	l_responsibility_id varchar2(80);
	l_responsibility_appl_id varchar2(30);
	l_resp_string varchar2(30);
	l_display_name varchar2(80);
	l_incident_date date;
	l_expected_resolution_date date;
	l_default_department_id wip_eam_parameters.default_department_id%type;
	l_return_status varchar2(240);
	l_incident_status_id cs_incidents_all_b.incident_status_id%type;
	l_incident_severity_id cs_incidents_all_b.incident_severity_id%type;
	l_customer_id cs_incidents_all_b.customer_id%type;
	l_service_rec cs_servicerequest_pub.service_request_rec_type;
	l_sr_user_id number;
	l_sr_resp_id number;
	l_sr_resp_appl_id number;
	l_notes_rec cs_servicerequest_pub.notes_table;
	l_contacts_rec cs_servicerequest_pub.contacts_table;
	l_sr_api_version number;
	l_object_version_number number;
	l_sr_return_status varchar2(1);
	l_sr_msg_count number;
	l_sr_msg_data varchar2(2000);
	l_sr_workflow_process_id number;
	l_sr_interaction_id number;
	/*Commented for bug 4488769:
	l_prev_severity_id number;
	l_prev_type_id number;
	l_prev_status_id number;
	l_prev_urgency_id number;
	l_prev_summary cs_incidents_all_b.summary%type;
	l_request_status_old number;
   	l_prev_owner_id number;
   	End Commented for Bug 4488769*/
   	l_instance_id	number;
	l_instance_number	varchar2(30);
	l_instance_description csi_item_instances.instance_description%type;
	l_maint_organization_id	cs_incidents_all_b.maint_organization_id%type;

begin
	itemtype := 'EAMSRAPR';
	l_sr_api_version := 3.0;

   	-- get the service request number from the event message
   	l_incident_number := wf_event.getValueForParameter('REQUEST_NUMBER',p_event.Parameter_List);
   	l_sr_user_id	  := wf_event.getValueForParameter('USER_ID',p_event.Parameter_List);
   	l_sr_resp_id := wf_event.getValueForParameter('RESP_ID',p_event.Parameter_List);
	l_sr_resp_appl_id := wf_event.getValueForParameter('RESP_APPL_ID',p_event.Parameter_List);
   	/*
   	l_prev_type_id := wf_event.getValueForParameter('PREV_TYPE_ID',p_event.Parameter_List);
   	l_prev_severity_id := wf_event.getValueForParameter('PREV_SEVERITY_ID',p_event.Parameter_List);
   	l_prev_status_id := wf_event.getValueForParameter('PREV_STATUS_ID',p_event.Parameter_List);
   	l_prev_urgency_id := wf_event.getValueForParameter('PREV_URGENCY_ID',p_event.Parameter_List);
   	l_prev_summary := wf_event.getValueForParameter('PREV_SUMMARY',p_event.Parameter_List);
   	l_request_status_old := wf_event.getValueForParameter('REQUEST_STATUS_OLD',p_event.Parameter_List);
   	l_prev_owner_id := wf_event.getValueForParameter('PREV_OWNER_ID',p_event.Parameter_List);
	*/
   	-- get the service request id and service request type
   	select
   	cia.incident_id,cia.owning_department_id,cia.inventory_item_id,cia.maint_organization_id,
   	cia.incident_date, cia.expected_resolution_date,cit.maintenance_flag
   	,cia.customer_product_id
   	into
   	l_incident_id,l_owning_department_id,l_inventory_item_id,l_maint_organization_id
   	,l_incident_date, l_expected_resolution_date,l_maintenance_flag
   	,l_instance_id
   	from cs_incidents_vl_sec cia, cs_incident_types_vl_sec cit
   	where cia.incident_number = l_incident_number
   	and cia.incident_type_id = cit.incident_type_id;

   	-- if service request type is maintenance, then proceed  else terminate
   	if (l_maintenance_flag is not null AND l_maintenance_flag = 'Y') then
		-- if owning department is not specified on Service Request
		if (l_owning_department_id is null) then
			-- get default department id for organization
			select default_department_id
			into l_default_department_id
			from wip_eam_parameters
			where organization_id = l_maint_organization_id;

			if (l_default_department_id is not null) then
				-- update the service request owning department id
				l_owning_department_id  := l_default_department_id;

				select department_code
				into l_owning_department_code
				from bom_departments
				where department_id = l_owning_department_id
				and organization_id = l_maint_organization_id;

				-- call service request update API to update the owning dept on Service Request
				fnd_global.apps_initialize(
					user_id => l_sr_user_id,
					resp_id => l_sr_resp_id,
				    	resp_appl_id => l_sr_resp_appl_id
				);
				cs_servicerequest_pub.initialize_rec(l_service_rec);
				l_service_rec.owning_department_id := l_owning_department_id;
				cs_servicerequest_pub.update_serviceRequest(
					p_api_version => l_sr_api_version
					,p_request_id => l_incident_id
					,p_service_request_rec => l_service_rec
					,p_object_version_number => l_object_version_number
					,p_notes => l_notes_rec
					,p_contacts => l_contacts_rec
					,p_last_updated_by => l_sr_user_id
					,p_last_update_date => sysdate
					,p_resp_appl_id => l_sr_resp_appl_id
					,p_resp_id => l_sr_resp_id
					,x_return_status => l_sr_return_status
					,x_msg_count => l_sr_msg_count
					,x_msg_data => l_sr_msg_data
					,x_workflow_process_id => l_sr_workflow_process_id
					,x_interaction_id => l_sr_interaction_id
				);

				if (l_sr_return_status <> FND_API.G_RET_STS_SUCCESS) then
					return 'WARNING';
				end if;
			end if;
		else
			select department_code
			into l_owning_department_code
			from bom_departments
			where department_id = l_owning_department_id
			and organization_id = l_maint_organization_id;
		end if;

		/*call Workflow default Rule function */
		l_return_status:=WF_RULE.DEFAULT_RULE(p_subscription_guid=>p_subscription_guid,p_event=>p_event);
   	end if;
   	return 'SUCCESS';
exception
	when others then
		wf_core.context('EAM_SRAPPROVAL_PVT','service_request_updated',
					p_event.getEventName(),p_subscription_guid);
		wf_event.setErrorInfo(p_event,'WARNING');
	return 'ERROR';
end;


Function return_department_id
    (
        p_maintenance_org_id in number, -- OPTIONAL, null can be passed
        p_inventory_item_id in number, -- OPTIONAL, null can be passed
        p_customer_product_id in number -- OPTIONAL, null can be passed
    )    return number
is
	l_default_department_id number;
begin
	if (p_maintenance_org_id is not null) then

		if p_customer_product_id is null then
			begin
				select default_department_id
				into l_default_department_id
				from wip_eam_parameters
				where organization_id = p_maintenance_org_id;
			exception
				when no_data_found then
					null;
			end;

		else
			begin
				select owning_department_id
				into l_default_department_id
				from eam_org_maint_defaults
				where object_type = 50
				and object_id = p_customer_product_id
				and organization_id = p_maintenance_org_id;
			exception
				when no_data_found then
					null;
			end;

			if l_default_department_id is null then
				begin

					select default_department_id
					into l_default_department_id
					from wip_eam_parameters
					where organization_id = p_maintenance_org_id;
				exception
					when no_data_found then
						null;
				end;

			end if;
		end if;
	end if;

	return l_default_department_id;
exception
	WHEN NO_DATA_FOUND THEN
		return l_default_department_id;
end return_department_id;

END EAM_SRAPPROVAL_PVT;

/
