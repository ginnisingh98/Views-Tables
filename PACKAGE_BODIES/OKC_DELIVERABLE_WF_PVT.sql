--------------------------------------------------------
--  DDL for Package Body OKC_DELIVERABLE_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DELIVERABLE_WF_PVT" AS
/* $Header: OKCVDELWFB.pls 120.2.12010000.4 2013/09/03 14:36:26 serukull ship $ */
 ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_subject_text
--Function:
--  This is a callback procedure for a PL/SQL Document attribute in workflow.  It is used to populate the subject text of a deliverable notification.
--
--Parameters:
--document_id : of the form 'MESSAGE_CODE:DELIVERABLE_ID', where message_code comes from FND_NEW_MESSAGES, and deliverable_id will be used to query OKC_DELIVERABLES and populate the tokens of the message.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
-- package variables
---------------------------------------------------------------------------
    g_module VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';
---------------------------------------------------------------------------

PROCEDURE get_subject_text  (document_id in varchar2,
                            display_type in varchar2,
                            document in out NOCOPY varchar2,
                            document_type in out NOCOPY varchar2)
IS

l_divider_index NUMBER;
l_del_id NUMBER;
l_msg_code VARCHAR2(30);
l_uom_text VARCHAR2(80);

  CURSOR deliverable_tokens_cursor IS
  SELECT busDocTL.name,
   busDocTL.document_type,
	 deliverable.business_document_number,
	 deliverable.deliverable_name,
         deliverable.notify_prior_due_date_value,
	 deliverable.notify_prior_due_date_uom
    FROM okc_bus_doc_types_tl busDocTL, okc_deliverables deliverable
    WHERE deliverable.deliverable_id = l_del_id
	  AND   deliverable.business_document_type = busDocTL.document_type
          AND   busDocTL.language = userenv('LANG');
  del_tokens_rec deliverable_tokens_cursor%ROWTYPE;


	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(500);

begin
  --document_id is of the form MSG_CODE:DEL_ID
  l_divider_index := instr(document_id,':');
  l_msg_code := substr(document_id,1,l_divider_index-1);
  l_del_id := 	substr(document_id,l_divider_index+1,length(document_id));

  --set message code
  fnd_message.clear;
  fnd_message.set_name(APPLICATION=>'OKC',NAME=>l_msg_code);

  --set tokens
  OPEN deliverable_tokens_cursor;
  FETCH deliverable_tokens_cursor INTO del_tokens_rec;
  IF deliverable_tokens_cursor%FOUND THEN

				  --Acq Plan Message Cleanup
    l_resolved_token := OKC_API.resolve_del_token(del_tokens_rec.document_type);

    fnd_message.set_token(TOKEN => 'DEL_TOKEN',VALUE => l_resolved_token);
    fnd_message.set_token(TOKEN => 'DELIVERABLENAME',VALUE => del_tokens_rec.deliverable_name);
    fnd_message.set_token(TOKEN => 'BUSDOCTYPE',VALUE => del_tokens_rec.name);
    fnd_message.set_token(TOKEN => 'BUSDOCNUM',VALUE => del_tokens_rec.business_document_number);

    --Before due may have extra tokens

    l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_BEFOREDUE_NTF_SUBJECT',del_tokens_rec.document_type);

    --if l_msg_code = 'OKC_DEL_BEFOREDUE_NTF_SUBJECT' THEN
     if l_msg_code = 'OKC_DEL_BEFOREDUE_NTF_SUBJECT' OR l_msg_code = l_resolved_msg_name THEN
     l_resolved_token := OKC_API.resolve_del_token(del_tokens_rec.document_type);

    fnd_message.set_token(TOKEN => 'DEL_TOKEN',VALUE => l_resolved_token);

        fnd_message.set_token(TOKEN => 'AMOUNT',VALUE => del_tokens_rec.notify_prior_due_date_value);

        select meaning into l_uom_text from fnd_lookups
        where lookup_type = 'OKC_DELIVERABLE_TIME_UNITS'
        and lookup_code = del_tokens_rec.notify_prior_due_date_uom;
        fnd_message.set_token(TOKEN => 'UNITS' ,VALUE => l_uom_text);
    end if; --end setting extra tokens
  END IF;
  CLOSE deliverable_tokens_cursor;


  document:=fnd_message.get;


end get_subject_text;


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_internal_user_role
--Function:
--  Function returns the role name of the employee with ID p_employee_id
--  If the employee has no FND_USER entry, it will create an adhoc role with the
--  employee's email address and return that adhoc role name.
--Parameters:
--p_employee_id : PERSON ID from  PER_PEOPLE_F hr_employees_current_v
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

FUNCTION get_internal_user_role(p_employee_id IN NUMBER,
                                x_role_display_name OUT NOCOPY VARCHAR2) RETURN VARCHAR2

IS
    --bug#4694703 replaced hr_employees_current_v with PER_PEOPLE_F
    cursor C_user_email(x_employee_id NUMBER) is
    select email_address, full_name from PER_PEOPLE_F where person_id = x_employee_id;

    l_role_name wf_roles.name%TYPE;
    l_role_display_name wf_roles.display_name%TYPE;

    l_email per_people_f.email_address%TYPE;
    l_full_name per_people_f.full_name%TYPE;

    l_api_name CONSTANT VARCHAR2(30) :='get_internal_user_role';

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered INTO get_internal_user_role');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                      ,'101: p_employee_id = '||p_employee_id);

    END IF;

    IF p_employee_id IS NULL THEN
	return NULL;
    END IF;

    -- for given employee id, get WF role_name and role_display_name from wf_local_roles
    WF_DIRECTORY.GetUserName (p_orig_system => 'PER',
                              p_orig_system_id => p_employee_id,
                              p_name => l_role_name,
                              p_display_name => l_role_display_name);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                      ,'102: Found Role Name = '||l_role_name);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                      ,'103: Found Role Display Name = '||l_role_display_name);
    END IF;

    -- if role name is still NULL, creat an adhoc role to send email notification
    -- to the employee's email address
    IF l_role_name is NULL THEN

      OPEN C_user_email(p_employee_id);
        FETCH C_user_email into l_email, l_full_name;
      CLOSE C_user_email;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'104:  Employee Email = '||l_email);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'105: Employee Full Name = '||l_full_name);
      END IF;

      IF l_email IS NOT NULL AND l_full_name IS NOT NULL THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                          ,'106:  Calling createAdHocRole');
        END IF;

        -- set role display name as Employee's Full Name
        l_role_display_name := l_full_name;
        WF_DIRECTORY.createAdHocRole(role_name=>l_role_name,
                                     role_display_name=>l_role_display_name,
                                     language=>null,
                                     territory=>null,
                                     role_description=>'Deliverables Ad hoc role',
                                     notification_preference=>'MAILHTML',
                                     email_address=>l_email,
                                     status=>'ACTIVE',
                                     expiration_date=>SYSDATE+1);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                          ,'107:  DONE createAdHocRole');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                          ,'108:  Got Role Name = '||l_role_name);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                          ,'109:  Got Role Display Name = '||l_role_display_name);
        END IF;

      END IF; -- IF l_email IS NOT NULL AND l_full_name IS NOT NULL
    END IF; -- IF l_role_name is NULL

    -- set x_role_display_name as l_role_display_name
    x_role_display_name := l_role_display_name;

    return l_role_name;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_user_email%ISOPEN THEN
 	   CLOSE C_user_email;
      END IF;
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                       ,'110: IN EXCEPTION '||substr(sqlerrm,1,200));
      END IF;

    return l_role_name;

