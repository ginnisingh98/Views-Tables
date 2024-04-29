--------------------------------------------------------
--  DDL for Package Body JTF_UM_WF_DELEGATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_WF_DELEGATION_PVT" as
/* $Header: JTFVDELB.pls 120.5 2006/01/16 09:42:41 vimohan ship $ */
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

MODULE_NAME  CONSTANT VARCHAR2(50) := 'JTF.UM.PLSQL.JTF_UM_WF_DELEGATION_PVT';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME);

procedure has_admin_enrollment (
                                   p_subscription_id       in number,
                                   p_user_id               in number,
                                   x_has_enrollment        out NOCOPY number
                               ) IS

l_procedure_name CONSTANT varchar2(30) := 'has_admin_enrollment';
CURSOR FIND_SUB_ROLES IS SELECT PRINCIPAL_NAME FROM JTF_UM_SUBSCRIPTION_ROLE
WHERE SUBSCRIPTION_ID = p_subscription_id
AND   NVL(EFFECTIVE_END_DATE , SYSDATE+1) > SYSDATE;

l_principal_name JTF_AUTH_PRINCIPALS_B.PRINCIPAL_NAME%TYPE;

BEGIN

  JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if (JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME) ) then
  /* Bug #3468334  */
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_id:' || p_subscription_id || '+' || 'p_user_id:' || p_user_id
                                    );
  end if;


   x_has_enrollment := 1; -- true if there are no roles associated to an enrollment

   OPEN FIND_SUB_ROLES;
   LOOP
     FETCH FIND_SUB_ROLES INTO l_principal_name;
     EXIT WHEN FIND_SUB_ROLES%NOTFOUND;

      x_has_enrollment := 0; -- set it to false, before checking, as we found at least one role

      if JTF_UM_UTIL_PVT.check_role(
                     p_user_id        => p_user_id,
                     p_principal_name => l_principal_name
                    ) then

            x_has_enrollment := 1;

      end if;

       IF  x_has_enrollment = 0 THEN
       EXIT;  -- no need to check further, if we can find at least one role
              -- which an admin does not have
       END IF;

    END LOOP;
  CLOSE FIND_SUB_ROLES;

   JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END has_admin_enrollment;

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
  * x_result: The value indicating whether an approver can delegate or not.
  *           This API will return true, if no delegation role has been
  *           defined for an enrollment
  *
  * Note:
  *
  * This API will call has_delagation_role() and has_admin_enrollment
  * Please note that this API should NOT be used for the enrollments
  * that have either "IMPLICIT" or "EXPLICIT" delegation mode.
 */
procedure can_delegate(
                       p_subscription_id  in number,
                       p_user_id          in number,
                       x_result           out NOCOPY boolean
                       )  is

l_procedure_name CONSTANT varchar2(30) := 'can_delegate';

l_has_enrollment number;
x_return_result boolean := false;

begin

    JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

    if ( JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME) ) then
    /* Bug #3468334 changed --  */
    JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_subscription_id:' || p_subscription_id || '+' || 'p_user_id:' || p_user_id
                                    );
    end if;

          x_result := false;

          -- Check if a user has a delegation role or not
          has_delegation_role (
                       p_subscription_id  => p_subscription_id,
                       p_user_id          => p_user_id,
                       x_result           => x_return_result
                              );

          -- If a user does have a delegation role then, check
          -- if a user has all the roles for an enrollment

          IF x_return_result THEN
          has_admin_enrollment (
                                   p_subscription_id   => p_subscription_id,
                                   p_user_id           => p_user_id,
                                   x_has_enrollment    => l_has_enrollment
                               );
          END IF;

          -- set the out parameter based on the result

          IF l_has_enrollment = 1 THEN

            x_result := true;

          END IF;

   JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

end can_delegate;

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
                                   x_result          out NOCOPY boolean) is

l_procedure_name CONSTANT varchar2 (23) := 'can_enrollment_delegate';
l_sub_flag jtf_um_usertype_subscrip.subscription_flag%type;

cursor get_subscription_flag is
  select subscription_flag
  from jtf_um_usertype_subscrip
  where usertype_id = p_usertype_id
  and subscription_id = p_subscription_id
  and effective_start_date <= sysdate
  and nvl (effective_end_date, sysdate + 1) > sysdate;

