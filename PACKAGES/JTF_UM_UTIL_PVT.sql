--------------------------------------------------------
--  DDL for Package JTF_UM_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: JTFVUUTS.pls 120.8 2006/02/14 00:15:13 snellepa ship $ */

/**
 * Procedure   :  get_wf_user
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns the user name, email and wf_user_name of a given user.
 *               If a email address is passed as an input parameter it
 *               checks to see if the email address is a valid one.
 *               If x_requester_user_name or x_requester_email is NULL then a valid email /user could
 *               not be found
 *               If x_wf_user is NULL, and x_requester_user_name and x_requester_email are not NULL then
 *               the user /email combination is valid but does not have a valid
 *               user in wf_user.
 * Parameters  : None
 * input parameters
 *     param  x_requester_user_name (*)  - user name of the requester
 *     param  x_requester_email          - email address the requester would like to use.
 *  (*) required fields
 * output parameters
 *     param  x_requester_user_name
 *     param  x_requester_email
 *     param  x_wf_user_name
 *     param  x_return_status
 * Errors      : Expected Errors
 *               x_requester_user_name and x_requester_email is null
 *               x_requester_user_name is not a valid user
 *               x_requester_email does not correspond to a valid user
 * Other Comments :
 * DEFAULTING LOGIC
 * If only the user name is passed then the email is defaulted using the following logic
 *  1. Email address from fnd_users where user_name = x_requester_user_name
 *  2. Email from per_all_people_F where person_id = employee_id (retrieved from fnd_users using the user_name)
 *  3. Email from hz_contact_points where owner_type_id = party_id and owner_table = 'HZ_PARTIES' and contact_point_type = 'EMAIL' and primary_flag = 'Y'.
 *  Party_id is determined using the following :
 *  (a)from hz_parties where party_id = customer_id (retrieved from
 *   fnd_users using the user_name) and party_type = 'PERSON' or 'ORGANIZATION'.
 *  (b)from hz_parties where party_id = customer_id (retrieved from fnd_users using the user_name) and party_type = 'PARTY_RELATIONSHIP'.
 *  Use this party_id to determine the subject_id from the hz_party_relationships
 * table. The subject_id would be used for the querying hz_contact_points.
 * In all the above cases the user, employee, party etc. have to be valid.
 *
 * The same logic is used to validate the requester_email.
 */
