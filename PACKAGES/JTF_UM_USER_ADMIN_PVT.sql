--------------------------------------------------------
--  DDL for Package JTF_UM_USER_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_USER_ADMIN_PVT" AUTHID CURRENT_USER as
  /* $Header: JTFVUUAS.pls 115.5 2002/11/21 22:57:49 kching ship $ */

  /**
   * Procedure   :  INACTIVE_USER
   * Type        :  Private
   * Pre_reqs    :  WF_DIRECTORY.CreateAdHocUser and
   *                WF_DIRECTORY.SetAdHocUserAttr
   * Description : Inactive an user with these Scenarios
   *   1. Usertype Request is PENDING
   *    - call FND_USER_PKG.DisableUser API
   *    - Kill the usertype WF
   *    - Set the usertype_reg table status to REJECTED
   *    - Find all the *PENDING* Enrollments, and REJECT these
   *      (believe we have a USERTYPE_REJECTED status or similar)
   *      in the subscription_reg table
   *    - revoke the "PENDING_APPROVAL" responsibility
   *
   *   2. Usertype Request is UPGRADE_PENDING
   *    - call FND_USER_PKG.DisableUser API
   *    - Set the usertype_reg table status to REJECTED
   *    - Reject the old approval task
   *
   *   3. Usertype Request is APPROVED or UPGRADE
   *    - call FND_USER_PKG.DisableUser API
   *    - Do not set the usertype_reg table status (leave as APPROVED)
   *    - Find all the *PENDING* Enrollments, and REJECT these (REJECTED status)
   *      in the subscription_reg table
   *    - Do not change the status for any approved / rejected enrollments
   * Parameters  :
   * input parameters
   *   p_username
   *     description:  The inactive username.
   *     required   :  Y
   * output parameters
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  PROCEDURE INACTIVE_USER (p_api_version_number in number,
                           p_init_msg_list      in varchar2 default FND_API.G_FALSE,
                           p_commit             in varchar2 default FND_API.G_FALSE,
                           p_validation_level   in number   default FND_API.G_VALID_LEVEL_FULL,
                           p_username           in varchar2,
                           x_return_status      out NOCOPY varchar2,
                           x_msg_data           out NOCOPY varchar2,
                           x_msg_count          out NOCOPY number);

/**
 * This API creates an entry into the jtf_usertype_reg table. It also sets the
 * responsibility to "pending". If approval is required a workflow is initiated
 * if not the credentials are assigned.
 */

PROCEDURE Create_System_User(p_username in varchar2,
                             p_usertype_id in number,
                             p_user_id  in number,
                             x_user_reg_id out NOCOPY number,
                             x_approval_id out NOCOPY number);

end JTF_UM_USER_ADMIN_PVT;

 

/