begin

  JTF_DEBUG_PUB.LOG_ENTERING_METHOD (p_module  => MODULE_NAME,
                                     p_message => l_procedure_name);

  if ( JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME) ) then
  /* Bug #3468334 changed -- */
  JTF_DEBUG_PUB.LOG_PARAMETERS (p_module  => MODULE_NAME,
                                p_message => 'p_subscription_id:' || p_subscription_id || '+' || 'p_usertype_id:' || p_usertype_id);
  end if;

  x_result := false;

  open get_subscription_flag;
  fetch get_subscription_flag into l_sub_flag;
  close get_subscription_flag;

  if (l_sub_flag = 'DELEGATION') or (l_sub_flag = 'DELEGATION_SELFSERVICE') then
    x_result := true;
  END IF;

  JTF_DEBUG_PUB.LOG_EXITING_METHOD (p_module  => MODULE_NAME,
                                    p_message => l_procedure_name);

end can_enrollment_delegate;

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
                       ) IS

l_result boolean := false;
BEGIN
           can_delegate(
                       p_subscription_id  => p_subscription_id,
                       p_user_id          => p_user_id,
                       x_result           => l_result
                       );

           IF l_result THEN
             x_result := 1;
           ELSE
             x_result := 0;
           END IF;

END can_delegate_int;

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
  * Note:
  * This API will return true, if there is no delegataion role defined for
  * an enrollment.
 */

procedure has_delegation_role (
                                         p_subscription_id  in number,
                                         p_user_id          in number,
                                         x_result           out NOCOPY boolean
                                        ) IS
l_procedure_name CONSTANT varchar2(30) := 'has_delegation_role';
l_delegation_role_id number;
BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

if( JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME) ) then
/* Bug #3468334 changed --  */
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                               p_message   => 'p_subscription_id:' || p_subscription_id || '+' || 'p_user_id:' || p_user_id
                                    );
end if;

IF NOT JTF_UM_UTIL_PVT.VALIDATE_USER_ID(p_user_id) THEN

JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('user_id')
                            );

RAISE_APPLICATION_ERROR(-20000, JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('user_id'));

END IF;

IF NOT JTF_UM_UTIL_PVT.VALIDATE_SUBSCRIPTION_ID(p_subscription_id) THEN

JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('subscription_id')
                            );

RAISE_APPLICATION_ERROR(-20000, JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('subscription_id'));


END IF;

     JTF_UM_SUBSCRIPTIONS_PKG.get_delegation_role(
                       p_subscription_id  => p_subscription_id,
                       x_delegation_role  => l_delegation_role_id
                                   );

    IF  l_delegation_role_id IS NULL THEN
    x_result := TRUE;
    ELSE

    x_result := JTF_UM_UTIL_PVT.check_role(
                                      p_user_id              => p_user_id,
                                      p_auth_principal_id    => l_delegation_role_id
                                     );
    END IF;

 JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END has_delegation_role;


/**
  * Procedure   :  get_checkbox_status
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
  * @param     p_grant_delegation_flag
  *     description:  The value of grant_delegation_flag
  *     required   :  Y
  *     validation :  Must be true or false
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
  *  Note : This is a package private procedure
  *
 */

procedure get_checkbox_status (
                                   p_subscription_id       in number,
                                   p_grant_delegation_flag in boolean,
                                   p_user_id               in number,
                                   p_usertype_id           in number,
                                   p_ignore_del_flag       in boolean := false,
                                   p_enrl_owner_user_id in number := FND_API.G_MISS_NUM,
                                   x_result                out NOCOPY number
                               ) IS

l_procedure_name CONSTANT varchar2(30) := 'get_checkbox_status';
l_delegation_role_id  JTF_UM_SUBSCRIPTIONS_B.AUTH_DELEGATION_ROLE_ID%TYPE;
l_has_user_enrollment number;
query_user_has_roles number :=0;
l_activation_mode JTF_UM_USERTYPE_SUBSCRIP.SUBSCRIPTION_FLAG%TYPE;
l_user_has_role boolean := false;

-- This query will find out the active user type to subscription mapping
-- If no active mapping exists, then it will pick up the latest record
-- which has been end dated

