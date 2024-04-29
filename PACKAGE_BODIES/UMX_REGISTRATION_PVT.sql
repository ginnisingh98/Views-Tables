--------------------------------------------------------
--  DDL for Package Body UMX_REGISTRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_REGISTRATION_PVT" AS
  /* $Header: UMXVREGB.pls 120.7.12010000.7 2017/11/09 04:30:40 avelu ship $ */

  PROCEDURE populateRegData(p_registration_data IN OUT NOCOPY UMX_REGISTRATION_DATA_TBL,
                            p_reg_request_id    IN NUMBER) IS

    CURSOR FIND_REG_DATA IS
      SELECT REG.REQUESTED_FOR_USER_ID, FU.USER_NAME, FU.PERSON_PARTY_ID,
             REG.STATUS_CODE
      FROM FND_USER FU, UMX_REG_REQUESTS REG
      WHERE REG.REG_REQUEST_ID = p_reg_request_id
      AND   REG.REQUESTED_FOR_USER_ID = FU.USER_ID;

    l_user_id  UMX_REG_REQUESTS.REQUESTED_FOR_USER_ID%TYPE;
    l_user_name FND_USER.USER_NAME%TYPE;
    l_party_id FND_USER.PERSON_PARTY_ID%TYPE;
    l_status_code UMX_REG_REQUESTS.STATUS_CODE%TYPE;
    j NUMBER;
    l_index_to_add NUMBER;

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVREGB.populateRegData.begin',
                     'regRequestId: ' || p_reg_request_id);
    end if;

    OPEN FIND_REG_DATA;
    FETCH FIND_REG_DATA INTO l_user_id, l_user_name, l_party_id, l_status_code;
    CLOSE FIND_REG_DATA;

    j := p_registration_data.FIRST;

    while (j <= p_registration_data.LAST) loop

      if p_registration_data(j).ATTR_NAME = 'requested_for_user_id' then
        p_registration_data(j).ATTR_VALUE := l_user_id;
        l_user_id := null;
      end if;

      if p_registration_data(j).ATTR_NAME = 'requested_username' then
        p_registration_data(j).ATTR_VALUE := l_user_name;
        l_user_name := null;
      end if;

      j := j + 1;

    end loop;

    l_index_to_add := p_registration_data.last;

    if l_user_id is not null then
      l_index_to_add := l_index_to_add + 1;
      p_registration_data(l_index_to_add).ATTR_NAME := 'requested_for_user_id';
      p_registration_data(l_index_to_add).ATTR_VALUE := l_user_id;
    end if;

    if l_user_name is not null then
      l_index_to_add := l_index_to_add + 1;
      p_registration_data(l_index_to_add).ATTR_NAME := 'requested_username';
      p_registration_data(l_index_to_add).ATTR_VALUE := l_user_name;
    end if;

    l_index_to_add := l_index_to_add + 1;
    p_registration_data(l_index_to_add).ATTR_NAME := 'person_party_id';
    p_registration_data(l_index_to_add).ATTR_VALUE := l_party_id;

    l_index_to_add := l_index_to_add + 1;
    p_registration_data(l_index_to_add).ATTR_NAME := 'status_code';
    p_registration_data(l_index_to_add).ATTR_VALUE := l_status_code;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'fnd.plsql.UMXVREGB.populateRegData.end', '');
    end if;

  END populateRegData;

  PROCEDURE DO_PROCESS_REQUEST(p_registration_data  IN OUT NOCOPY UMX_REGISTRATION_DATA_TBL,
 			     x_return_status out NOCOPY varchar2,
 			     x_message_data out NOCOPY varchar2) IS

    l_parameter_list wf_parameter_list_t;
    j number;
    l_item_key varchar2(2000);
    l_requested_by_user_id varchar2(2000);
    l_event_name WF_EVENTS_VL.NAME%type;
    l_reg_service_type UMX_REG_SERVICES_B.REG_SERVICE_TYPE%type;
    l_index_to_add number;

    l_status varchar2(8);
    l_result varchar2(30);
    l_errname varchar2(30);
    l_errmsg varchar2(2000);
    l_errstack varchar2(4000);
    l_actid number;

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVREGB.doProcessRequest.begin', 'start UMXREGWF');
    end if;

    POPULATE_REG_DATA (p_registration_data => p_registration_data);

    j := p_registration_data.FIRST;

    while (j <= p_registration_data.LAST) loop
      --Encrypt the password before starting workflow
      if p_registration_data(j).ATTR_NAME = 'password' then
         p_registration_data(j).ATTR_VALUE := icx_call.encrypt(p_registration_data(j).ATTR_VALUE);
      end if;

       -- Add parameter to the event object only if
      -- the attribute name is not null
      if p_registration_data(j).ATTR_NAME is not null then
        wf_event.addParametertoList(UPPER(p_registration_data(j).ATTR_NAME), p_registration_data(j).ATTR_VALUE,l_parameter_list);
      end if;
      --insert into chirag_test values(p_registration_data(j).ATTR_NAME, p_registration_data(j).ATTR_VALUE);
      if p_registration_data(j).ATTR_NAME = 'reg_service_type' then
        l_reg_service_type := p_registration_data(j).ATTR_VALUE;
      end if;

      if p_registration_data(j).ATTR_NAME = 'reg_request_id' then
        l_item_key :=  p_registration_data(j).ATTR_VALUE;
      end if;

      if p_registration_data(j).ATTR_NAME = 'requested_by_user_id' then
        l_requested_by_user_id := p_registration_data(j).ATTR_VALUE;
      end if;

      j := j + 1;
    end loop;

    if (l_reg_service_type = 'ADDITIONAL_ACCESS') or
       (l_reg_service_type = 'ADMIN_ADDITIONAL_ACCESS') then
      l_event_name := 'oracle.apps.fnd.umx.startaccessrequestwf';
    else
      l_event_name := 'oracle.apps.fnd.umx.startaccountrequestwf';
    end if;

    if l_item_key is null then
      select UMX_REG_REQUESTS_S.nextval into l_item_key from dual;
      l_index_to_add := p_registration_data.last + 1;
      p_registration_data(l_index_to_add).ATTR_NAME := 'reg_request_id';
      p_registration_data(l_index_to_add).ATTR_VALUE := l_item_key;
    end if;

    --if l_requested_by_user_id is null then
    wf_event.addParametertoList('REQUESTED_BY_USER_ID', FND_GLOBAL.USER_ID, l_parameter_list);
    --end if;

    wf_event.addParametertoList('UMX_PARENT_ITEM_TYPE', UMX_REGISTRATION_UTIL.G_ITEM_TYPE, l_parameter_list);
    wf_event.addParametertoList('UMX_PARENT_ITEM_KEY', l_item_key, l_parameter_list);
    if WF_ITEM.ITEM_EXIST('UMXREGWF', L_ITEM_KEY) then
       if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'fnd.plsql.UMXVREGB.doProcessRequest', 'Error: UMXREGWF with the Item Key -' ||L_ITEM_KEY ||' already exists');
       end if;
    else
      WF_EVENT.RAISE(L_EVENT_NAME,L_ITEM_KEY,null,L_PARAMETER_LIST,sysdate);
    end if;
    wf_engine.iteminfo (itemtype => 'UMXREGWF',
                        itemkey  => l_item_key,
                        status   => l_status,
                        result   => l_result,
                        actid    => l_actid,
                        errmsg   => l_errmsg,
                        errname  => l_errname,
                        errstack => l_errstack);

    if (l_status = 'ERROR') then
