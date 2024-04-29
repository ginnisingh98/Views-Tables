--------------------------------------------------------
--  DDL for Package Body CS_SR_MASS_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_MASS_UPDATE_PKG" as
/* $Header: cssrmub.pls 120.0.12010000.11 2009/10/07 05:03:16 mkundali noship $ */

procedure sr_mass_update(p_incident_id_arr in SYSTEM.IBU_NUM_TBL_TYPE,
					  p_status_id in NUMBER,
					  p_resolution_code in VARCHAR2,
					  p_owner_id in NUMBER,
					  p_owner_group_id in NUMBER,
					  p_note_type in VARCHAR2,
					  p_noteVisibility in VARCHAR2,
					  p_noteDetails in VARCHAR2,
					  p_last_updated_by in NUMBER,
					  auto_assign_group_flag in VARCHAR2,
					  auto_assign_owner_flag in VARCHAR2,
					  x_param_incident_id out NOCOPY CS_KB_NUMBER_TBL_TYPE,
					  x_param_status out NOCOPY JTF_VARCHAR2_TABLE_4000,
					  x_param_msg_data out NOCOPY JTF_VARCHAR2_TABLE_4000
					  )

IS
  x_return_status               VARCHAR2(1);
  x_msg_count                    NUMBER;
  x_msg_data                    VARCHAR2(2000);
  l_last_update_date            DATE := SYSDATE;
  l_object_version_number       NUMBER;
  l_sr_rec                      CS_SERVICEREQUEST_PVT.service_request_rec_type;
  l_notes_table                 CS_SERVICEREQUEST_PVT.notes_table;
  l_contacts_table              CS_SERVICEREQUEST_PVT.contacts_table;
  l_validate_sr_closure         VARCHAR2(1) := 'N';
  l_auto_close_child_entities   VARCHAR2(1) := 'N';
  l_temp_close_value            VARCHAR2(100);
  l_responsibility_id           NUMBER;
  l_sr_update_out_rec          CS_ServiceRequest_PVT.sr_update_out_rec_type;
  l_cs_auto_assignment         VARCHAR2(1) := 'N';
  p_auto_assign                VARCHAR2(1) := 'N';
  l_data	               varchar2(2000);
  l_msg_index			number := 1;
  l_msg_index_out		number;
  l_count			number;
  l_status_msg     varchar2(1000);

