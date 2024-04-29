--------------------------------------------------------
--  DDL for Package UMX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_PUB" AUTHID CURRENT_USER AS
/* $Header: UMXPRRSS.pls 120.5.12010000.3 2009/07/22 20:16:23 jstyles ship $ */
/*#
 * This is the public interface that provides APIs to execute various
 * functions for the RBAC support of User Management (UMX).
 * @rep:scope public
 * @rep:product UMX
 * @rep:displayname User Management Public Interface
 * @rep:category BUSINESS_ENTITY UMX_ROLE_REG_REQUESTS
 * @rep:category BUSINESS_ENTITY UMX_ACCT_REG_REQUESTS
 * @rep:category BUSINESS_ENTITY UMX_ROLE
 */

  -- Function         :  get_attribute_value
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API, is intended to be called by the AME's Rule,
  --                     will return the value of the registration data.
  -- input parameters (Mandatory):
  --   p_reg_request_id : Registration Request ID
  --   p_attribute_name : Attribute name
  -- Output           :
  --   Description : Attribute value
  --
  /*#
   * This API, is intended to be called by the AME's Rule,
   * will return the value of the registration data.
   * @param p_reg_request_id The Registration Request ID
   * @paraminfo {@rep:required}
   * @param p_attribute_name The name of the registration data.
   * @paraminfo {@rep:required}
   * @return The value of the registration data.
   * @rep:displayname Get the value from the User Management's Registration Data.
   * @rep:scope public
   * @rep:lifecycle active
   */
  function get_attribute_value (
    p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
    p_attribute_name in varchar2
  ) return varchar2;

  --
  -- Procedure        :  assign_role
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API assigns role to a user either by direct assigning or
  --                     launching the UMX Registration Workflow process.
  -- Input Parameters (Mandatory):
  --   p_registration_data : Table of record type of UMX_REGISTRATION_DATA
  -- Output Parameters:
  --   p_registration_data : Table of record type of UMX_REGISTRATION_DATA
  --
  /*#
   * This API assigns a role to a user either by direct assigning or
   * launching the UMX Registration Workflow process.
   * @param p_registration_data The registration data
   * @paraminfo {@rep:required}
   * @rep:displayname Assign Role to a User
   * @rep:businessevent oracle.apps.fnd.umx.rolerequested
   * @rep:businessevent oracle.apps.fnd.umx.requestapproved
   * @rep:scope public
   * @rep:lifecycle active
   */
procedure assign_role (p_registration_data in out NOCOPY UMX_REGISTRATION_PVT.UMX_REGISTRATION_DATA_TBL);

  procedure assign_role (p_registration_data in out NOCOPY UMX_REGISTRATION_PVT.UMX_REGISTRATION_DATA_TBL
    , x_return_status out NOCOPY varchar2
 		, x_message_data out NOCOPY varchar2);

  --
  -- Procedure        :  updateWfAttribute
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API can be invoked by anyone who registers a PL/SQL subscription to
  --                     UMX raised Business Events during registration. This API will update the main
  -- 			 User Management workflow event(payload) object and also the corresponding
  --			 workflow attribute. If p_attr_name doesn't exist in the workflow, one is created.
  --                     This API can also be called by anyone who has a custom notification workflow
  --			 defined, and want this name value pair to be reflected in the main workflow;
  --			 this name value pair will be available to rest of subscriptions and workflow
  --			 activities.
  -- Input Parameters (Mandatory):
  -- p_event : Oracle Workflow WF_EVENT_T object type
  -- p_attr_name : Varchar2, name of the attribute, maps to workflow attribute name.
  -- p_attr_value : varchar2, value of the attribute, maps to Workflow attribute string value.
  -- Output Parameters:
  -- p_event : Oracle Workflow WF_EVENT_T object type
  --
