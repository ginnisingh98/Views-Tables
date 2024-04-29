--------------------------------------------------------
--  DDL for Package JTF_UM_SUBSCRIPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_SUBSCRIPTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: JTFUMSBS.pls 120.3 2005/11/28 08:52:24 vimohan ship $ */
procedure INSERT_ROW (
  X_SUBSCRIPTION_ID out NOCOPY NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_SUBSCRIPTION_KEY in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_ID in NUMBER,
  X_PARENT_SUBSCRIPTION_ID in NUMBER,
  X_AVAILABILITY_CODE in VARCHAR2,
  X_LOGON_DISPLAY_FREQUENCY in NUMBER,
  X_SUBSCRIPTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_AUTH_DELEGATION_ROLE_ID in NUMBER);
procedure LOCK_ROW (
  X_SUBSCRIPTION_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_SUBSCRIPTION_KEY in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_ID in NUMBER,
  X_PARENT_SUBSCRIPTION_ID in NUMBER,
  X_AVAILABILITY_CODE in VARCHAR2,
  X_LOGON_DISPLAY_FREQUENCY in NUMBER,
  X_SUBSCRIPTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_AUTH_DELEGATION_ROLE_ID in NUMBER
);
procedure UPDATE_ROW (
  X_SUBSCRIPTION_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_SUBSCRIPTION_KEY in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_END_DATE in DATE,
  X_APPROVAL_ID in NUMBER,
  X_PARENT_SUBSCRIPTION_ID in NUMBER,
  X_AVAILABILITY_CODE in VARCHAR2,
  X_LOGON_DISPLAY_FREQUENCY in NUMBER,
  X_SUBSCRIPTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_AUTH_DELEGATION_ROLE_ID in NUMBER
);
procedure DELETE_ROW (
  X_SUBSCRIPTION_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure LOAD_ROW (
    X_SUBSCRIPTION_ID        IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_OWNER                  IN VARCHAR2,
    X_APPROVAL_ID	     IN NUMBER,
    X_APPLICATION_ID         IN NUMBER,
    X_ENABLED_FLAG           IN VARCHAR2,
    X_PARENT_SUBSCRIPTION_ID IN NUMBER,
    X_AVAILABILITY_CODE      IN VARCHAR2,
    X_LOGON_DISPLAY_FREQUENCY IN NUMBER,
    X_SUBSCRIPTION_KEY       IN VARCHAR2,
    X_SUBSCRIPTION_NAME       IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    X_AUTH_DELEGATION_ROLE_ID IN NUMBER,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
);

procedure TRANSLATE_ROW (
  X_SUBSCRIPTION_ID in NUMBER, -- key field
  X_SUBSCRIPTION_NAME in VARCHAR2, -- translated name
  X_DESCRIPTION in VARCHAR2, -- translated description
  X_OWNER in VARCHAR2, -- owner field
  x_last_update_date       in varchar2 default NULL,
  X_CUSTOM_MODE            in varchar2 default NULL
);

procedure CREATE_TEMPLATE_ASSIGNMENT(
   X_SUBSCRIPTION_ID IN NUMBER,
   X_TEMPLATE_ID IN NUMBER,
   X_EFFECTIVE_START_DATE IN DATE DEFAULT SYSDATE,
   X_EFFECTIVE_END_DATE IN DATE DEFAULT NULL,
   X_CREATED_BY IN NUMBER DEFAULT FND_GLOBAL.USER_ID,
   X_LAST_UPDATED_BY IN NUMBER DEFAULT FND_GLOBAL.USER_ID
);

procedure UPDATE_TEMPLATE_ASSIGNMENT(
   X_SUBSCRIPTION_ID IN NUMBER,
   X_TEMPLATE_ID IN NUMBER,
   X_EFFECTIVE_START_DATE IN DATE,
   X_EFFECTIVE_END_DATE IN DATE,
   X_LAST_UPDATE_DATE IN DATE,
   X_LAST_UPDATED_BY IN NUMBER,
   X_LAST_UPDATE_LOGIN IN NUMBER
);

procedure LOAD_SUBSCRIPTION_TMPL_ROW(
    X_SUBSCRIPTION_ID        IN NUMBER,
    X_TEMPLATE_ID            IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_OWNER                  IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
);

procedure ASSOCIATE_TEMPLATE(
   X_SUBSCRIPTION_ID NUMBER,
   X_TEMPLATE_ID NUMBER
);
procedure REMOVE_TEMPLATE_ASSIGNMENT(
   X_SUBSCRIPTION_ID IN NUMBER
);
procedure INSERT_SUBREG_ROW (
  X_SUBSCRIPTION_ID in NUMBER,
  X_LAST_APPROVER_COMMENT in VARCHAR2,
  X_APPROVER_USER_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_WF_ITEM_TYPE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_SUBSCRIPTION_REG_ID out NOCOPY NUMBER,
  X_USER_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_GRANT_DELEGATION_FLAG in VARCHAR2 := 'N'
);

/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_reg_id
 *    description:  The subscription_reg_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean equivallent int value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This procedure is create as wrapper procedure to pass boolean
 *   values, as JDBC cannot handle boolean !!!!!
 */
procedure update_grant_delegation_flag (
                       p_subscription_reg_id       in number,
                       p_grant_delegation_flag     in number
                                        );

/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_reg_id
 *    description:  The subscription_reg_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean equivallent int value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *   p_grant_delegation_role:
 *     description:  The Boolean equivallent int value of the decision
 *                   whether to grant delegation role or not
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This procedure is create as wrapper procedure to pass boolean
 *   values, as JDBC cannot handle boolean !!!!!
 */
procedure update_grant_delegation_flag (
                       p_subscription_reg_id       in number,
                       p_grant_delegation_flag     in number,
                       p_grant_delegation_role     in number
                                        );


/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_reg_id
 *    description:  The subscription_reg_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be true or false. The procedure will default it to
 *                   false, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   The procedure will try to update the grant_delegation_flag based on the input values.
 *   If a procedure can not find any matching row, then it will not raise any exception
 *   but will not update any rows. It is caller's responsibility to make sure that
 *   the correct parameters are passed
 */
procedure update_grant_delegation_flag (
                       p_subscription_reg_id       in number,
                       p_grant_delegation_flag     in boolean
                                        );


/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_user_name:
 *     description:  The user_name of a user
 *     required   :  Y
 *     validation :  Must be a valid user_name.The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean equivallent int value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This procedure is create as wrapper procedure to pass boolean
 *   values, as JDBC cannot handle boolean !!!!!
 */
procedure update_grant_delegation_flag (
                       p_subscription_id       in number,
                       p_user_name             in varchar2,
                       p_grant_delegation_flag in number
                                        );




/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_user_name:
 *     description:  The user_name of a user
 *     required   :  Y
 *     validation :  Must be a valid user_name.The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be true or false. The procedure will default it to
 *                   false, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   The procedure will try to update the grant_delegation_flag based on the input values.
 *   If a procedure can not find any matching row, then it will not raise any exception
 *   but will not update any rows. It is caller's responsibility to make sure that
 *   the correct parameters are passed
 */
procedure update_grant_delegation_flag (
                       p_subscription_id       in number,
                       p_user_name             in varchar2,
                       p_grant_delegation_flag in boolean
                                        );


/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id.The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean equivallent int value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be 0 or 1. The procedure will default it to
 *                   0, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   This procedure is create as wrapper procedure to pass boolean
 *   values, as JDBC cannot handle boolean !!!!!
 */

procedure update_grant_delegation_flag (
                       p_subscription_id       in number,
                       p_user_id               in number,
                       p_grant_delegation_flag in number
                                        );


/*
 * Name        :  update_grant_delegation_flag
 * Pre_reqs    :  None
 * Description :  Will update the information of the grant_delegation_flag
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id. The procedure will not do
 *                   any explicit validation.
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id.The procedure will not do
 *                   any explicit validation.
 *   p_grant_delegation_flag:
 *     description:  The Boolean value of the grant_delegation_flag
 *     required   :  Y
 *     validation :  Should be true or false. The procedure will default it to
 *                   false, if null value is passed
 *
 * output parameters
 * None
 *
 * Notes:
 *
 *   The procedure will try to update the grant_delegation_flag based on the input values.
 *   If a procedure can not find any matching row, then it will not raise any exception
 *   but will not update any rows. It is caller's responsibility to make sure that
 *   the correct parameters are passed
 */
procedure update_grant_delegation_flag (
                       p_subscription_id       in number,
                       p_user_id               in number,
                       p_grant_delegation_flag in boolean
                                        );

/*
 * Name        : get_delegation_role
 * Pre_reqs    :  None
 * Description :  Will determine if an enrollment has a delegation role
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id
 * output parameters
 * x_delegation_role
 *    description: The value of the column auth_delegation_id of the table
 *                 JTF_UM_ENROLLMENTS_B. This value will be 0, if no
 *                 no delegation role has been defined for this enrollment
 *
 * Note:
 *
 *   This API will raise an exception if no record is found which matches
 *   to the subscription_id being passed
 */

procedure get_delegation_role(
                       p_subscription_id  in number,
                       x_delegation_role  out NOCOPY number
                             );

/**
 * Procedure   :  get_grant_delegation_flag
 * Type        :  Private
 * Pre_reqs    :  None
 * Description :  Will return the value of the column grant_delegation_flag
 *                from the table JTF_UM_SUBSCRIPTIONS_REG
 * Parameters  :
 * input parameters
 * @param     p_subscription_id
 *    description:  The subscription_id of an enrollment
 *     required   :  Y
 *     validation :  Must be a valid subscription_id
 *   p_user_id:
 *     description:  The user_id of a user
 *     required   :  Y
 *     validation :  Must be a valid user_id
 * output parameters
 * x_result: The Boolean value based on the column grant_delegation_flag
 *
 * Note:
 *
 * This API will raise an exception, if subscription_id or user_id is invalid
 *
 */

procedure get_grant_delegation_flag(
                       p_subscription_id  in number,
                       p_user_id          in number,
                       x_result           out NOCOPY boolean
                                  );

end JTF_UM_SUBSCRIPTIONS_PKG;

 

/