END get_internal_user_role;

--------------------------------------------------------------------------
--Start of Comments
--Name: deliverables_notifier
--Function:
--  This procedure sends notifications by starting a workflow process.  The
-- notification will be sent to either the internal or external contacts or both depending
-- on the type of notification.  The notifications will have embedded OA regions
-- describing the business context and the deliverable details.
--Parameters:
--IN:
--p_msg_code - one of G_COMPLETE_NTF_CODE, G_OVERDUE_NTF_CODE,G_BEFOREDUE_NTF_CODE,G_ESCALATE_NTF_CODE
--OUT:
-- x_notification_id - the notification id of the notification sent if only 1 was sent
--                      or the id of the one sent to the responsible party if 2 were sent.
--Notes:
-- We select column external_userlist_proc from the OKC_BUS_DOC_TYPES_V view.  This
-- value, if not null, must carry the following parameters:
--'begin '||l_external_function_name||'(
-- p_api_version=>:p_api_version,
-- p_document_id=>:p_document_id,
-- p_document_type=>:p_document_type,
-- x_return_status=>:x_return_status,
-- x_msg_count=>:x_msg_count,
-- x_msg_data=>:x_msg_data,
-- x_external_userlist=>:x_external_userlist);
-- Testing:
--
--End of Comments
--------------------------------------------0-----------------------------------
PROCEDURE deliverables_notifier(

        p_api_version  IN NUMBER:=1.0,
	p_init_msg_list IN VARCHAR2:=FND_API.G_FALSE,
	p_deliverable_id IN NUMBER,
	p_deliverable_name IN VARCHAR2,
        p_deliverable_type IN VARCHAR2,
	p_business_document_id IN NUMBER,
	p_business_document_version IN NUMBER,
	p_business_document_type IN VARCHAR2,
        p_business_document_number IN VARCHAR2,
        p_resp_party IN VARCHAR2,
	p_external_contact IN NUMBER,
	p_internal_contact  IN NUMBER,
	p_requester_id IN NUMBER default null,
        p_notify_prior_due_date_value IN VARCHAR2 default null,
        p_notify_prior_due_date_uom IN VARCHAR2 default null,
	p_msg_code IN VARCHAR2,
	x_notification_id OUT NOCOPY NUMBER,
	x_msg_data  OUT NOCOPY  VARCHAR2,
	x_msg_count OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2) IS

    l_item_key number;
    l_msg_key varchar2(30);
    l_item_type varchar2(30):='OKCDELWF';
    l_process_name varchar2(30):='OKCDELNOTIFY';
    l_notif_id number;

    l_busdoctype_meaning varchar2(150);

    l_internal_role_name varchar2(320);
    l_external_role_name varchar2(320); -- could be either from fnd_user or ad hoc role
    l_requester_role_name varchar2(320);
    l_external_email varchar2(2000);
    l_internal_email varchar2(240);
    l_role_desc varchar2(500);
    l_role_desc2 varchar2(500);
    l_email varchar2(500);

    l_ext_users varchar2(1000);
    l_ext_contact_error varchar2(1);
    l_subject_text varchar2(200);
    l_error_msg varchar2(4000);
    l_ui_region varchar2(1000);

    l_header_function_name varchar2(2000);

    l_api_name         CONSTANT VARCHAR2(30) := 'deliverables_notifier';
    l_sql_string varchar2(1000);
    l_doc_class varchar2(30);
    l_external_function_name varchar2(50);

    l_external_is_fyi VARCHAR2(1) := 'N';
    l_internal_only VARCHAR2(1) := 'N';

    CURSOR BUSDOC_TYPE IS
    SELECT tl.name,b.document_type_class,
    b.external_userlist_proc,b.notification_header_function
    FROM okc_bus_doc_types_b b, okc_bus_doc_types_tl tl
    WHERE b.document_type = tl.document_type
    AND   tl.language = userenv('LANG')
    AND   b.document_type = p_business_document_type;
    busdoc_type_rec  busdoc_type%ROWTYPE;

    -- Bug # 4292616 FND_USER.CUSTOMER_ID TO STORE RELATIONSHIP_PARTY_ID
    -- Bug # 5149752 replaced user_name with user_id
    cursor ext_user is
    select user_id
    from fnd_user
    where person_party_id=p_external_contact;

    -- updated cursor for bug#4069955
    CURSOR delTypeInternalFlag is
    select delType.internal_flag
    from okc_deliverable_types_b delType,
    okc_bus_doc_types_b docType,
    okc_del_bus_doc_combxns delComb
    where delType.deliverable_type_code = p_deliverable_type
    and docType.document_type = p_business_document_type
    and docType.document_type_class = delComb.document_type_class
    and delType.deliverable_type_code = delComb.deliverable_type_code;

    l_internal_deliverable_type varchar2(1) :='N';

    CURSOR getRespPartyCode IS
    select resp_party_code
    from
    okc_resp_parties_b delrsp
   ,okc_bus_doc_types_b docType
    where delrsp.resp_party_code = p_resp_party
    and doctype.document_type = p_business_document_type
    and delrsp.document_type_class = docType.document_type_class
    and delrsp.intent = docType.intent;

    l_resp_party_code VARCHAR2(30);

    CURSOR del_cur IS
    select external_party_id, external_party_role
    from okc_deliverables
    where deliverable_id = p_deliverable_id;
    del_rec  del_cur%ROWTYPE;
    l_external_party_id  okc_deliverables.external_party_id%TYPE;
    l_external_party_role  okc_deliverables.external_party_role%TYPE;
    l_id_for_email NUMBER;

    --bug#4145213
    CURSOR getRelationId IS
    select relation.party_id party_id
    from hz_parties relation
    ,hz_parties person
    ,hz_relationships hz
    where relation.party_id = hz.party_id
    and person.party_id = hz.subject_id
    and hz.subject_type = 'PERSON'
    and hz.object_type = 'ORGANIZATION'
    and hz.subject_table_name ='HZ_PARTIES'
    and hz.object_table_name ='HZ_PARTIES'
    and person.party_id = p_external_contact;

    CURSOR ext_user_email(x NUMBER) IS
    SELECT hc.email_address
    FROM hz_contact_points  hc
    WHERE hc.owner_table_name = 'HZ_PARTIES'
    AND   hc.primary_flag = 'Y'
    AND   hc.contact_point_type = 'EMAIL'
    AND   hc.owner_table_id  = x;

    /*cursor ext_user_email is
    select email_address
    from hz_parties
    where party_id=p_external_contact;*/

    l_int_role_display_name wf_roles.display_name%TYPE;
    l_req_role_display_name wf_roles.display_name%TYPE;
    l_ext_role_display_name wf_roles.display_name%TYPE;
    l_fnd_user_id fnd_user.user_id%TYPE;

    TYPE l_user_email_list       IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
    l_user_tbl             l_user_email_list;

    i PLS_INTEGER := 0;
    j PLS_INTEGER := 0;
    k PLS_INTEGER := 0;
    tmp_email_list VARCHAR2(8000);
    l_user_list    VARCHAR2(4000);

	--Acq Plan Message Cleanup
    l_resolved_msg_name1 VARCHAR2(30);
    l_resolved_msg_name2 VARCHAR2(30);
    l_resolved_msg_name3 VARCHAR2(30);
    l_resolved_msg_name4 VARCHAR2(30);
    l_resolved_msg_name5 VARCHAR2(30);
    l_resolved_msg_name6 VARCHAR2(30);
    l_resolved_msg_name7 VARCHAR2(30);
    l_resolved_msg_name8 VARCHAR2(30);
    l_resolved_msg_name VARCHAR2(30);

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entering deliverables_notifier');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Notification type - '||p_msg_code);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'102: Deliverable id - '||p_deliverable_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'103: ExtContactId - '||p_external_contact);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: IntContactId - '||p_internal_contact);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'105: BusDocId:'||p_business_document_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'106: BusDocType:'||p_business_document_type);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list=>p_init_msg_list);

    --Get item key from sequence
    select to_char(okc_wf_notify_s1.nextval) into l_item_key from dual;

    --get RESP_PARTY_CODE
    OPEN getRespPartyCode;
      FETCH getRespPartyCode INTO l_resp_party_code;
    CLOSE getRespPartyCode;

    -- populate busdoc type attributes
    OPEN BUSDOC_TYPE;
      FETCH BUSDOC_TYPE INTO busdoc_type_rec;
    IF BUSDOC_TYPE%FOUND THEN
      l_busdoctype_meaning :=  busdoc_type_rec.name;
      l_doc_class :=  busdoc_type_rec.document_type_class;
      l_external_function_name :=  busdoc_type_rec.external_userlist_proc;
      l_header_function_name := busdoc_type_rec.notification_header_function;
    END IF;
    CLOSE BUSDOC_TYPE;

    --Get DeliverableType Internal_flag
    OPEN delTypeInternalFlag;
      FETCH delTypeInternalFlag into l_internal_deliverable_type;
    IF delTypeInternalFlag%NOTFOUND then
      l_internal_deliverable_type := 'N';
    END IF;
    CLOSE delTypeInternalFlag;

    /*--Repository Changes: Deliverable Type Internal flag obtained now from above cursor--
      --check if we need to send to supplier
      IF instr(p_deliverable_type,'INTERNAL')<>0 then
        l_internal_deliverable_type := 'Y';
      END IF; --internal deliv type
    ------------------------------------------------------------------------------------*/
