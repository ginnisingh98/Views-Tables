--------------------------------------------------------
--  DDL for Package JTF_UM_APPROVAL_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_APPROVAL_REQUESTS_PVT" AUTHID CURRENT_USER as
/* $Header: JTFVAPRS.pls 120.1.12010000.3 2013/03/27 07:48:39 anurtrip ship $ */


TYPE APPROVAL_REQUEST_TYPE IS RECORD
(
  REG_LAST_UPDATE_DATE DATE                                           := FND_API.G_MISS_DATE,
  USER_NAME            FND_USER.USER_NAME%TYPE                        := FND_API.G_MISS_CHAR,
  COMPANY_NAME         HZ_PARTIES.PARTY_NAME%TYPE                     := FND_API.G_MISS_CHAR,
  ENTITY_SOURCE        VARCHAR2(25)                                   := FND_API.G_MISS_CHAR,
  ENTITY_NAME          JTF_UM_SUBSCRIPTIONS_TL.SUBSCRIPTION_NAME%TYPE := FND_API.G_MISS_CHAR,
  WF_ITEM_TYPE         JTF_UM_USERTYPE_REG.WF_ITEM_TYPE%TYPE          := FND_API.G_MISS_CHAR,
  REG_ID               NUMBER                                         := FND_API.G_MISS_NUM,
  APPROVER             FND_USER.USER_NAME%TYPE                        := FND_API.G_MISS_CHAR,
  ERROR_ACTIVITY       NUMBER                                         := FND_API.G_MISS_NUM
);

TYPE APPROVAL_REQUEST_TABLE_TYPE IS TABLE OF APPROVAL_REQUEST_TYPE INDEX BY BINARY_INTEGER;

/**
  * Procedure   :  PENDING_APPROVAL_SYSADMIN
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Return the pending requests foy sysadmin
  * Parameters  :
  * input parameters
  * @param     p_sort_order
  *     description:  The sort order
  *     required   :  Y
  *     validation :  Must be a valid sort order
  *   p_number_of_records:
  *     description:  The number of records to retrieve from a database
  *     required   :  Y
  *     validation :  Must be a valid number
  * output parameters
  *   x_result: APPROVAL_REQUEST_TABLE_TYPE
 */
procedure PENDING_APPROVAL_SYSADMIN(
                       p_sort_order             in varchar2,
                       p_number_of_records      in number,
                       x_result                 out NOCOPY APPROVAL_REQUEST_TABLE_TYPE,
                       p_sort_option in varchar2
                       );


/**
  * Procedure   :  PENDING_APPROVAL_PRIMARY
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Return the pending requests foy Primary User
  * Parameters  :
  * input parameters
  * @param     p_sort_order
  *     description:  The sort order
  *     required   :  Y
  *     validation :  Must be a valid sort order
  *   p_number_of_records:
  *     description:  The number of records to retrieve from a database
  *     required   :  Y
  *     validation :  Must be a valid number
  *   p_approver_user_id
  *     description:  The user_id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  *   x_result:  APPROVAL_REQUEST_TABLE_TYPE
 */
procedure PENDING_APPROVAL_PRIMARY(
                       p_sort_order             in varchar2,
                       p_number_of_records      in number,
                       p_approver_user_id       in number,
                       x_result                 out NOCOPY APPROVAL_REQUEST_TABLE_TYPE,
                       p_sort_option in varchar2);


/**
  * Procedure   :  PENDING_APPROVAL_OWNER
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Return the pending requests for the request owner
  * Parameters  :
  * input parameters
  * @param     p_sort_order
  *     description:  The sort order
  *     required   :  Y
  *     validation :  Must be a valid sort order
  *   p_number_of_records:
  *     description:  The number of records to retrieve from a database
  *     required   :  Y
  *     validation :  Must be a valid number
  *   p_approver_user_id
  *     description:  The user_id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  *   x_result:  APPROVAL_REQUEST_TABLE_TYPE
 */
procedure PENDING_APPROVAL_OWNER(
                       p_sort_order             in varchar2,
                       p_number_of_records      in number,
                       p_approver_user_id       in number,
                       x_result                 out NOCOPY APPROVAL_REQUEST_TABLE_TYPE,
                       p_sort_option in varchar2);


/**
  * Function   :  getWFActivityStatus
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Return the status of the given WF item
  * Parameters  :
  * input parameters
  * @param     itemType
  *     description:  The WF item type
  *     required   :  Y
  *     validation :  Must be a valid WF item type
  *   itemKey:
  *     description:  The WF item key
  *     required   :  Y
  *     validation :  Must be a valid WF item key
  *
  * Return Value
  *   x_result:  -1 => Errored WF
  *              -2 => Cancelled WF
  *               0 => Active WF
 */
function getWorkflowActivityStatus(itemType varchar2, itemKey varchar2) return number;

end JTF_UM_APPROVAL_REQUESTS_PVT;

/