procedure get_wf_user(p_api_version_number  in number,
                 p_init_msg_list            in varchar2 := FND_API.G_FALSE,
                 p_commit                   in varchar2 := FND_API.G_FALSE,
                 p_validation_level         in number   := FND_API.G_VALID_LEVEL_FULL,
                 x_requester_user_name      in out NOCOPY varchar2,
                 x_requester_email          in out NOCOPY varchar2,
                 x_wf_user                  out NOCOPY varchar2,
                 x_return_status            out NOCOPY varchar2,
                 x_msg_count                out NOCOPY number,
                 x_msg_data                 out NOCOPY varchar2
                 );


  /**
   * Procedure   :  GetAdHocUser
   * Type        :  Public
   * Pre_reqs    :  WF_DIRECTORY.CreateAdHocUser and
   *                WF_DIRECTORY.SetAdHocUserAttr
   * Description :  This API tries to create an adhoc user with the provided
   *                username.  If the username is already being used in the
   *                database, just update input attributes.
   * Parameters  :
   * input parameters
   * @param
   *   p_username
   *     description:  The adhoc username.
   *     required   :  Y
   *   p_display_name
   *     description:  The adhoc display name.
   *     required   :  N
   *     default    :  null
   *   p_language
   *     description:  The value of the database NLS_LANGUAGE initialization
   *                   parameter that specifies the default language-dependent
   *                   behavior of the user's notification session. If null,
   *                   the procedure resolves this to the language setting of
   *                   your current session.
   *     required   :  N
   *     default    :  null
   *   p_territory
   *     description:  The value of the database NLS_TERRITORY initialization
   *                   parameter that specifies the default territory-dependant
   *                   date and numeric formatting used in the user's
   *                   notification session. If null, the procedure resolves
   *                   this to the territory setting of your current session.
   *     required   :  N
   *     default    :  null
   *   p_description
   *     description:  Description for the user.
   *     required   :  N
   *     default    :  null
   *   p_notification_preference
   *     description:  Indicate how this user prefers to receive notifications:
   *                   'MAILTEXT', 'MAILHTML', 'MAILATTH', 'QUERY' or 'SUMMARY'.
   *                   If null, the procedure sets the notification preference
   *                   to 'MAILHTML'.
   *     required   :  N
   *     default    :  'MAILTEXT'
   *   p_email_address
   *     description:  Electronic mail address for this user.
   *     required   :  Y
   *   p_fax
   *     description:  Fax number for the user
   *     required   :  N
   *     default    :  null
   *   p_status
   *     description:  The availability of the user to participate in a
   *                   workflow process. The possible statuses are 'ACTIVE',
   *                   'EXTLEAVE', 'INACTIVE', and 'TMPLEAVE'. If null, the
   *                   procedure sets the status to 'ACTIVE'.
   *     required   :  N
   *     default    :  'ACTIVE'
   *   p_expiration_date
   *     description:  The date at which the user is no longer valid in the
   *                   directory service. If null, the procedure defaults the
   *                   expiration date to sysdate.
   *     required   :  N
   *     default    :  sysdate
   * output parameters
   * @return
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  PROCEDURE GetAdHocUser (p_api_version_number      in number,
                          p_init_msg_list           in varchar2 default FND_API.G_FALSE,
                          p_commit                  in varchar2 default FND_API.G_FALSE,
                          p_validation_level        in number   default FND_API.G_VALID_LEVEL_FULL,
                          p_username                in varchar2,
                          p_display_name            in varchar2 default null,
                          p_language                in varchar2 default null,
                          p_territory               in varchar2 default null,
                          p_description             in varchar2 default null,
                          p_notification_preference in varchar2 default 'MAILTEXT',
                          p_email_address           in varchar2,
                          p_fax                     in varchar2 default null,
                          p_status                  in varchar2 default 'ACTIVE',
                          p_expiration_date         in date default sysdate,
                          x_return_status           out NOCOPY varchar2,
                          x_msg_data                out NOCOPY varchar2,
                          x_msg_count               out NOCOPY varchar2);

  /**
   * Procedure   :  EMAIL_NOTIFICATION
   * Type        :  Public
   * Pre_reqs    :  WF_NOTIFICATION.Send, WF_ENGINE.SetItemAttrText
   * Description :  Send email notification to fnd user.
   * Parameters  :
   * input parameters
   * @param
   *   p_username
   *     description:  FND user's username.  The recep of the notification.
   *     required   :  Y
   *     validation :  Must be a valid FND User.
   *   p_subject
   *     description:  The subject of the notification.
   *     required   :  Y
   *   p_text_body
   *     description:  Text version of the notification body.
   *     required   :  Y
   *   p_HTML_body
   *     description:  HTML version of the notification body.
   *     required   :  N
   *     default    :  null
   *   p_email_address
   *     description:  Send to this email and overwrite the email address
   *                   in the FND_USER table.
   *     required   :  N
   *     default    :  null
   * output parameters
   * @return
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  PROCEDURE EMAIL_NOTIFICATION (p_api_version_number in number,
                                p_init_msg_list      in varchar2 default FND_API.G_FALSE,
                                p_commit             in varchar2 default FND_API.G_FALSE,
                                p_validation_level   in number   default FND_API.G_VALID_LEVEL_FULL,
                                p_username           in varchar2 default null,
                                p_email_address      in varchar2 default null,
                                p_subject            in varchar2,
                                p_text_body          in varchar2,
                                p_HTML_body          in varchar2 default null,
                                x_return_status      out NOCOPY varchar2,
                                x_msg_data           out NOCOPY varchar2,
                                x_msg_count          out NOCOPY varchar2);


   /*
    ** VALUE_SPECIFIC - Get profile value for a specific user/resp/appl
    **
    ** Unlike fnd_profile.value_specific this procedure retrieves the
    ** profile value only at the level(s) that is not null.
    ** For retrieving profiles at site level site id should be set to true.
    ** For retrieving profiles at responsibility level pass both responsibility_id and resp_appl_id
    ** To retrieve values at any level pass all the parameters.
    ** This procedure does not get the resp and app id from login.
    */
    function VALUE_SPECIFIC(NAME              in varchar2,
                            USER_ID           in number default null,
                            RESPONSIBILITY_ID in number default null,
                            RESP_APPL_ID      in number default null,
                            APPLICATION_ID    in number default null,
                            SITE_LEVEL        in boolean default false) return varchar2;


/**
 * This procedure gets the default appl and resp id using the following logic
 *
 * If appl id and resp id are null - get the user value of the profiles
 * JTF_PROFILE_DEFAULT_RESPONSIBILITY, JTF_PROFILE_DEFAULT_APPLICATION. These
 * values can be set to 'Pending appr' if user requires approval.
 * In this case we use the resp of the usertype the user has registered to.
 * these values could still be null if the user was registered from fnd.
 *
 */

 procedure getDefaultAppRespId (P_USERNAME  IN VARCHAR2,
                                P_RESP_ID   IN NUMBER := null,
                                P_APPL_ID   IN NUMBER := null,
                                X_RESP_ID   out NOCOPY NUMBER,
                                X_APPL_ID   out NOCOPY NUMBER);

/*
 * Name        : check_role
 * Pre_reqs    :  None
 * Description :  Will determine if a user has a specific role or not
 * Parameters  :
 * input parameters
 * @param     p_user_id
 *    description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id
 * @param     p_auth_principal_id
 *    description:  The jtf_auth_principal_id of a role
 *     required   :  Y
 *     validation :  Must be a valid jtf_auth_principal_id
 *
 * Note:
 *
 *   This API will raise an exception if a user name or a jtf_auth_principal_id
 *   is invalid
 */