l_resolved_msg_name1 := OKC_API.resolve_message('OKC_DEL_ESCALATE_NTF_SUBJECT',p_business_document_type);
l_resolved_msg_name2 := OKC_API.resolve_message('OKC_DEL_BEFOREDUE_NTF_SUBJECT',p_business_document_type);

  IF l_internal_deliverable_type = 'Y' OR
     --p_msg_code = 'OKC_DEL_ESCALATE_NTF_SUBJECT' OR
    -- (p_msg_code = 'OKC_DEL_BEFOREDUE_NTF_SUBJECT' and l_resp_party_code = 'INTERNAL_ORG') then
    p_msg_code = 'OKC_DEL_ESCALATE_NTF_SUBJECT' OR p_msg_code = l_resolved_msg_name1 or
     ((p_msg_code = 'OKC_DEL_BEFOREDUE_NTF_SUBJECT' OR p_msg_code = l_resolved_msg_name2) and l_resp_party_code = 'INTERNAL_ORG') then
    l_internal_only := 'Y';
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'107: Send to internal users only: '||l_internal_only);
  END IF;

  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_COMPLETE_NTF_SUBJECT',p_business_document_type);
  l_resolved_msg_name6 := OKC_API.resolve_message('OKC_DEL_CANCEL_NTF_SUBJECT',p_business_document_type);
  l_resolved_msg_name7 := OKC_API.resolve_message('OKC_DEL_FAILED_NTF_SUBJECT',p_business_document_type);
  l_resolved_msg_name8 := OKC_API.resolve_message('OKC_DEL_SUBMIT_NTF_SUBJECT',p_business_document_type);

  --check if supplier gets FYI (he cant respond)
  IF l_internal_only = 'N' and
   (p_msg_code = 'OKC_DEL_COMPLETE_NTF_SUBJECT' OR
    p_msg_code = l_resolved_msg_name OR
    --p_msg_code = 'OKC_DEL_CANCEL_NTF_SUBJECT' OR
    p_msg_code = 'OKC_DEL_CANCEL_NTF_SUBJECT' OR  p_msg_code = l_resolved_msg_name6 or
    --p_msg_code = 'OKC_DEL_FAILED_NTF_SUBJECT' OR
    p_msg_code = 'OKC_DEL_FAILED_NTF_SUBJECT' OR p_msg_code = l_resolved_msg_name7 or
--    p_msg_code = 'OKC_DEL_SUBMIT_NTF_SUBJECT') then
    p_msg_code = 'OKC_DEL_SUBMIT_NTF_SUBJECT' OR p_msg_code = l_resolved_msg_name8) then
    l_external_is_fyi := 'Y';
  END IF;

  --Find the rolenames for the internal and external user whether they be adhoc or fnd_users
  --only need to process external user in some cases
  IF l_internal_only='N' then

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Start, Role name for External contact ');
    END IF;

    -- if external contact found on Deliverable
    IF p_external_contact IS NOT NULL THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'109: Found External contact on Deliverable = '||p_external_contact);
      END IF;

      -- find user id for the given external contact
      OPEN ext_user;
        FETCH ext_user into l_fnd_user_id;
      CLOSE ext_user;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'110: External contact IS A FND USER = '||l_fnd_user_id);
      END IF;

      IF l_fnd_user_id IS NOT NULL THEN

        -- fetch wf role name and display name
        WF_DIRECTORY.GetUserName (p_orig_system => 'FND_USR',
                                  p_orig_system_id => l_fnd_user_id,
                                  p_name => l_external_role_name,
                                  p_display_name => l_ext_role_display_name);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'111: External Role Name = '||l_external_role_name);
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'112: External Role Display Name = '||l_ext_role_display_name);
        END IF;

      ELSE

        -- fetch wf role name and display name, when contact is not registered as FND_USER
        WF_DIRECTORY.GetUserName (p_orig_system => 'HZ_PARTY',
                                  p_orig_system_id => p_external_contact,
                                  p_name => l_external_role_name,
                                  p_display_name => l_ext_role_display_name);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'113: External Role Name = '||l_external_role_name);
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'114: External Role Display Name = '||l_ext_role_display_name);
        END IF;

      END IF; --IF l_fnd_user_id IS NOT NULL

    ELSIF (p_external_contact IS NULL AND  l_external_function_name is not null) THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'115: External Contact is NULL, External List Function = '||l_external_function_name);
      END IF;

      -- fetch party contact and party role from Deliverable
      OPEN del_cur;
        FETCH del_cur INTO del_rec;
        l_external_party_id := del_rec.external_party_id;
        l_external_party_role := del_rec.external_party_role;
      CLOSE del_cur;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'116: External Party Id = '||l_external_party_id);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'117: External Party Role = '||l_external_party_role);
      END IF;

      Begin--start procedure execution to get userlist

        IF l_doc_class = 'REPOSITORY' THEN
          l_sql_string := 'begin '||l_external_function_name|| '(p_api_version=>:p_api_version
                , p_init_msg_list=>:p_init_msg_list, p_document_id=>:p_document_id
                , p_document_type=>:p_document_type, p_external_party_id => :p_external_party_id
                , p_external_party_role => :p_external_party_role
                , x_return_status=>:x_return_status, x_msg_count=>:x_msg_count
                , x_msg_data=>:x_msg_data, x_external_userlist=>:x_external_userlist); end;';

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'118: Calling RESPOSITORY FUNCTION');
          END IF;

	  EXECUTE IMMEDIATE l_sql_string using
                  in p_api_version,
                  in p_init_msg_list,
		  in p_business_document_id,
		  in p_business_document_type,
                  in l_external_party_id,
                  in l_external_party_role,
		  out x_return_status,
		  out x_msg_count,
		  out x_msg_data,
		  out l_ext_users;

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'119: DONE RESPOSITORY FUNCTION, with list = '||l_ext_users);
          END IF;

        ELSE -- if class is not REPOSITORY

          l_sql_string := 'begin '||l_external_function_name||'(p_api_version=>:p_api_version,
            p_document_id=>:p_document_id,
            p_document_type=>:p_document_type,
            p_external_contact_id => :p_external_contact_id,
            x_return_status=>:x_return_status,
            x_msg_count=>:x_msg_count,
            x_msg_data=>:x_msg_data,
            x_external_userlist=>:x_external_userlist); end;';

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'120: Calling OTHER DOC FUNCTION');
          END IF;

          EXECUTE IMMEDIATE l_sql_string using
                in p_api_version,
                in p_business_document_id,
                in p_business_document_type,
                in p_external_contact,
                out x_return_status,
                out x_msg_count,
                out x_msg_data,
                out l_ext_users;

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'121: DONE OTHER DOC FUNCTION, with list = '||l_ext_users);
          END IF;

        END IF; -- IF l_doc_class = 'REPOSITORY'

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'122: Got External Users list = '||l_ext_users);
        END IF;

        IF x_return_status <>  G_RET_STS_SUCCESS OR l_ext_users IS NULL then
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'123: ERROR finding External Users List');
          END IF;
          l_ext_contact_error :='Y';

          Okc_Api.Set_Message(p_app_name=>G_APP_NAME,
                              p_msg_name=>'OKC_DEL_NTF_EXT_USER_NOT_FOUND',
			      p_token1  => 'BUSDOCTYPE',
                	      p_token1_value => l_busdoctype_meaning,
			      p_token2  => 'BUSDOCNUM',
	            	      p_token2_value => p_business_document_number);
          x_return_status := G_RET_STS_ERROR;

        ELSE

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'124: Create Adhoc Role');
          END IF;

          IF l_doc_class = 'REPOSITORY' THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'125: For REPOSITORY, create adhoc role using list of users Email addresses');
            END IF;

            -- copy list of email addresses to temp list
            tmp_email_list := l_ext_users;
            LOOP
              i := INSTR(tmp_email_list,',');
              IF i > 0 THEN
                -- comma found
                l_user_tbl(j) := SUBSTR(tmp_email_list,1,i-1);
                tmp_email_list := SUBSTR(tmp_email_list,i+1, length(tmp_email_list) - i);
                j := j + 1;
              ELSE
                -- no comma found i.e last contract id
                l_user_tbl(j) := tmp_email_list;
                EXIT;
              END IF;
            END LOOP;
            -- for each email create a adhoc user
            FOR k IN NVL(l_user_tbl.FIRST,0)..NVL(l_user_tbl.LAST,-1)
              LOOP
                l_external_role_name := '';
                BEGIN
                  WF_DIRECTORY.CreateAdHocUser(
                    name                    => l_external_role_name,
                    display_name            => l_external_role_name,
                    language                => null,
                    territory               => null,
                    description             => 'Deliverables Ad hoc user',
                    notification_preference => 'MAILHTML',
                    email_address           => l_user_tbl(k),
                    status                  => 'ACTIVE',
                    expiration_date         => SYSDATE+1 ,
                    parent_orig_system      => null,
                    parent_orig_system_id   => null);
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'127: Role Name = '||l_external_role_name);
                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'128: Role Display Name = '||l_ext_role_display_name);
                    END IF;
                    -- build concatinated list of user name for adhoc role
                    l_user_list := l_user_list||','||l_external_role_name;
               EXCEPTION
               WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('OKC', 'OKC_CREATE_ADHOC_USER_FAILED');
                FND_MESSAGE.set_token('USER_NAME',l_user_tbl(k));
                FND_MESSAGE.set_token('SQL_ERROR',SQLERRM);
                FND_MSG_PUB.add;
                RAISE FND_API.G_EXC_ERROR;
              END;
            END LOOP;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'128a: Concantenated List of Adhoc users = '||l_user_list);
            END IF;

            -- call wf api to create the adhoc role
            BEGIN
              l_external_role_name := '';
              l_ext_role_display_name := '';
              Wf_Directory.CreateAdHocRole
              (
               role_name               => l_external_role_name,
               role_display_name       => l_ext_role_display_name,
               language                => null,
               territory               => null,
               role_description        => 'Deliverables Ad hoc role',
               notification_preference => 'MAILHTML',
               role_users              => l_user_list,
               status                  => 'ACTIVE',
               expiration_date         => SYSDATE+1,
               parent_orig_system      => null,
               parent_orig_system_id   => null,
               owner_tag               => null
              );
            EXCEPTION
              WHEN OTHERS THEN
                  FND_MESSAGE.SET_NAME('OKC','OKC_CREATE_ADHOC_ROLE_FAILED');
                  FND_MESSAGE.set_token('ROLE_NAME',l_external_role_name);
                  FND_MESSAGE.set_token('SQL_ERROR',SQLERRM);
                  FND_MSG_PUB.add;
                  RAISE FND_API.G_EXC_ERROR;
            END;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'128b: DONE adhoc role creation');
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'128c: Role Name = '||l_external_role_name);
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'128d: Role Display Name = '||l_ext_role_display_name);
            END IF;

          ELSIF (instr(l_ext_users,',')=0) THEN
            /* only 1 user, no need to create role */
            l_external_role_name := l_ext_users;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'129: NOT REPOSITORY CLASS and got only 1 User from the List = '||l_external_role_name);
            END IF;
          ELSE
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'130: NOT REPOSITORY CLASS and got multiple Users');
            END IF;

           BEGIN
              l_external_role_name := '';
              l_ext_role_display_name := '';

            /* create the ad hoc role using the users obtained from the userlist procedure */
            WF_DIRECTORY.createAdHocRole(role_name             =>l_external_role_name,
	                               role_display_name       =>l_ext_role_display_name,
                                       language                =>null,
                                       territory               =>null,
                                       role_description        =>'Deliverables Ad hoc role',
                                       notification_preference =>'MAILHTML',
                                       role_users              =>l_ext_users,
                                       status                  => 'ACTIVE',
                                       expiration_date         => SYSDATE+1,
                                       parent_orig_system      => null,
                                       parent_orig_system_id   => null,
                                       owner_tag               => null);

            EXCEPTION
              WHEN OTHERS THEN
                  FND_MESSAGE.SET_NAME('OKC','OKC_CREATE_ADHOC_ROLE_FAILED');
                  FND_MESSAGE.set_token('ROLE_NAME',l_external_role_name);
                  FND_MESSAGE.set_token('SQL_ERROR',SQLERRM);
                  FND_MSG_PUB.add;
                  RAISE FND_API.G_EXC_ERROR;
            END;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'131: DONE adhoc role creation');
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'132: Role Name = '||l_external_role_name);
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'133: Role Display Name = '||l_ext_role_display_name);
            END IF;

          END IF; -- IF l_doc_class = 'REPOSITORY'
        END IF; --IF x_return_status <>  G_RET_STS_SUCCESS OR l_ext_users IS NULL
      End;--End of procedure execution to get userlist

    ELSIF (p_external_contact IS NULL AND  l_external_function_name is null) THEN
      l_ext_contact_error :='Y';

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'134: External Contact and External List Function BOTH are NULL, Error = '||l_ext_contact_error);
      END IF;

      Okc_Api.Set_Message(p_app_name=>G_APP_NAME,
                          p_msg_name=>'OKC_DEL_NTF_EXT_USER_NOT_FOUND',
                          p_token1       => 'BUSDOCTYPE',
                          p_token1_value => l_busdoctype_meaning,
                          p_token2       => 'BUSDOCNUM',
                          p_token2_value => p_business_document_number);
      x_return_status := G_RET_STS_ERROR;

    END IF; -- p_external_contact IS NULL AND  l_external_function_name is not null

  END IF; -- l_internal_only = N end process external user check

  -- Now Create Internal Roles
  l_internal_role_name := get_internal_user_role(p_internal_contact, l_int_role_display_name);
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'135: Internal Contact Role Name = '||l_internal_role_name);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'136: Internal Contact Role Display Name = '||l_int_role_display_name);
  END IF;

  IF l_internal_role_name IS NULL THEN
    Okc_Api.Set_Message(G_APP_NAME,'OKC_DEL_NTF_INT_USER_NO_EMAIL');
    x_return_status := G_RET_STS_ERROR;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'137: Invalid Internal contact Id (no email), raising error');
    END IF;

    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF; --end internal user not found

  l_requester_role_name := get_internal_user_role(p_requester_id, l_req_role_display_name);
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'138: Requestor Contact Role Name = '||l_requester_role_name);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'139: Requestor Contact Role Display Name = '||l_req_role_display_name);
  END IF;


				  --Acq Plan Message Cleanup
                  l_resolved_msg_name1 := OKC_API.resolve_message('OKC_DEL_OVERDUE_NTF_SUBJECT',p_business_document_type);
                  l_resolved_msg_name2 := OKC_API.resolve_message('OKC_DEL_BEFOREDUE_NTF_SUBJECT',p_business_document_type);
                  l_resolved_msg_name3 := OKC_API.resolve_message('OKC_DEL_ESCALATE_NTF_SUBJECT',p_business_document_type);
                  l_resolved_msg_name4 := OKC_API.resolve_message('OKC_DEL_REOPEN_NTF_SUBJECT',p_business_document_type);
                  l_resolved_msg_name5 := OKC_API.resolve_message('OKC_DEL_REJECT_NTF_SUBJECT',p_business_document_type);

   --Logic to determine which workflow process to choose
   if l_internal_deliverable_type = 'Y' OR l_ext_contact_error = 'Y' OR
    --  p_msg_code = 'OKC_DEL_ESCALATE_NTF_SUBJECT' then
      p_msg_code = 'OKC_DEL_ESCALATE_NTF_SUBJECT' OR p_msg_code = l_resolved_msg_name3 then
     --Internal Deliverables and  missing ext contacts
     l_process_name := 'OKCDELNOTIFYINTERNAL';
   --elsif ((p_msg_code='OKC_DEL_REOPEN_NTF_SUBJECT' or
   elsif ((p_msg_code='OKC_DEL_REOPEN_NTF_SUBJECT' OR  p_msg_code = l_resolved_msg_name4 OR
	--p_msg_code='OKC_DEL_REJECT_NTF_SUBJECT' OR
  p_msg_code='OKC_DEL_REJECT_NTF_SUBJECT' OR p_msg_code = l_resolved_msg_name5 or
--Acq Plan Messages Cleanup
	--p_msg_code='OKC_DEL_OVERDUE_NTF_SUBJECT') and
  p_msg_code='OKC_DEL_OVERDUE_NTF_SUBJECT' OR p_msg_code = l_resolved_msg_name1 ) and
	l_resp_party_code <> 'INTERNAL_ORG') then
     --Deliverables where external user can submit thru notification
     l_process_name :='OKCDELNOTIFYBOTH';
   --elsif (p_msg_code='OKC_DEL_BEFOREDUE_NTF_SUBJECT') then
   elsif (p_msg_code='OKC_DEL_BEFOREDUE_NTF_SUBJECT' OR p_msg_code=l_resolved_msg_name2) then
     --Only responsible party
     l_process_name :='OKCDELNOTIFYRESPPARTY';
   else
     --FYI to all parties
     l_process_name := 'OKCDELNOTIFYFYI';
   end if;

   --Create the process
   wf_engine.CreateProcess(itemtype => l_item_type,
		   	   itemkey  => l_item_key,
                           process  => l_process_name);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'140: Creating process:'||l_item_type||':'
      ||l_item_key||':'||l_process_name);
   END IF;

   wf_engine.SetItemUserKey (itemtype => l_item_type,
			     itemkey  => l_item_key,
                             userkey  => l_item_key);
   wf_engine.SetItemOwner (itemtype => l_item_type,
                           itemkey  => l_item_key,
                           owner    => fnd_global.user_name);
  -- Set global attributes
  wf_engine.SetItemAttrNumber (itemtype	=> l_item_type,
                               itemkey 	=> l_item_key,
                               aname 	=> 'OKCDELID',
                               avalue	=> p_deliverable_id);

  wf_engine.SetItemAttrText (itemtype  => l_item_type,
                             itemkey   => l_item_key,
                             aname     => 'OKCDELINTUSERROLE',
                             avalue    => l_internal_role_name);

  wf_engine.SetItemAttrText (itemtype 	=> l_item_type,
                             itemkey 	=> l_item_key,
                             aname 	=> 'OKCDELSUBJECT',
                             avalue	=> p_msg_code||':'||p_deliverable_id);

  IF l_requester_role_name IS NOT NULL THEN
    wf_engine.SetItemAttrText (itemtype => l_item_type,
                               itemkey 	=> l_item_key,
                               aname 	=> 'OKCDELREQUESTOR',
                               avalue	=> l_requester_role_name);

    wf_engine.SetItemAttrText (itemtype => l_item_type,
                               itemkey 	=> l_item_key,
                               aname 	=> 'OKCDELREQUESTEREXISTS',
                               avalue	=> 'Y');
  END IF;

  wf_engine.SetItemAttrText (itemtype 	=> l_item_type,
                             itemkey 	=> l_item_key,
                             aname 	=> 'OKCDELEXTUSERROLE',
                             avalue	=> l_external_role_name);

    l_ui_region := 'JSP:/OA_HTML/OA.jsp?OAFunc=OKC_DEL_NOTIF_EMBEDDED_RN&BUSDOCCONTEXT_REGION_PATH='
    ||l_header_function_name||'&documentHeaderId='
    ||p_business_document_id||'&OKC_DOCUMENT_TYPE='||p_business_document_type
    ||'&OKC_DOC_VER_NUM='||p_business_document_version
    ||'&_MANAGE_MODE=Y&_UPDATE_STATUS_MODE=N&_HIDE_NTF=Y&OKC_DEL_HIDE_ATTACHMENTS=Y&OKC_DEL_HIDE_STATUS_DISC=Y&_FLEX_DISPLAY=N&_DELIVERABLE_ID='||p_deliverable_id||'&OKC_DEL_NO_ENCRYPT=Y';
    wf_engine.SetItemAttrText (itemtype 	=> l_item_type,
				itemkey 	=> l_item_key,
  	      			aname 	=> 'OKCDELBUSDOCDETAILSRN',
				avalue	=> l_ui_region);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'141: Setting workflow attributes.');
  END IF;

  wf_engine.SetItemAttrText (itemtype 	=> l_item_type,
                             itemkey 	=> l_item_key,
                             aname 	=> 'FROMROLE',
                             avalue	=> l_internal_role_name);

  wf_engine.SetItemAttrText (itemtype 	=> l_item_type,
                             itemkey 	=> l_item_key,
                             aname 	=> 'OKCDELRESPPARTY',
                             avalue	=> l_resp_party_code);

  wf_engine.StartProcess(itemtype 	=> l_item_type,
                         itemkey 	=> l_item_key);

  --Even though we've sent notifications already, if there was an error with the external contact, we want to send an error notification.
  IF l_ext_contact_error = 'Y' THEN
   RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'142: Subject of notification:'||fnd_message.get);
  END IF;

  --logic to get the notification id for the OUT parameter
  IF l_internal_only = 'Y' THEN
    x_notification_id:=wf_engine.GetItemAttrNumber (itemtype => l_item_type,
                                                    itemkey  => l_item_key,
                                                    aname    =>'OKCDELINTNOTIFID');
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'143:  Notification ID is for internal user:'||x_notification_id);
    END IF;

  ELSE
    IF l_external_is_fyi = 'Y' THEN
      x_notification_id:=wf_engine.GetItemAttrNumber (itemtype 	=> l_item_type,
                                                      itemkey 	=> l_item_key,
                                                      aname 	=> 'OKCDELEXTNOTIFID');
    ELSE
      select notification_id into x_notification_id from wf_item_activity_statuses
      where item_type = l_item_type and
      item_key = l_item_key and
      assigned_user = l_external_role_name;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'144: Getting Notification ID for ext user from attribute:'
        ||x_notification_id);
    END IF;
  END IF; --end internal notifications

  IF x_notification_id IS NOT NULL THEN
    x_return_status:= G_RET_STS_SUCCESS;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Returning notification Id: '||to_char(x_notification_id));
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Notifier returning status: '||x_return_status);
  ELSE
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'145: null notification ID');
    END IF;
  END IF; --end check notification id

  EXCEPTION
    WHEN OTHERS THEN
        If delTypeInternalFlag%ISOPEN then
	     CLOSE delTypeInternalFlag;
	   End If;
	   If getRespPartyCode%ISOPEN then
	     CLOSE getRespPartyCode;
	   End If;
	   If BUSDOC_TYPE%ISOPEN then
	     CLOSE BUSDOC_TYPE;
	   End If;
	   If del_cur%ISOPEN then
	     CLOSE del_cur;
	   End If;
	   If ext_user%ISOPEN then
	     CLOSE ext_user;
	   End If;
	   If ext_user_email%ISOPEN then
	     CLOSE ext_user_email;
	   End If;

        FND_MSG_PUB.Count_And_Get(p_encoded=>'F'
                                , p_count => x_msg_count
		                , p_data  => x_msg_data );

      	FND_FILE.PUT_LINE(FND_FILE.LOG,'Error message count: '||to_char(x_msg_count));

	FOR i IN 1..x_msg_count LOOP
      FND_FILE.PUT_LINE(FND_FILE.LOG,
	    'Error message number '||i||': '||FND_MSG_PUB.get(p_msg_index => i,p_encoded => 'F'));
    END LOOP;

	if x_msg_count > 1 then
	  x_msg_data := substr(FND_MSG_PUB.get(p_msg_index => x_msg_count,
					       p_encoded => 'F'),1,250);

	  x_msg_count := 1;
  	end if;

	l_error_msg := x_msg_data;

      -- send notification to the logged in user that workflow notification
      -- could not be sent
      x_notification_id := WF_NOTIFICATION.Send(role => fnd_global.user_name,
			    msg_type => 'OKCDELWF',
			    msg_name => 'OKCDELFAILEDTOSENDMSG');
      WF_NOTIFICATION.SetAttrText(nid=>x_notification_id,
				  aname=>'DELIVERABLENAME',
				  avalue=>p_deliverable_name);
      WF_NOTIFICATION.SetAttrText(nid=>x_notification_id,
				  aname=>'SUBJECT',
				  avalue=>l_subject_text);
      WF_NOTIFICATION.SetAttrText(nid=>x_notification_id,
				  aname=>'ERRORMSG',
				  avalue=>l_error_msg);
      WF_NOTIFICATION.SetAttrText(nid=>x_notification_id,
				  aname=>'#FROM_ROLE',
				  avalue=> fnd_global.user_name);

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error notification Id: '||to_char(x_notification_id));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Notifier returning status: '||x_return_status);

        x_return_status := G_RET_STS_UNEXP_ERROR ;

        /* commented to avoid display problem in OA page if there are more than
        one message in the stack.
        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
        END IF;*/
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module,'700: Leaving Deliverable Notifier with  G_RET_STS_UNEXP_ERROR');
      END IF;

