--------------------------------------------------------
--  DDL for Package Body IBU_REQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_REQ_PKG" as
/* $Header: ibursrb.pls 120.11.12010000.3 2010/01/13 11:40:28 mkundali ship $ */
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | History                                                              |
 |  12.20.99    Alex Lau Created                                        |
 |  6-APR-2001  Alan Lau                                                |
 |              Add major enhancement for 11.5.4.F                      |
 |              Commented out UpdateStatus, UpdateUrgency,              |
 |              CreateTask, and GetContract.                            |
 |  03/01/2002  klou, added error code                                  |
 |  13/03/2002  klou, add logic to handle employee logging SRs          |
 |              NOTE: This version is based on 115.81. 115.82 inlcudes  |
 |              multiple notes and has been leapfrogged.                |
 |  18/03/2002  klou,                                                   |
 |              1. add p_serial_number to create_service_request.       |
 |              2. add logic to fetch serial number and tag number      |
 |                 from install base table.                             |
 |  25-MAR-2002 allau                                                   |
 |              Remove assignment manager logic to leverage TeleService |
 |              auto-assignment feature                                 |
 |  29-MAR-2002 ALLAU                                                   |
 |              Pass LAST_UPDATE_CHANNEL := 'WEB' when calling          |
 |              TeleService CreateServiceRequest and                    |
 |              UpdateServiceRequest APIs.                              |
 |  31-MAR-2002 KLOU (UCONTACT)                                         |
 |              Add new parameters to UpdateServiceRequest to hanlde    |
 |              update contacts in SR detail.                           |
 |  11-APR-2002 KLOU (ASSG)                                             |
 |              SR creation: add logic to check whether CS              |
 |              Auto-Assignment is ON. If not, check whether IBU profile|
 |              of "use default resource owner" is ON. If yes, fecth    |
 |              owner group, owner id, group type from profile.         |
 |              Otherwise, do noting.                                   |
 |  15-APR-2002 KLOU (PLANG)                                            |
 |              Set perferred language to appropriate column, i.e. not  |
 |              use attribute6.                                         |
 |  25-MAY-2002 WMA                                                     |
 |              Add the SR location address information to the create   |
 |              API.                                                    |
 |  31-MAY-2002 KLOU                                                    |
 |              Set category id to null if it is -1 during SR creation. |
 |  20-AUG-2002 WMA                                                     |
 |              Get the default SR owner type for the SR creation       |
 |  17-OCT-2002 WMA                                                     |
 |              1. modified the create API according to CS change       |
 |              2. add five more parameters for bill to and ship to     |
 |  01-NOV-2002 WMA                                                     |
 |              1. add the attachment category ID                       |
 |  06-NOV-2002 SPOLAMRE                                                |
 |              Add DFF attributes                                      |
 |  13-NOV-2002 WMA                                                     |
 |              Check the DEF parameters null case                      |
 |  115.100 06-DEC-2002 WZLI changed OUT and IN OUT calls to use NOCOPY |
 |                           hint to enable pass by reference.          |
 |                           changed the api version from 2.0 to 3.0.   |
 |                           added two parameters: p_bill_to_party_id   |
 |                           and p_ship_to_party_id in the create       |
 |                           service request procedure.                 |
 |  02-Jan-2002  WMA  add one more API get_default_status API           |
 |                    add the responsibility id to pass in              |
 |  31-Jan-2003 SPOLAMRE                                                |
 |              Changed the PROCEDURE AddAttachment to take file name as|
 |              parameter and pass it to the API                        |
 |              FND_WEBATTCH.ADD_ATTACHMENT                             |
 |  115.106 11-SEP-2003  wzli   Made changes for create SR for 11.5.10  |
 |  115.107 15-SEP-2003  WZLI   Change the location type to             |
 |                              HZ_PARTY_SITE                           |
 |  115.108  09-OCT-2003 WZLI   added procedure decodeErrorMsg          |
 |  115.109  10-OCT-2003 WZLI   Remove debug message from decodeErrorMsg|
 |  115.110  12-OCT-2003 WMA change the update API for 11510 requirement|
 |  115.111  20-OCT-2003 wzli added two parameterss: p_street_number and|
 |                            p_timezone_id in the create SR procedure. |
 |  115.112  19-NOV-2003 wzli Fixed problem(bug#3063305): 'No entries   |
 |                            found for List of Values error when trying|
 |                            to query the Item field only for SR's     |
 |                            created via iSupport.                     |
 |  115.113  03-DEC-2003 WZLI add logic to decode message               |
 |                            FORM_RECORD_CHANGED                       |
 |  115.114  15-DEC-2003 WZLI Because the error messages in the error   |
 |                            stack are separated by chr(0), they need  |
 |                            to be parsed befor we decode them.        |
 |  115.115  29-DEC-2003 WZLI Made change to code logic: If installed   |
 |                            base product is selected, don't save the  |
 |                            serial number.                            |
 |  115.116  09-DEC-2003 WMA  modify the Email logic, increase the size |
 |                            of Email body.                            |
 |  115.117  19-Jan-2003 WMA  fixed bug 3377241.                        |
 |                            AUTO ASSIGNMENT ON UPDATE THRU I-SUPPORT  |
 |                            NOT FUNCTIONING                           |
 |  115.118  27-JAN-2004 mkcyee In AddAttachment, the function name     |
 |                              parameter should be obtained from the   |
 |                              profile and not hard-coded to CSXSRISR  |
 |  115.119  10-MAR-2004 WZLI added parameter: p_note_status.           |
 |  115.120  16-APR-2004 WZLI When creating sr, pass sysdate to         |
 |                            parameter incident_occurred_date.         |
 |  115.121  09-JUN-2004 WZLI Fixed problem(bug#3676419):In procedure   |
 |                           get_default_status(),select status_group_id|
 |                            from cs_incident_types_b instead of from  |
 |                            cs_incident_types_vl                      |
 |  115.122  29-JUL-2004 WZLI Fixed problem(bug#3796975):Saving Service |
 |                            request gives invalid date error.         |
 |  115.123  15-OCT-2004 WMA  for sendEmail function, use  userID       |
 |                            fullname as role display name.            |
 |  115.124  28-NOV-2004 WMA  add the srID in the Send Email API.       |
 |                            change the way to start work flow.        |
 |                            add new API startEmailWorkFlow().         |
 |  115.125 29-NOV-2004  WMA  change the way to create role for Email.  |
 |  115.126 30-NOV-2004  WMA  change the rolename.                      |
 |  120.1   04-AUG-2005  WMA  added pending approval flag checking for  |
 |                            default statuses.                         |
 |  120.2  09-SEP-2005   WMA  add the logic to handle the multi bytes   |
 |  120.3  28-NOV-2005   WZLI made change for link object enhancement.  |
 |  120.4  28-NOV-2005   WZLI Fixed GSCC error.                         |
 |  120.5  10-DEC-2005   WMA  add validate_http_service_ticket()        |
 |                       change the logic for workflow APIs.            |
 |  120.6  19-JAN-2006   WMA change the sequence name for the WF role   |
 |  120.7  30-JAN-2006   WMA modify the logic for creating emp role.    |
 |  120.9  14-Nov-2007   MPATHANI Profile 'Service : Default Group Owner|
 |                       Type for Service Request' is obsoleted,        |
 |		         	     added 'RS_GROUP'.                  |
 | 120.10  11-FEB-2009  mkundali added for 12.1.2 enhancement bug8245975|
 +======================================================================*/

/**
 *  UpdateServiceRequest
 */
PROCEDURE UpdateServiceRequest(
  p_request_id                  IN NUMBER,
  p_status_id                   IN NUMBER,
  p_urgency_id                  IN NUMBER,
  p_problem_description         IN VARCHAR2,
  p_problem_detail              IN VARCHAR2,
  p_note_type                   IN VARCHAR2,
  p_last_updated_by             IN NUMBER,
  p_language                    IN VARCHAR2,
  -- UCONTACT
  p_contact_party_id            IN JTF_NUMBER_TABLE       := null,
  p_contact_type                IN JTF_VARCHAR2_TABLE_100 := null,
  p_contact_point_id            IN JTF_NUMBER_TABLE       := null,
  p_contact_point_type          IN JTF_VARCHAR2_TABLE_100 := null,
  p_contact_primary             IN JTF_VARCHAR2_TABLE_100 := null,
  p_sr_contact_point_id         IN JTF_NUMBER_TABLE       := null,
  -- DONE
  x_return_status               OUT NOCOPY VARCHAR2,
  x_msg_count                   OUT NOCOPY NUMBER,
  x_msg_data                    OUT NOCOPY VARCHAR2
)
IS
  l_msg_count                   NUMBER;
  l_call_id                     NUMBER;
  l_last_update_date            DATE := SYSDATE;
  l_object_version_number       NUMBER;
  l_sr_rec                      CS_SERVICEREQUEST_PVT.service_request_rec_type;
  l_notes_table                 CS_SERVICEREQUEST_PVT.notes_table;
  x_interaction_id              NUMBER;
  l_contacts_table              CS_SERVICEREQUEST_PVT.contacts_table;
  l_org_id                      NUMBER;
  l_workflow_process_id         NUMBER;
  l_index                       BINARY_INTEGER;

  l_validate_sr_closure         VARCHAR2(1) := 'N';
  l_auto_close_child_entities   VARCHAR2(1) := 'N';
  l_temp_close_value            VARCHAR2(100);

  l_retainCharNum               number := 0;
  l_truncateCharNum             number := 0;
  l_responsibility_id           NUMBER; --Wei Ma
  cursor cur_contact_type(p_party_id number) is  --UCONTACT
    select party_type
    from   hz_parties
    where  party_id = p_party_id;

  l_sr_update_out_rec      CS_ServiceRequest_PVT.sr_update_out_rec_type;
  l_cs_auto_assignment         VARCHAR2(1) := 'N';

BEGIN
  select OBJECT_VERSION_NUMBER
  into   l_object_version_number
  from   CS_INCIDENTS_ALL_B
  where  INCIDENT_ID = p_request_id;

  -- UCONTACT
  if p_contact_point_id.count > 0 then
    for l_index in p_contact_point_id.FIRST..p_contact_point_id.LAST loop
       if(nvl(p_contact_point_id(l_index), -1) > 0 ) then
          if( p_sr_contact_point_id(l_index) = -1) then
              l_contacts_table(l_index).sr_contact_point_id := null;
          else
              l_contacts_table(l_index).sr_contact_point_id :=  p_sr_contact_point_id(l_index);
          end if;

          l_contacts_table(l_index).party_id            :=  p_contact_party_id(l_index);
          l_contacts_table(l_index).contact_point_id    :=  p_contact_point_id(l_index);
          l_contacts_table(l_index).primary_flag        :=  p_contact_primary(l_index);
          l_contacts_table(l_index).contact_point_type  :=  p_contact_point_type(l_index);
          if(p_contact_type(l_index)= 'CUSTOMER') then
              open cur_contact_type(l_contacts_table(l_index).party_id);
              fetch  cur_contact_type into l_contacts_table(l_index).contact_type;
              close cur_contact_type;
          else -- for employee
              l_contacts_table(l_index).contact_type := 'EMPLOYEE';
              if p_contact_point_type(l_index) <> 'PHONE' then
                  l_contacts_table(l_index).contact_point_id := null;
              end if;

          end if;
       end if;
     end loop;
  end if; -- end p_contact_point_id is not null
  -- DONE
  if (p_problem_description is NOT NULL ) THEN
    l_notes_table(1).note_type := p_note_type;
    -- l_notes_table(1).note_type := FND_PROFILE.VALUE('IBU_SR_UPDATE_NOTE_TYPE');
  --  l_notes_table(1).note := p_problem_description;
    check_string_length_bites(
        p_string =>  p_problem_description,
        p_targetlen => 2000,
        x_returnLen =>  l_retainCharNum,
        x_truncateCharNum => l_truncateCharNum
      );
      if(l_truncateCharNum > 0) then
        l_notes_table(1).note := substr(p_problem_description, 0, l_retainCharNum);
      else
        l_notes_table(1).note := p_problem_description;
      end if;
      l_retainCharNum := 0;
      l_truncateCharNum := 0;
    l_notes_table(1).note_detail := p_problem_detail;
    l_notes_table(1).note_status := 'E';
  END IF;

  CS_SERVICEREQUEST_PVT.INITIALIZE_REC(p_sr_record => l_sr_rec);
  l_sr_rec.language := p_language;
  if (p_status_id > 0) then
    l_sr_rec.status_id := p_status_id;
  end if;

  if (p_urgency_id > 0) then
    l_sr_rec.urgency_id := p_urgency_id;
  end if;

  l_sr_rec.last_update_channel := 'WEB';

   -- added by weim
  l_sr_rec.creation_program_code  := 'ISUPPORTSRUI';
  l_sr_rec.last_update_program_code := 'ISUPPORTSRUI';

  -- added by wei ma
  select fnd_global.resp_id into l_responsibility_id from dual;


  -- added for 11.5.10
  l_temp_close_value := FND_PROFILE.VALUE('CS_SR_AUTO_CLOSE_CHILDREN');
  if (l_temp_close_value = 'CS_SR_VALIDATE_AND_CLOSE') then
    l_auto_close_child_entities := 'Y';
    l_validate_sr_closure := 'Y';
  end if;

  if (l_temp_close_value = 'CS_SR_NONE') then
    l_auto_close_child_entities := 'N';
    l_validate_sr_closure := 'N';
  end if;

  -- added in 11510 for auto-assignment.
  Select nvl(fnd_profile.value('CS_AUTO_ASSIGN_OWNER_HTML'), 'N')
  Into l_cs_auto_assignment From dual;

  CS_SERVICEREQUEST_PVT.UPDATE_SERVICEREQUEST(
    p_api_version => 4.0,
    p_init_msg_list => fnd_api.g_true,
    p_resp_id => l_responsibility_id,
    p_commit => fnd_api.g_true,
    p_request_id => p_request_id,
    p_object_version_number => l_object_version_number,
    p_last_updated_by => p_last_updated_by,
    p_last_update_date => l_last_update_date,
    p_service_request_rec => l_sr_rec,
    p_notes => l_notes_table,
    p_contacts => l_contacts_table,
    p_validate_sr_closure => l_validate_sr_closure,
    p_auto_close_child_entities => l_auto_close_child_entities,
    x_msg_count => x_msg_count,
    p_auto_assign =>l_cs_auto_assignment,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_sr_update_out_rec => l_sr_update_out_rec);

    if (x_return_status <> 'S') then
      decodeErrorMsg();
    end if;

/*  CS_SERVICEREQUEST_PVT.UPDATE_SERVICEREQUEST(
    p_api_version => 4.0,
    p_init_msg_list => fnd_api.g_true,
    p_resp_id => l_responsibility_id,
    p_commit => fnd_api.g_true,
    p_request_id => p_request_id,
    p_object_version_number => l_object_version_number,
    p_last_updated_by => p_last_updated_by,
    p_last_update_date => l_last_update_date,
    p_service_request_rec => l_sr_rec,
    p_notes => l_notes_table,
    p_contacts => l_contacts_table,
--    p_validate_sr_closure => l_validate_sr_closure,
--    p_auto_close_child_entities => l_auto_close_child_entities,
    x_msg_count => x_msg_count,
    x_workflow_process_id => l_workflow_process_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_interaction_id => x_interaction_id); */

END UpdateServiceRequest;

/**
 * AddAttachment
 */
procedure AddAttachment(
  p_request_id  IN NUMBER,
  p_user_id     IN VARCHAR2,
  p_media_id    IN NUMBER,
  p_name        IN VARCHAR2,
  p_desc        IN VARCHAR2)
is
  seq_num       NUMBER := 10;
  p_category_id NUMBER := nvl(FND_PROFILE.VALUE('IBU_A_SR_DEFAULT_ATTACHMENT_CATEGORY'), 1);
  -- mkcyee 01/27/2004 - we obtain the function name from the profile
  -- to secure attachments
  l_function_name FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := nvl(FND_PROFILE.value('IBU_SR_ATTACH_SECURITY_FUNC'), 'CSXSRISR');

begin
  select NVL(max(seq_num),0) + 10
  into   seq_num
  from   fnd_attached_documents
  where  entity_name = 'CS_INCIDENTS'
  and    pk1_value   = p_request_id;

  FND_WEBATTCH.ADD_ATTACHMENT(
    seq_num => seq_num,
    category_id => p_category_id,
    document_description => p_desc,
    datatype_id => '6',
    text => null,
    file_name => p_name,
    url => null,
    function_name => l_function_name,
    entity_name => 'CS_INCIDENTS',
    pk1_value => p_request_id,
    pk2_value => null,
    pk3_value => null,
    pk4_value => null,
    pk5_value => null,
    media_id => p_media_id,
    user_id => p_user_id);
end AddAttachment;


/**
 * CREATE_SERVICE_REQUEST
 * Thin PL/SQL wrapper for callling TeleService API.
 */
procedure create_service_request(
  p_request_number                      IN OUT NOCOPY VARCHAR2,
  p_type_id                             IN NUMBER,
  p_account_id                          IN NUMBER,
  p_product                             IN NUMBER,
  p_inventory_item                      IN NUMBER,
  p_problem_code_id                     IN VARCHAR2,
  p_caller_type                         IN VARCHAR2,
  p_language                            IN VARCHAR2,
  p_urgency_id                          IN NUMBER,
  p_summary                             IN VARCHAR2,
  p_problem_description                 IN jtf_varchar2_table_32767,
  p_problem_detail                      IN jtf_varchar2_table_32767,
  p_note_status                         in jtf_varchar2_table_100,
  p_contact_party_id                    in jtf_number_table,
  p_contact_type                        in jtf_varchar2_table_100,
  p_contact_point_id                    IN jtf_number_table,
  p_contact_point_type                  in jtf_varchar2_table_100,
  p_contact_primary                     in jtf_varchar2_table_100,

  p_status_id                           IN NUMBER,
  p_severity_id                         IN NUMBER,
--  p_owner_id                            IN NUMBER,
  p_user_id                             IN NUMBER,
  p_customer_id                         IN NUMBER,
  p_platform_id                         IN NUMBER,
  p_cp_revision_id                      IN NUMBER,
  p_inv_item_revision                   IN VARCHAR2,
  p_helpdesk_no                         IN VARCHAR2,
  p_party_id                            IN NUMBER,
  p_solved                              IN VARCHAR2,
  p_employee_id                         IN NUMBER,
  p_note_type                           IN jtf_varchar2_table_100,
  p_contract_id                         in varchar2,
  p_project_num                         in varchar2,
  p_short_code                          in varchar2,
  p_os_version                          in varchar2,
  p_db_version                          in varchar2,
  p_product_revision                    in varchar2,
 -- p_attr_6                              in varchar2,
  p_cust_pref_lang_code                 in varchar2 := NULL,
  p_pref_contact_method                 in varchar2,
  p_rollout                             in varchar2,
  p_error_code                          in varchar2 := NULL,
  p_serial_number                       in varchar2 := NULL,
  p_inv_category_id                     in NUMBER,
  p_time_zone_id                        in NUMBER,
-- for the SR location information
  p_location_id                         in NUMBER,
  p_address                             in varchar2 := NULL,
  p_city                                in varchar2 := NULL,
  p_state                               in varchar2 := NULL,
  p_country                             in varchar2 := NULL,
  p_province                            in varchar2 := NULL,
  p_postal_code                         in varchar2 := NULL,
  p_county                              in varchar2 := NULL,
-- add the following for 11.5.10
  p_addrLine2                            in varchar2 := NULL,
  p_addrLine3                            in varchar2 := NULL,
  p_addrLine4                            in varchar2 := NULL,
  p_poboxNumber                          in varchar2 := NULL,
  p_houseNumber                          in varchar2 := NULL,
  p_streetSuffix                         in varchar2 := NULL,
  p_street                               in varchar2 := NULL,
  p_street_number                        in varchar2 := NULL,
  p_floor                                in varchar2 := NULL,
  p_suite                                in varchar2 := NULL,
  p_postalPlus4Code                      in varchar2 := NULL,
  p_position                             in varchar2 := NULL,
  p_locationDirections                   in varchar2 := NULL,
  p_description                          in varchar2 := NULL,
  p_pointOfInterest                      in varchar2 := NULL,
  p_crossStreet                          in varchar2 := NULL,
  p_directionQualifier                   in varchar2 := NULL,
  p_distanceQualifier                    in varchar2 := NULL,
  p_distanceQualUom                      in varchar2 := NULL,
 --for the bill to and ship to
  p_bill_to_site_id                     in NUMBER,
  p_bill_to_contact_id                  in NUMBER,
  p_ship_to_site_id                     in NUMBER,
  p_ship_to_contact_id                  in NUMBER,
  p_install_site_use_id                 in NUMBER,
  p_bill_to_party_id                    in NUMBER,
  p_ship_to_party_id                    in NUMBER,
 -- added for 11.5.10
  p_bill_to_account_id                  in NUMBER,
  p_ship_to_account_id                  in NUMBER,
 -- added for link object enhancement
  p_ref_object_code                     in varchar2,
  p_ref_object_id                       in number,
 -- added for eam enhancement
  p_asset_id                            in number,
  p_maint_org_id                        in number,
  p_owning_dept_id                      in number,
  p_eam_type                            in varchar2,
--for DFF
  p_external_attribute_1                IN varchar2,
  p_external_attribute_2                IN varchar2,
  p_external_attribute_3                IN varchar2,
  p_external_attribute_4                IN varchar2,
  p_external_attribute_5                IN varchar2,
  p_external_attribute_6                IN varchar2,
  p_external_attribute_7                IN varchar2,
  p_external_attribute_8                IN varchar2,
  p_external_attribute_9                IN varchar2,
  p_external_attribute_10               IN varchar2,
  p_external_attribute_11               IN varchar2,
  p_external_attribute_12               IN varchar2,
  p_external_attribute_13               IN varchar2,
  p_external_attribute_14               IN varchar2,
  p_external_attribute_15               IN varchar2,
  p_external_context                    IN varchar2,

  x_return_status                       OUT NOCOPY VARCHAR2,
  x_msg_count                           OUT NOCOPY NUMBER,
  x_msg_data                            OUT NOCOPY VARCHAR2,
  x_request_id                          OUT NOCOPY NUMBER,
  p_site_name                                in varchar2 := NULL,
  p_site_number                                in varchar2 := NULL,
  p_addressee                                in varchar2 := NULL
)
IS

  cursor cur_contact_type(p_party_id number) is
    select party_type
    from   hz_parties
    where  party_id = p_party_id;

  cursor get_ib_serial_tag_csr(p_instance_id number) is
    select serial_number, external_reference
    from csi_item_instances
    where instance_id = p_instance_id;

  l_call_id                NUMBER;
  x_interaction_id         NUMBER;
  l_last_update_date       DATE := SYSDATE;
  l_object_version_number  NUMBER := 1;
  l_owner_id               NUMBER;
  l_sr_rec                 CS_SERVICEREQUEST_PVT.service_request_rec_type;
  l_notes_table            CS_SERVICEREQUEST_PVT.notes_table;
  l_contacts_table         CS_SERVICEREQUEST_PVT.contacts_table;
  x_workflow_process_id    NUMBER;
  l_validation_level       NUMBER  := FND_API.G_VALID_LEVEL_FULL;
  l_primary_contact_party_type     VARCHAR2(30);
  l_secondary_contact_party_type   VARCHAR2(30);
  l_contact_type           varchar2(30);
  l_contact_point_type     varchar2(30);

  l_index                 BINARY_INTEGER;
  l_note_index            BINARY_INTEGER;
  l_cs_atuo_assignment    VARCHAR2(1);
  l_ibu_assignment        VARCHAR2(1);
  l_default_coverage_temp_id   NUMBER;

  --added by wei ma
  x_individual_owner      VARCHAR2(100);
  x_group_owner           VARCHAR2(100);
  x_individual_type       VARCHAR2(100);

  -- wei ma tempoary
  l_responsibility_id     NUMBER;
  l_type_return_staus     VARCHAR2(1);

  l_retainCharNum Number := 0;
  l_truncateCharNum Number := 0;
  l_noteDetailNum number:= 0;
  -- Made change for 11.5.10, some of the output parameters are saved
  -- in the following recored.
  l_sr_create_out_rec      CS_ServiceRequest_PVT.sr_create_out_rec_type;

  -- added for link object enhancement
  l_ref_object_code varchar2(30) := p_ref_object_code;
  l_ref_object_id number := p_ref_object_id;
  l_select_id varchar2(200);
  l_from_table varchar2(200);
  l_where_clause varchar2(2000);
  l_ref_object_count number := 0;
  l_sr_create_link_rec cs_incidentlinks_pvt.CS_INCIDENT_LINK_REC_TYPE;
  l_user_id number;
  l_login_id number;
  l_resp_appl_id number;
  lx_return_status varchar2(3);
  lx_msg_count number;
  lx_msg_data varchar2(4000);
  lx_object_version_number number;
  lx_reciprocal_link_id number;
  lx_link_id number;
  l_dbg_msg varchar2(4000);
BEGIN

CS_SERVICEREQUEST_PVT.INITIALIZE_REC( p_sr_record => l_sr_rec);

l_sr_rec.request_date   := l_last_update_date;
l_sr_rec.incident_occurred_date := l_last_update_date;
l_sr_rec.type_id        := p_type_id;
--l_sr_rec.status_id      := p_status_id;
--added by wei
get_default_status(p_type_id =>p_type_id,
                   x_status_id =>l_sr_rec.status_id,
                   x_return_status=>l_type_return_staus);
l_sr_rec.severity_id    := p_severity_id;
l_sr_rec.summary        := p_summary;
l_sr_rec.caller_type    := p_caller_type;

l_sr_rec.language       := p_language;

l_sr_rec.current_serial_number  := p_serial_number;  -- klou IKON

if p_inv_category_id = -1 then
  l_sr_rec.category_id  := null;
  l_sr_rec.category_set_id := null;
else
  l_sr_rec.category_id  := p_inv_category_id;
  l_sr_rec.category_set_id := FND_PROFILE.VALUE('CS_SR_DEFAULT_CATEGORY_SET');
end if;

--l_sr_rec.resource_type  := 'RS_EMPLOYEE';

if (p_contract_id is not null and p_contract_id <> '-1') then
  l_sr_rec.contract_id := p_contract_id;
end if;

if (p_project_num is not null) then
  l_sr_rec.project_number := p_project_num;
end if;


/* for rollout only */
if (p_platform_id > 0) then
  l_sr_rec.platform_id := p_platform_id;
end if;

if (p_os_version is not null) then
  l_sr_rec.operating_system_version := p_os_version;
end if;

if (p_db_version is not null) then
  l_sr_rec.db_version := p_db_version;
end if;

if (p_short_code is not null) then
  l_sr_rec.request_attribute_4 := p_short_code;
end if;

if (p_product_revision is not null) then
  l_sr_rec.product_revision := p_product_revision;
end if;


/*
if (p_attr_6 is not null) then
  l_sr_rec.request_attribute_6 := p_attr_6;
end if;
*/
l_sr_rec.cust_pref_lang_code := p_cust_pref_lang_code;

/* end for rollout */

if (p_pref_contact_method is not null) then
  l_sr_rec.comm_pref_code := p_pref_contact_method;
end if;

if (p_urgency_id > 0) then
  l_sr_rec.urgency_id := p_urgency_id;
end if;

if (p_problem_code_id <> 'NONE') then
  l_sr_rec.problem_code := p_problem_code_id;
end if;

IF (p_inventory_item > 0) THEN
  l_sr_rec.inventory_item_id := p_inventory_item;
  l_sr_rec.inventory_org_id := CS_STD.Get_Item_Valdn_Orgzn_ID();
  if(p_inv_item_revision <> '-1') then
    l_sr_rec.inv_item_revision := p_inv_item_revision;
  end if;
END IF;

l_sr_rec.cust_ticket_number := p_helpdesk_no;
l_sr_rec.verify_cp_flag := 'N';
l_sr_rec.sr_creation_channel := 'WEB';

if (p_customer_id > 0) then
  l_sr_rec.customer_id := p_customer_id;
end if;

if (p_rollout = 'N') then

  if (p_employee_id > 0) THEN
    l_sr_rec.employee_id := p_employee_id;
   /* Follwoing is added for handling employee logging SRs 03/07/03, klou */
   l_sr_rec.customer_id := fnd_profile.value('IBU_EMP_SR_ORG');
   l_sr_rec.caller_type  := 'ORGANIZATION';
  else
    IF (p_product > 0) THEN
      l_sr_rec.customer_product_id := p_product;
      l_sr_rec.inventory_org_id := CS_STD.Get_Item_Valdn_Orgzn_ID();
      if(p_cp_revision_id > 0) then
        l_sr_rec.cp_revision_id := p_cp_revision_id;
      end if;
      -- klou IKON
--      open get_ib_serial_tag_csr(p_product);
--      fetch get_ib_serial_tag_csr
--      into l_sr_rec.current_serial_number, l_sr_rec.external_reference;
--      close get_ib_serial_tag_csr;
    end if;

    l_sr_rec.customer_id := p_customer_id;

    if (p_account_id > 0) then
      l_sr_rec.account_id := p_account_id;
    end if;
  end if; /* if employee id */

   -- debugging
  if p_contact_party_id.count <= 0 then
    l_sr_rec.summary  := l_sr_rec.summary ||' contact tables not passed ';
  end if;

  if (p_contact_party_id is not null and p_contact_party_id.count > 0) then
      l_index := p_contact_party_id.first;
      while (l_index is not null) loop
        if (p_contact_party_id(l_index) > 0) then
          if (p_contact_type(l_index) = 'CUSTOMER') then
            open cur_contact_type(p_contact_party_id(l_index));
            fetch cur_contact_type into l_contact_type;
            if (cur_contact_type%notfound) then
              close cur_contact_type;
              raise no_data_found;
            end if;
            close cur_contact_type;

            l_contacts_table(l_index).contact_type := l_contact_type;
          else
            l_contacts_table(l_index).contact_type := 'EMPLOYEE';
          end if;

          l_contacts_table(l_index).party_id := p_contact_party_id(l_index);
          l_contacts_table(l_index).primary_flag :=p_contact_primary(l_index);

          if (l_contacts_table(l_index).party_id > 0) then
            if (p_contact_type(l_index) <> 'EMPLOYEE' or
                p_contact_point_type(l_index) <> 'EMAIL') then
              l_contacts_table(l_index).contact_point_id :=
                p_contact_point_id(l_index);
            end if;

            -- get contact_point_id for employee if contact_type is PHONE, klou
            if p_contact_type(l_index) = 'EMPLOYEE' and
                p_contact_point_type(l_index) = 'PHONE' Then
                l_contacts_table(l_index).contact_point_id :=
                  p_contact_point_id(l_index);
            end if;

            l_contacts_table(l_index).contact_point_type :=
              p_contact_point_type(l_index);
          end if;
        end if; /* p_contact_party_id */

        l_index := p_contact_party_id.next(l_index);
      end loop;

    end if; /* if p_contact_party_id */

 -- end if; /* if employee id */  -- moved up by klou

else /* rollout = 'Y' */

  if (p_employee_id > 0) then
    l_sr_rec.employee_id := p_employee_id;
  end if;

  if (p_customer_id > 0) then
    if (p_contact_party_id is not null and p_contact_party_id.count > 0) then
      l_index := p_contact_party_id.first;
      while (l_index is not null) loop
        if (p_contact_party_id(l_index) > 0) then

        if (p_contact_type(l_index) = 'CUSTOMER') then
          open cur_contact_type(p_contact_party_id(l_index));
          fetch cur_contact_type into l_contact_type;
          if (cur_contact_type%notfound) then
            close cur_contact_type;
            raise no_data_found;
          end if;
          close cur_contact_type;

          l_contacts_table(l_index).contact_type := l_contact_type;
        else
          l_contacts_table(l_index).contact_type := 'EMPLOYEE';
        end if;

        l_contacts_table(l_index).party_id := p_contact_party_id(l_index);
        l_contacts_table(l_index).primary_flag := p_contact_primary(l_index);

        if (l_contacts_table(l_index).party_id > 0) then
          if (p_contact_type(l_index) <> 'EMPLOYEE' or
              p_contact_point_type(l_index) <> 'EMAIL') then
            l_contacts_table(l_index).contact_point_id :=
              p_contact_point_id(l_index);
          end if;

          l_contacts_table(l_index).contact_point_type :=
            p_contact_point_type(l_index);
        end if;
        end if; /* if p_contact_party_id */

        l_index := p_contact_party_id.next(l_index);
      end loop;

    end if; /* if p_contact_party_id */

  end if; /* p_customer_id */

end if; /* rollout */

if (p_eam_type = 'Y') then
  l_sr_rec.inventory_org_id := CS_STD.Get_Item_Valdn_Orgzn_ID();
  if (p_inventory_item > 0 and p_maint_org_id > 0) then l_sr_rec.maint_organization_id := p_maint_org_id; end if;
end if;

if (p_employee_id > 0 and p_asset_id > 0) then
  l_sr_rec.customer_product_id := p_asset_id;
  if (p_maint_org_id > 0) then l_sr_rec.maint_organization_id := p_maint_org_id; end if;
  if (p_owning_dept_id > 0) then l_sr_rec.owning_dept_id := p_owning_dept_id; end if;
end if;

-- modified by wei
-- chnage the notes to be table.
if(p_problem_description is not null and p_problem_description.count > 0) then
  l_note_index := p_problem_description.FIRST;
  while l_note_index IS NOT NULL LOOP
    if (p_problem_description(l_note_index)is NOT NULL) THEN
      l_notes_table(l_note_index).note_type := p_note_type(l_note_index);
    --  l_notes_table(l_note_index).note := p_problem_description(l_note_index);
      check_string_length_bites(
        p_string =>  p_problem_description(l_note_index),
        p_targetlen => 2000,
        x_returnLen =>  l_retainCharNum,
        x_truncateCharNum => l_truncateCharNum
      );

      if(l_truncateCharNum > 0) then
        l_notes_table(l_note_index).note := substr(p_problem_description(l_note_index), 0, l_retainCharNum);
      else
        l_notes_table(l_note_index).note := p_problem_description(l_note_index);
      end if;
      l_retainCharNum := 0;
      l_truncateCharNum := 0;
      l_notes_table(l_note_index).note_detail:= p_problem_detail(l_note_index);
      l_notes_table(l_note_index).note_status:= p_note_status(l_note_index);
    end if;
   l_note_index := p_problem_description.NEXT(l_note_index);
  end loop;
 end if; /* end of the p_problem_description */

-- Fix to bug 2200212
-- Don't set Org ID
-- fnd_client_info.set_org_context(CS_STD.Get_Item_Valdn_Orgzn_ID());


/* Removed the logic to getting resource from Assignment Manager in order
 * to fully leverage TeleService Auto-Assignment feature in 11.5.7.1
 * 11-APR-2002 KLOU, (ASSG)
 */

 Select nvl(fnd_profile.value('CS_AUTO_ASSIGN_OWNER_HTML'), 'N')
 Into l_cs_atuo_assignment From dual;

 If l_cs_atuo_assignment = 'N' Then
    Select nvl(fnd_profile.value('IBU_R_ASSIGNMENT_USED_OWNERS'), 'Y')
    Into l_ibu_assignment From dual;

    If l_ibu_assignment = 'Y' Then

-- Start of Fix to Bug 6621657
-- Profile CS_SR_DEFAULT_GROUP_TYPE is obsoleted in 12.0.2 and 12.0.3.

/*	   Select fnd_profile.value('CS_SR_DEFAULT_GROUP_TYPE')
 *	   Into l_sr_rec.group_type From dual;
 */

        l_sr_rec.group_type := 'RS_GROUP';

--End of Fix to Bug 6621657

        Select fnd_profile.value('CS_SR_DEFAULT_GROUP_OWNER')
        Into l_sr_rec.owner_group_id From dual;

        Select fnd_profile.value('INC_DEFAULT_INCIDENT_OWNER')
        Into l_sr_rec.owner_id From dual;

        Select fnd_profile.value('CS_SR_DEFAULT_OWNER_TYPE')
        into l_sr_rec.resource_type from dual;

    End If;
 End If;
-- Done auto assignment


l_sr_rec.error_code := p_error_code;
l_sr_rec.last_update_channel := 'WEB';

l_sr_rec.creation_program_code  := 'ISUPPORTSRUI';
l_sr_rec.last_update_program_code := 'ISUPPORTSRUI';

if (p_time_zone_id <> -1) then
  l_sr_rec.time_zone_id := p_time_zone_id;
end if;

--Next is the section for the service request location address
--If p_location_id is -1, we don't need to pass it to the lower level CS
--package

if(p_location_id <> -1) then
  l_sr_rec.incident_location_id := p_location_id;
  l_sr_rec.incident_location_type := 'HZ_PARTY_SITE';
end if;

if(p_address is not null) then
  l_sr_rec.incident_address  := p_address;
end if;

if(p_city is not null) then
  l_sr_rec.incident_city := p_city;
end if;

if(p_state is not null) then
  l_sr_rec.incident_state := p_state;
end if;

if(p_country is not null) then
  l_sr_rec.incident_country := p_country;
end if;

if(p_province is not null) then
  l_sr_rec.incident_province := p_province;
end if;

if(p_postal_code is not null) then
  l_sr_rec.incident_postal_code := p_postal_code;
end if;

if(p_county is not null) then
  l_sr_rec.incident_county := p_county;
end if;

if(p_addrLine2 is not null) then
  l_sr_rec.incident_address2 := p_addrLine2;
end if;

if(p_addrLine3 is not null) then
  l_sr_rec.incident_address3 := p_addrLine3;
end if;

if(p_addrLine4 is not null) then
  l_sr_rec.incident_address4 := p_addrLine4;
end if;

if(p_poboxNumber is not null) then
  l_sr_rec.incident_po_box_number := p_poboxNumber;
end if;

if(p_houseNumber is not null) then
  l_sr_rec.incident_house_number := p_houseNumber;
end if;

if(p_streetSuffix is not null) then
  l_sr_rec.incident_street_suffix := p_streetSuffix;
end if;

if(p_street is not null) then
  l_sr_rec.incident_street := p_street;
end if;

if(p_street_number is not null) then
  l_sr_rec.incident_street_number := p_street_number;
end if;

if(p_floor is not null) then
  l_sr_rec.incident_floor := p_floor;
end if;

if(p_suite is not null) then
  l_sr_rec.incident_suite := p_suite;
end if;

if(p_postalPlus4Code is not null) then
  l_sr_rec.incident_postal_plus4_code := p_postalPlus4Code;
end if;

if(p_position is not null) then
  l_sr_rec.incident_position := p_position;
end if;

if(p_locationDirections is not null) then
  l_sr_rec.incident_location_directions := p_locationDirections;
end if;

if(p_description is not null) then
  l_sr_rec.incident_location_description := p_description;
end if;

if(p_pointOfInterest is not null) then
  l_sr_rec.incident_point_of_interest := p_pointOfInterest;
end if;

if(p_crossStreet is not null) then
  l_sr_rec.incident_cross_street := p_crossStreet;
end if;

if(p_directionQualifier is not null) then
  l_sr_rec.incident_direction_qualifier := p_directionQualifier;
end if;

if(p_distanceQualifier is not null) then
  l_sr_rec.incident_distance_qualifier := p_distanceQualifier;
end if;

if(p_distanceQualUom is not null) then
  l_sr_rec.incident_distance_qual_uom := p_distanceQualUom;
end if;


-- the following is for the bill to and ship to
if(p_bill_to_site_id <> -1) then
  l_sr_rec.bill_to_site_id := p_bill_to_site_id ;
end if;

if(p_bill_to_contact_id <> -1) then
   l_sr_rec.bill_to_contact_id := p_bill_to_contact_id;
end if;

if(p_ship_to_site_id <> -1) then
   l_sr_rec.ship_to_site_id := p_ship_to_site_id;
end if;

if(p_ship_to_contact_id <> -1) then
  l_sr_rec.ship_to_contact_id := p_ship_to_contact_id;
end if;

if(p_install_site_use_id <> -1) then
  l_sr_rec.install_site_use_id := p_install_site_use_id;
end if;

if(p_bill_to_party_id <> -1) then
  l_sr_rec.bill_to_party_id := p_bill_to_party_id;
end if;

if(p_ship_to_party_id <> -1) then
  l_sr_rec.ship_to_party_id := p_ship_to_party_id;
end if;

if(p_ship_to_account_id <> -1) then
  l_sr_rec.ship_to_account_id := p_ship_to_account_id;
end if;

if(p_bill_to_account_id <> -1) then
  l_sr_rec.bill_to_account_id := p_bill_to_account_id;
end if;

if(p_external_attribute_1 is not null) then
l_sr_rec.external_attribute_1 := p_external_attribute_1;
end if ;

if(p_external_attribute_2 is not null) then
l_sr_rec.external_attribute_2 := p_external_attribute_2;
end if;

if(p_external_attribute_3 is not null) then
l_sr_rec.external_attribute_3 := p_external_attribute_3;
end if;

if(p_external_attribute_4 is not null) then
l_sr_rec.external_attribute_4 := p_external_attribute_4;
end if;

if(p_external_attribute_5 is not null) then
l_sr_rec.external_attribute_5 := p_external_attribute_5;
end if;

if(p_external_attribute_6 is not null) then
l_sr_rec.external_attribute_6 := p_external_attribute_6;
end if;

if(p_external_attribute_7 is not null) then
l_sr_rec.external_attribute_7 := p_external_attribute_7;
end if;

if(p_external_attribute_8 is not null) then
l_sr_rec.external_attribute_8 := p_external_attribute_8;
end if;

if(p_external_attribute_9 is not null) then
l_sr_rec.external_attribute_9 := p_external_attribute_9;
end if;

if(p_external_attribute_10 is not null) then
l_sr_rec.external_attribute_10 := p_external_attribute_10;
end if;

if(p_external_attribute_11 is not null) then
l_sr_rec.external_attribute_11 := p_external_attribute_11;
end if;

if(p_external_attribute_12 is not null) then
l_sr_rec.external_attribute_12 := p_external_attribute_12;
end if;

if(p_external_attribute_13 is not null) then
l_sr_rec.external_attribute_13 := p_external_attribute_13;
end if;

if(p_external_attribute_14 is not null) then
l_sr_rec.external_attribute_14 := p_external_attribute_14;
end if;

if(p_external_attribute_15 is not null) then
l_sr_rec.external_attribute_15 := p_external_attribute_15;
end if;

if(p_external_context is not null) then
l_sr_rec.external_context := p_external_context;
end if;

if (p_site_name is not null) then
  l_sr_rec.site_name := p_site_name;
end if;

if (p_site_number is not null) then
  l_sr_rec.site_number := p_site_number;
end if;

if (p_addressee is not null) then
  l_sr_rec.addressee := p_addressee;
end if;
--wei ma added
select fnd_global.resp_id, fnd_global.resp_appl_id, fnd_global.user_id, fnd_global.login_id
into l_responsibility_id, l_resp_appl_id, l_user_id, l_login_id
from dual;
-- added for 11.5.10
l_default_coverage_temp_id := fnd_profile.value('CS_SR_DEFAULT_COVERAGE');

CS_ServiceRequest_PVT.Create_ServiceRequest(
  p_api_version => 4.0,
  p_init_msg_list => fnd_api.g_true,
  p_commit => fnd_api.g_true,
  p_resp_id => l_responsibility_id,
  p_user_id => p_user_id,
  p_service_request_rec => l_sr_rec,
  p_notes => l_notes_table,
  p_contacts => l_contacts_table,
  p_auto_assign =>  l_cs_atuo_assignment,
  p_validation_level => l_validation_level,
  p_auto_generate_tasks => 'N',
  p_default_contract_sla_ind => 'Y',
  p_default_coverage_template_id => l_default_coverage_temp_id,
  x_msg_count => x_msg_count,
  x_return_status => x_return_status,
  x_msg_data => x_msg_data,
  x_sr_create_out_rec => l_sr_create_out_rec
  );

  x_request_id := l_sr_create_out_rec.request_id;
  p_request_number := l_sr_create_out_rec.request_number;

  if (x_return_status <> 'S') then
    decodeErrorMsg();
  end if;

  -- added for link type enhancement
  if (x_return_status = 'S' and (l_ref_object_code is null or length(l_ref_object_code) = 0) and l_ref_object_id <> -1) then
    if ((FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      l_dbg_msg := fnd_message.get_string('IBU', 'IBU_SR_REF_OBJ_CODE_NOT_PASSED');
      FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'ibu.plsql.IBU_REQ_PKG.create_service_request', l_dbg_msg);
    end if;
  end if;

  if (x_return_status = 'S' and l_ref_object_id = -1 and l_ref_object_code is not null and length(l_ref_object_code) > 0) then
    if ((FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      l_dbg_msg := fnd_message.get_string('IBU', 'IBU_SR_REF_OBJ_ID_NOT_PASSED');
      FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'ibu.plsql.IBU_REQ_PKG.create_service_request', l_dbg_msg);
    end if;
  end if;

  if (x_return_status = 'S' and l_ref_object_code is not null and length(l_ref_object_code) > 0 and l_ref_object_id <> -1) then
    getObjectInfo(p_ref_object_code => l_ref_object_code,
                  x_select_id => l_select_id,
                  x_from_table => l_from_table,
                  x_where_clause => l_where_clause,
                  x_object_count => l_ref_object_count);

    if (l_ref_object_count = 0) then
      if ((FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
        l_dbg_msg := fnd_message.get_string('IBU','IBU_SR_REF_OBJ_CODE_INVALID');
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'ibu.plsql.IBU_REQ_PKG.create_service_request', l_dbg_msg);
      end if;
    else
      l_ref_object_count := 0;

      checkObjectID(p_ref_object_id => l_ref_object_id,
                    p_select_id => l_select_id,
                    p_from_table => l_from_table,
                    p_where_clause => l_where_clause,
                    x_object_count => l_ref_object_count);

      if (l_ref_object_count = 0) then
        if ((FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
          l_dbg_msg := fnd_message.get_string('IBU', 'IBU_SR_REF_OBJ_ID_INVALID');
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'ibu.plsql.IBU_REQ_PKG.create_service_request', l_dbg_msg);
        end if;
      else
        l_sr_create_link_rec.SUBJECT_ID := x_request_id;
        l_sr_create_link_rec.SUBJECT_TYPE := 'SR';
        l_sr_create_link_rec.OBJECT_ID := l_ref_object_id;
        l_sr_create_link_rec.OBJECT_TYPE := l_ref_object_code;
        l_sr_create_link_rec.LINK_TYPE_ID := 6;
        l_sr_create_link_rec.LINK_TYPE := 'REF';

        cs_incidentlinks_pvt.CREATE_INCIDENTLINK(P_API_VERSION => 2.0,
                                                 P_INIT_MSG_LIST => fnd_api.g_true,
                                                 P_COMMIT => fnd_api.g_true,
                                                 P_VALIDATION_LEVEL => l_validation_level,
                                                 P_USER_ID => l_user_id,
                                                 P_LOGIN_ID => null,
                                                 P_LINK_REC => l_sr_create_link_rec,
                                                 X_RETURN_STATUS => lx_return_status,
                                                 X_MSG_COUNT => lx_msg_count,
                                                 X_MSG_DATA => lx_msg_data,
                                                 X_OBJECT_VERSION_NUMBER => lx_object_version_number,
                                                 X_RECIPROCAL_LINK_ID => lx_reciprocal_link_id,
                                                 X_LINK_ID => lx_link_id
                                                );

        if (lx_return_status <> 'S') then
          if ((FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'ibu.plsql.IBU_REQ_PKG.create_service_request', lx_msg_data);
          end if;
        end if;

      end if;
    end if;
  end if;

end create_service_request;


/**
 * Send email notification to user
 */
procedure send_email(
  email_address_in in varchar2,
  user_id          in varchar2,
  subject          in varchar2,
  msg_body         in varchar2,
  srID             in number,
  emailStyleSheet  in varchar2,
  emailbranding    in varchar2,
  emaillinkURL     in varchar2,
  notification_pref in varchar2,
  contactType       in varchar2,
  contactID         in number
)
as
  user_name      varchar2(100) := null;
  user_display_name   varchar2(100) := null;
  language              varchar2(100) := 'AMERICAN';
  territory             varchar2(100) := 'America';
  description   varchar2(100) := NULL;
  --notification_preference varchar2(100) := 'MAILTEXT';
  notification_preference varchar2(100) := 'MAILHTM2';
  email_address varchar2(100) := NULL;
  fax                   varchar2(100) :=NULL;
  status                varchar2(100) := 'ACTIVE';
  expiration_date varchar2(100) := NULL;
  role_name             varchar2(100) := NULL;
  role_display_name     varchar2(100) := NULL;
  role_description      varchar2(100) := NULL;
  wf_id         Number;
  msg_type  varchar2(100) := 'IBU_SUBS';
  msg_name  varchar2(100) := 'IBU_MESG';

  due_date date := NULL;
  callback varchar2(100) := NULL;
  context varchar2(100) := NULL;
  send_comment varchar2(100) := NULL;
  priority  number := null;

  email_content   Wf_Engine.TextTabTyp;
  email_content_count_end number := 1;
  temp_email_msg_body varchar2(32000) := null;
  truncateCharNum number := 0; -- added by wei ma
  retainCharNum number := 0;
  i number := 1;
  finaltotalCharNum number := 0;
  originatotalCharNum number := 0;
  temp_email_content_holder varchar2(16000) := null;

  -- define cursors for role defintion
  temp_role_name varchar2(100) := null;
  temp_pref_name varchar2(100) := null;
  constructNewRoleName boolean := true;
  cursor cur_sr_email_cus_role(p_contact_id number, p_email_address varchar2) is
     select name from wf_roles
       where orig_system = 'HZ_PARTY'
       and orig_system_id = p_contact_id
       and email_address = p_email_address;

  cursor cur_sr_email_emp_role(p_contact_id number, p_email_address varchar2) is
     select notification_preference, name from wf_roles
       where orig_system = 'PER'
       and orig_system_id = p_contact_id
       and email_address = p_email_address;

  duplicate_user_or_role  exception;
  PRAGMA  EXCEPTION_INIT (duplicate_user_or_role, -20002);
  begin

  role_name := 'IBUSR1_'||email_address_in;
  role_display_name := user_id; --actual user fullName
  email_address := email_address_in;

  temp_email_msg_body := substr(msg_body, 0, 29000);
  originatotalCharNum := length(temp_email_msg_body);

  -- from the here is the section to construct the role
  if('CUS' = contactType) then
    open cur_sr_email_cus_role(contactID, email_address_in);
    fetch cur_sr_email_cus_role into temp_role_name;
    close cur_sr_email_cus_role;
    if(temp_role_name is not null) then
       constructNewRoleName := false;
       role_name := temp_role_name;
    else
       constructNewRoleName := true;
    end if;
  end if;

  if('EMP' = contactType) then
     open cur_sr_email_emp_role(contactID, email_address_in);
     fetch cur_sr_email_emp_role into temp_pref_name, temp_role_name;
     close cur_sr_email_emp_role;

     if(temp_pref_name is not null and ('MAILHTML'=  temp_pref_name or 'MAILHTM2' =  temp_pref_name or
      'MAILTEXT' =  temp_pref_name or 'MAILATTH' =  temp_pref_name)) then
       role_name := temp_role_name;
       constructNewRoleName := false;
     else
      constructNewRoleName := true;
     end if;
   end if;

  -- end of the section to construct the role

  while (i < 16 ) loop
     if(finaltotalCharNum < originatotalCharNum) then
       temp_email_content_holder := substr(temp_email_msg_body, 0, 1950);
        check_string_length_bites(
            p_string => temp_email_content_holder, --email_content(i),
            p_targetlen => 1950,
            x_returnLen => retainCharNum,
            x_truncateCharNum => truncateCharNum);
      email_content(i) := substr(temp_email_content_holder, 0, retainCharNum);
      temp_email_msg_body := substr(temp_email_msg_body, 1951-truncateCharNum);
      finaltotalCharNum := finaltotalCharNum + retainCharNum;

    else
      email_content(i) := '';
    end if;
    i := i+1;

  end loop;

  if(constructNewRoleName) then
    notification_preference := notification_pref;
    begin
     WF_Directory.CreateAdHocUser(role_name, role_display_name, language,
       territory, role_description, notification_preference,
       email_address, fax, status, expiration_date);
     exception
       when duplicate_user_or_role then
         WF_Directory.SetAdHocUserAttr (role_name, role_display_name,
           notification_preference, language, territory, email_address, fax);
     end;
  end if;

 -- next is to use the new startProcess procedure
  StartEmailProcess(role_name, srID, subject, email_content,
        role_name, 'IBU_SENDMAIL', 'IBUSRDTL', emailStyleSheet, emailBranding, emaillinkURL);

 /*   wf_id := WF_Notification.send(role_name, 'IBUSRDTL', 'IBU_MESG',
    due_date, callback, context, send_comment, priority);
  WF_Notification.SetAttrText(wf_id, 'IBU_SUBJECT', subject);
--  WF_Notification.SetAttrText(wf_id, 'IBU_CONTENT', msg_body);

  for i in 1..8 loop
    if(i = 1)  then
     WF_Notification.SetAttrText(wf_id, 'IBU_CONTENT', email_content(i));
    else
     WF_Notification.SetAttrText(wf_id, 'IBUCONTENT'||i, email_content(i));
    end if;
  end loop; */

end send_email;

procedure get_default_status(
   p_type_id         in number,
   x_status_id       out nocopy number,
   x_return_status out NOCOPY VARCHAR2
)as
 l_responsibility_id   number;
 l_status_id           number;
 l_group_id            number;
 no_status_defined     Exception;

 cursor cur_sr_def_status_group_a(p_type_id number,p_resp_id number) is
    SELECT
      TypeMapping.status_group_id
    FROM
     cs_sr_type_mapping TypeMapping
   WHERE
     incident_type_id = p_type_id AND
     responsibility_id = p_resp_id AND
     TRUNC(SYSDATE) BETWEEN TRUNC(NVL(TypeMapping.start_date, SYSDATE)) AND
     TRUNC(NVL(TypeMapping.end_date, SYSDATE));

  cursor cur_sr_def_status_group_b(p_type_id number) is
     SELECT  status_group_id
     FROM  cs_incident_types_b
     WHERE incident_type_id = p_type_id AND
     TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE)) AND
     TRUNC(NVL(end_date_active, SYSDATE));

  cursor cur_sr_group_def_staus_id(p_status_group_id number) is
     select default_incident_status_id
     from cs_sr_status_groups_b
     where status_group_id = p_status_group_id
     and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date, SYSDATE)) AND
     TRUNC(NVL(end_date, SYSDATE));

  cursor cur_sr_def_status_from_group(p_status_group_id number) is
     select csIncidentStatus.incident_status_id
     from CS_SR_ALLOWED_STATUSES       allowedStatus,
          CS_INCIDENT_STATUSES_B    csIncidentStatus
     where
          allowedStatus.status_group_id =  p_status_group_id and
          allowedStatus.incident_status_id =
            csIncidentStatus.incident_status_id and
          csIncidentStatus.valid_in_create_flag = 'Y' and
          csIncidentStatus.incident_subtype = 'INC' and
          (csIncidentStatus.pending_approval_flag is null or
           csIncidentStatus.pending_approval_flag = 'N') and
          TRUNC(SYSDATE) BETWEEN TRUNC(NVL(allowedStatus.start_date, SYSDATE))
          AND
          TRUNC(NVL(allowedStatus.end_date, SYSDATE)) AND
          TRUNC(SYSDATE) BETWEEN
          TRUNC(NVL(csIncidentStatus.start_date_active, SYSDATE)) AND
          TRUNC(NVL(csIncidentStatus.end_date_active, SYSDATE)) and
          rownum <=1 ;

 begin
  select fnd_global.resp_id into l_responsibility_id from dual;

  open cur_sr_def_status_group_a(p_type_id, l_responsibility_id);
  fetch  cur_sr_def_status_group_a into l_group_id;
  close cur_sr_def_status_group_a;

  if(l_group_id is not null and l_group_id > 0) then
     open cur_sr_group_def_staus_id(l_group_id);
     fetch  cur_sr_group_def_staus_id into l_status_id;
     close cur_sr_group_def_staus_id;

     if(l_status_id is null or l_status_id <=0) then
       open cur_sr_def_status_from_group(l_group_id);
       fetch cur_sr_def_status_from_group into l_status_id;
       close  cur_sr_def_status_from_group;
      end if;
  end if;

  if(l_group_id is null or l_group_id <= 0) then
      open cur_sr_def_status_group_b(p_type_id);
      fetch  cur_sr_def_status_group_b into l_group_id;
      close cur_sr_def_status_group_b;

       if(l_group_id is not null and l_group_id > 0) then
          open cur_sr_group_def_staus_id(l_group_id);
          fetch  cur_sr_group_def_staus_id into l_status_id;
          close cur_sr_group_def_staus_id;
       end if;
       if(l_status_id is null or l_status_id <=0) then
         open cur_sr_def_status_from_group(l_group_id);
         fetch cur_sr_def_status_from_group into l_status_id;
         close cur_sr_def_status_from_group;
      end if;

   end if;

  if(l_group_id is null or l_group_id <= 0) then
    l_status_id := fnd_profile.value('INC_DEFAULT_INCIDENT_STATUS');
  end if;
  x_status_id := l_status_id;

end get_default_status;

/**
 * Decode the error messages:
 *   CS_SR_CANNOT_CLOSE_SR
 *   CS_SR_OPEN_TASKS_EXISTS
 *   CS_SR_OPEN_CHARGES_EXISTS
 *   CS_SR_SCHEDULED_TASKS_EXISTS
 *   CS_SR_TASK_DEBRIEF_INCOMPLETE
 * TO
 * "This service request cannot be closed at this time.
 *  Please call customer support for assistance."
 */

procedure decodeErrorMsg
as
  l_count   number;
  l_data	  varchar2(2000);
  tempMsg   varchar2(2000);
  l_msg_index number := 1;
  l_msg_index_out number;
  l_app_code varchar2(10);
  l_msg_name varchar2(100);
begin
  l_count := FND_MSG_PUB.Count_Msg;

  while l_msg_index <= l_count loop
    FND_MSG_PUB.Get(p_msg_index => l_msg_index,
                    p_data => l_data,
                    p_msg_index_out => l_msg_index_out
                    );

    fnd_message.parse_encoded (
                               l_data,
                               l_app_code,
                               l_msg_name
                               );

    if (l_msg_name = 'CS_SR_CANNOT_CLOSE_SR' or
        l_msg_name = 'CS_SR_OPEN_TASKS_EXISTS' or
        l_msg_name = 'CS_SR_OPEN_CHARGES_EXISTS' or
        l_msg_name = 'CS_SR_SCHEDULED_TASKS_EXISTS' or
        l_msg_name = 'CS_SR_TASK_DEBRIEF_INCOMPLETE') then

      FND_MSG_PUB.Delete_Msg(l_msg_index_out);
      FND_MESSAGE.SET_NAME('IBU', 'IBU_SR_CANNOT_CLOSE_SR');
      FND_MSG_PUB.Add;
      l_count := l_count - 1;
    elsif (l_msg_name = 'FORM_RECORD_CHANGED') then
      FND_MSG_PUB.Delete_Msg(l_msg_index_out);
      FND_MESSAGE.SET_NAME('IBU', 'IBU_SR_CANNOT_UPDATE_SR');
      FND_MSG_PUB.Add;
      l_count := l_count - 1;
    else
      l_msg_index := l_msg_index + 1;
    end if;
  end loop;
end decodeErrorMsg;

/**
 * This procedure is to start the Email work flow.
 *
 */

procedure StartEmailProcess (
   roleName in varchar2,
   srID    in number,
   subject in varchar2,
   content   Wf_Engine.TextTabTyp,
   ProcessOwner in varchar2,
   Workflowprocess in varchar2 ,
   item_type in varchar2,
   emailStyleSheet  in varchar2,
   emailbranding    in varchar2,
   emaillinkURL     in varchar2) is

ItemType varchar2(30) := nvl(item_type, 'IBUSRDTL');
ItemKey  varchar2(200) := 'NOTIF_' || roleName;
ItemUserKey varchar2(200) := roleName;

cnt number := 0;
i number := 0;
l_user varchar2(50);
seq number := 0;
--create_seq varchar2(50) := 'create sequence IBU_SR_NOTIFICATION_S';
--get_seq varchar2(50) := 'select ' || 'IBU_SR_NOTIFICATION_S' || '.nextval from dual';
get_seq varchar2(50) := 'select ' || 'IBU_WF_ITEM_KEY_S' || '.nextval from dual';
mailAttrVals   Wf_Engine.TextTabTyp ;
begin
   /* Get schema name */
  select user into l_user from dual;

  /* Get sequence for item key to be unique */
  /* select count(*) into cnt from all_objects
  where object_name like 'IBU_SR_NOTIFICATION_S'
  and object_type = 'SEQUENCE'
  and owner = l_user; */

 /*  if cnt = 0 then
     execute immediate create_seq;
   else
     execute immediate get_seq into seq;
  end if; */
  execute immediate get_seq into seq;

  ItemKey := roleName||seq;

  wf_engine.CreateProcess(itemtype => ItemType,
                           itemkey => ItemKey,
                           process => WorkflowProcess );

  wf_engine.SetItemUserKey(itemtype => Itemtype,
                            itemkey => Itemkey,
                            userkey => ItemUserKey);

  wf_engine.SetItemAttrText(itemtype => Itemtype,
                             itemkey => Itemkey,
                             aname => 'IBU_ROLE',
                             avalue => roleName);

  wf_engine.SetItemAttrText (itemtype => Itemtype,
                              itemkey => Itemkey,
                              aname => 'IBU_SUBJECT_ITEM',
                              avalue => subject);

  wf_engine.SetItemAttrNumber(itemtype => Itemtype,
                              itemkey => Itemkey,
                              aname => 'IBUSRID',
                              avalue => srID);

  wf_engine.SetItemAttrText(itemtype => Itemtype,
                              itemkey => Itemkey,
                              aname => 'IBUSTYLESHEET',
                              avalue => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'|| emailStyleSheet);

  wf_engine.SetItemAttrText(itemtype => Itemtype,
                              itemkey => Itemkey,
                              aname => 'IBUBRANDING',
                              avalue => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'|| emailbranding);

  wf_engine.SetItemAttrText(itemtype => Itemtype,
                              itemkey => Itemkey,
                              aname => 'IBUURL',
                              avalue => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'|| emaillinkurl);

  wf_engine.SetItemOwner(itemtype => Itemtype,
                         itemkey => Itemkey,
                         owner => roleName);

  for i in 1..15 loop
    mailAttrVals(i) := 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/' || content(i);
    if(i = 1)  then
      wf_engine.SetItemAttrText(itemtype => Itemtype,
                             itemkey => Itemkey,
                             aname => 'IBU_ITEM_CONTENT',
                             avalue => mailAttrVals(i));
    else
      wf_engine.SetItemAttrText(itemtype => Itemtype,
                             itemkey => Itemkey,
                             aname => 'IBUCONTENT'||(i-1),
                             avalue => mailAttrVals(i));
    end if;
   end loop;

  wf_engine.StartProcess (itemtype => Itemtype,
			  itemkey => Itemkey );

  end StartEmailProcess;

  procedure check_string_length_bites(
    p_string         in varchar2,
    p_targetlen      number,
    x_returnLen      out NOCOPY number,
    x_truncateCharNum out NOCOPY number
  ) is
   lowBound number := 0;
   highBound number := length(p_string);
   orginalhighBound number := highBound;
   middleBound number := floor((lowBound + highBound)/2);
   inputStringBites number := lengthb(p_string);
   bitesCharDiff number := inputStringBites - highBound;
   tempString varchar2(32000) := '';
   tempCounter number := 0;
  begin
   if(bitesCharDiff = 0 or inputStringBites <= p_targetlen) then
     x_returnLen := highBound;
   else -- not eaual case:
     if(bitesCharDiff > 0 and bitesCharDiff <= 256) then
       x_returnLen :=  highBound - bitesCharDiff;
     else
        -- we need to use binary search to locate the position
      while(lowBound < highBound) loop
        tempCounter := tempCounter +1;

        middleBound := floor((lowBound + highBound)/2);
        tempString := substr(p_string, 0, middleBound);
        inputStringBites :=  lengthb(tempString);

        bitesCharDiff :=  p_targetlen - inputStringBites ;

        if(bitesCharDiff = 0) then
           x_returnLen := middleBound;
           exit;
        else
           if(bitesCharDiff < 0) then
             highBound := middleBound;
           else
              if(bitesCharDiff > 256) then
                lowBound := middleBound;
              else
                x_returnLen := middleBound;
                exit;
              end if;
           end if;
         end if;
       end loop;
     end if;
   end if;

  x_truncateCharNum := orginalhighBound - x_returnLen;
  end check_string_length_bites;

/**
 * get the object info from jtf_object
 */

procedure getObjectInfo(
   p_ref_object_code in varchar2,
   x_select_id out NOCOPY varchar2,
   x_from_table out NOCOPY varchar2,
   x_where_clause out NOCOPY varchar2,
   x_object_count out NOCOPY number
   ) as

   l_ref_object_code varchar2(30) := p_ref_object_code;
   l_ref_object_value varchar2(30) := null;
begin

   select object_code, select_id, from_table, where_clause
   into l_ref_object_value, x_select_id, x_from_table, x_where_clause
   from jtf_objects_b
   where sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate)
     and object_code = l_ref_object_code;

   if l_ref_object_value is null then x_object_count :=0; else x_object_count :=1; end if;

   EXCEPTION
      WHEN OTHERS THEN
         x_object_count := 0;

end getObjectInfo;

procedure checkObjectID(
   p_ref_object_id in number,
   p_select_id in varchar2,
   p_from_table in varchar2,
   p_where_clause in varchar2,
   x_object_count out NOCOPY number
   ) as
   l_ref_object_id number := p_ref_object_id;
   l_select_statement varchar2(3500);
begin

   if (p_where_clause is not null and length(p_where_clause) > 0) then
     l_select_statement := 'select count(*) from ' || p_from_table || ' where ' || p_where_clause || ' and ' || p_select_id || ' = :p1 and rownum < 2 ';
   else
     l_select_statement := 'select count(*) from ' || p_from_table || ' where ' || p_select_id || ' = ' || l_ref_object_id;
   end if;

   execute immediate l_select_statement into x_object_count;

   EXCEPTION
      WHEN OTHERS THEN
         x_object_count := 0;

end checkObjectID;

procedure validate_http_service_ticket(
   p_ticket_string   in varchar2,
   x_return_status   out NOCOPY VARCHAR2
)is

ticketValid boolean := false;
X2    raw(32);
SVC   varchar2(30) := 'CS_IBU_EMAIL';
ticketNumber varchar2(400) := '';
begin
   X2 := FND_HTTP_TICKET.SET_SERVICE_TICKET(SVC);
   -- Probably don't need this call to the "get" interface
   ticketNumber := FND_HTTP_TICKET.GET_SERVICE_TICKET_STRING(SVC);
   ticketValid := FND_HTTP_TICKET.COMPARE_SERVICE_TICKET_STRINGS(ticketNumber, p_ticket_string);
   if(ticketValid) then
     x_return_status := 'T';
   else
     x_return_status := 'F';
   end if;

   Exception
    when others then
     x_return_status := 'F';

 end validate_http_service_ticket;


END IBU_REQ_PKG;

/