--      raise_application_error ('-20000',l_errmsg);
      x_return_status := 'E';
      x_message_data := l_errmsg;
    else
      x_return_status := 'S';
      populateRegData(p_registration_data, l_item_key);
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVREGB.doProcessRequest.end', 'end UMXREGWF');
    end if;

  END do_process_request;

  /** Procedure   :  UMX_PROCESS_REG_REQUEST
    * Type        :  Private
    * Pre_reqs    :  None
    * Description :  Invokes Workflow process after registration flow
    *                This API will return an error if the size of the
    *                that WF can accept to raise an event
    * Parameters  :
    * input parameters
    * @param     p_registration_data
    *     description:  This is of type UMX_REGISTRATION_PVT.UMX_REGISTRATION_DATA
    *     required   :  Y
    *     validation :  None
    */
  PROCEDURE UMX_PROCESS_REG_REQUEST (p_registration_data  IN OUT NOCOPY UMX_REGISTRATION_DATA_TBL,
 			     x_return_status out NOCOPY varchar2,
 			     x_message_data out NOCOPY varchar2) IS

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'fnd.plsql.UMXVREGB.umxProcessRegRequest.begin', '');
    end if;

    DO_PROCESS_REQUEST(p_registration_data, x_return_status, x_message_data);


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'fnd.plsql.UMXVREGB.umxProcessRegRequest.end', '');
    end if;

  END UMX_PROCESS_REG_REQUEST;

  function  format_address_lov(p_party_id number) return varchar2 IS

    cursor get_address_info is
      select ADDRESS1, ADDRESS2, ADDRESS3, ADDRESS4, CITY,
             POSTAL_CODE, PROVINCE, STATE, COUNTY, COUNTRY
      from hz_parties
      where party_id = p_party_id;

    l_address1     HZ_PARTIES.ADDRESS1%TYPE;
    l_address2     HZ_PARTIES.ADDRESS2%TYPE;
    l_address3     HZ_PARTIES.ADDRESS3%TYPE;
    l_address4     HZ_PARTIES.ADDRESS4%TYPE;
    l_city         HZ_PARTIES.CITY%TYPE;
    l_postal_code  HZ_PARTIES.POSTAL_CODE%TYPE;
    l_province     HZ_PARTIES.PROVINCE%TYPE;
    l_state        HZ_PARTIES.STATE%TYPE;
    l_county       HZ_PARTIES.COUNTY%TYPE;
    l_country      HZ_PARTIES.COUNTRY%TYPE;

    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             NUMBER;
    l_formatted_address    VARCHAR2(360);

    l_tbl_cnt      NUMBER;
    l_tbl          hz_format_pub.string_tbl_type;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVREGB.formatAddressLov.begin',
                     'partyId: ' || p_party_id);
    end if;

    open get_address_info;
    fetch get_address_info into l_address1, l_address2, l_address3, l_address4,
                                l_city, l_postal_code, l_province, l_state,
                                l_county, l_country;
    close get_address_info;

    IF l_country IS NULL THEN
      RETURN NULL;
    END IF;

    hz_format_pub.format_address (
      p_style_code               => 'POSTAL_ADDR',
      p_line_break               => ', ',
      p_space_replace            => ' ',
      p_address_line_1           => l_address1,
      p_address_line_2           => l_address2,
      p_address_line_3           => l_address3,
      p_address_line_4           => l_address4,
      p_city                     => l_city,
      p_postal_code              => l_postal_code,
      p_state                    => l_state,
      p_province                 => l_province,
      p_county                   => l_county,
      p_country                  => l_country,
      p_address_lines_phonetic   => null,
      -- output parameters
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data,
      x_formatted_address        => l_formatted_address,
      x_formatted_lines_cnt      => l_tbl_cnt,
      x_formatted_address_tbl    => l_tbl);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVREGB.formatAddressLov.end',
                     'formattedAddress: ' || l_formatted_address);
    end if;

    RETURN l_formatted_address;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_formatted_address;

  end format_address_lov;


  function get_event_name (p_event_guid WF_EVENTS.guid%type) return wf_events.name%type is

    CURSOR get_event_name_cursor is
      select name
      from   wf_events
      where  guid = HEXTORAW(p_event_guid);

    x_event_name wf_events.name%type;

  begin
    open get_event_name_cursor;
    fetch get_event_name_cursor into x_event_name;
    close get_event_name_cursor;

    return x_event_name;
  end get_event_name;


  procedure get_req_data_from_req_id (
        p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%type,
        p_reg_service_code in UMX_REG_SERVICES_B.REG_SERVICE_CODE%type,
        x_reg_service_type out nocopy UMX_REG_SERVICES_VL.REG_SERVICE_TYPE%type,
        x_requested_by_user_id out nocopy UMX_REG_REQUESTS.REQUESTED_BY_USER_ID%type,
        x_requested_for_user_id out nocopy UMX_REG_REQUESTS.REQUESTED_FOR_USER_ID%type,
        x_requested_for_party_id out nocopy UMX_REG_REQUESTS.REQUESTED_FOR_PARTY_ID%type,
        x_requested_username out nocopy UMX_REG_REQUESTS.REQUESTED_USERNAME%type,
        x_wf_role_name out nocopy UMX_REG_SERVICES_VL.WF_ROLE_NAME%type,
        x_ame_application_id out nocopy UMX_REG_SERVICES_VL.AME_APPLICATION_ID%type,
        x_ame_transaction_type_id out nocopy UMX_REG_SERVICES_VL.AME_TRANSACTION_TYPE_ID%type,
        x_justification out nocopy UMX_REG_REQUESTS.JUSTIFICATION%type,
        x_wf_notification_event_name out nocopy WF_EVENTS.NAME%type,
        x_email_verification_flag out nocopy UMX_REG_SERVICES_VL.EMAIL_VERIFICATION_FLAG%type,
        x_application_id out nocopy UMX_REG_SERVICES_VL.APPLICATION_ID%type,
        x_reg_function_name out nocopy FND_FORM_FUNCTIONS.FUNCTION_NAME%type,
        x_display_name out nocopy UMX_REG_SERVICES_VL.DISPLAY_NAME%type,
        x_description out nocopy UMX_REG_SERVICES_VL.DESCRIPTION%type,
        x_wf_bus_logic_event_name out nocopy WF_EVENTS.NAME%type) is

    CURSOR get_request_data is
      SELECT regreq.WF_ROLE_NAME, regreq.REG_SERVICE_TYPE, regser.APPLICATION_ID,
             regreq.AME_APPLICATION_ID, regreq.AME_TRANSACTION_TYPE_ID,
             regser.EMAIL_VERIFICATION_FLAG, func.FUNCTION_NAME, regser.DISPLAY_NAME,
             regser.DESCRIPTION, regreq.JUSTIFICATION, regreq.REQUESTED_BY_USER_ID,
             regreq.REQUESTED_FOR_USER_ID, regreq.REQUESTED_FOR_PARTY_ID,
             regreq.REQUESTED_USERNAME, regser.wf_notification_event_guid,
             regser.wf_bus_logic_event_guid
      FROM   UMX_REG_SERVICES_VL regser, fnd_form_functions func,
             UMX_REG_REQUESTS regreq
      WHERE  regser.reg_function_id = func.function_id (+)
      AND    regreq.REG_SERVICE_CODE = regser.REG_SERVICE_CODE
      AND    regreq.reg_request_id = p_reg_request_id;

    l_wf_notification_event_guid wf_events.guid%type;
    l_wf_bus_logic_event_guid wf_events.guid%type;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVREGB.getReqDataFromReqId.begin',
                     'regRequestId: ' || p_reg_request_id ||
                     ' | regServiceCode: ' || p_reg_service_code);
    end if;

    open get_request_data;
    fetch get_request_data into x_wf_role_name, x_reg_service_type, x_application_id,
                                x_ame_application_id, x_ame_transaction_type_id,
                                x_email_verification_flag, x_reg_function_name,
                                x_display_name, x_description, x_justification,
                                x_requested_by_user_id, x_requested_for_user_id,
                                x_requested_for_party_id, x_requested_username,
                                l_wf_notification_event_guid, l_wf_bus_logic_event_guid;
    close get_request_data;

    x_wf_notification_event_name := get_event_name (l_wf_notification_event_guid);
    x_wf_bus_logic_event_name := get_event_name (l_wf_bus_logic_event_guid);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVREGB.getReqDataFromReqId.end',
                     'regServiceType: ' || x_reg_service_type ||
                     ' | requestedByUserId: ' || x_requested_by_user_id ||
                     ' | requestedForUserId: ' || x_requested_for_user_id ||
                     ' | requestedForPartyId: ' || x_requested_for_party_id ||
                     ' | requestedUsername: ' || x_requested_username ||
                     ' | wfRoleName: ' || x_wf_role_name ||
                     ' | ameApplicationId: ' || x_ame_application_id ||
                     ' | ameTransactionTypeId: ' || x_ame_transaction_type_id ||
                     ' | justification: ' || x_justification ||
                     ' | wfNotificationEventName: ' || x_wf_notification_event_name ||
                     ' | emailVerificationFlag: ' || x_email_verification_flag ||
                     ' | applicationId: ' || x_application_id ||
                     ' | regFunctionName: ' || x_reg_function_name ||
                     ' | displayName: ' || x_display_name ||
                     ' | description: ' || x_description ||
                     ' | wfBusLogicEventName: ' || x_wf_bus_logic_event_name);
    end if;

  end get_req_data_from_req_id;


  procedure get_req_data_from_req_sv_code (
        p_reg_service_code in UMX_REG_SERVICES_B.REG_SERVICE_CODE%type,
        x_reg_service_type out nocopy UMX_REG_SERVICES_VL.REG_SERVICE_TYPE%type,
        x_wf_role_name out nocopy UMX_REG_SERVICES_VL.WF_ROLE_NAME%type,
        x_ame_application_id out nocopy UMX_REG_SERVICES_VL.AME_APPLICATION_ID%type,
        x_ame_transaction_type_id out nocopy UMX_REG_SERVICES_VL.AME_TRANSACTION_TYPE_ID%type,
        x_wf_notification_event_name out nocopy WF_EVENTS.NAME%type,
        x_email_verification_flag out nocopy UMX_REG_SERVICES_VL.EMAIL_VERIFICATION_FLAG%type,
        x_application_id out nocopy UMX_REG_SERVICES_VL.APPLICATION_ID%type,
        x_reg_function_name out nocopy FND_FORM_FUNCTIONS.FUNCTION_NAME%type,
        x_display_name out nocopy UMX_REG_SERVICES_VL.DISPLAY_NAME%type,
        x_description out nocopy UMX_REG_SERVICES_VL.DESCRIPTION%type,
        x_wf_bus_logic_event_name out nocopy WF_EVENTS.NAME%type) is

    CURSOR get_req_svc_data IS
      SELECT regser.WF_ROLE_NAME, regser.REG_SERVICE_TYPE, regser.APPLICATION_ID,
             regser.wf_notification_event_guid, regser.AME_APPLICATION_ID,
             regser.AME_TRANSACTION_TYPE_ID, regser.EMAIL_VERIFICATION_FLAG,
             func.FUNCTION_NAME, regser.DISPLAY_NAME, regser.DESCRIPTION,
             regser.wf_bus_logic_event_guid
      FROM   UMX_REG_SERVICES_VL regser, fnd_form_functions func
      WHERE  regser.reg_function_id = func.function_id (+)
      AND    REG_SERVICE_CODE = p_reg_service_code;

    l_wf_notification_event_guid wf_events.guid%type;
    l_wf_bus_logic_event_guid wf_events.guid%type;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVREGB.getReqDataFromReqSvCode.begin',
                     'regServiceCode: ' || p_reg_service_code);
    end if;

    open get_req_svc_data;
    fetch get_req_svc_data into x_wf_role_name, x_reg_service_type, x_application_id,
                                l_wf_notification_event_guid, x_ame_application_id,
                                x_ame_transaction_type_id, x_email_verification_flag,
                                x_reg_function_name, x_display_name, x_description,
                                l_wf_bus_logic_event_guid;
    close get_req_svc_data;

    x_wf_notification_event_name := get_event_name (l_wf_notification_event_guid);
    x_wf_bus_logic_event_name := get_event_name (l_wf_bus_logic_event_guid);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVREGB.getReqDataFromReqSvCode.end',
                      'regServiceType: ' || x_reg_service_type ||
                      ' | wfRoleName: ' || x_wf_role_name ||
                      ' | ameApplicationId: ' || x_ame_application_id ||
                      ' | ameTransactionTypeId: ' || x_ame_transaction_type_id ||
                      ' | wfNotificationEventName: ' || x_wf_notification_event_name ||
                      ' | emailVerificationFlag: ' || x_email_verification_flag ||
                      ' | applicationId: ' || x_application_id ||
                      ' | regFunctionName: ' || x_reg_function_name ||
                      ' | displayName: ' || x_display_name ||
                      ' | description: ' || x_description ||
                      ' | wfBusLogicEventName:' || x_wf_bus_logic_event_name);
    end if;
  end get_req_data_from_req_sv_code;

  procedure get_req_data_from_role_name (
        p_wf_role_name in UMX_REG_SERVICES_VL.WF_ROLE_NAME%type,
        x_reg_service_code out nocopy UMX_REG_SERVICES_B.REG_SERVICE_CODE%type,
        x_reg_service_type out nocopy UMX_REG_SERVICES_VL.REG_SERVICE_TYPE%type,
        x_ame_application_id out nocopy UMX_REG_SERVICES_VL.AME_APPLICATION_ID%type,
        x_ame_transaction_type_id out nocopy UMX_REG_SERVICES_VL.AME_TRANSACTION_TYPE_ID%type,
        x_wf_notification_event_name out nocopy WF_EVENTS.NAME%type,
        x_email_verification_flag out nocopy UMX_REG_SERVICES_VL.EMAIL_VERIFICATION_FLAG%type,
        x_reg_function_name out nocopy FND_FORM_FUNCTIONS.FUNCTION_NAME%type,
        x_wf_bus_logic_event_name out nocopy WF_EVENTS.NAME%type) is

      CURSOR get_reg_svc_code_from_role (p_reg_serivce_type in varchar2) IS
        select REG_SERVICE_TYPE, REG_SERVICE_CODE, AME_APPLICATION_ID,
               AME_TRANSACTION_TYPE_ID, REG_FUNCTION_ID,
               wf_notification_event_guid, EMAIL_VERIFICATION_FLAG,
               wf_bus_logic_event_guid
        from   UMX_REG_SERVICES_B
        where  WF_ROLE_NAME = p_wf_role_name
        and    reg_service_type = p_reg_serivce_type;

      l_wf_notification_event_guid wf_events.guid%type;
      l_wf_bus_logic_event_guid wf_events.guid%type;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVREGB.getReqDataFromRoleName.begin',
                      'wfRoleName: ' || p_wf_role_name);
    end if;

    open get_reg_svc_code_from_role ('ADMIN_ADDITIONAL_ACCESS');
    fetch get_reg_svc_code_from_role into x_reg_service_type, x_reg_service_code, x_ame_application_id,
                                x_ame_transaction_type_id, x_reg_function_name,
                                l_wf_notification_event_guid, x_email_verification_flag,
                                l_wf_bus_logic_event_guid;
    if (get_reg_svc_code_from_role%notfound) then
      close get_reg_svc_code_from_role;
      open get_reg_svc_code_from_role ('ADDITIONAL_ACCESS');
      fetch get_reg_svc_code_from_role into x_reg_service_type, x_reg_service_code, x_ame_application_id,
                                  x_ame_transaction_type_id, x_reg_function_name,
                                  l_wf_notification_event_guid, x_email_verification_flag,
                                  l_wf_bus_logic_event_guid;
    end if;
    close get_reg_svc_code_from_role;

    x_wf_notification_event_name := get_event_name (l_wf_notification_event_guid);
    x_wf_bus_logic_event_name := get_event_name (l_wf_bus_logic_event_guid);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVREGB.getReqDataFromRoleName.end',
                      'regServiceCode: ' || x_reg_service_code ||
                      ' | regServiceType: ' || x_reg_service_type ||
                      ' | ameApplicationId: ' || x_ame_application_id ||
                      ' | ameTransactionTypeId: ' || x_ame_transaction_type_id ||
                      ' | wfNotificationEventName: ' || x_wf_notification_event_name ||
                      ' | emailVerificationFlag: ' || x_email_verification_flag ||
                      ' | regFunctionName: ' || x_reg_function_name ||
                      ' | wfBusLogicEventName: ' || x_wf_bus_logic_event_name);
    end if;

  end get_req_data_from_role_name;

  procedure POPULATE_REG_DATA (p_registration_data IN OUT NOCOPY UMX_REGISTRATION_DATA_TBL) IS
    l_reg_request_id    UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE;
    l_reg_service_code  UMX_REG_SERVICES_B.REG_SERVICE_CODE%TYPE;
    j number;
    l_wf_role_name UMX_REG_SERVICES_VL.WF_ROLE_NAME%TYPE;
    l_reg_service_type UMX_REG_SERVICES_VL.REG_SERVICE_TYPE%TYPE;
    l_application_id UMX_REG_SERVICES_VL.APPLICATION_ID%TYPE;
    l_wf_notification_event_name wf_events.name%TYPE;
    l_ame_application_id UMX_REG_SERVICES_VL.AME_APPLICATION_ID%TYPE;
    l_ame_transaction_type_id UMX_REG_SERVICES_VL.AME_TRANSACTION_TYPE_ID%TYPE;
    l_email_verification_flag UMX_REG_SERVICES_VL.EMAIL_VERIFICATION_FLAG%TYPE;
    l_reg_function_name fnd_form_functions.FUNCTION_NAME%TYPE;
    l_display_name UMX_REG_SERVICES_VL.DISPLAY_NAME%TYPE;
    l_description UMX_REG_SERVICES_VL.DESCRIPTION%TYPE;
    l_wf_bus_logic_event_name wf_events.name%TYPE;
    l_justification UMX_REG_REQUESTS.JUSTIFICATION%TYPE;
    l_requested_by_user_id UMX_REG_REQUESTS.REQUESTED_BY_USER_ID%TYPE;
    l_requested_for_user_id UMX_REG_REQUESTS.REQUESTED_FOR_USER_ID%TYPE;
    l_requested_for_party_id UMX_REG_REQUESTS.REQUESTED_FOR_PARTY_ID%type;
    l_requested_username UMX_REG_REQUESTS.REQUESTED_USERNAME%TYPE;

    l_index_to_add number;
    l_count number := 0;
    l_employee_id number;
    l_customer_id number;
    l_supplier_id number;
    l_fax varchar2(30);
    l_password_lifespan_accesses  number;
    l_password_lifespan_days  number;

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVREGB.populateRegData.begin', '');
    end if;

    j := p_registration_data.FIRST;

    -- We first have to get the Registration Service Code and Registration Request ID.
    while ((j <= p_registration_data.LAST) and (l_count < 2)) loop

      if p_registration_data(j).ATTR_NAME = G_REG_SERVICE_CODE then
        l_reg_service_code :=  p_registration_data(j).ATTR_VALUE;
        l_count := l_count + 1;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REG_REQUEST_ID then
        l_reg_request_id :=  p_registration_data(j).ATTR_VALUE;
        l_count := l_count + 1;
      end if;

      j := j + 1;

    end loop;

    if l_reg_request_id is null then
      -- Possibly from Self Service
      get_req_data_from_req_sv_code (l_reg_service_code, l_reg_service_type, l_wf_role_name,
                                     l_ame_application_id, l_ame_transaction_type_id,
                                     l_wf_notification_event_name, l_email_verification_flag,
                                     l_application_id, l_reg_function_name,
                                     l_display_name, l_description, l_wf_bus_logic_event_name);
    else
      -- Possibly from ART or SMART
      get_req_data_from_req_id (l_reg_request_id, l_reg_service_code,
                                l_reg_service_type, l_requested_by_user_id,
                                l_requested_for_user_id, l_requested_for_party_id,
                                l_requested_username, l_wf_role_name,
                                l_ame_application_id, l_ame_transaction_type_id,
                                l_justification, l_wf_notification_event_name,
                                l_email_verification_flag, l_application_id,
                                l_reg_function_name, l_display_name, l_description,
                                l_wf_bus_logic_event_name);
    end if;

    -- Requested by User ID must be filled with some value.  If it is null, then
    -- get the value from the current logged in user.
    if (l_requested_by_user_id is null) then
      l_requested_by_user_id := fnd_global.user_id;
    end if;

    -- Look for existing data. If we already find the metadata in the table
    -- we will add into its value.

    j := p_registration_data.FIRST;

    while (j <= p_registration_data.LAST) loop

      if p_registration_data(j).ATTR_NAME = G_WF_ROLE_NAME then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_wf_role_name := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REG_SERVICE_TYPE then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_reg_service_type := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REG_SERVICE_APP_ID then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_application_id := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_WF_NOTIFICATION_EVENT then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_wf_notification_event_name := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_WF_BUS_LOGIC_EVENT then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_wf_bus_logic_event_name := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_AME_APPLICATION_ID then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_ame_application_id := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_AME_TXN_TYPE_ID then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_ame_transaction_type_id := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_IDENTITY_VERIFY_REQD then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_email_verification_flag := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REG_FUNCTION_NAME then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_reg_function_name := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REG_SERVICE_DISP_NAME then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_display_name := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REG_SERVICE_DESCRIPTION then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_description := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_JUSTIFICATION then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_justification := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REQUESTED_BY_USER_ID then
        if (p_registration_data(j).ATTR_NAME is not null) then
          l_requested_by_user_id := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REQUESTED_FOR_USER_ID then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_requested_for_user_id := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REQUESTED_FOR_PARTY_ID then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_requested_for_party_id := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_REQUESTED_USERNAME then
        if (p_registration_data(j).ATTR_VALUE is not null) then
          l_requested_username := null;
        end if;
	  end if;
      if p_registration_data(j).ATTR_NAME = G_EMPLOYEE_ID then
        if (P_REGISTRATION_DATA(J).ATTR_VALUE is not null) then
          l_employee_id := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_CUSTOMER_ID then
        if (P_REGISTRATION_DATA(J).ATTR_VALUE is not null) then
          l_customer_id := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_SUPPLIER_ID then
        if (P_REGISTRATION_DATA(J).ATTR_VALUE is not null) then
          l_supplier_id := null;
        end if;
      end if;

      if p_registration_data(j).ATTR_NAME = G_DESCRIPTION then
        if (P_REGISTRATION_DATA(J).ATTR_VALUE is not null) then
          l_description := null;
        END IF;
      end if;

      if p_registration_data(j).ATTR_NAME = G_FAX then
        if (P_REGISTRATION_DATA(J).ATTR_VALUE is not null) then
          l_fax := null;
        end if;
      END IF;

      if p_registration_data(j).ATTR_NAME = G_PASSWORD_LIFESPAN_ACCESSES then
        if (P_REGISTRATION_DATA(J).ATTR_VALUE is not null) then
          l_password_lifespan_accesses := null;
        END IF;
      END IF;

      if p_registration_data(j).ATTR_NAME = G_PASSWORD_LIFESPAN_DAYS then
        if (P_REGISTRATION_DATA(J).ATTR_VALUE is not null) then
          l_password_lifespan_days := null;
        END IF;
      end if;

      j := j + 1;

    end loop;

    -- Add meta data that did not exist
    l_index_to_add := p_registration_data.last + 1;

    if l_wf_role_name is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_WF_ROLE_NAME;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_wf_role_name;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_reg_service_type is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_REG_SERVICE_TYPE;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_reg_service_type;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_application_id is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_REG_SERVICE_APP_ID;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_application_id;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_wf_notification_event_name is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_WF_NOTIFICATION_EVENT;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_wf_notification_event_name;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_wf_bus_logic_event_name is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_WF_BUS_LOGIC_EVENT;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_wf_bus_logic_event_name;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_ame_application_id is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_AME_APPLICATION_ID;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_ame_application_id;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_ame_transaction_type_id is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_AME_TXN_TYPE_ID;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_ame_transaction_type_id;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_email_verification_flag is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_IDENTITY_VERIFY_REQD;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_email_verification_flag;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_reg_function_name is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_REG_FUNCTION_NAME;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_reg_function_name;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_display_name is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_REG_SERVICE_DISP_NAME;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_display_name;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_description is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_REG_SERVICE_DESCRIPTION;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_description;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_justification is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_JUSTIFICATION;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_justification;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_requested_by_user_id is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_REQUESTED_BY_USER_ID;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_requested_by_user_id;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_requested_for_user_id is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_REQUESTED_FOR_USER_ID;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_requested_for_user_id;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_requested_for_party_id is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_REQUESTED_FOR_PARTY_ID;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_requested_for_party_id;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_requested_username is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_REQUESTED_USERNAME;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_requested_username;
      l_index_to_add := l_index_to_add + 1;
    end if;
    if l_employee_id is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_EMPLOYEE_ID;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_employee_id;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_customer_id is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_CUSTOMER_ID;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_customer_id;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_supplier_id is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_SUPPLIER_ID;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_supplier_id;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_description is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_DESCRIPTION;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_description;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_fax is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_FAX;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_fax;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_password_lifespan_accesses is not null then
      p_registration_data(l_index_to_add).ATTR_NAME := G_PASSWORD_LIFESPAN_ACCESSES;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_password_lifespan_accesses;
      l_index_to_add := l_index_to_add + 1;
    end if;

    if l_password_lifespan_days is not null then
      p_registration_data(l_index_to_add).attr_name := g_password_lifespan_days;
      p_registration_data(l_index_to_add).ATTR_VALUE := l_password_lifespan_days;
      l_index_to_add := l_index_to_add + 1;
    end if;


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVREGB.populateRegData.end', '');
    end if;

  END POPULATE_REG_DATA;

  --
  -- Procedure        :  assign_role
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will assign or launch wf to assign role.
  -- Input Parameters (Mandatory):
  -- p_registration_data : Table of record type of UMX_REGISTRATION_DATA
  -- Output Parameters:
  -- p_registration_data : Table of record type of UMX_REGISTRATION_DATA
  --
  procedure assign_role (p_registration_data in out NOCOPY UMX_REGISTRATION_DATA_TBL,
           x_return_status out NOCOPY varchar2,
 			     x_message_data out NOCOPY varchar2) IS

    l_parameter_list wf_parameter_list_t;
    l_event_key varchar2 (240);
    i number;

    l_reg_request_id_i number;
    l_reg_service_type_i number;
    l_status_code_i number;
    l_requested_for_party_id_i number;
    l_wf_role_name_i number;
    l_reg_service_code_i number;
    l_ame_application_id_i number;
    l_ame_transaction_type_id_i number;
    l_wf_notification_event_i number;
    l_wf_bus_logic_event_i number;
    l_email_verification_flag_i number;
    l_application_id_i number;
    l_reg_function_name_i number;
    l_display_name_i number;
    l_description_i number;

    l_reg_request_id umx_reg_requests.reg_request_id%type;
    l_reg_service_type umx_reg_requests.reg_service_type%type;
    l_status_code umx_reg_requests.status_code%type;
    l_requested_start_date umx_reg_requests.requested_start_date%type;
    l_requested_by_user_id umx_reg_requests.requested_by_user_id%type;
    l_requested_for_user_id umx_reg_requests.requested_for_user_id%type;
    l_requested_for_user_name fnd_user.user_name%type;
    l_requested_for_party_id umx_reg_requests.requested_for_party_id%type;
    l_requested_username umx_reg_requests.requested_username%type;
    l_requested_end_date umx_reg_requests.requested_end_date%type;
    l_wf_role_name umx_reg_requests.wf_role_name%type;
    l_reg_service_code umx_reg_requests.reg_service_code%type;
    l_ame_application_id umx_reg_requests.ame_application_id%type;
    l_ame_transaction_type_id umx_reg_requests.ame_transaction_type_id%type;
    l_justification umx_reg_requests.justification%type;
    l_wf_notification_event_name wf_events.name%TYPE;
    l_wf_bus_logic_event_name wf_events.name%TYPE;
    l_email_verification_flag UMX_REG_SERVICES_VL.EMAIL_VERIFICATION_FLAG%TYPE;
    l_application_id UMX_REG_SERVICES_VL.APPLICATION_ID%TYPE;
    l_reg_function_name fnd_form_functions.FUNCTION_NAME%TYPE;
    l_display_name UMX_REG_SERVICES_VL.DISPLAY_NAME%TYPE;
    l_description UMX_REG_SERVICES_VL.DESCRIPTION%TYPE;

    cursor get_username_from_userid (l_userid in fnd_user.user_id%type) is
      select user_name
      from   fnd_user
      where  user_id = l_userid;

    cursor get_requested_for_party_id (l_userid in fnd_user.user_id%type) is
      select person_party_id
      from   fnd_user
      where  user_id = l_userid;

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      -- Print all the name and value in p_registration_data.
      i := p_registration_data.first;
      while (i <= p_registration_data.last) loop
        if (p_registration_data(i).attr_name is not null) then
          FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                          'fnd.plsql.UMXVREGB.assignRole.begin',
                          'p_registration_data(' || i || ').attr_name = ' || p_registration_data(i).attr_name ||
                          ' | attr_value = ' || p_registration_data(i).attr_value);
        else
          FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                          'fnd.plsql.UMXVREGB.assignRole.begin', 'p_registration_data(' || i || ').attr_name is null');
        end if;
        i := i + 1;
      end loop;
    end if;

    i := p_registration_data.first;

    -- Save the index of each attribute for later use
    while (i <= p_registration_data.last) loop
      if (p_registration_data(i).attr_name = G_REG_REQUEST_ID) then
        l_reg_request_id_i := i;
        l_reg_request_id := p_registration_data(i).attr_value;
      elsif (p_registration_data(i).attr_name = G_REG_SERVICE_TYPE) then
        l_reg_service_type_i := i;
      elsif (p_registration_data(i).attr_name = G_REG_REQUEST_STATUS) then
        l_status_code_i := i;
      elsif (p_registration_data(i).attr_name = G_REQUESTED_START_DATE) then
        if (p_registration_data(i).attr_value is not null) then
          l_requested_start_date := fnd_date.canonical_to_date (p_registration_data(i).attr_value);
        else
          l_requested_start_date := sysdate;
          p_registration_data(i).attr_value := fnd_date.date_to_canonical (l_requested_start_date);
        end if;
      elsif (p_registration_data(i).attr_name = G_REQUESTED_BY_USER_ID) then
        if (p_registration_data(i).attr_value is null) then
          l_requested_by_user_id := fnd_global.user_id;
          p_registration_data(i).attr_value := l_requested_by_user_id;
        else
          l_requested_by_user_id := p_registration_data(i).attr_value;
        end if;
      elsif (p_registration_data(i).attr_name = G_REQUESTED_FOR_USER_ID) then
        l_requested_for_user_id := p_registration_data(i).attr_value;
      elsif (p_registration_data(i).attr_name = G_REQUESTED_FOR_PARTY_ID) then
        l_requested_for_party_id_i := i;
      elsif (p_registration_data(i).attr_name = G_REQUESTED_USERNAME) then
        l_requested_username := p_registration_data(i).attr_value;
      elsif (p_registration_data(i).attr_name = G_REQUESTED_END_DATE) then
        if (p_registration_data(i).attr_value is not null) then
          l_requested_end_date := fnd_date.canonical_to_date (p_registration_data(i).attr_value);
        end if;
      elsif (p_registration_data(i).attr_name = G_WF_ROLE_NAME) then
        l_wf_role_name_i := i;
      elsif (p_registration_data(i).attr_name = G_REG_SERVICE_CODE) then
        l_reg_service_code_i := i;
      elsif (p_registration_data(i).attr_name = G_AME_APPLICATION_ID) then
        l_ame_application_id_i := i;
      elsif (p_registration_data(i).attr_name = G_AME_TXN_TYPE_ID) then
        l_ame_transaction_type_id_i := i;
      elsif (p_registration_data(i).attr_name = G_JUSTIFICATION) then
        l_justification := p_registration_data(i).attr_value;
      elsif (p_registration_data(i).attr_name = G_WF_NOTIFICATION_EVENT) then
        l_wf_notification_event_i := i;
      elsif (p_registration_data(i).attr_name = G_WF_BUS_LOGIC_EVENT) then
        l_wf_bus_logic_event_i := i;
      elsif (p_registration_data(i).attr_name = G_IDENTITY_VERIFY_REQD) then
        l_email_verification_flag_i := i;
      elsif (p_registration_data(i).attr_name = G_REG_SERVICE_APP_ID) then
        l_application_id_i := i;
      elsif (p_registration_data(i).attr_name = G_REG_FUNCTION_NAME) then
        l_reg_function_name_i := i;
        l_reg_function_name := p_registration_data(i).attr_value;
      elsif (p_registration_data(i).attr_name = G_REG_SERVICE_DISP_NAME) then
        l_display_name_i := i;
      elsif (p_registration_data(i).attr_name = G_REG_SERVICE_DESCRIPTION) then
        l_description_i := i;
      end if;
      i := i + 1;
    end loop;

    -- Get the 'requested for party id'
    if (l_requested_for_user_id is not null) then
      open get_requested_for_party_id (l_requested_for_user_id);
      fetch get_requested_for_party_id into l_requested_for_party_id;
      close get_requested_for_party_id;

      if (l_requested_for_party_id_i is null) then
        l_requested_for_party_id_i := p_registration_data.last + 1;
        p_registration_data(l_requested_for_party_id_i).attr_name := G_REQUESTED_FOR_PARTY_ID;
      end if;

      if (l_requested_for_party_id is not null) then
        p_registration_data(l_requested_for_party_id_i).attr_value := l_requested_for_party_id;
      end if;
    end if;


    if (l_reg_service_code_i is null) then
      -- We need to add the Reg Service Code into the p_registration_data
      l_reg_service_code_i := p_registration_data.last + 1;
      p_registration_data(l_reg_service_code_i).attr_name := G_REG_SERVICE_CODE;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVREGB.assignRole',
                      'regServiceCode:' || p_registration_data(l_reg_service_code_i).attr_value);
    end if;

    -- Query the rest of the Reg Service meta data.
    if (p_registration_data(l_reg_service_code_i).attr_value is null) then
      -- Calling from SMART
      l_wf_role_name := p_registration_data(l_wf_role_name_i).attr_value;
      get_req_data_from_role_name (l_wf_role_name, l_reg_service_code, l_reg_service_type,
                                   l_ame_application_id, l_ame_transaction_type_id,
                                   l_wf_notification_event_name, l_email_verification_flag,
                                   l_reg_function_name, l_wf_bus_logic_event_name);
    else
      l_reg_service_code := p_registration_data(l_reg_service_code_i).attr_value;

      get_req_data_from_req_sv_code (l_reg_service_code, l_reg_service_type, l_wf_role_name,
                                     l_ame_application_id, l_ame_transaction_type_id,
                                     l_wf_notification_event_name, l_email_verification_flag,
                                     l_application_id, l_reg_function_name,
                                     l_display_name, l_description, l_wf_bus_logic_event_name);
    end if;

    -- Set the queried data into p_registration_data only if the value is null.
    if (l_wf_role_name_i is null) then
      l_wf_role_name_i := p_registration_data.last + 1;
      p_registration_data(l_wf_role_name_i).attr_name := G_WF_ROLE_NAME;
      p_registration_data(l_wf_role_name_i).attr_value := l_wf_role_name;
    else
      if (p_registration_data(l_wf_role_name_i).attr_value is null) then
        p_registration_data(l_wf_role_name_i).attr_value := l_wf_role_name;
      else
        l_wf_role_name := p_registration_data(l_wf_role_name_i).attr_value;
      end if;
    end if;

    if (l_reg_service_type_i is null) then
      l_reg_service_type_i := p_registration_data.last + 1;
      p_registration_data(l_reg_service_type_i).attr_name := G_REG_SERVICE_TYPE;
      p_registration_data(l_reg_service_type_i).attr_value := l_reg_service_type;
    else
      if (p_registration_data(l_reg_service_type_i).attr_value is null) then
        p_registration_data(l_reg_service_type_i).attr_value := l_reg_service_type;
      else
        l_reg_service_type := p_registration_data(l_reg_service_type_i).attr_value;
      end if;
    end if;

    if (l_application_id_i is null) then
      l_application_id_i := p_registration_data.last + 1;
      p_registration_data(l_application_id_i).attr_name := G_REG_SERVICE_APP_ID;
      p_registration_data(l_application_id_i).attr_value := l_application_id;
    else
      if (p_registration_data(l_application_id_i).attr_value is null) then
        p_registration_data(l_application_id).attr_value := l_application_id;
      else
        l_application_id := p_registration_data(l_application_id).attr_value;
      end if;
    end if;

    if (l_wf_notification_event_i is null) then
      l_wf_notification_event_i := p_registration_data.last + 1;
      p_registration_data(l_wf_notification_event_i).attr_name := G_WF_NOTIFICATION_EVENT;
      p_registration_data(l_wf_notification_event_i).attr_value := l_wf_notification_event_name;
    else
      if (p_registration_data(l_wf_notification_event_i).attr_value is null) then
        p_registration_data(l_wf_notification_event_i).attr_value := l_wf_notification_event_name;
      else
        l_wf_notification_event_name := p_registration_data(l_wf_notification_event_i).attr_value;
      end if;
    end if;

    if (l_wf_bus_logic_event_i is null) then
      l_wf_bus_logic_event_i := p_registration_data.last + 1;
      p_registration_data(l_wf_bus_logic_event_i).attr_name := G_WF_BUS_LOGIC_EVENT;
      p_registration_data(l_wf_bus_logic_event_i).attr_value := l_wf_bus_logic_event_name;
    else
      if (p_registration_data(l_wf_bus_logic_event_i).attr_value is null) then
        p_registration_data(l_wf_bus_logic_event_i).attr_value := l_wf_bus_logic_event_name;
      else
        l_wf_bus_logic_event_name := p_registration_data(l_wf_bus_logic_event_i).attr_value;
      end if;
    end if;

    if (l_ame_application_id_i is null) then
      l_ame_application_id_i := p_registration_data.last + 1;
      p_registration_data(l_ame_application_id_i).attr_name := G_AME_APPLICATION_ID;
      p_registration_data(l_ame_application_id_i).attr_value := l_ame_application_id;
    else
      if (p_registration_data(l_ame_application_id_i).attr_value is null) then
        p_registration_data(l_ame_application_id_i).attr_value := l_ame_application_id;
      else
        l_ame_application_id := p_registration_data(l_ame_application_id_i).attr_value;
      end if;
    end if;

    if (l_ame_transaction_type_id_i is null) then
      l_ame_transaction_type_id_i := p_registration_data.last + 1;
      p_registration_data(l_ame_transaction_type_id_i).attr_name := G_AME_TXN_TYPE_ID;
      p_registration_data(l_ame_transaction_type_id_i).attr_value := l_ame_transaction_type_id;
    else
      if (p_registration_data(l_ame_transaction_type_id_i).attr_value is null) then
        p_registration_data(l_ame_transaction_type_id_i).attr_value := l_ame_transaction_type_id;
      else
        l_ame_transaction_type_id := p_registration_data(l_ame_transaction_type_id_i).attr_value;
      end if;
    end if;

    if (l_email_verification_flag_i is null) then
      l_email_verification_flag_i := p_registration_data.last + 1;
      p_registration_data(l_email_verification_flag_i).attr_name := G_IDENTITY_VERIFY_REQD;
      p_registration_data(l_email_verification_flag_i).attr_value := l_email_verification_flag;
    else
      if (p_registration_data(l_email_verification_flag_i).attr_value is null) then
        p_registration_data(l_email_verification_flag_i).attr_value := l_email_verification_flag;
      else
        l_email_verification_flag := p_registration_data(l_email_verification_flag_i).attr_value;
      end if;
    end if;

    if (l_reg_function_name_i is null) then
      l_reg_function_name_i := p_registration_data.last + 1;
      p_registration_data(l_reg_function_name_i).attr_name := G_REG_FUNCTION_NAME;
      p_registration_data(l_reg_function_name_i).attr_value := l_reg_function_name;
    else
      if (p_registration_data(l_reg_function_name_i).attr_value is null) then
        p_registration_data(l_reg_function_name_i).attr_value := l_reg_function_name;
      else
        l_reg_function_name := p_registration_data(l_reg_function_name_i).attr_value;
      end if;
    end if;

    if (l_display_name_i is null) then
      l_display_name_i := p_registration_data.last + 1;
      p_registration_data(l_display_name_i).attr_name := G_REG_SERVICE_DISP_NAME;
      p_registration_data(l_display_name_i).attr_value := l_display_name;
    else
      if (p_registration_data(l_display_name_i).attr_value is null) then
        p_registration_data(l_display_name_i).attr_value := l_display_name;
      else
        l_display_name := p_registration_data(l_display_name_i).attr_value;
      end if;
    end if;

    if (l_description_i is null) then
      l_description_i := p_registration_data.last + 1;
      p_registration_data(l_description_i).attr_name := G_REG_SERVICE_DESCRIPTION;
      p_registration_data(l_description_i).attr_value := l_description;
    else
      if (p_registration_data(l_description_i).attr_value is null) then
        p_registration_data(l_description_i).attr_value := l_description;
      else
        l_description := p_registration_data(l_description_i).attr_value;
      end if;
    end if;

    open get_username_from_userid (l_requested_for_user_id);
    fetch get_username_from_userid into l_requested_for_user_name;
    close get_username_from_userid;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVREGB.assignRole',
                      'regServiceType: ' || l_reg_service_type ||
                      ' | wfRoleName: ' || l_wf_role_name);
    end if;

    -- The request will be directly assigned if:
    -- 1) The registration service type is set to have DIRECT_ASSIGNED
    -- 2) The requested by and requested for is different AND the registration
    --    service type is ADDITIONAL_ACCESS.
    -- 3) The request does not has a registration process.
    if (l_reg_service_type = 'DIRECT_ASSIGNED') or
       ((l_reg_service_type = 'ADDITIONAL_ACCESS') and (l_requested_by_user_id <> l_requested_for_user_id)) or
       ((l_reg_service_type is null) and (l_wf_role_name is not null)) then

      l_reg_service_type := 'DIRECT_ASSIGNED';
      p_registration_data(l_reg_service_type_i).attr_value := l_reg_service_type;

      i := p_registration_data.first;
      while (i <= p_registration_data.last) loop
        wf_event.addParametertoList (upper(p_registration_data(i).ATTR_NAME),
                                     p_registration_data(i).ATTR_VALUE,
                                     l_parameter_list);
        i := i + 1;
      end loop;

      -- Raise WF Event
      select umx_events_s.nextval into l_event_key from dual;
      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXVREGB.assignRole',
                        'Raising oracle.apps.fnd.umx.rolerequested event with l_event_key=' || l_event_key);
      end if;
      wf_event.raise (p_event_name => 'oracle.apps.fnd.umx.rolerequested',
                      p_event_key  => l_event_key,
                      p_event_data => null,
                      p_parameters => l_parameter_list,
                      p_send_date  => sysdate);

      -- Launch the custom event if the custom event name is not null.
      if (l_wf_bus_logic_event_name is not null) then
        -- Set the custom event context
        wf_event.addParametertoList ('UMX_CUSTOM_EVENT_CONTEXT', 'ROLE APPROVED', l_parameter_list);
        -- Finally, raise the custom event.
        if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
          FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                          'fnd.plsql.UMXVREGB.assignRole',
                          'Raising ' || l_wf_bus_logic_event_name || ' event with l_event_key=' || l_event_key);
        end if;
        wf_event.raise (p_event_name => l_wf_bus_logic_event_name,
                        p_event_key  => l_event_key,
                        p_event_data => null,
                        p_parameters => l_parameter_list,
                        p_send_date  => sysdate);
      end if;

      -- populate the wf_local_user_roles table and update the reg table
      -- with status approved
      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXVREGB.assignRole',
                        'Calling wf_local_synch.propagateUserRole (p_user_name => ' || l_requested_for_user_name ||
                        ', p_role_name => ' || l_wf_role_name ||
                        ', p_start_date => ' || l_requested_start_date ||
                        ', p_expiration_date => ' || l_requested_end_date ||
                        ', p_raiseErrors => true' ||
                        ', p_assignmentReason => ' || l_justification);
      end if;
      wf_local_synch.propagateUserRole (
        p_user_name        => l_requested_for_user_name,
        p_role_name        => l_wf_role_name,
        p_start_date       => l_requested_start_date,
        p_expiration_date  => l_requested_end_date,
        p_raiseErrors      => true,
        p_assignmentReason => l_justification);

      l_status_code := 'APPROVED';

      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXVREGB.assignRole',
                        'Raising oracle.apps.fnd.umx.requestapproved event with l_event_key=' || l_event_key);
      end if;
      wf_event.raise (p_event_name => 'oracle.apps.fnd.umx.requestapproved',
                      p_event_key  => l_event_key,
                      p_event_data => null,
                      p_parameters => l_parameter_list,
                      p_send_date  => sysdate);

    else

      -- Any requests (Additional Access or Admin Additional Access) that have
      -- a page flow defined the status code will be UNASSIGNED.
      if (l_reg_function_name is not null) then
        l_status_code := 'UNASSIGNED';
      else
        l_status_code := 'PENDING';
      end if;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVREGB.assignRole',
                      'statusCode: ' || l_status_code);
    end if;

    -- Set the status code now into the registration data
    if (l_status_code_i is null) then
      l_status_code_i := p_registration_data.last + 1;
      p_registration_data(l_status_code_i).attr_name := G_REG_REQUEST_STATUS;
      p_registration_data(l_status_code_i).attr_value := l_status_code;
    else
      p_registration_data(l_status_code_i).attr_value := l_status_code;
    end if;

    UMX_REG_REQUESTS_PKG.insert_row (
        x_reg_request_id   => l_reg_request_id ,
        x_reg_service_type => l_reg_service_type,
        x_status_code => l_status_code,
        x_requested_by_user_id => l_requested_by_user_id,
        x_requested_for_user_id => l_requested_for_user_id,
        x_requested_for_party_id => l_requested_for_party_id,
        x_requested_username => l_requested_username,
        x_requested_start_date => l_requested_start_date,
        x_requested_end_date => l_requested_end_date,
        x_wf_role_name => l_wf_role_name,
        x_reg_service_code => l_reg_service_code,
        x_ame_application_id => l_ame_application_id,
        x_ame_transaction_type_id => l_ame_transaction_type_id,
        x_justification => l_justification);

    if (l_reg_request_id_i is null) then
      l_reg_request_id_i := p_registration_data.last + 1;
      p_registration_data(l_reg_request_id_i).attr_name := G_REG_REQUEST_ID;
      p_registration_data(l_reg_request_id_i).attr_value := l_reg_request_id;
    else
      p_registration_data(l_reg_request_id_i).attr_value := l_reg_request_id;
    end if;

    --check for reg_function_id if no page flow and request type is additional access
    --call the workflow launcher api here.
    -- else set the status in reg table as unassigned
    if (l_reg_function_name is null and
        l_status_code <> 'APPROVED') then
      DO_PROCESS_REQUEST (p_registration_data, x_return_status, x_message_data);
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      -- Print all the name and value in p_registration_data.
      i := p_registration_data.first;
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVREGB.assignRole.end', 'p_registration_data.last=' || p_registration_data.last);
      while (i <= p_registration_data.last) loop
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXVREGB.assignRole.end',
                        'p_registration_data(' || i || ').attr_name = ' || p_registration_data(i).attr_name ||
                        ' | attr_value = ' || p_registration_data(i).attr_value);
        i := i + 1;
      end loop;
    end if;
  END assign_role;

 /**
   * Please refer to the package specifications for details
   */

  function GET_PHONE_NUMBER(p_person_id  in per_all_people_f.person_id%type) return varchar2 IS