END deliverables_notifier;


-------------------------------------------------------------------------------
--Start of Comments
--Name: set_int_notif_id
--Function:
--  This function determines sets a workflow attribute for either internal user the notification id of the notification that was just sent.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

procedure  set_int_notif_id  (itemtype in varchar2,
                                        itemkey in varchar2,
                                        actid in number,
                                        funcmode in varchar2,
                                        resultout out nocopy varchar2 )

IS
l_requestor VARCHAR2(100);
l_internal_role_name VARCHAR2(100);

BEGIN

if ( funcmode = 'RUN' ) then

      --Store the internal users nid in case we need to return it
        wf_engine.SetItemAttrNumber (itemtype 	=> itemtype,
				 	         itemkey 	=> itemkey,
          	      			 aname 	=> 'OKCDELINTNOTIFID',
       					     avalue	=> wf_Engine.g_nid);

resultout:='COMPLETE';
return;
end if;


if ( funcmode = 'CANCEL' ) then

resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('OKCDELWF', 'set_notif_id', itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';
raise;



end set_int_notif_id;

-------------------------------------------------------------------------------
--Start of Comments
--Name: set_ext_notif_id
--Function:
--  This function determines sets a workflow attribute for the external user the notification id of the notification that was just sent.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

procedure  set_ext_notif_id  (itemtype in varchar2,
                                        itemkey in varchar2,
                                        actid in number,
                                        funcmode in varchar2,
                                        resultout out nocopy varchar2 )

IS

BEGIN

if ( funcmode = 'RUN' ) then

      --Store the internal users nid in case we need to return it
        wf_engine.SetItemAttrNumber (itemtype 	=> itemtype,
				 	         itemkey 	=> itemkey,
          	      			 aname 	=> 'OKCDELEXTNOTIFID',
       					     avalue	=> wf_Engine.g_nid);

resultout:='COMPLETE';
return;
end if;


if ( funcmode = 'CANCEL' ) then

resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('OKCDELWF', 'set_ext_notif_id', itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';
raise;

end set_ext_notif_id;


-------------------------------------------------------------------------------
--Start of Comments
--Name: update_status
--Function:
--  This function is called after an external user clicks the 'SUBMIT DELIVERABLE'
--  button on a notification.  The function updates that deliverable's status to SUBMITTED,
-- and creates an entry in the status history table.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

procedure  update_status  (itemtype in varchar2,
                                        itemkey in varchar2,
                                        actid in number,
                                        funcmode in varchar2,
                                        resultout out nocopy varchar2 )


IS
l_old_status VARCHAR2(100);
l_notes VARCHAR2(2000);
l_deliverable_id NUMBER;
l_new_status VARCHAR2(100);
l_temp VARCHAR2(1);


cursor update_allowed is
select 'X' -- removed into l_temp for 8174 compatability bug#3288934
from okc_deliverables d,okc_del_status_combxns s where
d.deliverable_id=l_deliverable_id and
s.current_status_code=d.deliverable_status and
s.allowable_status_code=l_new_status and
s.status_changed_by='EXTERNAL' and
d.manage_yn = 'Y'; --from bug 3696869

BEGIN

l_notes := wf_engine.GetItemAttrText (itemtype 	=> itemtype,
				 	         itemkey 	=> itemkey,
  	      			       	 aname 	=> 'NOTES2',ignore_notfound=>true);

l_deliverable_id :=  wf_engine.GetItemAttrNumber (itemtype 	=> itemtype,
				 	         itemkey 	=> itemkey,
          	      			 aname 	=> 'OKCDELID');

l_new_status := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'RESULT');

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module,'100: Entering update status for deliverable id:'||l_deliverable_id);
   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module,'100: New status will be:'||l_new_status);

 end if;


