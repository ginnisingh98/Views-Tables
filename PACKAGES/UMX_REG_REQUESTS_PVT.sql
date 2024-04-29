--------------------------------------------------------
--  DDL for Package UMX_REG_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_REG_REQUESTS_PVT" AUTHID CURRENT_USER AS
/* $Header: UMXVRRSS.pls 120.2.12010000.3 2014/12/19 08:56:29 avelu ship $ */

  --
  -- RECORD: REG_REQUEST_TYPE
  -- REG_REQUEST_ID             : Registration Request ID
  -- REG_SERVICE_TYPE           : The code of the registration service type
  --                              code.
  -- STATUS_CODE                : Request Status Code (UMX_REQUEST_STATUS
  --                              FND Lookup)
  -- REQUESTED_BY_USER_ID       : The user id of the user who requested this
  --                              registration request.
  -- REQUESTED_FOR_USER_ID      : The user_id of the user who this registration
  --                              request is requested for.
  -- REQUESTED_FOR_PARTY_ID     : The Person Party ID of the person who this
  --                              request is requested for.
  -- REQUESTED_USERNAME         : The username requested for a user account
  -- WF_ROLE_NAME               : The name of the WF access role
  -- REG_SERVICE_CODE           : This is the Registration Service Code.
  --                              This is a null value ONLY when an access role
  --                              doesn't have the relationship with
  --                              registration service code.
  -- AME_APPLICATION_ID         : Application ID of the AME Transaction.
  -- AME_TRANSACTION_TYPE_ID    : AME's Transaction Type ID.
  -- JUSTIFICATION              : Justification
  -- WF_EVENT_NAME              : The event name of the notification event
  -- EMAIL_VERIFICATION_FLAG    : Flag for email verfication
  --
  TYPE REG_REQUEST_TYPE IS RECORD (
    REG_REQUEST_ID             UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
    REG_SERVICE_TYPE           UMX_REG_REQUESTS.REG_SERVICE_TYPE%TYPE,
    STATUS_CODE                UMX_REG_REQUESTS.STATUS_CODE%TYPE,
    REQUESTED_BY_USERID        UMX_REG_REQUESTS.REQUESTED_BY_USER_ID%TYPE DEFAULT NULL,
    REQUESTED_FOR_USER_ID      UMX_REG_REQUESTS.REQUESTED_FOR_USER_ID%TYPE DEFAULT NULL,
    REQUESTED_FOR_PARTY_ID     UMX_REG_REQUESTS.REQUESTED_FOR_PARTY_ID%TYPE DEFAULT NULL,
    REQUESTED_USERNAME         UMX_REG_REQUESTS.REQUESTED_USERNAME%TYPE DEFAULT NULL,
    REQUESTED_START_DATE       DATE  DEFAULT SYSDATE,
    REQUESTED_END_DATE         DATE  DEFAULT NULL,
    WF_ROLE_NAME               UMX_REG_REQUESTS.WF_ROLE_NAME%TYPE DEFAULT NULL,
    REG_SERVICE_CODE           UMX_REG_REQUESTS.REG_SERVICE_CODE%TYPE DEFAULT NULL,
    AME_APPLICATION_ID         UMX_REG_REQUESTS.AME_APPLICATION_ID%TYPE DEFAULT NULL,
    AME_TRANSACTION_TYPE_ID    UMX_REG_REQUESTS.AME_TRANSACTION_TYPE_ID%TYPE DEFAULT NULL,
    JUSTIFICATION              UMX_REG_REQUESTS.JUSTIFICATION%TYPE DEFAULT NULL,
    WF_EVENT_NAME              WF_EVENTS.NAME%TYPE DEFAULT NULL,
    EMAIL_VERIFICATION_FLAG    UMX_REG_SERVICES_B.EMAIL_VERIFICATION_FLAG%TYPE DEFAULT 'N'
  );

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
  function is_username_available (
    p_username in FND_USER.USER_NAME%TYPE
  ) return boolean;

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
  procedure update_reg_request (
    p_reg_request    in out NOCOPY  REG_REQUEST_TYPE
  );

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
    p_reg_request_id    in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE
  );

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
  ) return fnd_user.user_id%type;

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
  -- @param  p_user_id
  --    Description : ID of the user account
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
    p_end_date        in FND_USER.END_DATE%TYPE default null
  );

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
    p_username       in FND_USER.USER_NAME%TYPE
  );

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
    p_username       in FND_USER.USER_NAME%TYPE
  );

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
  Procedure approve_reg_request (
    p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE
  );

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
  Procedure reject_reg_request (
    p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE
  );

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
  --      Description: Name of the current approver
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
      x_justification          out NOCOPY UMX_REG_REQUESTS.JUSTIFICATION%TYPE);

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
  --      Description: Name of the current approver
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
      x_justification          out NOCOPY UMX_REG_REQUESTS.JUSTIFICATION%TYPE);

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
                               x_errstack       out nocopy varchar2);

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
                               x_errstack       out nocopy varchar2);

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
  function is_pend_request_error (p_reg_request_id in umx_reg_requests.reg_request_id%type) return varchar2;

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
  function is_pend_account_error (p_user_id in fnd_user.user_id%type) return varchar2;

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
                               p_reg_request_id          in varchar2) return ame_util.approverRecord2;

  --
  -- Procedure        :  remove_reg_request
  -- Type             :  Private
  -- Pre_reqs         :  None
  -- Description      :  This API will remove pending request from ART page
  --                     and cancel the registration Workflow
  --
  --                     This API should be called from ART.
  -- Input Parameters :
  -- @param  p_reg_request_id
  --    Description : ID for the registration request
  --    Required    : Yes
  -- Output           :
  -- @param x_result
  --    Description : Returns 'S' on Success and 'E' on Error
  procedure remove_reg_request (
    p_reg_request_id in umx_reg_requests.reg_request_id%type,
    x_result         out nocopy varchar2
  );

END UMX_REG_REQUESTS_PVT;

/
