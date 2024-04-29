--------------------------------------------------------
--  DDL for Package JTF_UM_WF_DELEGATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_WF_DELEGATION_PVT" AUTHID CURRENT_USER as
/* $Header: JTFVDELS.pls 115.5 2002/11/21 22:57:59 kching ship $ */

 NO_CHECKBOX           CONSTANT NUMBER := 0;
 CHECKED_UPDATE        CONSTANT NUMBER := 1;
 NOT_CHECKED_UPDATE    CONSTANT NUMBER := 2;
 CHECKED_NO_UPDATE     CONSTANT NUMBER := 3;
 NOT_CHECKED_NO_UPDATE CONSTANT NUMBER := 4;

/**
  * Procedure   :  can_delegate
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine if an approver can delegate
  * Parameters  :
  * input parameters
  * @param     p_subscription_id
  *     description:  The subscription_id of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid subscription_id
  *   p_user_id:
  *     description:  The user_id of an approver
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  * x_result: The value indicating whether an approver can delegate or not
 */
procedure can_delegate(
                       p_subscription_id  in number,
                       p_user_id          in number,
                       x_result           out NOCOPY boolean
                       );

/**
  * Procedure   :  can_enrollment_delegate
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine if an enrollment can delegate
  * Parameters  :
  * input parameters
  * @param     p_subscription_id
  *     description:  The subscription_id of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid subscription_id
  *   p_usertype_id:
  *     description:  The usertype_id of the user
  *     required   :  Y
  *     validation :  Must be a valid usertype_id
  * output parameters
  * x_result: The value indicating whether an enrollment can delegate or not.
  *           This API will return true, if no delegation role has been
  *           defined for an enrollment
  *
  * Note:
 */
procedure can_enrollment_delegate (p_subscription_id in number,
                                   p_usertype_id     in number,
                                   x_result          out NOCOPY boolean);

/**
  * Procedure   :  can_delegate_int
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine if an approver can delegate
  * Parameters  :
  * input parameters
  * @param     p_subscription_id
  *     description:  The subscription_id of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid subscription_id
  *   p_user_id:
  *     description:  The user_id of an approver
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  * x_result: The boolean value in number, 0 or 1 indicating whether
  *           an approver can delegate or not. This API has been created
  *           as JDBC does not support boolean!!!!
 */
procedure can_delegate_int(
                       p_subscription_id  in number,
                       p_user_id          in number,
                       x_result           out NOCOPY number
                       );


/**
  * Procedure   :  has_delegation_role
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine if an approver has a delegation role
  * Parameters  :
  * input parameters
  * @param     p_subscription_id
  *     description:  The subscription_id of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid subscription_id
  *   p_user_id:
  *     description:  The user_id of an approver
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  * x_result: The value indicating whether an approver has a delegation role or not
  *
 */

procedure has_delegation_role (
                                         p_subscription_id  in number,
                                         p_user_id          in number,
                                         x_result           out NOCOPY boolean
                                        );

/**
  * Procedure   :  get_checkbox_status
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine the status of the checkbox for granting delegation role
  * Parameters  :
  * input parameters
  * @param     p_reg_id
  *     description:  The usertype_reg_id or subscription_reg_id
  *     required   :  Y
  *     validation :  Must be a usertype_reg_id or subscription_reg_id
  *   p_user_id:
  *     description:  The user_id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user_id
  *   p_ignore_del_flag:
  *     description: If set to yes, it will ignore the value of the grant delegation flag
  * output parameters
  * x_result: Following int values
  *     0 - NO_CHECKBOX
  *     1 - CHECKED_UPDATE
  *     2 - NOT_CHECKED_UPDATE
  *     3 - CHECKED_NO_UPDATE
  *     4 - NOT_CHECKED_NO_UPDATE
  *
  *
 */

procedure get_checkbox_status (
                                   p_reg_id  in number,
                                   p_user_id in number,
                                   p_ignore_del_flag in boolean,
                                   p_enrl_owner_user_id in number := FND_API.G_MISS_NUM,
                                   x_result  out NOCOPY number
                               );