if l_new_status IS NOT NULL then

    open update_allowed;
    fetch update_allowed into l_temp;
        if update_allowed%NOTFOUND then
            resultout:='COMPLETE';
             IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module,'200: Update is not allow from current status to '
               ||l_new_status||' by external user.  Exitting');
             end if;

        else
            update okc_deliverables set deliverable_status = l_new_status, status_change_notes=l_notes
            where deliverable_id = l_deliverable_id;

            insert into okc_del_status_history(deliverable_id,
                                    deliverable_status,
                                    status_change_date,
                                    status_change_notes,
                                    object_version_number,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
	                            last_update_date,
                                    last_update_login,
				    status_changed_by)
                                    values (l_deliverable_id,
                                            l_new_status,
                                            sysdate,
                                            l_notes,
                                            1,
                                            fnd_global.user_id,
                                            sysdate,
                                	    fnd_global.user_id,
                                            sysdate,
                                            fnd_global.login_id,
 					    fnd_global.user_id);
             IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module,'200: Deliverable updated and row inserted into status history');
             end if;


        end if; -- end updating status
      close update_allowed;
end if;

if ( funcmode = 'RUN' ) then

resultout:='COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then

resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then

resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('OKCDELWF', 'update_status', itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';
raise;

end update_status;



-------------------------------------------------------------------------------
--Start of Comments
--Name: send_notification_bus_event
--Function:
--  This function is called from an business event subscription.  The two parameters are DELIVERABLE_ID and MSG_CODE.  It will query all the rest of the required info and call deliverables_notifier.
--  It will set the sent notification's id in the OKC_DELIVERABLES table
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

function send_notification_bus_event (p_subscription_guid in raw,
                                      p_event in out nocopy WF_EVENT_T) return varchar2 is



  l_deliverable_id NUMBER;
  l_msg_code VARCHAR2(30);
  l_notification_id NUMBER;
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;
  l_return_status VARCHAR2(1);
  l_event_status VARCHAR2(10);

    CURSOR del_cur IS
    SELECT *
    FROM okc_deliverables
    where deliverable_id = l_deliverable_id;

  l_del_rec  del_cur%ROWTYPE;


begin

  l_deliverable_id := p_event.GetValueForParameter('DELIVERABLE_ID');
  l_msg_code := p_event.GetValueForParameter('MSG_CODE');

  open del_cur;
  fetch del_cur into l_del_rec;
  close del_cur;

  okc_deliverable_wf_pvt.deliverables_notifier(
            p_api_version               => 1.0,
            p_init_msg_list             => FND_API.G_TRUE,
            p_deliverable_id            => l_del_rec.deliverable_id,
            p_deliverable_name          => l_del_rec.deliverable_name,
            p_deliverable_type          => l_del_rec.deliverable_type,
            p_business_document_id      => l_del_rec.business_document_id,
            p_business_document_version => l_del_rec.business_document_version,
            p_business_document_type    => l_del_rec.business_document_type,
            p_business_document_number  => l_del_rec.business_document_number,
            p_resp_party                => l_del_rec.responsible_party,
            p_external_contact          => l_del_rec.external_party_contact_id,
            p_internal_contact          => l_del_rec.internal_party_contact_id,
            p_requester_id              => l_del_rec.requester_id,
            p_msg_code                  => l_msg_code,
            x_notification_id           => l_notification_id,
            x_msg_data                  => l_msg_data,
            x_msg_count                 => l_msg_count,
            x_return_status             => l_return_status);

if (l_notification_id IS NOT NULL AND l_return_status = 'S') then
	update okc_deliverables set completed_notification_id = l_notification_id where deliverable_id = l_deliverable_id;
    	l_event_status := 'SUCCESS';
elsif l_notification_id IS NOT NULL then
	l_event_status :='WARNING';
	p_event.setErrorMessage(l_msg_data);
else
	l_event_status := 'ERROR';
	p_event.setErrorMessage(l_msg_data);
end if;
	commit;
return l_event_status;

    exception

         when others then

            WF_CORE.CONTEXT('OKC_DELIVERABLE_WF_PVT', 'send_notification_bus_event',

                            p_event.getEventName( ),
			    p_subscription_guid);

            WF_EVENT.setErrorInfo(p_event, 'ERROR');

            return 'ERROR';

  end send_notification_bus_event;


END OKC_DELIVERABLE_WF_PVT;

/
