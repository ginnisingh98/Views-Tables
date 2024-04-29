--------------------------------------------------------
--  DDL for Package UMX_REGISTRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_REGISTRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: UMXVREGS.pls 120.1.12010000.3 2014/12/19 09:14:20 avelu ship $ */

  TYPE UMX_REGISTRATION_DATA IS RECORD (ATTR_NAME VARCHAR2(30), ATTR_VALUE VARCHAR2(2000));

  TYPE UMX_REGISTRATION_DATA_TBL IS TABLE OF UMX_REGISTRATION_DATA INDEX BY BINARY_INTEGER;

  G_REG_SERVICE_CODE        constant varchar2(30) := 'reg_service_code';
  G_REG_SERVICE_TYPE        constant varchar2(30) := 'reg_service_type';
  G_REG_SERVICE_DESCRIPTION constant varchar2(30) := 'regsvc_descrirption';
  G_REG_SERVICE_APP_ID      constant varchar2(30) := 'application_id';
  G_REG_FUNCTION_NAME       constant varchar2(30) := 'reg_function_name';
  G_REG_SERVICE_DISP_NAME   constant varchar2(30) := 'regsvc_disp_name';
  G_REG_REQUEST_ID          constant varchar2(30) := 'reg_request_id';
  G_REG_REQUEST_STATUS      constant varchar2(30) := 'status_code';
  G_IDENTITY_VERIFY_REQD    constant varchar2(30) := 'identity_verification_reqd';
  G_REQUESTED_FOR_USER_ID   constant varchar2(30) := 'requested_for_user_id';
  G_REQUESTED_BY_USER_ID    constant varchar2(30) := 'requested_by_user_id';
  G_REQUESTED_USERNAME      constant varchar2(30) := 'requested_username';
  G_JUSTIFICATION           constant varchar2(30) := 'justification';
  G_REQUESTED_START_DATE    constant varchar2(30) := 'requested_start_date';
  G_REQUESTED_END_DATE      constant varchar2(30) := 'requested_end_date';
  G_WF_NOTIFICATION_EVENT   constant varchar2(30) := 'wf_notification_event';
  G_WF_ROLE_NAME            constant varchar2(30) := 'wf_role_name';
  G_AME_APPLICATION_ID      constant varchar2(30) := 'ame_application_id';
  G_AME_TXN_TYPE_ID         constant varchar2(30) := 'ame_transaction_type_id';
  G_REQUESTED_FOR_PARTY_ID  constant varchar2(30) := 'person_party_id';
  G_WF_BUS_LOGIC_EVENT         constant varchar2(30) := 'custom_event_name';
  G_EMPLOYEE_ID             constant varchar2(30) := 'employee_id';
  G_CUSTOMER_ID             constant varchar2(30) := 'customer_id';
  G_SUPPLIER_ID             constant varchar2(30) := 'supplier_id';
  G_DESCRIPTION             CONSTANT VARCHAR2(30) := 'description';
  G_FAX                     constant varchar2(30) := 'fax';
  G_PASSWORD_LIFESPAN_ACCESSES  constant varchar2(30) := 'password_lifespan_accesses';
  G_PASSWORD_LIFESPAN_DAYS      CONSTANT VARCHAR2(30) := 'password_lifespan_days';

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
  procedure UMX_PROCESS_REG_REQUEST (p_registration_data  IN OUT NOCOPY UMX_REGISTRATION_DATA_TBL,
 			     x_return_status out NOCOPY varchar2,
 			     x_message_data out NOCOPY varchar2);

  function  format_address_lov(p_party_id number) return varchar2;

  procedure POPULATE_REG_DATA(p_registration_data IN OUT NOCOPY UMX_REGISTRATION_DATA_TBL);

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
 			     x_message_data out NOCOPY varchar2);

/**
   * Function    :  GET_PHONE_NUMBER
   * Type        :  Private
   * Description :  Retrieve phone number
   * Parameters  :
   * input parameters
   * @param
   *   p_person_id
   *     description:  Person Id of the person
   *     required   :  Y
   *     validation :  Must be a valid person_id
   *     default    :  null
   * output parameters
   * @return        : Phone Number of the person
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  function GET_PHONE_NUMBER(p_person_id  in per_all_people_f.person_id%type) return varchar2;
/**
   * Function    :  GET_PERSON_ID
   * Type        :  Private
   * Description :  Retrieve person_id from party_id
   * Parameters  :
   * input parameters
   * @param
   *   p_party_id
   *     description:  Party Id of the person
   *     required   :  Y
   *     validation :  Must be a valid party_id
   *     default    :  null
   * output parameters
   * @return        : Person Id of the user
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  function GET_PERSON_ID (p_party_id  in hz_parties.party_id%type) return number;
/**
   * Function    :  GET_MANAGER_NAME
   * Type        :  Private
   * Description :  Find Manager's Name
   * Parameters  :
   * input parameters
   * @param
   *   p_person_id
   *     description:  Person Id of the person
   *     required   :  Y
   *     validation :  Must be a valid person_id
   *     default    :  null
   * output parameters
   * @return        : Name of the manager of the person
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  function GET_MANAGER_NAME(p_person_id  in per_all_people_f.person_id%type) return varchar2;

 /**
   * Function    :  GET_JOB_TITLE
   * Type        :  Private
   * Description :  Find Job Title
   * Parameters  :
   * input parameters
   * @param
   *   p_person_id
   *     description:  Person Id of the person
   *     required   :  Y
   *     validation :  Must be a valid person_id
   *     default    :  null
   * output parameters
   * @return        : Job Title
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  function GET_JOB_TITLE(p_person_id  in per_all_people_f.person_id%type) return varchar2;

end UMX_REGISTRATION_PVT;

/