CURSOR FIND_ACTIVATION_MODE IS SELECT SUBSCRIPTION_FLAG FROM JTF_UM_USERTYPE_SUBSCRIP
WHERE SUBSCRIPTION_ID = p_subscription_id
AND   USERTYPE_ID = p_usertype_id
ORDER BY EFFECTIVE_END_DATE DESC;

BEGIN

  JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


  if ( JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME) ) then
  /* Bug #3468334 changed  */
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                               p_message   => 'p_subscription_id:' || p_subscription_id || '+'  || 'p_grant_delegation_flag:' || JTF_DBSTRING_UTILS.getBooleanString(p_grant_delegation_flag) || '+'  || 'p_user_id:' || p_user_id
                                    );
  end if;

  OPEN FIND_ACTIVATION_MODE;
  FETCH FIND_ACTIVATION_MODE INTO l_activation_mode;
  CLOSE FIND_ACTIVATION_MODE;

  IF l_activation_mode IS NULL THEN
    JTF_DEBUG_PUB.LOG_EXCEPTION( p_module   => MODULE_NAME,
                             p_message   => JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('JTA_UM_UT_ENROLL_NO_ASGN')
                            );

    RAISE_APPLICATION_ERROR(-20000,  JTF_DEBUG_PUB.GET_INVALID_PARAM_MSG('JTA_UM_UT_ENROLL_NO_ASGN'));
  END IF;


  -- Check if an enrollment is IMPLICIT or EXPLICIT
  -- In this case, the status of the checkbox will be grayed and unchecked

  IF l_activation_mode = 'IMPLICIT' OR l_activation_mode = 'EXPLICIT' THEN

     x_result := NOT_CHECKED_NO_UPDATE;

  ELSE    -- The enrollment is either DELEGATION or DELEGATION_SELFSERVICE.


      -- Check if a user has all the roles for this enrollment

      has_admin_enrollment (
                                   p_subscription_id      => p_subscription_id,
                                   p_user_id              => p_user_id,
                                   x_has_enrollment       => l_has_user_enrollment
                            );

  --check if queried user has all the roles

	    if p_enrl_owner_user_id <> FND_API.G_MISS_NUM then

	    has_admin_enrollment (
                                   p_subscription_id      => p_subscription_id,
                                   p_user_id              => p_enrl_owner_user_id,
                                   x_has_enrollment       => query_user_has_roles
                            );

            end if;



      -- Check if an enrollment has a delegation role

      JTF_UM_SUBSCRIPTIONS_PKG.get_delegation_role(
                       p_subscription_id  => p_subscription_id,
                       x_delegation_role  => l_delegation_role_id
                                   );



           IF l_has_user_enrollment = 1 THEN   -- User does have all the roles

	   IF  l_delegation_role_id IS NULL THEN

              -- The enrollment does not have a delegation role

	                --check if queried user has all the roles
	                IF query_user_has_roles = 1 THEN

                         x_result := CHECKED_NO_UPDATE;

			 ELSE

			 x_result := NOT_CHECKED_NO_UPDATE;

			 END IF;



           ELSE

              -- The enrollment does have a delegation role

                 -- Check if  queried user has this delegation role

              IF p_ignore_del_flag THEN

                    l_user_has_role := false;


                 IF JTF_UM_UTIL_PVT.check_role(
                                      p_user_id              => p_enrl_owner_user_id,
                                      p_auth_principal_id    => l_delegation_role_id
                                              ) THEN



		    l_user_has_role := true;


                 END IF;

               END IF;

                 -- Check if a current logged in user has this delegation role

                 IF JTF_UM_UTIL_PVT.check_role(
                                      p_user_id              => p_user_id,
                                      p_auth_principal_id    => l_delegation_role_id
                                              ) THEN

                         -- The user does have the delegation role

                   IF p_ignore_del_flag THEN

                       IF l_user_has_role THEN

			 --check if queried user has all the roles
		         IF query_user_has_roles = 1 THEN

                         x_result := CHECKED_UPDATE;

			 ELSE

			 x_result := NOT_CHECKED_NO_UPDATE;

			 END IF;

                       ELSE

			 --check if queried user has all the roles
                         IF query_user_has_roles = 1 THEN

			 x_result := NOT_CHECKED_UPDATE;

			 ELSE

                         x_result := NOT_CHECKED_NO_UPDATE;

			 END IF;

                       END IF;

                   ELSE

                     IF  p_grant_delegation_flag THEN

                         -- The grant delegation flag is set

                           x_result := CHECKED_UPDATE;

                     ELSE

                         -- The grant delegation flag is not set

                            x_result := NOT_CHECKED_UPDATE;

                     END IF;

                   END IF;

                 ELSE
                         -- A user does not have the delegation role


                    IF p_ignore_del_flag THEN

                       IF l_user_has_role THEN

		         --check if queried user has all the roles
			 IF query_user_has_roles = 1 THEN

                         x_result := CHECKED_NO_UPDATE;

			 ELSE

			 x_result := NOT_CHECKED_NO_UPDATE;

			 END IF;


                       ELSE

                         x_result := NOT_CHECKED_NO_UPDATE;

                       END IF;

                    ELSE

                      IF  p_grant_delegation_flag THEN

                         -- The grant delegation flag is set

                           x_result := CHECKED_NO_UPDATE;

                      ELSE

                         -- The grant delegation flag is not set

                           x_result := NOT_CHECKED_NO_UPDATE;

                      END IF;

                   END IF;

                 END IF;

           END IF;

      ELSE  -- User does not have all the roles


             IF  l_delegation_role_id IS NULL THEN

              -- The enrollment does not have a delegation role

	                 --check if queried user has all the roles
			 IF query_user_has_roles = 1 THEN

                         x_result := CHECKED_NO_UPDATE;

			 ELSE

			 x_result := NOT_CHECKED_NO_UPDATE;

			 END IF;



           ELSE

              IF p_ignore_del_flag THEN

                    l_user_has_role := false;

                 IF JTF_UM_UTIL_PVT.check_role(
                                      p_user_id              => p_enrl_owner_user_id,
                                      p_auth_principal_id    => l_delegation_role_id
                                              ) THEN

                    l_user_has_role := true;


                 END IF;

               END IF;

              -- The enrollment does have a delegation role

                 IF p_ignore_del_flag THEN

                       IF l_user_has_role THEN

                        --check if queried user has all the roles
			IF query_user_has_roles = 1 THEN

                         x_result := CHECKED_NO_UPDATE;

			 ELSE

			 x_result := NOT_CHECKED_NO_UPDATE;

			 END IF;


                       ELSE

                         x_result := NOT_CHECKED_NO_UPDATE;

                       END IF;

                 ELSE

                     IF  p_grant_delegation_flag THEN

                         -- The grant delegation flag is set

                           x_result := CHECKED_NO_UPDATE;

                     ELSE

                         -- The grant delegation flag is not set

                           x_result := NOT_CHECKED_NO_UPDATE;

                     END IF;

                 END IF;

           END IF;

        END IF;

  END IF;

 JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END get_checkbox_status;


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
                               ) IS