/**
  * Procedure   :  get_checkbox_status
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine the status of the checkbox for granting delegation role
  * Parameters  :
  * input parameters
  * @param     p_reg_id
  *     description:  The usertype_reg_id or subscription_reg_id
  *     required   :  Y
  *     validation :  Must be a usertype_reg_id or subscription_reg_id
  *   p_user_id:
  *     description:  The user_id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  * x_result: Following int values
  *     0 - NO_CHECKBOX
  *     1 - CHECKED_UPDATE
  *     2 - NOT_CHECKED_UPDATE
  *     3 - CHECKED_NO_UPDATE
  *     4 - NOT_CHECKED_NO_UPDATE
  *
  *
 */

procedure get_checkbox_status (
                                   p_reg_id  in number,
                                   p_user_id in number,
                                   x_result  out NOCOPY number
                               );



/**
  * Procedure   :  get_checkbox_status_reg
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine the status of the checkbox for
  * granting delegation role
  * Parameters  :
  * input parameters
  * @param     p_subscription_id
  *     description:  The subscription_id of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid subscription_id
  * @param     p_user_id:
  *     description:  The user_id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  * x_result: Following int values
  *     1 - CHECKED_UPDATE
  *     2 - NOT_CHECKED_UPDATE
  *     3 - CHECKED_NO_UPDATE
  *     4 - NOT_CHECKED_NO_UPDATE
  *
  *
 */

procedure get_checkbox_status_reg (
                                   p_subscription_id       in number,
                                   p_user_id               in number,
                                   p_usertype_id           in number,
                                   x_result                out NOCOPY number
                               );

/**
  * Procedure   :  get_enrollment_avail
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine if an admin can assign this enrollment
  *                to a user or not and it will also determine the
  *                checkbox status
  * granting delegation role
  * Parameters  :
  * input parameters
  * @param     p_subscription_id
  *     description:  The subscription_id of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid subscription_id
  * @param     p_user_id:
  *     description:  The user_id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  * x_checkbox_code: Following int values
  *     1 - CHECKED_UPDATE
  *     2 - NOT_CHECKED_UPDATE
  *     3 - CHECKED_NO_UPDATE
  *     4 - NOT_CHECKED_NO_UPDATE
  * x_can_assign
  *     0 - if admin cannot assign
  *     1 - if admin can assign
  *
 */

procedure get_enrollment_avail (
                                   p_subscription_id       in number,
                                   p_user_id               in number,
                                   p_usertype_id           in number,
                                   x_checkbox_code         out NOCOPY number,
                                   x_can_assign            out NOCOPY number
                               );

/**
  * Procedure   :  has_admin_enrollment
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine if an admin has all the roles
  *                for an enrollment or not
  * granting delegation role
  * Parameters  :
  * input parameters
  * @param     p_subscription_id
  *     description:  The subscription_id of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid subscription_id
  * @param     p_user_id:
  *     description:  The user_id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  * x_has_enrollment
  *     0 - if admin does not have all the roles
  *     1 - if admin has all the roles
  *
 */

procedure has_admin_enrollment (
                                   p_subscription_id       in number,
                                   p_user_id               in number,
                                   x_has_enrollment        out NOCOPY number
                               ) ;
/**
  * Function    :  is_approval_required
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine if an approval is required
  *                for an enrollment or not
  * Parameters  :
  * input parameters
  * @param     p_subscription_id
  *     description:  The subscription_id of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid subscription_id
  * @param     p_approval_id:
  *     description:  The p_approval_id of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid approval_id
  * @param     p_activation_mode:
  *     description:  The p_activation_mode of an enrollment
  *     required   :  Y
  *     validation :  Must be a valid activation mode
  * @param     p_is_admin:
  *     description:  To determine, if a user is an admin or not
  *     required   :  Y
  *     validation :  Must be 0 or 1
  * @return
  *     0 - if approval is not required
  *     1 - if approval is required
  *
 */

function is_approval_required(
                         p_subscription_id  in number,
                         p_approval_id      in number,
                         p_activation_mode  in varchar2,
                         p_is_admin         in number,
                         p_can_assign       in number
                                 ) return number;

end JTF_UM_WF_DELEGATION_PVT;

 

/
