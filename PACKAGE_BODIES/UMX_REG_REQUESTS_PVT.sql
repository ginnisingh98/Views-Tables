--------------------------------------------------------
--  DDL for Package Body UMX_REG_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_REG_REQUESTS_PVT" AS
/* $Header: UMXVRRSB.pls 120.6.12010000.12 2017/11/09 04:34:31 avelu ship $ */

  -- procedure
  --
  --
  PROCEDURE populateRegRecord (p_reg_request     in out NOCOPY REG_REQUEST_TYPE,
                               x_reg_function_id out NOCOPY varchar2) IS

    cursor getPersonPartyId ( x_user_id in number ) is

      select PERSON_PARTY_ID
      from   FND_USER
      where  USER_ID = X_USER_ID
      and    nvl( END_DATE, sysdate+1) > sysdate;

    cursor getRegSvcFromRegCode ( x_reg_service_code in varchar2 ) is

      select URS.REG_SERVICE_TYPE, URS.WF_ROLE_NAME, URS.AME_APPLICATION_ID,
             URS.AME_TRANSACTION_TYPE_ID, URS.REG_FUNCTION_ID, WE.NAME,
             URS.EMAIL_VERIFICATION_FLAG
      from   UMX_REG_SERVICES_B URS, WF_EVENTS WE
      where  URS.REG_SERVICE_CODE = X_REG_SERVICE_CODE
      and    nvl(URS.END_DATE, sysdate+1) > sysdate
      and    URS.WF_NOTIFICATION_EVENT_GUID = WE.GUID;

    cursor getRegSvcFromRoleName (x_wf_role_name in varchar2) is

      select URS.REG_SERVICE_TYPE, URS.REG_SERVICE_CODE, URS.AME_APPLICATION_ID,
             URS.AME_TRANSACTION_TYPE_ID, URS.REG_FUNCTION_ID, WE.NAME,
             URS.EMAIL_VERIFICATION_FLAG
      from   UMX_REG_SERVICES_B URS, WF_EVENTS WE
      where  URS.WF_ROLE_NAME = x_wf_role_name
      and    nvl(URS.END_DATE, sysdate+1) > sysdate
      and    URS.REG_SERVICE_TYPE = 'ADDITIONAL_ACCESS'
      and    URS.WF_NOTIFICATION_EVENT_GUID = WE.GUID;

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.populateRegRecord.begin',
                      'regServiceCode: ' || p_reg_request.reg_service_code ||
                      ' | requestedForUserId: ' || p_reg_request.requested_for_user_id);
    end if;

    if (p_reg_request.reg_service_code is not null) then

      -- ART request. query the person_party_id
      -- throw exception if user id is not passed

      if ( p_reg_request.requested_for_user_id is null) then
        fnd_message.set_name('FND','UMX_COMMON_MISS_PARAM_MSG');
        fnd_message.set_token('PARAM', 'p_reg_request.requested_for_user_id');
        fnd_message.set_token('API', 'UMX_REG_REQUESTS_PVT.populateRegRecord');
        raise_application_error ('-20000', fnd_message.get);

      else

        open getPersonPartyId ( p_reg_request.requested_for_user_id );
        fetch getPersonPartyId into p_reg_request.requested_for_party_id;

        if (getPersonPartyId%notfound) then
          close getPersonPartyId;
          fnd_message.set_name('FND','UMX_COMMON_MISS_PARAM_MSG');
          fnd_message.set_token('PARAM', 'getPersonPartyId');
          fnd_message.set_token('API', 'UMX_REG_REQUESTS_PVT.populateRegRecord');
          raise_application_error ('-20000', fnd_message.get);
        end if;

        close getPersonPartyId;

      end if;

      -- populate the regrecord based on the reg_service_code
      -- request from art
      open getRegSvcFromRegCode (p_reg_request.reg_service_code);
      fetch getRegSvcFromRegCode into
        p_reg_request.reg_service_type,
        p_reg_request.wf_role_name,
        p_reg_request.ame_application_id,
        p_reg_request.AME_TRANSACTION_TYPE_ID,
        x_reg_function_id,
        p_reg_request.WF_EVENT_NAME,
        p_reg_request.EMAIL_VERIFICATION_FLAG;

      if (getRegSvcFromRegCode%notfound) then
        close getRegSvcFromRegCode;
        raise_application_error('-20000','illegal reg_service_code passed');
      end if;

      close getRegSvcFromRegCode;

    elsif (p_reg_request.wf_role_name is null) then
      -- this is a smart request and role name should be passed
      fnd_message.set_name('FND','UMX_COMMON_MISS_PARAM_MSG');
      fnd_message.set_token('PARAM', 'p_reg_request.wf_role_name');
      fnd_message.set_token('API', 'UMX_REG_REQUESTS_PVT.populateRegRecord');
      raise_application_error ('-20000', fnd_message.get);
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.populateRegRecord',
                      'regServiceCode: ' || p_reg_request.reg_service_code ||
                      ' | requestedForUserId: ' || p_reg_request.requested_for_user_id);
    end if;

    if (p_reg_request.reg_service_code is null and
        p_reg_request.wf_role_name is not null) then
      --  query data based on role name smart request
      open getRegSvcFromRoleName (p_reg_request.wf_role_name);

      fetch getRegSvcFromRoleName into
        p_reg_request.reg_service_type,
        p_reg_request.reg_service_code,
        p_reg_request.ame_application_id,
        p_reg_request.AME_TRANSACTION_TYPE_ID,
        x_reg_function_id,
        p_reg_request.WF_EVENT_NAME,
        p_reg_request.EMAIL_VERIFICATION_FLAG;

      if (getRegSvcFromRoleName%notfound) then
        -- this is a direct assigned role from smart
        p_reg_request.reg_service_type := 'DIRECT_ASSIGNED';
      end if;

      close getRegSvcFromRoleName;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.populateRegRecord.end',
                      'regFunctionId:' || x_reg_function_id);
    end if;

  END populateRegRecord;

  --procedure
  --
  --
  PROCEDURE validate_fnd_lookup (p_lookup_type   IN VARCHAR2,
                                 p_column        IN VARCHAR2,
                                 p_column_value  IN VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2) IS
    CURSOR c1 IS
      SELECT 'Y'
      FROM   fnd_lookup_values
      WHERE  lookup_type = p_lookup_type
        AND  lookup_code = p_column_value
        AND  ROWNUM      = 1;

    l_exist VARCHAR2(1);

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.validate_fnd_lookup.begin',
                      'lookupType: ' || p_lookup_type ||
                      ' | column: ' || p_column ||
                      ' | columnValue: ' || p_column_value);
    end if;

    IF (p_column_value IS NOT NULL AND p_column_value <> fnd_api.g_miss_char ) THEN
      OPEN c1;
      FETCH c1 INTO l_exist;
      IF c1%NOTFOUND THEN
        CLOSE c1;
        fnd_message.set_name('AR','HZ_API_INVALID_LOOKUP');
        fnd_message.set_token('COLUMN',p_column);
        fnd_message.set_token('LOOKUP_TYPE',p_lookup_type);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c1;
    END IF;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.validate_fnd_lookup.end',
                      'returnStatus: ' || x_return_status);
    end if;

  END validate_fnd_lookup;

  --
  -- Procedure        :  update_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will create a registration request
  --                     into the UMX_REG_REQUESTS table.
  --                     Before registration request can be inserted into
  --                     UMX_REG_REQUESTS table, this API will check to see
  --                     if the requester already have a valid association to
  --                     this access role in wf_local_user_role.  This API will
  --                     return null if there is a valid access role.
  -- Input Parameters (Mandatory):
  --    p_reg_request.reg_type_code: The code of the registration service type
  --                                 code.
  --
  -- At least one of the below parameter needs to be passed in as an input
  -- parameter:
  --    p_reg_request.wf_role_name: The user_id of the user who this
  --                                registration request is requested for.
  --    p_reg_request.reg_service_code: The Person Party ID of the person who
  --                                    this request is requested for.
  -- Input Parameters (non-Mandatory):
  --    p_extra_check: Check if user already has an association with the role.
  -- Output Parameters:
  --    x_reg_request_id: Registration Request ID
  --
  procedure update_reg_request (p_reg_request in out NOCOPY REG_REQUEST_TYPE) IS
  BEGIN
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.update_reg_request.begin', 'Begin');
    end if;

    UMX_REG_REQUESTS_PKG.update_row (
                  X_REG_REQUEST_ID => p_reg_request.reg_request_id,
                  X_STATUS_CODE  => p_reg_request.status_code,
                  X_REQUESTED_BY_USER_ID  => fnd_global.user_id,
                  X_REQUESTED_FOR_USER_ID => p_reg_request.requested_for_user_id,
                  X_REQUESTED_FOR_PARTY_ID => p_reg_request.requested_for_party_id,
                  X_REQUESTED_USERNAME  => upper (p_reg_request.requested_username),
                  X_REQUESTED_START_DATE  => p_reg_request.requested_start_date,
                  X_REQUESTED_END_DATE  => p_reg_request.requested_end_date,
                  X_WF_ROLE_NAME    => p_reg_request.wf_role_name,
                  X_REG_SERVICE_CODE  => p_reg_request.reg_service_code,
                  X_AME_APPLICATION_ID => p_reg_request.ame_application_id,
                  X_AME_TRANSACTION_TYPE_ID => p_reg_request.ame_transaction_type_id,
                  X_JUSTIFICATION => p_reg_request.justification
    );
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.update_reg_request.end', 'End');
    end if;

  END update_reg_request;

  --
  -- Procedure        :  delete_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will delete a registration request
  --                     into the UMX_REG_REQUESTS table.
  --                     Before registration request can be inserted into
  --                     UMX_REG_REQUESTS table, this API will check to see
  --                     if the requester already have a valid association to
  --                     this access role in wf_local_user_role.  This API will
  --                     return null if there is a valid access role.
  -- Input Parameters (Mandatory):
  --    p_reg_request.reg_type_code: The code of the registration service type
  --                                 code.
  --
  -- At least one of the below parameter needs to be passed in as an input
  -- parameter:
  --    p_reg_request.wf_role_name: The user_id of the user who this
  --                                registration request is requested for.
  --    p_reg_request.reg_service_code: The Person Party ID of the person who
  --                                    this request is requested for.
  -- Input Parameters (non-Mandatory):
  --    p_extra_check: Check if user already has an association with the role.
  -- Output Parameters:
  --    x_reg_request_id: Registration Request ID
  --
  procedure delete_reg_request (
    p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE
  ) is
  BEGIN
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.delete_reg_request.begin',
                      'regRequestId: ' || p_reg_request_id);
    end if;

    UMX_REG_REQUESTS_PKG.DELETE_ROW (X_REG_REQUEST_ID => p_reg_request_id);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.delete_reg_request.end', 'End');
    end if;

  END delete_reg_request;

  --
  -- Function         :  is_username_available
  -- Type             :  PRIVATE
  -- Pre_reqs         :  None
  -- Description      :  It will query if username is being used in
  --                     FND_USER table.
  -- input parameters :
  -- @param     p_username
  --    Description:  username to perform the check
  --    Required   :  Y
  -- output           :
  --   Description : It will output boolean value of true or false.
  --                 true  - username is available
  --                 false - username is not available
  --
  function is_username_available (p_username in FND_USER.USER_NAME%TYPE) return boolean is

    cursor getUserFromFNDUSER (l_username in fnd_user.user_name%type) is
      select user_name
      from   fnd_user
      where  user_name = l_username;

    l_username_available boolean;
    l_username fnd_user.user_name%type;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.is_username_available.begin',
                      'username: ' || p_username);
    end if;

    l_username := (RTRIM (LTRIM (p_username)));

    if (p_username is null) or (l_username is null) then
      -- Username is a required input parameter.
      fnd_message.set_name('FND','UMX_COMMON_MISS_PARAM_MSG');
      fnd_message.set_token('PARAM', 'p_username');
      fnd_message.set_token('API', 'UMX_REG_REQUESTS_PVT.is_username_available');
      raise_application_error ('-20000', fnd_message.get);
    end if;

    open getUserFromFNDUSER (l_username);
    fetch getUserFromFNDUSER into l_username;
    if (getUserFromFNDUSER%notfound) then
      -- Query didn't find out username in FND_USER table,
      -- username is available
      l_username_available := true;

      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXVRRSB.is_username_available.end',
                        'usernameAvailable: true');
      end if;

    else
      -- Query returns something.
      -- username is not available
      l_username_available := false;

      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXVRRSB.is_username_available.end',
                        'usernameAvailable: false');
      end if;

    end if;
    close getUserFromFNDUSER;

    return l_username_available;

  end is_username_available;

  --
  -- Function         :  reserve_username
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will ...
  --                     1) Call fnd_user_pkg.reserve_username API to reserve
  --                        the requested username.
  --                     2) Update the UMX_REG_REQUESTS table with the
  --                        requested for username and requested by username
  --                        (if requested by is null).
  --
  --                     This API should be called when user requests a user
  --                     account
  --
  -- Input Parameters (Mandatory):
  -- p_reg_request_id       : Registration Request ID
  -- p_username             : username to be reserved
  -- p_owner                : 'SEED', 'CUST' (customer) or NULL
  --                          (fnd_global.user_id)
  -- p_unencrypted_password : Unencrypted password
  -- Output Parameters:
  --    Description : It will either return the user ID if the username is
  --                  successfully reserved or null if otherwise.
  --
  function reserve_username (
    p_reg_request_id             in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
    p_username                   in FND_USER.USER_NAME%TYPE,
    p_owner                      in varchar2 default null,
    p_unencrypted_password       in varchar2,
    p_session_number             in number default 0,
    p_last_logon_date            in date default null,
    p_description                in varchar2 default null,
    p_password_date              in date default null,
    p_password_accesses_left     in number default null,
    p_password_lifespan_accesses in number default null,
    p_password_lifespan_days     in number default null,
    p_email_address              in FND_USER.EMAIL_ADDRESS%TYPE default null,
    p_fax                        in varchar2 default null,
    p_person_party_id            in FND_USER.PERSON_PARTY_ID%TYPE default null,
    p_employee_id                in number default null,
    p_customer_id                in number default null,
    p_supplier_id                in number default null
  ) return fnd_user.user_id%type is

    l_user_id fnd_user.user_id%type;
    l_requested_by_user_id UMX_reg_requests.requested_by_user_id%type;
    l_reg_service_code UMX_reg_requests.reg_service_code%type;
     l_unencrypted_password varchar2(100);

   cursor getRequestedByUserId (p_reg_request_id in UMX_reg_requests.reg_request_id%type) is
      select requested_by_user_id
      from   umx_reg_requests
      where  reg_request_id = p_reg_request_id;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reserve_username.begin',
                      'regRequestId: ' || p_reg_request_id ||
                      ' | username: ' || p_username ||
                      ' | owner: ' || p_owner ||
                      ' | sessionNumber: ' || p_session_number ||
                      ' | lastLogonDate: ' || p_last_logon_date ||
                      ' | description: ' || p_description ||
                      ' | passwordDate: ' || p_password_date ||
                      ' | passwordAccessesLeft: ' || p_password_accesses_left ||
                      ' | passwordLifespanAccesses: ' || p_password_lifespan_accesses ||
                      ' | passwordLifespanDays: ' || p_password_lifespan_days ||
                      ' | emailAddress: ' || p_email_address ||
                      ' | fax: ' || p_fax ||
                      ' | personPartyId: ' || p_person_party_id);
    end if;

    -- First call fnd's resrve_username to reserve a username in FND user table.
    -- Still waiting for their true implementation from the proposal
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reserve_username',
                      'Before calling fnd_user_pkg.CreatePendingUser');
    end if;

	select REG_SERVICE_CODE into l_reg_service_code from umx_reg_requests  where REG_REQUEST_ID = p_reg_request_id;
    l_unencrypted_password := icx_call.decrypt(p_unencrypted_password);
    if (l_reg_service_code = 'UMX_USER_ACCOUNT_CREATION') then
        l_user_id := fnd_user_pkg.CreateUserId (
          x_user_name                  => p_username,
          x_owner                      => p_owner,
          x_unencrypted_password       => l_unencrypted_password,
          x_session_number             => p_session_number,
          x_start_date                 => FND_API.G_MISS_DATE,
          x_end_date                   => FND_API.G_MISS_DATE,
          x_description                => p_description,
          x_password_date              => nvl (p_password_date, fnd_user_pkg.null_date),
          x_password_accesses_left     => p_password_accesses_left,
          x_password_lifespan_accesses => p_password_lifespan_accesses,
          x_password_lifespan_days     => p_password_lifespan_days,
          x_employee_id                => p_employee_id,
          x_customer_id                => p_customer_id,
          X_SUPPLIER_ID                => P_SUPPLIER_ID,
          x_email_address              => p_email_address,
          x_fax                        => p_fax);
    else
		l_user_id := fnd_user_pkg.CreatePendingUser (
		  x_user_name                  => p_username,
		  x_owner                      => p_owner,
		  x_unencrypted_password       => l_unencrypted_password,
		  x_session_number             => p_session_number,
		  x_description                => p_description,
		  x_password_date              => nvl (p_password_date, fnd_user_pkg.null_date),
		  x_password_accesses_left     => p_password_accesses_left,
		  x_password_lifespan_accesses => p_password_lifespan_accesses,
		  x_password_lifespan_days     => p_password_lifespan_days,
		  x_email_address              => p_email_address,
		  x_fax                        => p_fax,
		  x_person_party_id            => p_person_party_id);
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reserve_username',
                      'After calling fnd_user_pkg.CreatePendingUser');
    end if;

    -- Find who is the requested_by_user_id.  If it is null, then
    -- we need to update the new user_id to the requested_by_user_id as well.
    open getRequestedByUserId (p_reg_request_id);
    fetch getRequestedByUserId into l_requested_by_user_id;
    if (getRequestedByUserId%notfound) then
      close getRequestedByUserId;
      raise_application_error ('-20000', '<<requested_by_user_id is missing in the umx_reg_requests table>>');
    end if;
    close getRequestedByUserId;

    if (l_requested_by_user_id is null) then
      -- requested_by_user_id is null, need to update with l_user_id.
      l_requested_by_user_id := l_user_id;
    end if;

    -- Update the Reg Requests table
    UMX_REG_REQUESTS_PKG.update_row (
        X_REG_REQUEST_ID        => p_reg_request_id,
        X_REQUESTED_BY_USER_ID  => l_requested_by_user_id,
        X_REQUESTED_FOR_USER_ID => l_USER_ID,
        X_REQUESTED_USERNAME    => p_username,
        X_STATUS_CODE           => 'PENDING');

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reserve_username.end',
                      'userId: ' || l_user_id);
    end if;

    return l_user_id;

  end reserve_username;

  --
  -- Procedure        :  approve_username_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will ...
  --                     1) Activiate the user account by calling
  --                        fnd_user_pkg.activate_user_account.
  --                     2) Set the status code to "APPROVED" in
  --                        UMX_REG_REQUESTS table.
  --
  --                     This API should be called from Self-Service Registration or
  --                     Admin Creation.
  -- Input Parameters :
  -- @param  p_reg_request_id
  --    Description : ID for the registration request
  --    Required    : Yes
  -- @param  p_username
  --    Description : The username of the user account.
  --    Required    : Yes
  -- @param  p_start_date
  --    Description : Starting active date of the user account.
  --    Required    : No
  -- @param  p_end_date
  --    Description : Inactive date of the user account.
  --    Required    : No
  -- @param  p_person_party_id
  --    Description : The person party ID of the user account.
  --    Required    : No

  -- Output           :
  --    None
  --    Description :
  --
  Procedure approve_username_reg_request (
    p_reg_request_id  in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
    p_username        in FND_USER.USER_NAME%TYPE,
    p_person_party_id in FND_USER.PERSON_PARTY_ID%TYPE,
    p_start_date      in FND_USER.START_DATE%TYPE default sysdate,
    p_end_date        in FND_USER.END_DATE%TYPE default null) is

    l_start_date fnd_user.start_date%type;
    eid fnd_user.employee_id%type;
    pid per_people_f.person_id%type;
    oid hz_parties.orig_system_reference%type;
    uid fnd_user.user_id%type;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.approve_username_reg_request.begin',
                      'regRequestId: ' || p_reg_request_id ||
                      ' | username: ' || p_username ||
                      ' | personPartyId: ' || p_person_party_id ||
                      ' | startDate: ' || p_start_date ||
                      ' | endDate: ' || p_end_date);
    end if;

    -- Call FND's activate_user_account API to activate the user account.
    fnd_user_pkg.EnableUser (
        username   => p_username,
        start_date => nvl (p_start_date, sysdate),
        end_date   => nvl (p_end_date, fnd_user_pkg.null_date));

	if (P_PERSON_PARTY_ID is not null) then

		--- Need to update the Person Party's ID in the FND_USER table
		fnd_user_pkg.UpdateUserParty (
			x_user_name        => p_username,
			x_owner            => NULL,
			x_person_party_id  => p_person_party_id);


        --   begin changes for hrms future employee and security attributes
        BEGIN
                SELECT user_id
                INTO   uid
                FROM   FND_USER
                WHERE  USER_NAME = UPPER(p_username) ;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                uid := NULL;
        END;
        BEGIN
                SELECT orig_system_reference
                INTO   oid
                FROM   HZ_PARTIES
                WHERE  party_id = p_person_party_id ;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                oid := NULL;
        END;
        --  If the user is an employee, then populate employee security attributes
        IF(oid LIKE 'PER%') THEN
                BEGIN
                        SELECT EMPLOYEE_ID
                        INTO   eid
                        FROM   FND_USER
                        WHERE  USER_NAME = UPPER(p_username) ;

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        eid := NULL;
                END;
                -- for future users employee id wont be populated even if orig system ref is PER%
                IF(EID IS NULL ) THEN
                        --   return the first person_id from HRMS , this would be used to populate FND_USER
                        BEGIN
                                SELECT person_id
                                INTO   pid
                                FROM   per_people_f
                                WHERE  party_id = p_person_party_id
                                   AND rownum   =1;

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                pid := NULL;
                        END;
                        -- Changes for employee security attributes     ( For HRMS Employee)  +   for future employee bug#7460262
                        -- calling UpdateUser would populate default security attributes, but for this customer one-off we
                        --  are explicitily inserting them. The insert commands should be removed for next releases
                        fnd_user_pkg.UpdateUser (x_user_name =>p_username, x_owner => NULL , x_employee_id =>pid);
                        eid :=pid;
                END IF;
                --  Changes for employee security attributes     ( For HRMS Employee)
                --  populate both the default security attributes with employee_id as value.
                BEGIN
                        -- ICX_HR_PERSON_ID
                        UPDATE AK_WEB_USER_SEC_ATTR_VALUES
                        SET    NUMBER_VALUE             = eid               ,
                               LAST_UPDATED_BY          = fnd_global.user_id,
                               LAST_UPDATE_DATE         = SYSDATE           ,
                               LAST_UPDATE_LOGIN        = fnd_global.login_id
                        WHERE  WEB_USER_ID              = uid
                           AND ATTRIBUTE_CODE           = 'ICX_HR_PERSON_ID'
                           AND ATTRIBUTE_APPLICATION_ID = 178;

                        IF (sql%rowcount = 0) THEN
                                INSERT
                                INTO   ak_web_user_sec_attr_values
                                       (
                                              web_user_id             ,
                                              attribute_code          ,
                                              attribute_application_id,
                                              number_value            ,
                                              created_by              ,
                                              creation_date           ,
                                              last_updated_by         ,
                                              last_update_date        ,
                                              last_update_login
                                       )
                                       VALUES
                                       (
                                              uid               ,
                                              'ICX_HR_PERSON_ID',
                                              178               ,
                                              eid               ,
                                              fnd_global.user_id,
                                              SYSDATE           ,
                                              fnd_global.user_id,
                                              SYSDATE           ,
                                              fnd_global.login_id
                                       );

                        END IF;
                        -- TO_PERSON_ID
                        UPDATE AK_WEB_USER_SEC_ATTR_VALUES
                        SET    NUMBER_VALUE             = eid              ,
                               LAST_UPDATED_BY          =fnd_global.user_id,
                               LAST_UPDATE_DATE         = SYSDATE          ,
                               LAST_UPDATE_LOGIN        = fnd_global.login_id
                        WHERE  WEB_USER_ID              = uid
                           AND ATTRIBUTE_CODE           = 'TO_PERSON_ID'
                           AND ATTRIBUTE_APPLICATION_ID = 178;

                        IF (sql%rowcount = 0) THEN
                                INSERT
                                INTO   ak_web_user_sec_attr_values
                                       (
                                              web_user_id             ,
                                              attribute_code          ,
                                              attribute_application_id,
                                              number_value            ,
                                              created_by              ,
                                              creation_date           ,
                                              last_updated_by         ,
                                              last_update_date        ,
                                              last_update_login
                                       )
                                       VALUES
                                       (
                                              uid               ,
                                              'TO_PERSON_ID'    ,
                                              178               ,
                                              eid               ,
                                              fnd_global.user_id,
                                              SYSDATE           ,
                                              fnd_global.user_id,
                                              SYSDATE           ,
                                              fnd_global.login_id
                                       );

                        END IF;
                EXCEPTION
                WHEN OTHERS THEN
                        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
                                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'fnd.plsql.UMXVRRSB.approve_username_reg_request.begin', 'When inserting security attributes');
                        END IF;
                END;
        END IF;
        --end changes for hrms and security attributes

	end if;

    -- Update the record in the Reg Requests table with status and party id
    UMX_REG_REQUESTS_PKG.update_row (
        X_REG_REQUEST_ID => p_reg_request_id,
        X_STATUS_CODE  => 'APPROVED',
        X_REQUESTED_FOR_PARTY_ID => p_person_party_id);


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.approve_username_reg_request.end', 'End');
    end if;

  end approve_username_reg_request;

  --
  -- Procedure        :  reject_cancel_username_reg_req
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will ...
  --                     1) Release the username by calling
  --                        fnd_user_pkg.release_username API.
  --                     2) Set the status code to "REJECT" or "CANCELLED" in
  --                        UMX_REG_REQUESTS table.
  --                     3) Remove the REQUESTED_FOR_USER_ID
  --                     4) If the REQUESTED_BY_USER_ID is the same as the
  --                        REQUESTED_FOR_USER_ID, remove the
  --                        REQUESTED_BY_USER_ID
  --
  -- Input Parameters :
  -- @param  p_reg_request_id
  --    Description : ID for the registration request
  --    Required    : Yes
  -- @param  p_username
  --    Description : Username of the account
  --    Required    : Yes
  -- @param  p_user_id
  --    Description : User ID of the account
  --    Required    : Yes
  -- @param  p_status_code
  --    Description : Status code of the reg request
  --    Required    : Yes
  -- Output           :
  --    None
  --    Description :
  --
  Procedure reject_cancel_username_reg_req (
    p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
    p_username       in FND_USER.USER_NAME%TYPE,
    p_user_id        in FND_USER.USER_ID%TYPE,
    p_status_code    in UMX_REG_REQUESTS.STATUS_CODE%TYPE) is

    l_requested_by_user_id umx_reg_requests.requested_by_user_id%type;

    cursor getRequestedByUserID (p_reg_request_id in UMX_reg_requests.reg_request_id%type) is
      select requested_by_user_id
      from   umx_reg_requests
      where  reg_request_id = p_reg_request_id;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reject_cancel_username_reg_req.begin',
                      'regRequestId: ' || p_reg_request_id ||
                      ' | username: ' || p_username ||
                      ' | userId: ' || p_user_id ||
                      ' | statusCode: ' || p_status_code);
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reject_cancel_username_reg_req.begin',
                      'Before calling fnd_user_pkg.RemovePendingUser');
    end if;

    -- Call FND's release_username API to release/delete the username
    fnd_user_pkg.RemovePendingUser (username => p_username);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reject_cancel_username_reg_req.begin',
                      'After calling fnd_user_pkg.RemovePendingUser');
    end if;

    -- Query the requested_by_user_id from UMX_reg_requests table
    -- If the requested_by_user_id is equal to the requested_for_user_id,
    -- make requested_by_user_id null to avoid dangling foreign key.
    open getRequestedByUserID (p_reg_request_id);
    fetch getRequestedByUserID into l_requested_by_user_id;
    if (getRequestedByUserID%notfound) then
      -- cannot find the record
      close getRequestedByUserID;
      raise_application_error ('-20000', '<<is this a correct p_reg_request_id?>>');
    end if;

    if (p_user_id = l_requested_by_user_id) then
      -- User requested his own account, we need to make the
      -- requested_by_user_id to null.
      l_requested_by_user_id := fnd_api.g_miss_num;
    end if;

    UMX_REG_REQUESTS_PKG.update_row (
        X_REG_REQUEST_ID        => p_reg_request_id,
        X_STATUS_CODE           => p_status_code,
        X_REQUESTED_FOR_USER_ID => fnd_api.g_miss_num,
        X_REQUESTED_BY_USER_ID  => l_requested_by_user_id);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reject_cancel_username_reg_req.end', 'End');
    end if;

  end reject_cancel_username_reg_req;

  --
  -- Procedure        :  reject_username_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will call reject_cancel_username_reg_req
  --                     with status code = "REJECTED".
  --
  --                     This API should be called from Self-Service
  --                     Registration or Admin Creation.
  -- Input Parameters :
  -- @param  p_reg_request_id
  --    Description : ID for the registration request
  --    Required    : Yes
  -- @param  p_user_id
  --    Description : User ID of the user account
  --    Required    : Yes
  -- @param  p_username
  --    Description : Username of the account
  --    Required    : Yes
  -- Output           :
  --    None
  --    Description :
  --
  Procedure reject_username_reg_request (
      p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
      p_user_id        in FND_USER.USER_ID%TYPE,
      p_username       in FND_USER.USER_NAME%TYPE) is

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reject_username_reg_request.begin',
                      'regRequestId: ' || p_reg_request_id ||
                      ' | userId: ' || p_user_id ||
                      ' | username: ' || p_username);
    end if;

    -- Call reject_cancel_username_reg_req with status code = 'REJECTED'
    reject_cancel_username_reg_req (
      p_reg_request_id => p_reg_request_id,
      p_username       => p_username,
      p_user_id        => p_user_id,
      p_status_code    => 'REJECTED');

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reject_username_reg_request.end', 'End');
    end if;

  end reject_username_reg_request;

  --
  -- Procedure        :  cancel_username_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will call reject_cancel_username_reg_req API
  --                     with status_code = 'CANCELLED'.
  --
  --                     This API should be called from Self-Service Registration or
  --                     Admin Creation.
  -- Input Parameters :
  -- @param  p_reg_request_id
  --    Description : ID for the registration request
  --    Required    : Yes
  -- @param  p_user_id
  --    Description : ID of the user account
  --    Required    : Yes
  -- @param  p_username
  --    Description : Username of the account
  --    Required    : Yes
  -- Output           :
  --    None
  --    Description :
  --
  Procedure cancel_username_reg_request (
      p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
      p_user_id        in FND_USER.USER_ID%TYPE,
      p_username       in FND_USER.USER_NAME%TYPE) is

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.cancel_username_reg_request.begin',
                      'regRequestId: ' || p_reg_request_id ||
                      ' | userId: ' || p_user_id ||
                      ' | username: ' || p_username);
    end if;

    -- Call reject_cancel_username_reg_req with status code = 'CANCELLED'
    reject_cancel_username_reg_req (
      p_reg_request_id => p_reg_request_id,
      p_username       => p_username,
      p_user_id        => p_user_id,
      p_status_code    => 'CANCELLED');

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.cancel_username_reg_request.end', 'End');
    end if;

  end cancel_username_reg_request;

  --
  -- Procedure        :  approve_reject_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will set the status code of a record in
  --                     UMX_REG_REQUESTS table.
  --
  -- Input Parameters :
  -- @param  p_reg_request_id
  --    Description : ID for the registration request
  --    Required    : Yes
  -- @param  p_status_code
  --    Description : Status code of the record in UMX_REG_REQUESTS table
  --    Required    : Yes
  -- Output           :
  --    None
  --    Description :
  --
  Procedure approve_reject_reg_request (
      p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
      p_status_code    in UMX_REG_REQUESTS.STATUS_CODE%type) is

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.approve_reject_reg_request.begin',
                      'regRequestId: ' || p_reg_request_id ||
                      ' | statusCode: ' || p_status_code);
    end if;

    -- update the record in the Reg Requests table with status to status_code
    UMX_REG_REQUESTS_PKG.update_row (X_REG_REQUEST_ID => p_reg_request_id,
                                     X_STATUS_CODE    => p_status_code);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.approve_reject_reg_request.end', 'End');
    end if;

  end approve_reject_reg_request;

  --
  -- Procedure        :  approve_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will approve_reject_reg_request to approve
  --                     the Reg Request in UMX_REG_REQUESTS table.
  --
  --                     This API should be called from ART or SMART.
  -- Input Parameters :
  -- @param  p_reg_request_id
  --    Description : ID for the registration request
  --    Required    : Yes
  -- Output           :
  --    None
  --    Description :
  --
  Procedure approve_reg_request (p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE) is
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.approve_reg_request.begin',
                      'regRequestId: ' || p_reg_request_id);
    end if;

    -- Call approve_reject_reg_request to update the record in
    -- UMX_REG_REQUESTS table.
    approve_reject_reg_request (p_reg_request_id => p_reg_request_id,
                                p_status_code    => 'APPROVED');

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.approve_reg_request.end', 'End');
    end if;

  end approve_reg_request;

  --
  -- Procedure        :  reject_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will approve_reject_reg_request to reject
  --                     the Reg Request in UMX_REG_REQUESTS table.
  --
  --                     This API should be called from ART or SMART.
  -- Input Parameters :
  -- @param  p_reg_request_id
  --    Description : ID for the registration request
  --    Required    : Yes
  -- Output           :
  --    None
  --    Description :
  --
  Procedure reject_reg_request (p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE) is
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reject_reg_request.begin',
                      'regRequestId: ' || p_reg_request_id);
    end if;

    -- Call approve_reject_reg_request to update the record in
    -- UMX_REG_REQUESTS table.
    approve_reject_reg_request (p_reg_request_id => p_reg_request_id,
                                p_status_code    => 'REJECTED');

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.reject_reg_request.end', 'End');
    end if;

  end reject_reg_request;

  -- Function
  --      getNextApproverPvt
  --
  -- Description
  --   Private API that will call the ame_api2.GetNextApprover API
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  -- OUT
  --   l_next_approver - result of the process based on which the next step is followed
  function getNextApproverPvt (p_ame_application_id      in varchar2,
                               p_ame_transaction_type_id in varchar2,
                               p_reg_request_id          in varchar2) return ame_util.approverRecord2 is

    l_approval_complete varchar2 (1);
    l_next_approvers ame_util.approverstable2;
    l_next_approver ame_util.approverRecord2;
    i number := 1;

  begin

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.getNextApproverPvt.begin',
                      'p_ame_application_id=' || p_ame_application_id ||
                      ' | p_ame_transaction_type_id=' || p_ame_transaction_type_id ||
                      ' | p_reg_request_id=' || p_reg_request_id);
    end if;

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.UMXVRRSB.getNextApproverPvt',
                      'Before calling ame_api2.getNextApprovers4 (' ||
                      p_ame_application_id || ',' ||
                      p_ame_transaction_type_id || ',' ||
                      p_reg_request_id || ',' ||
                      ame_util.booleanFalse || ')');
    end if;

    ame_api2.getNextApprovers4 (
        applicationIdIn              => to_number (p_ame_application_id),
        transactionTypeIn            => p_ame_transaction_type_id,
        transactionIdIn              => p_reg_request_id,
        flagApproversAsNotifiedIn    => ame_util.booleanFalse,
        approvalProcessCompleteYNOut => l_approval_complete,
        nextApproversOut             => l_next_approvers);

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.UMXVRRSB.getNextApproverPvt',
                      'After calling ame_api2.getNextApprovers4 (' ||
                      l_approval_complete || ')');
    end if;

    if (l_next_approvers.count > 0) then
      loop
        if (l_next_approvers.exists(i)) then
          -- We are exiting because our Workflow Process will only support
          -- serial approval.
          l_next_approver := l_next_approvers(i);

          if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.UMXVRRSB.getNextApproverPvt',
                'approver username:'|| l_next_approver.name);
          end if;

          exit;
        end if;
        i := i + 1;
        if (i > l_next_approvers.count) then
          exit;
        end if;
      end loop;
    end if;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.getNextApproverPvt.End',
                      'l_next_approver=' || l_next_approver.name);
    end if;

    return l_next_approver;
  end getNextApproverPvt;

  Procedure get_current_approver_info (p_reg_request_id      in varchar2,
                                       p_application_id      in varchar2 default null,
                                       p_transaction_type_id in varchar2 default null,
                                       x_approver_name       out nocopy varchar2,
                                       x_approver_email      out nocopy varchar2) is

    cursor get_req_request_info (p_reg_request_id in umx_reg_requests.reg_request_id%type) is
      select ame_application_id, ame_transaction_type_id
      from umx_reg_requests
      where reg_request_id = p_reg_request_id;

    l_current_approver ame_util.approverRecord2;
    l_application_id UMX_REG_REQUESTS.ame_application_id%type;
    l_transaction_type_id UMX_REG_REQUESTS.ame_transaction_type_id%type;

    l_role_info_tbl wf_directory.wf_local_roles_tbl_type;

  Begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_current_approver_info.begin',
                      'regRequestId: ' || p_reg_request_id ||
                      ' | applicationId: ' || p_application_id ||
                      ' | transactionTypeId: ' || p_transaction_type_id);
    end if;

    l_application_id := p_application_id;
    l_transaction_type_id := p_transaction_type_id;

    -- Try to get the required parameters if they are not being passed when calling this API.
    if (l_application_id is null or
        l_transaction_type_id is null) then
      -- If any of these required variable is NULL, then we will query from UMX_REG_REQUESTS table
      if (p_reg_request_id is not null) then
        -- OK, we can query and get the required info.
        open get_req_request_info (p_reg_request_id);
        fetch get_req_request_info into l_application_id, l_transaction_type_id;
        close get_req_request_info;
      else
        raise_application_error ('-200000', 'Required input parameters are missing.  The API get_current_approver_info needs to be called with p_reg_request_id or combination of p_application_id and l_transaction_type_id.');
      end if;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_current_approver_info',
                      'regRequestId: ' || p_reg_request_id ||
                      ' | applicationId: ' || l_application_id ||
                      ' | transactionTypeId: ' || l_transaction_type_id);
    end if;

    if ((p_reg_request_id is not null) and
        (l_application_id is not null) and
        (l_transaction_type_id is not null)) then
      -- Get the current Approver name
      -- only if the application ID, Reg Request ID and Transaction Type ID is not null.
      begin

        l_current_approver := getNextApproverPvt (l_application_id, l_transaction_type_id, p_reg_request_id);

      exception
        when others
          -- Log the error statement.
          then
            if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
              FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                              'fnd.plsql.UMXVRRSB.get_current_approver_info',
                              'Exception occurs when calling ame_api.getNextApprover.');
            end if;
      end;

      x_approver_name := l_current_approver.display_name;

      wf_directory.GetRoleInfo2 (role          => l_current_approver.name,
                                 role_info_tbl => l_role_info_tbl);

      x_approver_email := l_role_info_tbl(1).email_address;

    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_current_approver_info.end', 'End');
    end if;

  End get_current_approver_info;

  --
  -- Procedure        :  get_pend_acct_info
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will return the current approver's username
  --                     by calling ame_api.getNextApprover and email address.
  --                     Active from and Active to from UMX's Workflow
  -- Input Parameters :
  -- @param  p_requester_user_id
  --    Description : Requester user ID
  --    Required    : Yes (If x_reg_request_id is provided, p_requester_user_id is not required)
  -- @param x_reg_request_id
  --    Description : Reg Request ID
  --    Required    : Yes (If p_requester_user_id is provided, x_reg_request_id is not required)
  -- Output           :
  --    x_reg_request_id
  --      Description : Reg Request ID
  --    x_requested_for_username
  --      Description : Requested for Username
  --    x_approver_name
  --      Description: Formated name of the current approver
  --    x_approver_email_address
  --      Description: Email address of the current approver
  --    x_status_code
  --      Description: Status code of the request
  --    x_active_from
  --      Description: The string version of the user account's start date.
  --                   If the start date is before the sysdate, then it will
  --                   return "Date of approval".
  --    x_active_to
  --      Description: The string version of the user account's end date .
  --                   If the end date is null or x_active_to is "Date of approval",
  --                   then it will return null.
  --    x_justification
  --      Description: Justification
  --
  Procedure get_pend_acct_info (
    p_requester_user_id      in FND_USER.USER_ID%TYPE default null,
    x_reg_request_id         in out NOCOPY UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
    x_requested_for_username out NOCOPY FND_USER.USER_NAME%TYPE,
    x_approver_name          out NOCOPY varchar2,
    x_approver_email_address out NOCOPY FND_USER.EMAIL_ADDRESS%TYPE,
    x_status_code            out NOCOPY UMX_REG_REQUESTS.STATUS_CODE%TYPE,
    x_active_from            out NOCOPY varchar2,
    x_active_to              out NOCOPY varchar2,
    x_justification          out NOCOPY UMX_REG_REQUESTS.JUSTIFICATION%TYPE) is

    l_application_id AME_CALLING_APPS.FND_APPLICATION_ID%TYPE;
    l_transaction_type_id AME_CALLING_APPS.TRANSACTION_TYPE_ID%TYPE;

    cursor get_reg_req_info_from_userid (p_user_id in FND_USER.USER_ID%TYPE) is
      select reg_request_id, status_code, ame_application_id,
             ame_transaction_type_id, requested_username, justification
      from   umx_reg_requests
      where  requested_for_user_id = p_user_id
      and    requested_username is not null;

    cursor get_reg_req_info_from_regid (p_reg_req_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE) is
      select status_code, ame_application_id, ame_transaction_type_id, justification
      from   umx_reg_requests
      where  reg_request_id = p_reg_req_id;

    cursor getUserName (l_user_id in fnd_user.user_id%type) is
      select user_name
      from   fnd_user
      where  user_id = l_user_id;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_pend_acct_info.begin',
                      'requesterUserId: ' || p_requester_user_id ||
                      ' | regRequestId: ' || x_reg_request_id);
    end if;

    -- The first thing we have to do is to get the pending information from the
    -- UMX_REG_REQUESTS table.
    if (p_requester_user_id is not null) then

      -- Since the requester_user_id is not null, which means the request is a
      -- user account, query the reg req table base on the requester_user_id
      -- Get the regRequest ID, ame application id, ame transaction type id from
      -- the RegRequests table by the user id where the status is PENDING.
      open get_reg_req_info_from_userid (p_requester_user_id);
      fetch get_reg_req_info_from_userid into
        x_reg_request_id, x_status_code, l_application_id,
        l_transaction_type_id, x_requested_for_username, x_justification;
      if (get_reg_req_info_from_userid%notfound) then
        -- Bug 4312235: We have a pending user but we are missing a record in the
        -- reg request table.  We will exit now.
        close get_reg_req_info_from_userid;
        open getUserName (p_requester_user_id);
        fetch getUserName into x_requested_for_username;
        close getUserName;
        x_status_code := 'PENDING';
        return;
      end if;
      close get_reg_req_info_from_userid;

      -- Lowercase the username
      if (x_requested_for_username is not null) then
        x_requested_for_username := lower (x_requested_for_username);
      end if;

    elsif (x_reg_request_id is not null) then

      -- Get the ame application id, ame transaction type id from
      -- the RegRequests table by the regReqID where the status is PENDING.
      open get_reg_req_info_from_regid (x_reg_request_id);
      fetch get_reg_req_info_from_regid into
        x_status_code, l_application_id,
        l_transaction_type_id, x_justification;
      if (get_reg_req_info_from_regid%notfound) then
        close get_reg_req_info_from_regid;
        raise_application_error ('-20000', 'Cannot find AME info in the Req Request Table with req_request_id: ' || x_reg_request_id);
      end if;
      close get_reg_req_info_from_regid;

    else

      -- There is an error while calling this API:
      -- All required input parameters are null
      raise_application_error ('-20000', 'Both p_requester_user_id and x_reg_request_id is null while calling UMX_REG_REQUESTS_PVT.get_pend_acct_info API.');

    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_pend_acct_info',
                      'statusCode: ' || x_status_code);
    end if;

    -- Get Current Approver name and email address
    if (x_status_code = 'PENDING') then
      -- Status code could be 'VERIFYING', in that case, don't get the next approver.
      UMX_REG_REQUESTS_PVT.get_current_approver_info (p_reg_request_id      => x_reg_request_id,
                                                      p_application_id      => l_application_id,
                                                      p_transaction_type_id => l_transaction_type_id,
                                                      x_approver_name       => x_approver_name,
                                                      x_approver_email      => x_approver_email_address);
    end if;

    -- Get activeFrom and activeTo
    x_active_from := wf_engine.getitemattrtext (
        itemtype => UMX_REGISTRATION_UTIL.G_ITEM_TYPE,
        itemkey  => x_reg_request_id,
        aname    => 'REQUESTED_START_DATE');

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_pend_acct_info',
                      'activeFrom: ' || x_active_from);
    end if;

    if (x_active_from is null) or (fnd_date.canonical_to_date (x_active_from) <= sysdate) then
      -- active from is null, get fnd message for "Date of approval"
      fnd_message.set_name ('FND', 'UMX_USER_ACCT_ACTIVE_FROM_VAL');
      x_active_from := fnd_message.get;
    else
      x_active_from := fnd_date.date_to_displaydate ( dateval  => fnd_date.canonical_to_date (x_active_from) , calendar_aware => fnd_date.calendar_aware );
    end if;

    x_active_to := wf_engine.getitemattrtext (
        itemtype => UMX_REGISTRATION_UTIL.G_ITEM_TYPE,
        itemkey  => x_reg_request_id,
        aname    => 'REQUESTED_END_DATE');

    if (x_active_to is not null) then
      x_active_to := fnd_date.date_to_displaydate ( dateval  => fnd_date.canonical_to_date (x_active_to), calendar_aware => fnd_date.calendar_aware );
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_pend_acct_info.end',
                      'x_reg_request_id: ' || x_reg_request_id ||
                      ' | x_requested_for_username: ' || x_requested_for_username ||
                      ' | x_approver_name: ' || x_approver_name ||
                      ' | x_approver_email_address: ' || x_approver_email_address ||
                      ' | x_status_code: ' || x_status_code ||
                      ' | x_active_from: ' || x_active_from ||
                      ' | x_active_to: ' || x_active_to ||
                      ' | x_justification: ' || x_justification);
    end if;

  end get_pend_acct_info;

  --
  -- Procedure        :  get_pend_acct_info_with_userid
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will return the current approver's username
  --                     by calling ame_api.getNextApprover and email address.
  --                     Active from and Active to from UMX's Workflow
  -- Input Parameters :
  -- @param  p_requester_user_id
  --    Description : Requester user ID
  --    Required    : Yes
  -- Output           :
  --    x_reg_request_id
  --      Description: Reg Request ID
  --    x_requested_for_username
  --      Description: Requested for Username
  --    x_approver_name
  --      Description: Formated name of the current approver
  --    x_approver_email_address
  --      Description: Email address of the current approver
  --    x_status_code
  --      Description: Status code of the request
  --    x_active_from
  --      Description: The string version of the user account's start date.
  --                   If the start date is before the sysdate, then it will
  --                   return "Date of approval".
  --    x_active_to
  --      Description: The string version of the user account's end date .
  --                   If the end date is null or x_active_to is "Date of approval",
  --                   then it will return null.
  --    x_justification
  --      Description: Justification
  --
  Procedure get_pend_acct_info_with_userid (
    p_requester_user_id      in  FND_USER.USER_ID%TYPE,
    x_reg_request_id         out NOCOPY UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
    x_requested_for_username out NOCOPY FND_USER.USER_NAME%TYPE,
    x_approver_name          out NOCOPY varchar2,
    x_approver_email_address out NOCOPY FND_USER.EMAIL_ADDRESS%TYPE,
    x_status_code            out NOCOPY UMX_REG_REQUESTS.STATUS_CODE%TYPE,
    x_active_from            out NOCOPY varchar2,
    x_active_to              out NOCOPY varchar2,
    x_justification          out NOCOPY UMX_REG_REQUESTS.JUSTIFICATION%TYPE) is

    l_reg_request_id UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_pend_acct_info_with_userid.begin',
                      'p_requester_user_id: ' || p_requester_user_id);
    end if;

    UMX_REG_REQUESTS_PVT.get_pend_acct_info (
      p_requester_user_id      => p_requester_user_id,
      x_reg_request_id         => x_reg_request_id,
      x_requested_for_username => x_requested_for_username,
      x_approver_name          => x_approver_name,
      x_approver_email_address => x_approver_email_address,
      x_status_code            => x_status_code,
      x_active_from            => x_active_from,
      x_active_to              => x_active_to,
      x_justification          => x_justification);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_pend_acct_info_with_userid.end',
                      'x_reg_request_id: ' || x_reg_request_id ||
                      ' | x_requested_for_username: ' || x_requested_for_username ||
                      ' | x_approver_name: ' || x_approver_name ||
                      ' | x_approver_email_address: ' || x_approver_email_address ||
                      ' | x_status_code: ' || x_status_code ||
                      ' | x_active_from: ' || x_active_from ||
                      ' | x_active_to: ' || x_active_to ||
                      ' | x_justification: ' || x_justification);
    end if;

  end get_pend_acct_info_with_userid;

  --
  -- Procedure        :  get_pend_acct_info_with_reqid
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will return the current approver's username
  --                     by calling ame_api.getNextApprover and email address.
  -- Input Parameters :
  -- @param x_reg_request_id
  --    Description : Reg Request ID
  --    Required    : Yes
  -- Output           :
  --    x_approver_name
  --      Description: Formated name of the current approver
  --    x_approver_email_address
  --      Description: Email address of the current approver
  --    x_status_code
  --      Description: Status code of the request
  --    x_active_from
  --      Description: The string version of the user account's start date.
  --                   If the start date is before the sysdate, then it will
  --                   return "Date of approval".
  --    x_active_to
  --      Description: The string version of the user account's end date .
  --                   If the end date is null or x_active_to is "Date of approval",
  --                   then it will return null.
  --    x_justification
  --      Description: Justification
  --
  Procedure get_pend_acct_info_with_reqid (
    p_reg_request_id         in  UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
    x_approver_name          out NOCOPY varchar2,
    x_approver_email_address out NOCOPY FND_USER.EMAIL_ADDRESS%TYPE,
    x_status_code            out NOCOPY UMX_REG_REQUESTS.STATUS_CODE%TYPE,
    x_active_from            out NOCOPY varchar2,
    x_active_to              out NOCOPY varchar2,
    x_justification          out NOCOPY UMX_REG_REQUESTS.JUSTIFICATION%TYPE) is

    l_reg_request_id UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE;
    l_requested_for_username FND_USER.USER_NAME%TYPE;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_pend_acct_info_with_reqid.begin',
                      'p_reg_request_id: ' || p_reg_request_id);
    end if;

    l_reg_request_id := p_reg_request_id;

    UMX_REG_REQUESTS_PVT.get_pend_acct_info (
      x_reg_request_id         => l_reg_request_id,
      x_requested_for_username => l_requested_for_username,
      x_approver_name          => x_approver_name,
      x_approver_email_address => x_approver_email_address,
      x_status_code            => x_status_code,
      x_active_from            => x_active_from,
      x_active_to              => x_active_to,
      x_justification          => x_justification);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_pend_acct_info_with_reqid.end',
                      'x_approver_name:' || x_approver_name ||
                      ' | x_approver_email_address: ' || x_approver_email_address ||
                      ' | x_status_code: ' || x_status_code ||
                      ' | x_active_from: ' || x_active_from ||
                      ' | x_active_to: ' || x_active_to ||
                      ' | x_justification: ' || x_justification);
    end if;

  end get_pend_acct_info_with_reqid;

  --
  -- Procedure        :  get_error_wf_info
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will call wf_engine.iteminfo to get the status
  --                     of the main UMX Workflow and all its event subscribers.
  -- Input Parameters (Mandatory):
  --    p_reg_request_id: Registration Request ID
  --
  -- Output Parameters:
  --    x_itemtype: Workflow's Item Type
  --    x_itemkey:  Workflow's Item Key
  --    x_status:   Workflow's Status
  --    x_result:   Result
  --    x_actid:    Activity ID
  --    x_errname:  Error Name
  --    x_errmsg:   Error Message
  --    x_errstack: Error Stack
  --
  --
  procedure get_error_wf_info (p_reg_request_id in wf_items.item_type%type,
                               x_itemtype       out nocopy wf_items.item_type%type,
                               x_itemkey        out nocopy wf_items.item_key%type,
                               x_status         out nocopy varchar2,
                               x_result         out nocopy varchar2,
                               x_actid          out nocopy number,
                               x_errname        out nocopy varchar2,
                               x_errmsg         out nocopy varchar2,
                               x_errstack       out nocopy varchar2) IS

    cursor get_child_workflow is
      select * from wf_items
      where parent_item_type = umx_registration_util.g_item_type
      and   parent_item_key  = p_reg_request_id;

    child get_child_workflow%rowtype;

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_error_wf_info.begin',
                      'p_reg_request_id: ' || p_reg_request_id);
    end if;

    -- Find the status of the main workflow first
    x_itemtype := umx_registration_util.g_item_type;
    x_itemkey := p_reg_request_id;
    wf_engine.iteminfo (itemtype => x_itemtype,
                        itemkey  => x_itemkey,
                        status   => x_status,
                        result   => x_result,
                        actid    => x_actid,
                        errname  => x_errname,
                        errmsg   => x_errmsg,
                        errstack => x_errstack);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_error_wf_info',
                      'x_status: ' || x_status);
    end if;

    if not (x_status = 'ERROR') then
      for child in get_child_workflow
        loop
          x_itemtype := child.item_type;
          x_itemkey := child.item_key;
          wf_engine.iteminfo (itemtype => x_itemtype,
                              itemkey  => x_itemkey,
                              status   => x_status,
                              result   => x_result,
                              actid    => x_actid,
                              errname  => x_errname,
                              errmsg   => x_errmsg,
                              errstack => x_errstack);
          exit when x_status = 'ERROR';
        end loop;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_error_wf_info.end',
                      'x_itemtype: ' || x_itemtype ||
                      ' | x_itemkey: ' || x_itemkey ||
                      ' | x_status: ' || x_status ||
                      ' | x_result: ' || x_result ||
                      ' | x_actid: ' || x_actid ||
                      ' | x_errname: ' || x_errname ||
                      ' | x_errmsg: ' || x_errmsg ||
                      ' | x_errstack: ' || x_errstack);
    end if;

  END get_error_wf_info;

  --
  -- Procedure        :  get_error_wf_info
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will call wf_engine.iteminfo to get the status
  --                     of the main UMX Workflow and all its event subscribers.
  -- Input Parameters (Mandatory):
  --    p_user_id: User ID of the requester
  --
  -- Output Parameters:
  --    x_itemtype: Workflow's Item Type
  --    x_itemkey:  Workflow's Item Key
  --    x_status:   Workflow's Status
  --    x_result:   Result
  --    x_actid:    Activity ID
  --    x_errname:  Error Name
  --    x_errmsg:   Error Message
  --    x_errstack: Error Stack
  --
  --
  procedure get_error_wf_info (p_user_id        in fnd_user.user_id%type,
                               x_itemtype       out nocopy wf_items.item_type%type,
                               x_itemkey        out nocopy wf_items.item_key%type,
                               x_status         out nocopy varchar2,
                               x_result         out nocopy varchar2,
                               x_actid          out nocopy number,
                               x_errname        out nocopy varchar2,
                               x_errmsg         out nocopy varchar2,
                               x_errstack       out nocopy varchar2) IS

    cursor get_reg_req_id_with_user_id (l_user_id in fnd_user.user_id%type) is
      select reg_request_id
      from   umx_reg_requests
      where  requested_for_user_id = l_user_id;

    l_reg_req_id umx_reg_requests.reg_request_id%type;

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_error_wf_info.begin',
                      'p_user_id: ' || p_user_id);
    end if;

    -- Get the reg request id from user id
    open get_reg_req_id_with_user_id (p_user_id);
    fetch get_reg_req_id_with_user_id into l_reg_req_id;
    if (get_reg_req_id_with_user_id%notfound) then
      -- There is a problem here.  A pending user but with no record in the
      -- Reg Table.
      close get_reg_req_id_with_user_id;
      x_status := 'PENDING';
    else
      close get_reg_req_id_with_user_id;

      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXVRRSB.get_error_wf_info',
                        'l_reg_req_id: ' || l_reg_req_id);
      end if;

      get_error_wf_info (p_reg_request_id => l_reg_req_id,
                         x_itemtype       => x_itemtype,
                         x_itemkey        => x_itemkey,
                         x_status         => x_status,
                         x_result         => x_result,
                         x_actid          => x_actid,
                         x_errname        => x_errname,
                         x_errmsg         => x_errmsg,
                         x_errstack       => x_errstack);
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.get_error_wf_info.end',
                      'x_itemtype: ' || x_itemtype ||
                      ' | x_itemkey: ' || x_itemkey ||
                      ' | x_status: ' || x_status ||
                      ' | x_result: ' || x_result ||
                      ' | x_actid: ' || x_actid ||
                      ' | x_errname: ' || x_errname ||
                      ' | x_errmsg: ' || x_errmsg ||
                      ' | x_errstack: ' || x_errstack);
    end if;

  END get_error_wf_info;

  --
  -- Function    :  is_pend_request_error
  -- Type        :  Private
  -- Pre_reqs    :  None
  -- Description :  This API will call wf_engine.iteminfo to get the status
  --                of the main UMX Workflow and all its event subscribers.
  --                It will return 'Y' if account is in error stage and 'N' if otherwise.
  -- Input Parameters (Mandatory):
  --   p_reg_request_id: Registration Request ID
  --
  -- Output Parameter:
  --   It will return 'Y' if pending account has error and 'N' if otherwise.
  --
  function is_pend_request_error (p_reg_request_id in umx_reg_requests.reg_request_id%type) return varchar2 is

    l_itemtype wf_items.item_type%type;
    l_itemkey wf_items.item_key%type;
    l_status varchar2(8);
    l_result varchar2(30);
    l_actid number;
    l_errname varchar2(30);
    l_errmsg varchar2(2000);
    l_errstack varchar2(4000);

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.is_pend_request_error.begin',
                      'p_reg_request_id: ' || p_reg_request_id);
    end if;

    get_error_wf_info (p_reg_request_id => p_reg_request_id,
                       x_itemtype       => l_itemtype,
                       x_itemkey        => l_itemkey,
                       x_status         => l_status,
                       x_result         => l_result,
                       x_actid          => l_actid,
                       x_errname        => l_errname,
                       x_errmsg         => l_errmsg,
                       x_errstack       => l_errstack);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.is_pend_request_error.end',
                      'l_status: ' || l_status);
    end if;

    if (l_status = 'ERROR') then
      return ('Y');
    else
      return ('N');
    end if;

  END is_pend_request_error;

  --
  -- Function    :  is_pend_account_error
  -- Type        :  Private
  -- Pre_reqs    :  None
  -- Description :  This API will call wf_engine.iteminfo to get the status
  --                of the main UMX Workflow and all its event subscribers.
  --                It will return 'Y' if account is in error stage and 'N' if otherwise.
  -- Input Parameters (Mandatory):
  --   p_user_id: User ID of the requester
  --
  -- Output Parameter:
  --   It will return 'Y' if pending account has error and 'N' if otherwise.
  --
  function is_pend_account_error (p_user_id in fnd_user.user_id%type) return varchar2 is

    l_itemtype wf_items.item_type%type;
    l_itemkey wf_items.item_key%type;
    l_status varchar2(8);
    l_result varchar2(30);
    l_actid number;
    l_errname varchar2(30);
    l_errmsg varchar2(2000);
    l_errstack varchar2(4000);

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.is_pend_account_error.begin',
                      'p_user_id: ' || p_user_id);
    end if;

    get_error_wf_info (p_user_id   => p_user_id,
                       x_itemtype  => l_itemtype,
                       x_itemkey   => l_itemkey,
                       x_status    => l_status,
                       x_result    => l_result,
                       x_actid     => l_actid,
                       x_errname   => l_errname,
                       x_errmsg    => l_errmsg,
                       x_errstack  => l_errstack);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVRRSB.is_pend_account_error.end',
                      'l_status: ' || l_status);
    end if;

    if (l_status = 'ERROR') then
      return ('Y');
    else
      return ('N');
    end if;

  END is_pend_account_error;

  --
  -- Procedure        :  remove_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will remove pending request from ART page
  --                     and cancel the registration Workflow
  --                     This API should be called from ART.
  -- Input Parameters :
  -- @param  p_reg_request_id
  --    Description : ID for the registration request
  --    Required    : Yes
  -- Output           :
  -- @param x_result
  --    Description : Returns 'S' on Success and 'E' on Error
  procedure remove_reg_request (p_reg_request_id in umx_reg_requests.reg_request_id%type,
    x_result         out nocopy varchar2) Is
    l_ame_transaction_type_id wf_activity_attributes.text_default%type;
    l_ame_application_id  wf_activity_attributes.text_default%type;
    l_current_approver ame_util.approverRecord2;
	l_status varchar2(50);
    l_result varchar2(50);
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      Fnd_Log.String (Fnd_Log.Level_Procedure,
                      'fnd.plsql.UMXVRRSB.remove_reg_request.begin',
                      'regRequestId: ' || p_reg_request_id);
    end if;

    select ame_application_id , ame_transaction_type_id into l_ame_application_id , l_ame_transaction_type_id from umx_reg_requests where reg_request_id = p_reg_request_id;

    if(l_ame_application_id is not null and l_ame_transaction_type_id is not null) then
       Begin
         --populate the l_current_approver record
         l_current_approver := umx_reg_requests_pvt.getNextApproverPvt (p_ame_application_id      => l_ame_application_id,
                                                                        p_ame_transaction_type_id => l_ame_transaction_type_id,
                                                                        p_reg_request_id          => p_reg_request_id);

			   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			   fnd_log.string (fnd_log.level_statement,
							'fnd.plsql.UMXVRRSB.Remove_Reg_Request',
							'approver username:'|| l_current_approver.name);
			   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
							'fnd.plsql.UMXVRRSB.Remove_Reg_Request',
							'Before calling ame_api2.updateapprovalstatus (' ||
							l_ame_application_id || ',' || l_ame_transaction_type_id || ',' ||
							p_reg_request_id || ',' || l_current_approver.name || ')');
			   end if;

			   l_current_approver.approval_status := ame_util.rejectstatus;
			   ame_api2.updateapprovalstatus (applicationidin   => l_ame_application_id,
											transactiontypein => l_ame_transaction_type_id,
											transactionIdIn   => p_reg_request_id,
											approverin        => l_current_approver);

			   if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
			   fnd_log.string (fnd_log.level_statement,
							'fnd.plsql.UMXVRRSB.Remove_Reg_Request',
							'After calling ame_api2.updateapprovalstatus.');
			   End If;

			exception
			 when others
          -- Suppress it for now, we will log the error statement.
          then
            if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
              FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                              'fnd.plsql.UMXVRRSB.Remove_Reg_Request',
                              'Exception occurs when calling ame_api.getNextApprover.');
            end if;
			end;
    end if;

    -- Call approve_reject_reg_request to update the record in
    -- UMX_REG_REQUESTS table.
    reject_reg_request (p_reg_request_id => p_reg_request_id);

	-- Kill the WF processes and notifications
    wf_engine.itemstatus('UMXREGWF',p_reg_request_id,l_status,l_result);

    if (l_status <> 'COMPLETE' ) then
      wf_engine.abortprocess(itemtype => 'UMXREGWF',
      itemkey => p_reg_request_id,
      process => 'ADDITION_ACCESS_REQUEST',
      cascade => true);
      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
              fnd_log.string (fnd_log.level_procedure,
                      'fnd.plsql.UMXVRRSB.remove_reg_request', 'Registration WF aborted');
       end if;
    end if;

    x_result := 'S';
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      fnd_log.string (fnd_log.level_procedure,
                      'fnd.plsql.UMXVRRSB.remove_reg_request.end', 'End');
    end if;

    exception
      when others
        then
            if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
              FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                              'fnd.plsql.UMXVRRSB.Remove_Reg_Request',
                              'Exception occurs in Remove_Reg_Request.');
            end if;
            x_result := 'E';

  End remove_Reg_Request;

END UMX_REG_REQUESTS_PVT;

/