BEGIN

   get_checkbox_status (
                        p_reg_id          => p_reg_id,
                        p_user_id         => p_user_id,
                        p_ignore_del_flag => false,
                        x_result          => x_result
                       );

END get_checkbox_status;
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
                               ) IS

l_procedure_name CONSTANT varchar2(30) := 'get_checkbox_status';

CURSOR FIND_DELEGATION_FLAG IS SELECT GRANT_DELEGATION_FLAG,SUBSCRIPTION_ID
FROM JTF_UM_SUBSCRIPTION_REG
WHERE SUBSCRIPTION_REG_ID = p_reg_id;

CURSOR FIND_USERTYPE_ID IS SELECT UTREG.USERTYPE_ID
FROM JTF_UM_USERTYPE_REG UTREG, JTF_UM_SUBSCRIPTION_REG SUBREG
WHERE SUBREG.USER_ID = UTREG.USER_ID
AND   SUBREG.SUBSCRIPTION_REG_ID = p_reg_id
and nvl(UTREG.effective_end_date,sysdate+1) > sysdate;

l_grant_delegation_flag JTF_UM_SUBSCRIPTION_REG.GRANT_DELEGATION_FLAG%TYPE;
l_subscription_id JTF_UM_SUBSCRIPTION_REG.SUBSCRIPTION_ID%TYPE;
l_delegation_role_id  JTF_UM_SUBSCRIPTIONS_B.AUTH_DELEGATION_ROLE_ID%TYPE;
l_flag_boolean boolean := false;
l_usertype_id number;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

if ( JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME) ) then
/* Bug #3468334 changed  */
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                               p_message   => 'p_reg_id:' || p_reg_id || '+' || 'p_user_id:' || p_user_id
                                    );
end if;
OPEN FIND_DELEGATION_FLAG;
FETCH FIND_DELEGATION_FLAG INTO l_grant_delegation_flag,l_subscription_id;

   IF FIND_DELEGATION_FLAG%NOTFOUND THEN

      x_result := NO_CHECKBOX;

   ELSE

      IF l_grant_delegation_flag = 'Y' THEN

        l_flag_boolean := true;

      END IF;

      OPEN FIND_USERTYPE_ID;
      FETCH FIND_USERTYPE_ID INTO l_usertype_id;
      CLOSE FIND_USERTYPE_ID;

      get_checkbox_status (
                            p_subscription_id       => l_subscription_id,
                            p_grant_delegation_flag => l_flag_boolean,
                            p_user_id               => p_user_id,
                            p_usertype_id           => l_usertype_id,
                            p_ignore_del_flag       => p_ignore_del_flag,
                            p_enrl_owner_user_id    => p_enrl_owner_user_id,
                            x_result                => x_result
                          );

   END IF;

CLOSE FIND_DELEGATION_FLAG;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


END get_checkbox_status;


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
                               ) IS

l_delegation_role_id  JTF_UM_SUBSCRIPTIONS_B.AUTH_DELEGATION_ROLE_ID%TYPE;
l_procedure_name CONSTANT varchar2(30) := 'get_checkbox_status_reg';

BEGIN

 JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );



      get_checkbox_status (
                            p_subscription_id       => p_subscription_id,
                            p_grant_delegation_flag => false,
                            p_user_id               => p_user_id,
                            p_usertype_id           => p_usertype_id,
                            x_result                => x_result
                          );

   JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END get_checkbox_status_reg;

/**
  * Procedure   :  get_enrollment_avail
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine if an admin has this enrollment
  *                or not and it will also determine the
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
                               ) IS

l_procedure_name CONSTANT varchar2(30) := 'get_enrollment_avail';

BEGIN


  JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


   x_checkbox_code := 0;

   can_delegate_int(
                       p_subscription_id  => p_subscription_id,
                       p_user_id          => p_user_id,
                       x_result           => x_can_assign
                       );

    get_checkbox_status_reg (
                              p_subscription_id  => p_subscription_id,
                              p_user_id          => p_user_id,
                              p_usertype_id      => p_usertype_id,
                              x_result           => x_checkbox_code
                            );

    JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


END get_enrollment_avail;


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
                                 ) return number is

l_procedure_name CONSTANT varchar2(30) := 'is_approval_required';
l_approval_required boolean;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

if ( JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME) ) then
/* Bug #3468334 changed --  */
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_subscription_id:'|| p_subscription_id || '+' || 'p_approval_id:' || p_approval_id
                              || '+' || 'p_activation_mode:' || p_activation_mode ||  '+' || 'p_is_admin:' || p_is_admin || '+' || 'p_can_assign:' || p_can_assign
                             );
end if;

  IF p_approval_id IS NULL THEN

    -- No approval is required, if approval id is null

    l_approval_required := false;

  ELSE

    IF p_is_admin = 0 THEN

       -- If it is not an admin then apprpoval is required

       l_approval_required := true;

    ELSE

       IF p_activation_mode = 'IMPLICIT' OR p_activation_mode = 'EXPLICIT' THEN

          -- If activation mode is implicit or explicit then approval
          -- is required. These are old activation modes

          l_approval_required := true;

       ELSIF p_can_assign = 1 THEN

             -- No approval is required, if an admin can assign

             l_approval_required := false;

       ELSE

             -- Approval is required, if an admin cannot assign

             l_approval_required := true;

       END IF;

    END IF;

  END IF;

 JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

 IF l_approval_required THEN
  return 1;
 ELSE
  return 0;
 END IF;

END is_approval_required;


end JTF_UM_WF_DELEGATION_PVT;

/
