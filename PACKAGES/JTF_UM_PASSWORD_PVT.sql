--------------------------------------------------------
--  DDL for Package JTF_UM_PASSWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_PASSWORD_PVT" AUTHID CURRENT_USER as
/* $Header: JTFVUMPS.pls 115.12 2002/11/21 22:57:51 kching ship $ */
-- Start of Comments
-- Package name     : JTF_UM_PASSWORD_PVT
-- Purpose          : generate password and send email to user with the password.
-- History          :

-- KCHERVEL  12/03/01  Created
-- NOTE             :
-- End of Comments

/**
 * Procedure   :  generate_password
 * Type        :  Private
 * Pre_reqs    :
 * Description : Creates a password. The length of the password is obtained from the profile
 *               SIGNON_PASSWORD_LENGTH.
 * Parameters
 * input parameters : None
 * output parameters
 * @return   returns a String that can be used as the password
  * Errors      :
 * Other Comments :
 */
procedure generate_password (p_api_version_number  in number,
                 p_init_msg_list               in varchar2 := FND_API.G_FALSE,
                 p_commit                      in varchar2 := FND_API.G_FALSE,
                 p_validation_level          in number   := FND_API.G_VALID_LEVEL_FULL,
                 x_password                  out NOCOPY varchar2,
                 x_return_status             out NOCOPY varchar2,
                 x_msg_count                 out NOCOPY number,
                 x_msg_data                  out NOCOPY varchar2
                 );


/**
 * Function    :  send_password
 * Type        :  Private
 * Pre_reqs    :  Should be called only after the changes to the user information are committed.
 * Description : this procedure initiates a workflow that sends an email to the user.
 * Parameters  : None
 * input parameters (see workflow parameters for description)
 *     param  p_requester_user_name    (*)
  *     param   p_requester_password      (*)
  *     param   p_requester_name
  *     param   p_usertype_id
  *     param   p_responsibility_id
  *     param   p_application_id
  *     param   p_first_time_user
  *     param   p_send_password
 *     param  p_date_of_request
 *     param  p_confirmation_id
 * output parameters
 *     param  x_return_status
 *     param  x_msg_data
 *     param  x_msg_count
 * (*) indicates required parameters
  * Errors      : Expected errors
 *               requester_user_name or password is null.
 *               e_mail address undefined
 * Other Comments :
 *
 */

procedure send_password (p_api_version_number  in number,
                 p_init_msg_list               in varchar2 := FND_API.G_FALSE,
                 p_commit                      in varchar2 := FND_API.G_FALSE,
                 p_validation_level            in number   := FND_API.G_VALID_LEVEL_FULL,
                 p_requester_user_name         in varchar2,
                 p_requester_password          in varchar2,
                 p_requester_last_name         in varchar2 := null,
                 p_requester_first_name        in varchar2 := null,
                 p_usertype_id                in number := null,
                 p_responsibility_id         in number := null,
                 p_application_id            in number := null,
                 p_wf_user_name              in varchar2 := null,
                 p_first_time_user           in varchar2 := 'Y',
                 p_user_verified             in varchar2 := 'N',
                 p_confirmation_number       in varchar2 := null,
                 p_enrollment_only           in varchar2 := 'N',
                 p_enrollment_list           in varchar2 := null,
                 x_return_status             out NOCOPY varchar2,
                 x_msg_count                 out NOCOPY number,
                 x_msg_data                  out NOCOPY varchar2);



/**
 * Procedure   :  set_parameters
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure sets all the parameters needed for the email / notifications.
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if all parameters are set properly
 *                - 'COMPLETE:F' if parameters could not be set
 *
 * Errors      :
 * Other Comments :
 */
procedure set_parameters (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2);


/**
 * Procedure   :  is_first_time_user
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns 'T' if the user is a first time user
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if the user is a first time user
 *                - 'COMPLETE:F' if the user is not a first time user
 *
 * Errors      :
 * Other Comments :
 */
procedure is_first_time_user (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2);


/**
 * Procedure   :  approval_required
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns whether or not an approval is required
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if approval is required
 *                - 'COMPLETE:F' if approval is not required
 *
 * Errors      :
 * Other Comments :
 */
procedure is_approval_required (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2);


/**
 * Procedure   :  user_verified
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns 'T' if a user is verified and a password can be sent to the user
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if user is verified
 *                - 'COMPLETE:F' if user is not verified
 *
 * Errors      :
 * Other Comments :
 */
procedure is_user_verified (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2);

/**
 * Procedure   :  enrollment_only
 * Type        :  Public
 * Pre_reqs    :
 * Description : this procedure returns 'T' if only enrollment information should be sent to the user.
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if user is verified
 *                - 'COMPLETE:F' if user is not verified
 *
 * Errors      :
 * Other Comments :
 */
procedure enrollment_only (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2);


/**
 * Procedure   :  reset_password
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure resets the password and sends and email to the user.
 *               Also, inserts a user into wf_local_user if a valid user and email
 *               is available and there is no valid wf_user
 * Parameters  : None
 * input parameters
 *     param  requester_user_name
 *     param  requester_email
 *  (*) required fields
 * output parameters
 *     param  x_return_status
 *     param  x_msg_data
 *     param  x_msg_count
  * Errors      : Expected Errors
 *               requester_user_name and email is null
 *               requester_user_name is not a valid user
 *               requester_email does not correspond to a valid user
 * Other Comments :
 * FND_USER update : The update of fnd_user table is done using fnd_user_pkg procedure
 * as recommended by fnd (bug 1713101)
 * DEFAULTING LOGIC
 * If only the user name is passed then the email is defaulted using the following logic
 *  1. Email address from fnd_users where user_name = p_requester_user_name
 *  2. Email from per_all_people_F where person_id = employee_id
 *     (retrieved from fnd_users using the user_name)
 *  3. Email from hz_contact_points where owner_type_id = party_id and
 *     owner_table = 'HZ_PARTIES' and contact_point_type = 'EMAIL' and primary_flag = 'Y'.
 *  Party_id is determined using the following :
 *  (a)from hz_parties where party_id = customer_id (retrieved from fnd_users
 *     using the user_name) and party_type = 'PERSON' or 'ORGANIZATION'.
 *  (b)from hz_parties where party_id = customer_id (retrieved from fnd_users
 *     using the user_name) and party_type = 'PARTY_RELATIONSHIP'. Use this party_id
 *     to determine the subject_id from the hz_party_relationships table.
 *     The subject_id would be used for the querying hz_contact_points.
 * In all the above cases the user, employee, party etc. have to be valid.
 *
 * If only the email is specified a similar procedure is used to determine the valid user.
 */

procedure reset_password(p_api_version_number  in number,
                 p_init_msg_list               in varchar2 := FND_API.G_FALSE,
                 p_commit                      in varchar2 := FND_API.G_FALSE,
                 p_validation_level            in number   := FND_API.G_VALID_LEVEL_FULL,
                 p_requester_user_name         in varchar2 := null,
                 p_requester_email             in varchar2 := null,
                 p_application_id              in number := null,
                 p_responsibility_id           in number := null,
                 x_return_status             out NOCOPY varchar2,
                 x_msg_count                 out NOCOPY number,
                 x_msg_data                  out NOCOPY varchar2
                 );


Procedure enrollment_info(document_id    in varchar2,
                          display_type   in varchar2,
                          document       in out NOCOPY varchar2,
                          document_type  in out NOCOPY varchar2);
End JTF_UM_PASSWORD_PVT;

 

/