/*#
 * This API Adds or Updates an attribute to the User Management Registration
 * workflow. This method is to be used in any synchronous subscriptions, for
 * events raised during registration process.
 * @param p_event WF_EVENT_T
 * @param p_attr_name attribute name
 * @param p_attr_value attribute value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update User Management Workflow attribute.
 */
  procedure updateWfAttribute (p_event in out NOCOPY WF_EVENT_T,
  			       p_attr_name in VARCHAR2 DEFAULT NULL,
			       p_attr_value in VARCHAR2 DEFAULT NULL);

  --
  -- Procedure        :  notification_process_done
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API will restart the sleeping main workflow.
/*#
 * This API signifies the end of the notification workflow, it raises an
 * event which will restart the main User Management workflow
 * This method should be used in the scenario of customizing the Notification
 * workflows. This Notification workflow must have been started by the event,
 * which was defined as part of meta-data. This method should be associated
 * with the last activity in your notification workflow. The signature of the
 * API is the standard API for PL/SQL procedures called by function activities.
 * @param item_type varchar2
 * @param item_key varchar2
 * @param activity_id number
 * @param command varchar2
 * @param resultout varchar2
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname User Management, Notification Process Done.
 */
  procedure Notification_Process_Done (item_type    in  varchar2,
                                       item_key     in  varchar2,
                                       activity_id  in  number,
                                       command      in  varchar2,
                                       resultout    out NOCOPY varchar2);

  --
  -- Procedure        :  get_suggested_username
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API will return the suggested user name for a person.
  --                     The user name will be generated via the
  --                     oracle.apps.fnd.umx.username.generate Business Event
  --                     which will be raised by this API.  The event could
  --                     return a null value as the user name if the user name
  --                     could not be generated.
  -- Input Parameters :
  -- @param     p_person_party_id
  --    Description:  Person Party ID of the person who to generate
  --                  a username for.
  --    Required   :  N
  -- Output Parameters :
  --   x_suggested_username: Username generated by the Username Policy. May return null.
  --
  /*#
   * This API will return the suggested user name for a person.
   * The user name will be generated via the
   * oracle.apps.fnd.umx.username.generate Business Event
   * which will be raised by this API.  The event could
   * return a null value as the user name if the user name
   * could not be generated.
   * @param p_person_party_id Person Party ID of the person who to generate a username for.
   * @param x_suggested_username Username generated by the Username Policy. May return null.
   * @rep:displayname Generate the Suggested User Name
   * @rep:scope public
   * @rep:lifecycle active
   */
  --
  procedure get_suggested_username (p_person_party_id    in HZ_PARTIES.PARTY_ID%TYPE default null,
                                    x_suggested_username out nocopy FND_USER.USER_NAME%TYPE);

  --
  -- Procedure        :  get_username_policy_desc
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API will return the description of the user name
  --                     policy.  The return parameters / user name policy is
  --                     based on the UMX: User Name Policy (UMX_USERNAME_POLICY)
  --                     profile option, which points to a LOOKUP TYPE that
  --                     should include the following:
  --
  --                       LOOKUP CODES: DESCRIPTION, PROMPT, HINT
  --
  --                     with the appropriate LOOKUP MEANING defined. Example:
  --
  --                       LOOKUP TYPE: UMX_USERNAME_POLICY:EMAIL
  --
  --  LOOKUP CODE    MEANING                     DESCRIPTION
  --  -----------    --------------------------  -------------------------------
  --  PROMPT         User Name                   Prompt of the user name text
  --                                             input field.
  --
  --  DESCRIPTION    User Names must be based    Description of the policy
  --                 on Email Address
  --
  --  HINT           example: michael@email.com  Example of what the username should
  --                                             look like.
  --
  -- Input Parameters :
  -- Output Parameters :
  -- x_policy_code:      User Name Policy code. Preseeded policies are:
  --
  --                     Code: UMX_USERNAME_POLICY:EMAIL
  --                     Meaning: User name should be defined as Email Address.
  --                              Product teams may choose to hide the email
  --                              field in any account creation / registration
  --                              UI's as long as the entered username (email)
  --                              is copied into the fnd_user.email_address field
  --                              as well.
  --
  --                     Code: UMX_USERNAME_POLICY:NONE
  --                     Meaning: No username policy / format defined, freetext
  --
  --                     Code: Anything else, this would be a custom policy defined
  --                           at a client site.
  --
  -- x_description:      User Name Policy description. May be null. For example:
  --
  --                       "User Names must be based on <b>Email Address</b>".
  --                       The description can be displayed as a quick tip in
  --                       the user account creation/registration page.
  --
  -- x_prompt:           Prompt of the User Name field. Defaults to "User Name" if
  --                     none is defined in the policy.
  --
  -- x_hint:             An example of the user name format. May be null. For
  --                     example:
  --
  --                       "(example: first.last@domain.com)"
  --
  --                     The hint can be displayed as an inline hint below the
  --                     User Name field in any user account creation/registration
  --                     page.
  --
  /*#
   * This API will return the description of the user name
   * policy.  The return parameters / user name policy is
   * based on the UMX: User Name Policy (UMX_USERNAME_POLICY)
   * profile option, which points to a LOOKUP TYPE that
   * should include the following:
   *   LOOKUP CODES: DESCRIPTION, PROMPT, HINT
   * with the appropriate LOOKUP MEANING defined. Example:
   *   LOOKUP TYPE: UMX_USERNAME_POLICY:EMAIL
   * LOOKUP CODE    MEANING                     DESCRIPTION
   * -----------    --------------------------  -------------------------------
   * PROMPT         User Name                   Prompt of the user name text
   *                                             input field.
   *
   * DESCRIPTION    User Names must be based    Description of the policy
   *                on Email Address
   *
   * HINT           example: michael@email.com  Example of what the username should
   *                                            look like.
   * @param x_policy_code User Name Policy code. Preseeded policies are:
   *                     Code: UMX_USERNAME_POLICY:EMAIL
   *                     Meaning: User name should be defined as Email Address.
   *                              Product teams may choose to hide the email
   *                              field in any account creation / registration
   *                              UI's as long as the entered username (email)
   *                              is copied into the fnd_user.email_address field
   *                              as well.
   *
   *                     Code: UMX_USERNAME_POLICY:NONE
   *                     Meaning: No username policy / format defined, freetext
   *
   *                     Code: Anything else, this would be a custom policy defined
   *                           at a client site.
   *
   * @param x_description User Name Policy description. May be null. For example:
   *
   *                       "User Names must be based on <b>Email Address</b>".
   *                       The description can be displayed as a quick tip in
   *                       the user account creation/registration page.
   *
   * @param x_prompt Prompt of the User Name field. Defaults to "User Name" if
   *                     none is defined in the policy.
   *
   * @param x_hint An example of the user name format. May be null. For
   *                     example:
   *
   *                       "(example: first.last@domain.com)"
   *
   *                     The hint can be displayed as an inline hint below the
   *                     User Name field in any user account creation/registration
   *                     page.
   * @rep:displayname Get the User Name Policy Descriptions
   * @rep:scope public
   * @rep:lifecycle active
   */
  --
  procedure get_username_policy_desc
                (x_policy_code out nocopy FND_LOOKUP_TYPES.LOOKUP_TYPE%TYPE,
                 x_description out nocopy FND_LOOKUP_VALUES.MEANING%TYPE,
                 x_prompt      out nocopy FND_LOOKUP_VALUES.MEANING%TYPE,
                 x_hint        out nocopy FND_LOOKUP_VALUES.MEANING%TYPE);

 BEFORE_ACT_ACTIVATION CONSTANT VARCHAR2(30) := 'BEFORE ACCOUNT ACTIVATION';
 AFTER_ACT_ACTIVATION CONSTANT VARCHAR2(30)  := 'AFTER ACCOUNT ACTIVATION';
 ROLE_APPROVED CONSTANT VARCHAR2(15) := 'ROLE APPROVED';
END UMX_PUB;

/