l_phone_number per_phones.phone_number%type;
cursor find_phone_number is
 select perph.phone_number
 from   per_phones perph
 where  perph.phone_type = 'W1'
 and    perph.parent_id = p_person_id
 and    perph.parent_table = 'PER_ALL_PEOPLE_F'
 and    perph.date_from <= trunc(sysdate)
 and    nvl(perph.date_to, trunc(sysdate + 1)) >= trunc(sysdate);


begin

open find_phone_number;
fetch find_phone_number into l_phone_number;
close find_phone_number;

return l_phone_number;

END GET_PHONE_NUMBER;
/**
   * Please refer to the package specifications for details
   */

function GET_PERSON_ID (p_party_id  in hz_parties.party_id%type) return number IS
l_matches varchar2(5);
l_person_id per_all_people_f.person_id%type;
l_cursorid integer;
l_blockstr varchar2(1000);
l_dummy integer;

-- Use dynamamic SQL - Bug 4653519
begin -- Outer Begin
    begin -- Inner begin for dynamic SQL
    l_cursorid := dbms_sql.open_cursor;
    l_blockstr :=
              'BEGIN
                hr_tca_utility.get_person_id(p_party_id => :l_party_id,
                                             p_person_id => :l_person_id,
                                             p_matches => :l_matches);
              END;';

     dbms_sql.parse(l_cursorid, l_blockstr, dbms_sql.v7);

     dbms_sql.bind_variable(l_cursorid, ':l_party_id', p_party_id);
     dbms_sql.bind_variable(l_cursorid, ':l_person_id', l_person_id);
     dbms_sql.bind_variable(l_cursorid, ':l_matches', l_matches, 1);

     l_dummy := dbms_sql.execute(l_cursorid);

     dbms_sql.variable_value(l_cursorid, ':l_person_id', l_person_id);
     dbms_sql.variable_value(l_cursorid, ':l_matches', l_matches);
     dbms_sql.close_cursor(l_cursorid);

  exception
      when others then
        l_person_id := null;
        dbms_sql.close_cursor(l_cursorid);
  end;
     return l_person_id;
