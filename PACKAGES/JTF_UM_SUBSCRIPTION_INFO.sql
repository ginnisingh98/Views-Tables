--------------------------------------------------------
--  DDL for Package JTF_UM_SUBSCRIPTION_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_SUBSCRIPTION_INFO" AUTHID CURRENT_USER as
/*$Header: JTFVSBIS.pls 115.4 2002/11/21 22:57:56 kching ship $*/


TYPE SUBSCRIPTION_INFO IS RECORD
(
 NAME               JTF_UM_SUBSCRIPTIONS_TL.SUBSCRIPTION_NAME%TYPE := FND_API.G_MISS_CHAR,
 KEY                JTF_UM_SUBSCRIPTIONS_B.SUBSCRIPTION_KEY%TYPE := FND_API.G_MISS_CHAR,
 DESCRIPTION        JTF_UM_SUBSCRIPTIONS_TL.DESCRIPTION%TYPE := FND_API.G_MISS_CHAR,
 DISPLAY_ORDER      NUMBER  := FND_API.G_MISS_NUM,
 ACTIVATION_MODE    JTF_UM_USERTYPE_SUBSCRIP.SUBSCRIPTION_FLAG%TYPE := FND_API.G_MISS_CHAR,
 DELEGATION_ROLE    NUMBER  := FND_API.G_MISS_NUM,
 CHECKBOX_STATUS    NUMBER  := FND_API.G_MISS_NUM,
 APPROVAL_REQUIRED   NUMBER  := FND_API.G_MISS_NUM,
 SUBSCRIPTION_ID    NUMBER  := FND_API.G_MISS_NUM,
 SUBSCRIPTION_REG_ID    NUMBER  := FND_API.G_MISS_NUM,
 APPROVAL_ID            NUMBER  := FND_API.G_MISS_NUM,
 IS_USER_ENROLLED       NUMBER  := FND_API.G_MISS_NUM,
 SUBSCRIPTION_STATUS VARCHAR2(30) := FND_API.G_MISS_CHAR,
 TEMPLATE_HANDLER        JTF_UM_TEMPLATES_B.TEMPLATE_HANDLER%TYPE := FND_API.G_MISS_CHAR,
 PAGE_NAME        JTF_UM_TEMPLATES_B.PAGE_NAME%TYPE := FND_API.G_MISS_CHAR
 );

TYPE SUBSCRIPTION_ID_REC IS RECORD
(
  SUBSCRIPTION_ID NUMBER  := FND_API.G_MISS_NUM
);

TYPE SUBSCRIPTION_INFO_TABLE IS TABLE OF SUBSCRIPTION_INFO INDEX BY BINARY_INTEGER;

TYPE SUBSCRIPTION_LIST IS TABLE OF SUBSCRIPTION_ID_REC INDEX BY BINARY_INTEGER;

/**
  * Procedure   :  GET_USERTYPE_SUB_INFO
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Returns the enrollment information for a user type
  * Parameters  :
  * input parameters
  * @param     p_usertype_id
  *     description:  The user type id
  *     required   :  Y
  *     validation :  Must be a valid user type id
  * @param     p_user_id
  *     description:  The user id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user id
  * @param     p_is_admin
  *     description:  To know, if logged in user is an admin
  *     required   :  Y
  *     validation :  Must be 0 or 1
  * output parameters
  *   x_result: SUBSCRIPTION_INFO_TABLE
 */

procedure GET_USERTYPE_SUB_INFO(
                       p_usertype_id  in number,
                       p_user_id      in number,
                       p_is_admin     in number,
                       x_result       out NOCOPY SUBSCRIPTION_INFO_TABLE
                       );


/**
  * Procedure   :  GET_USER_SUB_INFO
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Returns the enrollment information for a user type
  * Parameters  :
  * input parameters
  * @param     p_user_id
  *     description:  The user id for which enrollments are queried
  *     required   :  Y
  *     validation :  Must be a valid user id
  * @param     p_is_admin
  *     description:  To know, if logged in user is an admin
  *     required   :  Y
  *     validation :  Must be 0 or 1
  * @param     p_logged_in_user_id
  *     description:  The user id of logged in user
  *     required   :  Y
  *     validation :  Must be a valid user id
  * @param     p_sub_status
  *     description:  The status of the enrollment assignment
  *     required   :  Y
  *     validation :  Must be 'AVAILABLE', 'APPROVED' or 'PENDING'
  * output parameters
  *   x_result: SUBSCRIPTION_INFO_TABLE
 */

procedure GET_USER_SUB_INFO(
                       p_user_id           in number,
                       p_is_admin          in number,
                       p_logged_in_user_id in number,
                       p_administrator     in number,
                       p_sub_status        in varchar2,
                       x_result            out NOCOPY SUBSCRIPTION_INFO_TABLE
                       ) ;

/**
  * Procedure   :  GET_CONF_SUB_INFO
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Returns the enrollment information for a user type
  * Parameters  :
  * input parameters
  * @param     p_user_id
  *     description:  The user id
  *     required   :  Y
  *     validation :  Must be a valid user id
  * @param     p_usetype_id
  *     description:  The user type id
  *     required   :  Y
  *     validation :  Must be a valid user type id
  * @param     p_sub_list
  *     description:  The list of enrollments
  *     required   :  Y
  *     validation :  Must be a valid list
  * output parameters
  *   x_result: SUBSCRIPTION_INFO_TABLE
 */
procedure GET_CONF_SUB_INFO(
                       p_user_id      in number,
                       p_usertype_id  in number,
                       p_is_admin     in number,
                       p_admin_id     in number,
                       p_administrator in number,
                       p_sub_list     in SUBSCRIPTION_LIST,
                       x_result       out NOCOPY SUBSCRIPTION_INFO_TABLE
                       ) ;

/**
  * Procedure   :  GET_USERTYPE_SUB
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Returns the enrollment information for a user type
  * Parameters  :
  * input parameters
  * @param     p_usetype_id
  *     description:  The user type id
  *     required   :  Y
  *     validation :  Must be a valid user type id
  * @param     p_user_id
  *     description:  The user id
  *     required   :  Y
  *     validation :  Must be a valid user id
  * @param     p_sub_list
  *     description:  The list of enrollments
  *     required   :  Y
  *     validation :  Must be a valid list
  * @param     p_is_admin
  *     description:  To know, if logged in user is an admin
  *     required   :  Y
  *     validation :  Must be 0 or 1
  * output parameters
  *   x_result: SUBSCRIPTION_INFO_TABLE
 */
procedure GET_USERTYPE_SUB(
                       p_usertype_id  in number,
                       p_user_id      in number,
                       p_is_admin     in number,
                       p_admin_id     in number,
                       p_sub_list     in SUBSCRIPTION_LIST,
                       x_result       out NOCOPY SUBSCRIPTION_INFO_TABLE
                       ) ;


end JTF_UM_SUBSCRIPTION_INFO;

 

/
