--------------------------------------------------------
--  DDL for Package Body BIV_SR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_SR_PKG" AS
 -- $Header: bivupdtb.pls 115.0 2003/02/05 21:18:30 smisra noship $ */
 procedure  update_service_request(
                 p_sr_id            number,
                 p_status_id        number,
                 p_severity_id      number,
                 p_owner_id         number,
                 p_owner_group_id   number,
                 p_note_type        varchar2,
                 p_note_status      varchar2,
                 p_note             varchar2,
                 p_vrsn_no          number,
                 p_error out nocopy varchar2) as
	l_service_request_rec  CS_ServiceRequest_PVT.service_request_rec_type;
                l_owner_id number;
		l_return_status                 VARCHAR2(1);
		l_msg_count                     NUMBER ;
		l_msg_data                      VARCHAR2(2000);
		l_msg_index_out                 NUMBER;
		l_request_id  NUMBER;
		l_request_number VARCHAR2(64);
		l_interaction_id  NUMBER;
		l_object_version_number NUMBER;

		l_notes  CS_SERVICEREQUEST_PVT.notes_table;
		l_contacts  CS_SERVICEREQUEST_PVT.contacts_table;

		l_last_update_date  date;

		l_itemkey        VARCHAR2(240);
		l_return_status_wkflw   VARCHAR2(1) ;

		l_workflow_process_id   NUMBER ;
		begin
                biv_core_pkg.biv_debug('owner' || to_char(p_owner_id),
                                                                 'SR_UPDT');
                biv_core_pkg.biv_debug('group' || to_char(p_owner_group_id),
                                                                 'SR_UPDT');
                l_owner_id := p_owner_id;
                if (p_owner_id = 0) then l_owner_id := null;
                end if;
                biv_core_pkg.biv_debug('before init rec','SR_UPDT');
		CS_ServiceRequest_PVT.initialize_rec(l_service_request_rec);
		l_request_id :=  p_sr_id  ;
                /* when update jsp passed version number, delete this
                   statement */
                if (p_vrsn_no is null) then
		SELECT object_version_number
		  INTO l_object_version_number
		  FROM CS_INCIDENTS_ALL_B
		 WHERE incident_id = l_request_id;
                end if;

		l_last_update_date := SYSDATE;

		l_service_request_rec.status_id   :=   p_status_id  ;
		l_service_request_rec.severity_id :=   p_severity_id  ;
		l_service_request_rec.owner_id    :=  l_owner_id ;
                biv_version_specific_pkg.set_update_program(
                                                     l_service_request_rec);
                if (p_owner_group_id is not null) then
		   l_service_request_rec.owner_group_id := p_owner_group_id;
                end if;

                if (p_note is not null) then
		   l_notes(1).note_type   :=   p_note_TYpe ;
		   l_notes(1).note        :=   p_note  ;
		   l_notes(1).note_detail :=   p_note  ;
                end if;

                biv_core_pkg.biv_debug('before update SR','SR_UPDT');
	CS_ServiceRequest_PVT.Update_ServiceRequest
		 (p_api_version           => 3.0,
		  p_validation_level      => fnd_api.g_valid_level_full,
		  p_commit                => fnd_api.g_true,
		  p_init_msg_list         => fnd_api.g_true,
		  x_return_status         => l_return_status,
		  p_request_id            => l_request_id,
		  x_msg_count             => l_msg_count,
		  x_msg_data              => l_msg_data,
		  p_last_updated_by       => fnd_global.user_id,
		  p_last_update_date      => l_last_update_date,
		  p_service_request_rec   => l_service_request_rec,
		  p_notes                 => l_notes,
		  p_contacts              => l_contacts,
		  p_object_version_number => l_object_version_number,
		  x_interaction_id        => l_interaction_id,
		  x_workflow_process_id   => l_workflow_process_id);
                biv_core_pkg.biv_debug('after update SR','SR_UPDT');

  /*
  dbms_output.put_line('no of Errors:' ||to_char(l_msg_count));
  dbms_output.put_line(substr(l_msg_data,1,250));
  dbms_output.put_line(substr(l_msg_data,250,250));
  */
  p_error := null;
  IF (FND_MSG_PUB.Count_Msg > 1) THEN
      --Display all the error messages
      FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
        FND_MSG_PUB.Get(p_msg_index=>j,
                        p_encoded=>'F',
                        p_data=>l_msg_data,
                        p_msg_index_out=>l_msg_index_out);
       -- DBMS_OUTPUT.PUT_LINE(l_msg_data);
        p_error := p_error || ' ' || l_msg_data;
      END LOOP;
    ELSE
      --Only one error
      FND_MSG_PUB.Get(p_msg_index=>1,
                      p_encoded=>'F',
                      p_data=>l_msg_data,
                     p_msg_index_out=>l_msg_index_out);
      --DBMS_OUTPUT.PUT_LINE(l_msg_data);
      p_error := l_msg_data;

   END IF;
end;
end;

/