function check_role(
                     p_user_id                  in number,
                     p_auth_principal_id        in number
                    ) return boolean;

/*
 * Name        : check_role
 * Pre_reqs    :  None
 * Description :  Will determine if a user has a specific role or not
 * Parameters  :
 * input parameters
 * @param     p_user_id
 *    description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id
 * @param     p_principal_name
 *    description:  The principal_name of a role
 *     required   :  Y
 *     validation :  Must be a valid principal_name
 *
 * Note:
 *
 *   This API will raise an exception if a user name or a principal_name
 *   is invalid
 */

function check_role(
                     p_user_id                  in number,
                     p_principal_name           in varchar2
                    ) return boolean;



/*
 * Name        :  VALIDATE_USER_ID
 * Pre_reqs    :  None
 * Description :  Will validate the user_id
 * Parameters  :
 * input parameters
 * @param
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This is a package private helper function.
 */

function VALIDATE_USER_ID(p_user_id number) return boolean;


/*
 * Name        :  VALIDATE_SUBSCRIPTION_ID
 * Pre_reqs    :  None
 * Description :  Will validate the subscription_id
 * Parameters  :
 * input parameters
 * @param
 *   p_subscription_id:
 *     description:  The subscription_id of the subscription
 *     required   :  Y
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This is a package private helper function.
 */

function VALIDATE_SUBSCRIPTION_ID(p_subscription_id number) return boolean;

/**
 * Procedure   :  grant_roles
 * Type        :  Private
 * Pre_reqs    :  None
 * Description :  Will grant roles to users
 * Parameters  :
 * input parameters
 *   p_user_name:
 *     description:  The user_name of the user
 *     required   :  Y
 *     validation :  Must be a valid user_name
 *   p_role_id
 *     description: The value of the JTF_AUTH_PRINCIPAL_ID
 *     required   :  Y
 *     validation :  Must exist as a JTF_AUTH_PRONCIPAL_ID
 *                   in the table JTF_AUTH_PRINCIPALS_B
 *   p_source_name
 *     description: The value of the name of the source
 *     required   :  Y
 *     validation :  Must be "USERTYPE" or "ENROLLMENT"
 *   p_source_id
 *     description: The value of the id associated with the source
 *     required   :  Y
 *     validation :  Must be a usertype_id or a subscription_id
 * output parameters
 * None
 */
procedure grant_roles (
                       p_user_name          in varchar2,
                       p_role_id            in number,
                       p_source_name         in varchar2,
                       p_source_id         in varchar2
                     );

/*
    ** GET_SPECIFIC - Get a profile value for a specific user/resp/appl.
    **                Does not go up the hierarchy to retrieve the profile
    **                values if input values are null.
    */
    procedure GET_SPECIFIC(name_z              in varchar2,
                           user_id_z           in number    default null,
                           responsibility_id_z in number    default null,
                           resp_appl_id_z      in number    default null,
                           application_id_z    in number    default null,
                           site_id_z           in boolean    default false,
                           val_z               out NOCOPY varchar2,
                           defined_z           out NOCOPY boolean);

/*
 * Name        :  GET_USER_ID
 * Pre_reqs    :  None
 * Description :  Will get user id from username
 * Parameters  :
 * input parameters
 * @param
 *   p_user_id:
 *     description:  The user_name of a user
 *     required   :  Y
 *
 * output parameters
 * None
 *
 * Notes:
 *        This function will return null, if it can not find username
 *
 */

function GET_USER_ID(p_user_name varchar2) return NUMBER;

/*
 * Name        :  GET_USERTYPE_ID
 * Pre_reqs    :  None
 * Description :  Will get user type id for a user
 * Parameters  :
 * input parameters
 * @param
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *
 * output parameters
 * None
 *
 * Notes:
 *        This function will return null, if it can not find username
 *
 */

function GET_USERTYPE_ID(p_user_id NUMBER) return NUMBER;

/*
 *@Name: Check_Party_type
 *@Param: Party_id
 *@Description: function which returns the party_type of a party in hz_parties given
 * given party_id
 *@Output: party_type varchar2
 */

function CHECK_PARTY_TYPE(p_party_id NUMBER) return VARCHAR2;


/*
 *@Name: validate_user_name
 *@Param: username
 *@Description: checks is a user name is valid
 *@Output: number ( 1 True , 0 False)
 Code Changes for 5033237/5033238, the errMsg from FND_MESSAGE Stack is being re-used.

*/
function validate_user_name(username varchar2, errMsg out NOCOPY varchar2) return number;


/*
 *@Name: validate_user_name_in_use
 *@Param: username
 *@Description: checks is a user name is in use
 *@Output: number ( 1 True , 0 False)
*/
function validate_user_name_in_use(username varchar2) return number;

/* function to get the constant FND_API.G_MISS_DATE and use it in sql*/
FUNCTION GET_G_MISS_DATE return DATE;

/*
bug 4903775 - for name formatting based on region territory
*/
function format_user_name(fname varchar2, lname varchar2) return varchar;


end JTF_UM_UTIL_PVT;

 

/