end GET_PERSON_ID;

/**
   * Please refer to the package specifications for details
   */

  function GET_MANAGER_NAME(p_person_id  in per_all_people_f.person_id%type) return varchar2 IS

l_manager_name per_all_people_f.full_name%type;
cursor find_mgr_name is
 select mgr.full_name
 from   per_all_assignments_f emp, per_all_people_f mgr
 where  emp.supervisor_id = mgr.person_id
 and    emp.person_id = p_person_id
 and    emp.effective_start_date <= trunc(sysdate)
 and    nvl(emp.effective_end_date, trunc(sysdate + 1)) >= trunc(sysdate)
 and    mgr.effective_start_date <= trunc(sysdate)
 and    nvl(mgr.effective_end_date, trunc(sysdate + 1)) >= trunc(sysdate);

begin

open find_mgr_name;
fetch find_mgr_name into l_manager_name;
close find_mgr_name;

return l_manager_name;

END GET_MANAGER_NAME;

/**
   * Please refer to the package specifications for details
   */

  function GET_JOB_TITLE(p_person_id  in per_all_people_f.person_id%type) return varchar2 IS

l_title per_jobs_vl.name%type;
cursor find_title is
 select name
 from   per_all_assignments_f emp, per_jobs_vl jobs
 where  emp.person_id = p_person_id
 and    emp.effective_start_date <= trunc(sysdate)
 and    nvl(emp.effective_end_date, trunc(sysdate + 1)) >= trunc(sysdate)
 and    emp.job_id = jobs.job_id
 and    jobs.date_from <= trunc(sysdate)
 and    nvl(jobs.date_to, trunc(sysdate + 1)) >= trunc(sysdate);

begin

open find_title;
fetch find_title into l_title;
close find_title;

return l_title;

END GET_JOB_TITLE;


end UMX_REGISTRATION_PVT;

/