BEGIN
	/*Trap the error message for SRs which are closed and have the Disallow SR Update
	  Check box as checked bug 8726256*/
	FND_MESSAGE.Set_Name('CS','CS_API_SR_ONLY_STATUS_UPDATED');
	FND_MSG_PUB.Add;
	l_status_msg :=  FND_MSG_PUB.GET(FND_MSG_pub.Count_Msg,FND_API.G_FALSE);
	l_Status_msg:=substr(l_status_msg,instr(l_status_msg,':')+1);
	/*bug 8726256* ends here*/
	if (p_note_type is NOT NULL ) THEN
		l_notes_table(1).note_type := p_note_type;
	end if;
        if (p_noteVisibility is NOT NULL ) THEN
		l_notes_table(1).note_status := p_noteVisibility;
	end if;
        if (p_noteDetails is NOT NULL ) THEN
		l_notes_table(1).note := p_noteDetails;
	end if;
	x_param_incident_id := CS_KB_NUMBER_TBL_TYPE();
	x_param_status := JTF_VARCHAR2_TABLE_4000();
	x_param_msg_data := JTF_VARCHAR2_TABLE_4000();

	CS_SERVICEREQUEST_PVT.INITIALIZE_REC(p_sr_record => l_sr_rec);

	 Select nvl(fnd_profile.value('CS_AUTO_ASSIGN_OWNER_FORMS'), 'N')
	 Into l_cs_auto_assignment From dual;

	if(l_cs_auto_assignment = 'Y') then
		if (p_owner_group_id is not NULL and  p_owner_id is not NULL) then
			l_sr_rec.owner_group_id := p_owner_group_id;
			l_sr_rec.owner_id := p_owner_id;
		elsif(p_owner_group_id is NULL and  p_owner_id is NULL and auto_assign_owner_flag='on' and auto_assign_group_flag='off') then
			l_sr_rec.owner_group_id := FND_API.G_MISS_NUM;
			l_sr_rec.owner_id := null;
			p_auto_assign :='Y';
    		elsif(p_owner_group_id is NULL and  p_owner_id is NULL and (auto_assign_group_flag='on' or auto_assign_owner_flag='on')) then
			l_sr_rec.owner_group_id := null;
			l_sr_rec.owner_id := null;
			p_auto_assign :='Y';
		elsif(p_owner_group_id is not NULL and  p_owner_id is NULL and auto_assign_owner_flag='on') then
			l_sr_rec.owner_group_id := p_owner_group_id;
			l_sr_rec.owner_id := null;
			p_auto_assign :='Y';
		elsif(p_owner_group_id is not NULL) then
			l_sr_rec.owner_group_id := p_owner_group_id;
			l_sr_rec.owner_id := null;
		elsif(p_owner_id is not NULL) then
			l_sr_rec.owner_group_id := FND_API.G_MISS_NUM;
			l_sr_rec.owner_id := p_owner_id;
		elsif(p_owner_group_id is NULL and  p_owner_id is NULL and auto_assign_group_flag='off' and auto_assign_owner_flag='off') then
			p_auto_assign:='N';
		end if;
	elsif(l_cs_auto_assignment = 'N') then
		if (p_owner_group_id is not NULL and  p_owner_id is not NULL) then
			l_sr_rec.owner_group_id := p_owner_group_id;
			l_sr_rec.owner_id := p_owner_id;
		elsif(p_owner_group_id is not NULL) then
			l_sr_rec.owner_group_id := p_owner_group_id;
			l_sr_rec.owner_id := null;
		elsif(p_owner_id is not NULL) then
			l_sr_rec.owner_group_id:= FND_API.G_MISS_NUM;
			l_sr_rec.owner_id := p_owner_id;
		elsif(p_owner_group_id is NULL and  p_owner_id is NULL) then
			p_auto_assign:='N';
		end if;
	end if;

	l_sr_rec.language := 'US';
	if (p_status_id > 0) then
		l_sr_rec.status_id := p_status_id;
	end if;
	if (p_resolution_code is NOT NULL ) THEN
		l_sr_rec.resolution_code := p_resolution_code;
	end if;
	 select fnd_global.resp_id into l_responsibility_id from dual;

	 l_temp_close_value := FND_PROFILE.VALUE('CS_SR_AUTO_CLOSE_CHILDREN');
	 if (l_temp_close_value = 'CS_SR_VALIDATE_AND_CLOSE') then
		    l_auto_close_child_entities := 'Y';
		    l_validate_sr_closure := 'Y';
	 end if;

	 if (l_temp_close_value = 'CS_SR_NONE') then
		    l_auto_close_child_entities := 'N';
		    l_validate_sr_closure := 'N';
	 end if;


	for i in p_incident_id_arr.first..p_incident_id_arr.last
	loop
		if p_incident_id_arr(i) is not NULL then
			select OBJECT_VERSION_NUMBER
			into   l_object_version_number
			from   CS_INCIDENTS_ALL_B
			where  INCIDENT_ID = p_incident_id_arr(i);

		  CS_SERVICEREQUEST_PVT.UPDATE_SERVICEREQUEST(
		    p_api_version => 4.0,
		    p_init_msg_list => fnd_api.g_true,
		    p_resp_id => l_responsibility_id,
		    p_commit => fnd_api.g_true,
		    p_validation_level         => 100,
		    p_request_id => p_incident_id_arr(i),
		    p_object_version_number => l_object_version_number,
		    p_last_updated_by => p_last_updated_by,
		    p_last_update_date => l_last_update_date,
		    p_service_request_rec => l_sr_rec,
		    p_notes => l_notes_table,
		    p_contacts => l_contacts_table,
		    p_validate_sr_closure => l_validate_sr_closure,
		    p_auto_close_child_entities => l_auto_close_child_entities,
		    x_msg_count => x_msg_count,
		    p_auto_assign =>p_auto_assign,
		    x_return_status => x_return_status,
		    x_msg_data => x_msg_data,
		    x_sr_update_out_rec => l_sr_update_out_rec);

		    if(x_return_status = 'S' OR x_return_status = 'E') then
                         l_count := FND_MSG_PUB.Count_Msg;
                          FND_MSG_PUB.Get(p_msg_index => l_msg_index,
						    p_encoded       => 'F',
				                    p_data => l_data,
				                    p_msg_index_out => l_msg_index_out
				                    );
			/*Trap the error message for SRs which are closed and have the Disallow SR Update
			  Check box as checked bug 8726256*/
			if (l_status_msg=substr(l_data,instr(l_data,':')+1) and p_status_id is null) then
				x_return_status:='E';
			end if;
                    end if;

			x_param_incident_id.Extend;
			x_param_status.Extend;
			x_param_msg_data.Extend;
			x_param_incident_id(i) := p_incident_id_arr(i);
			x_param_status(i) := x_return_status;

			if(x_return_status = 'S' OR x_return_status = 'E') then
				x_param_msg_data(i) := l_data;
			else
				x_param_msg_data(i) := x_msg_data;
			end if;


end if;

end loop;
exception
WHEN OTHERS THEN
raise;

end sr_mass_update;

END cs_sr_mass_update_pkg;

/
