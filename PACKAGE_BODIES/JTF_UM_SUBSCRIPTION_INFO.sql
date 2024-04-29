--------------------------------------------------------
--  DDL for Package Body JTF_UM_SUBSCRIPTION_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_SUBSCRIPTION_INFO" as
/*$Header: JTFVSBIB.pls 120.1 2005/07/02 02:14:32 appldev ship $*/

MODULE_NAME  CONSTANT VARCHAR2(50) := 'JTF.UM.PLSQL.JTF_UM_SUBSCRIPTION_INFO';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME);

function is_user_enrolled(p_subscription_id number,
                          p_user_id         number) return NUMBER IS


CURSOR USER_ENROLLMENT IS SELECT SUBSCRIPTION_REG_ID
FROM JTF_UM_SUBSCRIPTION_REG
WHERE SUBSCRIPTION_ID = p_subscription_id
AND   USER_ID         = p_user_id
AND   NVL(EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND   STATUS_CODE IN ('APPROVED', 'PENDING');

l_return_value NUMBER;
l_dummy NUMBER;

BEGIN

  l_return_value := 1;

  OPEN USER_ENROLLMENT;
  FETCH USER_ENROLLMENT INTO l_dummy;

     IF USER_ENROLLMENT%NOTFOUND THEN

        l_return_value := 0;

     END IF;

  CLOSE USER_ENROLLMENT;

  return l_return_value;

END is_user_enrolled;



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
                       ) IS

l_procedure_name CONSTANT varchar2(30) := 'GET_USERTYPE_SUB_INFO';

CURSOR FIND_SUB_INFO IS SELECT A.SUBSCRIPTION_FLAG, A.SUBSCRIPTION_ID, A.SUBSCRIPTION_DISPLAY_ORDER, B.SUBSCRIPTION_KEY, B.SUBSCRIPTION_NAME, B.DESCRIPTION, B.AUTH_DELEGATION_ROLE_ID, B.APPROVAL_ID
FROM JTF_UM_USERTYPE_SUBSCRIP A, JTF_UM_SUBSCRIPTIONS_VL B
WHERE A.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.USERTYPE_ID = p_usertype_id
AND NVL(A.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND B.ENABLED_FLAG = 'Y'
AND A.EFFECTIVE_START_DATE < SYSDATE
ORDER BY A.SUBSCRIPTION_DISPLAY_ORDER, B.SUBSCRIPTION_NAME;

i NUMBER := 1;
show_enrollment boolean;
l_checkbox_code NUMBER;
l_can_assign NUMBER;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                 );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_usertype_id:' || p_usertype_id || '+' || 'p_user_id:' || p_user_id || '+' || 'p_is_admin:' || p_is_admin
                            );
end if;

   FOR j in FIND_SUB_INFO LOOP

       show_enrollment := false;
       l_can_assign := 0;

       JTF_UM_WF_DELEGATION_PVT.get_enrollment_avail(
                          p_subscription_id  => j.SUBSCRIPTION_ID,
                          p_user_id          => p_user_id,
                          p_usertype_id      => p_usertype_id,
                          x_checkbox_code    => l_checkbox_code,
                          x_can_assign       => l_can_assign
                            );

       IF j.SUBSCRIPTION_FLAG <> 'DELEGATION' THEN

          -- Show all the enrollments except Delegation Only

          show_enrollment := true;

       ELSIF p_is_admin = 1  AND l_can_assign = 1  THEN

          -- Don't show for self service user
          -- show if admin can assign this to user

          show_enrollment := true;

       END IF;

       IF show_enrollment THEN

         x_result(i).NAME            := j.SUBSCRIPTION_NAME;
         x_result(i).KEY             := j.SUBSCRIPTION_KEY;
         x_result(i).DESCRIPTION     := j.DESCRIPTION;
         x_result(i).DISPLAY_ORDER   := j.SUBSCRIPTION_DISPLAY_ORDER;
         x_result(i).ACTIVATION_MODE := j.SUBSCRIPTION_FLAG;
         x_result(i).DELEGATION_ROLE := j.AUTH_DELEGATION_ROLE_ID;
         x_result(i).CHECKBOX_STATUS := l_checkbox_code;
         x_result(i).SUBSCRIPTION_ID := j.SUBSCRIPTION_ID;

         x_result(i).APPROVAL_REQUIRED :=  JTF_UM_WF_DELEGATION_PVT.is_approval_required(
                         p_subscription_id  => j.SUBSCRIPTION_ID,
                         p_approval_id      => j.APPROVAL_ID,
                         p_activation_mode  => j.SUBSCRIPTION_FLAG,
                         p_is_admin         => p_is_admin,
                         p_can_assign       => l_can_assign
                                 );

         i := i + 1;

       END IF;

   END LOOP;


JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END GET_USERTYPE_SUB_INFO;


procedure GET_USER_ASSIGNED_SUB(
                       p_user_id           in number,
                       p_usertype_id       in number,
                       p_administrator     in number,
                       p_logged_in_user_id in number,
                       p_sub_status        in varchar2,
                       x_result            out NOCOPY SUBSCRIPTION_INFO_TABLE
                       ) IS

l_procedure_name CONSTANT varchar2(30) := 'GET_USER_ASSIGNED_SUB';

CURSOR FIND_SUB_INFO IS

SELECT SUBSCRIPTION_STATUS, SUBSCRIPTION_FLAG, SUBSCRIPTION_ID, SUBSCRIPTION_DISPLAY_ORDER,
SUBSCRIPTION_KEY, SUBSCRIPTION_NAME, DESCRIPTION, AUTH_DELEGATION_ROLE_ID, REG_ID FROM
(
SELECT DECODE(SUBREG.STATUS_CODE,'APPROVED','CURRENT','PENDING','PENDING') SUBSCRIPTION_STATUS, A.SUBSCRIPTION_FLAG, A.SUBSCRIPTION_ID, A.SUBSCRIPTION_DISPLAY_ORDER,
B.SUBSCRIPTION_KEY, B.SUBSCRIPTION_NAME, B.DESCRIPTION, B.AUTH_DELEGATION_ROLE_ID, SUBREG.SUBSCRIPTION_REG_ID REG_ID
FROM JTF_UM_USERTYPE_SUBSCRIP A, JTF_UM_SUBSCRIPTIONS_VL B, JTF_UM_SUBSCRIPTION_REG SUBREG
WHERE SUBREG.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.USERTYPE_ID  = p_usertype_id
AND SUBREG.USER_ID = p_user_id
AND SUBREG.STATUS_CODE = p_sub_status
AND NVL(A.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND NVL(SUBREG.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND SUBREG.EFFECTIVE_START_DATE < SYSDATE

UNION ALL

SELECT DECODE(SUBREG.STATUS_CODE,'APPROVED','CURRENT','PENDING','PENDING') SUBSCRIPTION_STATUS, A.SUBSCRIPTION_FLAG, A.SUBSCRIPTION_ID, A.SUBSCRIPTION_DISPLAY_ORDER,
B.SUBSCRIPTION_KEY, B.SUBSCRIPTION_NAME, B.DESCRIPTION, B.AUTH_DELEGATION_ROLE_ID, SUBREG.SUBSCRIPTION_REG_ID REG_ID

FROM JTF_UM_USERTYPE_SUBSCRIP A, JTF_UM_SUBSCRIPTIONS_VL B, JTF_UM_SUBSCRIPTION_REG SUBREG
WHERE SUBREG.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.USERTYPE_ID  = p_usertype_id
AND SUBREG.USER_ID = p_user_id
AND SUBREG.STATUS_CODE = p_sub_status
AND A.EFFECTIVE_END_DATE IS NOT NULL
AND A.EFFECTIVE_END_DATE < SYSDATE
AND NVL(SUBREG.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND SUBREG.EFFECTIVE_START_DATE < SYSDATE
AND NOT EXISTS (SELECT 'X'
FROM JTF_UM_USERTYPE_SUBSCRIP A, JTF_UM_SUBSCRIPTIONS_VL B, JTF_UM_SUBSCRIPTION_REG SUBREG
WHERE SUBREG.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.USERTYPE_ID  = p_usertype_id
AND SUBREG.USER_ID = p_user_id
AND SUBREG.STATUS_CODE = p_sub_status
AND NVL(A.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND NVL(SUBREG.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND SUBREG.EFFECTIVE_START_DATE < SYSDATE)
AND A.EFFECTIVE_END_DATE IN(
    SELECT MAX(EFFECTIVE_END_DATE) FROM JTF_UM_USERTYPE_SUBSCRIP USUB
    WHERE USUB.USERTYPE_ID = p_usertype_id
    AND   USUB.SUBSCRIPTION_ID = A.SUBSCRIPTION_ID
    )
) ALL_ENROLLMENTS ORDER BY SUBSCRIPTION_NAME;

i NUMBER := 1;
l_checkbox_code NUMBER;
show_enrollment boolean;
l_ignore_del_flag boolean := false;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                 );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_user_id:' || p_user_id || '+' || 'p_usertype_id:' || p_usertype_id || '+' ||
                              'p_administrator:' || p_administrator || '+' ||  'p_logged_in_user_id:' || p_logged_in_user_id || '+' || 'p_sub_status:' || p_sub_status
                            );
end if;


 FOR j in FIND_SUB_INFO LOOP

      show_enrollment := false;

      IF p_administrator = 1 THEN

        show_enrollment := true;

      ELSIF j.SUBSCRIPTION_FLAG <> 'IMPLICIT' THEN

        show_enrollment := true;

      END IF;

      IF show_enrollment THEN

          IF j.SUBSCRIPTION_STATUS = 'CURRENT' THEN

            l_ignore_del_flag := true;

          END IF;

          JTF_UM_WF_DELEGATION_PVT.get_checkbox_status(
                        p_reg_id          => j.REG_ID,
                        p_user_id         => p_logged_in_user_id,
                        p_ignore_del_flag => l_ignore_del_flag,
                        p_enrl_owner_user_id => p_user_id,
                        x_result          => l_checkbox_code
                               );

         x_result(i).NAME            := j.SUBSCRIPTION_NAME;
         x_result(i).KEY             := j.SUBSCRIPTION_KEY;
         x_result(i).DESCRIPTION     := j.DESCRIPTION;
         x_result(i).DISPLAY_ORDER   := j.SUBSCRIPTION_DISPLAY_ORDER;
         x_result(i).ACTIVATION_MODE := j.SUBSCRIPTION_FLAG;
         x_result(i).DELEGATION_ROLE := j.AUTH_DELEGATION_ROLE_ID;
         x_result(i).CHECKBOX_STATUS := l_checkbox_code;
         x_result(i).SUBSCRIPTION_ID := j.SUBSCRIPTION_ID;
         x_result(i).SUBSCRIPTION_STATUS :=  j.SUBSCRIPTION_STATUS;
         x_result(i).SUBSCRIPTION_REG_ID := j.REG_ID;

         i := i + 1;

      END IF;

   END LOOP;


JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END GET_USER_ASSIGNED_SUB;

procedure GET_USER_AVAIL_SUB(
                       p_user_id           in number,
                       p_usertype_id       in number,
                       p_is_admin          in number,
                       p_administrator     in number,
                       p_logged_in_user_id in number,
                       x_result            out NOCOPY SUBSCRIPTION_INFO_TABLE
                       ) IS

l_procedure_name CONSTANT varchar2(30) := 'GET_USER_AVAIL_SUB';

CURSOR FIND_SUB_INFO IS
SELECT 'AVAILABLE' SUBSCRIPTION_STATUS, A.SUBSCRIPTION_FLAG, A.SUBSCRIPTION_ID, A.SUBSCRIPTION_DISPLAY_ORDER, B.SUBSCRIPTION_KEY, B.SUBSCRIPTION_NAME, B.DESCRIPTION, B.AUTH_DELEGATION_ROLE_ID, B.APPROVAL_ID, to_number(NULL) REG_ID
FROM JTF_UM_USERTYPE_SUBSCRIP A, JTF_UM_SUBSCRIPTIONS_VL B
WHERE A.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.USERTYPE_ID = p_usertype_id
AND NVL(A.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND B.ENABLED_FLAG = 'Y'
AND A.EFFECTIVE_START_DATE < SYSDATE
AND NOT EXISTS (SELECT SUBSCRIPTION_REG_ID FROM JTF_UM_SUBSCRIPTION_REG REG WHERE
    USER_ID = p_user_id
    AND REG.SUBSCRIPTION_ID = A.SUBSCRIPTION_ID
    AND REG.STATUS_CODE IN ('APPROVED', 'PENDING')
	AND NVL(REG.EFFECTIVE_END_DATE, SYSDATE +1 ) > Sysdate
	)
ORDER BY A.SUBSCRIPTION_DISPLAY_ORDER, B.SUBSCRIPTION_NAME;


i NUMBER := 1;
show_enrollment boolean;
l_checkbox_code NUMBER;
l_can_assign NUMBER;
l_approval_required NUMBER;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                 );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_user_id:' || p_user_id || '+' || 'p_is_admin:' || p_is_admin || '+' || 'p_administrator:'
                              || p_administrator || '+' || 'p_logged_in_user_id:' || p_logged_in_user_id
                            );
end if;
 FOR j in FIND_SUB_INFO LOOP

       show_enrollment := false;


       JTF_UM_WF_DELEGATION_PVT.get_enrollment_avail(
                          p_subscription_id  => j.SUBSCRIPTION_ID,
                          p_user_id          => p_logged_in_user_id,
                          p_usertype_id      => p_usertype_id,
                          x_checkbox_code    => l_checkbox_code,
                          x_can_assign       => l_can_assign
                            );

       IF j.SUBSCRIPTION_FLAG <> 'DELEGATION' THEN

          -- Show all the enrollments except Delegation Only

          -- Implicit enrollments are to be shown only to the administrator

          IF j.SUBSCRIPTION_FLAG = 'IMPLICIT' THEN

             IF p_administrator = 1 THEN

                show_enrollment := true;

             END IF;

          ELSE

          show_enrollment := true;

          END IF;

       ELSIF p_is_admin = 1  AND l_can_assign = 1  THEN

          -- Don't show for self service user
          -- show if admin can assign this to user

          show_enrollment := true;

       END IF;

       l_approval_required :=  JTF_UM_WF_DELEGATION_PVT.is_approval_required(
                         p_subscription_id  => j.SUBSCRIPTION_ID,
                         p_approval_id      => j.APPROVAL_ID,
                         p_activation_mode  => j.SUBSCRIPTION_FLAG,
                         p_is_admin         => p_is_admin,
                         p_can_assign       => l_can_assign
                                 );


       IF show_enrollment THEN

         x_result(i).NAME            := j.SUBSCRIPTION_NAME;
         x_result(i).KEY             := j.SUBSCRIPTION_KEY;
         x_result(i).DESCRIPTION     := j.DESCRIPTION;
         x_result(i).DISPLAY_ORDER   := j.SUBSCRIPTION_DISPLAY_ORDER;
         x_result(i).ACTIVATION_MODE := j.SUBSCRIPTION_FLAG;
         x_result(i).DELEGATION_ROLE := j.AUTH_DELEGATION_ROLE_ID;
         x_result(i).CHECKBOX_STATUS := l_checkbox_code;
         x_result(i).SUBSCRIPTION_ID := j.SUBSCRIPTION_ID;
         x_result(i).APPROVAL_REQUIRED :=  l_approval_required;
         x_result(i).SUBSCRIPTION_STATUS :=  j.SUBSCRIPTION_STATUS;

         i := i + 1;

       END IF;

   END LOOP;


JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END GET_USER_AVAIL_SUB;


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
                       ) IS

l_procedure_name CONSTANT varchar2(30) := 'GET_USER_SUB_INFO';


BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                 );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_user_id:' || p_user_id || '+' || 'p_is_admin:' || p_is_admin || '+' || 'p_sub_status:' || p_sub_status
                            );
end if;

  IF p_sub_status = 'AVAILABLE' THEN

     GET_USER_AVAIL_SUB(
                       p_user_id      => p_user_id,
                       p_usertype_id  => JTF_UM_UTIL_PVT.GET_USERTYPE_ID(p_user_id),
                       p_is_admin     => p_is_admin,
                       p_administrator =>    p_administrator,
                       p_logged_in_user_id => p_logged_in_user_id,
                       x_result       => x_result
                       );

  ELSE

     GET_USER_ASSIGNED_SUB(
                       p_user_id      => p_user_id,
                       p_usertype_id  => JTF_UM_UTIL_PVT.GET_USERTYPE_ID(p_user_id),
                       p_administrator =>    p_administrator,
                       p_logged_in_user_id => p_logged_in_user_id,
                       p_sub_status   => p_sub_status,
                       x_result       => x_result
                       );

  END IF;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END GET_USER_SUB_INFO;

/**
  * Procedure   :  GET_USER_SUB_INFO
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Returns the enrollment information for a user type
  * Parameters  :
  * input parameters
  * @param     p_user_id
  *     description:  The user id
  *     required   :  Y
  *     validation :  Must be a valid user id
  * @param     p_usertype_id
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
                       ) IS

l_procedure_name CONSTANT varchar2(30) := 'GET_CONF_SUB_INFO';
l_subscription_id NUMBER;

CURSOR FIND_SUB_INFO IS
SELECT A.SUBSCRIPTION_FLAG, B.SUBSCRIPTION_NAME, B.DESCRIPTION, B.APPROVAL_ID, C.SUBSCRIPTION_REG_ID
FROM JTF_UM_USERTYPE_SUBSCRIP A, JTF_UM_SUBSCRIPTIONS_VL B, JTF_UM_SUBSCRIPTION_REG C
WHERE A.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.USERTYPE_ID = p_usertype_id
AND NVL(A.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND B.ENABLED_FLAG = 'Y'
AND A.EFFECTIVE_START_DATE < SYSDATE
AND C.USER_ID = p_user_id
AND C.SUBSCRIPTION_ID = l_subscription_id
AND C.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND NVL(C.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE;

i NUMBER := 1;
l_checkbox_code NUMBER;
l_can_assign NUMBER;
l_approval_required NUMBER;
sub_index NUMBER;
show_enrollment boolean;

BEGIN


JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                 );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_user_id:' || p_user_id || '+' || 'p_usertype_id:' || p_usertype_id
                              || '+' || 'p_is_admin:' || p_is_admin
                            );
end if;

 -- Start reading the subscription list

 sub_index := p_sub_list.first;

 -- Parse through each subscription

 WHILE sub_index <= p_sub_list.last LOOP

   -- set the value so that cursor can correcty be opened

   l_subscription_id :=  p_sub_list(sub_index).SUBSCRIPTION_ID;

      -- Execute the cursor and populate the result table
    FOR j in FIND_SUB_INFO LOOP

      -- Do not show Automatic enrollments to users other than administartor

      show_enrollment := false;

      IF p_administrator = 1 THEN

        show_enrollment := true;

      ELSIF j.SUBSCRIPTION_FLAG <> 'IMPLICIT' THEN

        show_enrollment := true;

      END IF;

      IF show_enrollment THEN

         JTF_UM_WF_DELEGATION_PVT.get_enrollment_avail(
                          p_subscription_id  => l_subscription_id,
                          p_user_id          => p_admin_id,
                          p_usertype_id      => p_usertype_id,
                          x_checkbox_code    => l_checkbox_code,
                          x_can_assign       => l_can_assign
                            );

        l_approval_required :=  JTF_UM_WF_DELEGATION_PVT.is_approval_required(
                         p_subscription_id  => l_subscription_id,
                         p_approval_id      => j.APPROVAL_ID,
                         p_activation_mode  => j.SUBSCRIPTION_FLAG,
                         p_is_admin         => p_is_admin,
                         p_can_assign       => l_can_assign
                                 );


        x_result(i).NAME            := j.SUBSCRIPTION_NAME;
        x_result(i).DESCRIPTION     := j.DESCRIPTION;
        x_result(i).APPROVAL_REQUIRED :=  l_approval_required;
        x_result(i).SUBSCRIPTION_REG_ID := j.SUBSCRIPTION_REG_ID;

      END IF;

     END LOOP;

    i := i + 1;
    sub_index := p_sub_list.next(sub_index);

 END LOOP;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END GET_CONF_SUB_INFO;


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
                       ) IS

l_procedure_name CONSTANT varchar2(30) := 'GET_USERTYPE_SUB';
l_subscription_id NUMBER;

CURSOR FIND_SUB_INFO IS
SELECT A.SUBSCRIPTION_FLAG, B.SUBSCRIPTION_NAME, B.DESCRIPTION, B.APPROVAL_ID, TMPL.TEMPLATE_HANDLER, TMPL.PAGE_NAME
FROM JTF_UM_USERTYPE_SUBSCRIP A, JTF_UM_SUBSCRIPTIONS_VL B, JTF_UM_SUBSCRIPTION_TMPL SUBTMPL, JTF_UM_TEMPLATES_B TMPL
WHERE A.SUBSCRIPTION_ID = B.SUBSCRIPTION_ID
AND A.USERTYPE_ID = p_usertype_id
AND NVL(A.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND NVL(SUBTMPL.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND NVL(TMPL.EFFECTIVE_END_DATE, SYSDATE+1) > SYSDATE
AND B.ENABLED_FLAG = 'Y'
AND A.EFFECTIVE_START_DATE < SYSDATE
AND B.SUBSCRIPTION_ID = SUBTMPL.SUBSCRIPTION_ID
AND SUBTMPL.TEMPLATE_ID = TMPL.TEMPLATE_ID
AND B.SUBSCRIPTION_ID   = l_subscription_id
AND TMPL.TEMPLATE_TYPE_CODE  = 'ENROLLMENT_TEMPLATE';

i NUMBER := 1;
l_checkbox_code NUMBER;
l_can_assign NUMBER;
l_approval_required NUMBER;
sub_index NUMBER;
l_is_user_enrolled NUMBER;

BEGIN


JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                 );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_usertype_id:' || p_usertype_id || '+' || 'p_admin_id:' || p_admin_id
                              || '+' || 'p_is_admin:' || p_is_admin
                            );
end if;

 -- Start reading the subscription list

 sub_index := p_sub_list.first;

 -- Parse through each subscription

 WHILE sub_index <= p_sub_list.last LOOP

   -- set the value so that cursor can correcty be opened

   l_subscription_id :=  p_sub_list(sub_index).SUBSCRIPTION_ID;

      -- Execute the cursor and populate the result table
    FOR j in FIND_SUB_INFO LOOP

      -- Do not show Automatic enrollments to users other than administartor


         JTF_UM_WF_DELEGATION_PVT.get_enrollment_avail(
                          p_subscription_id  => l_subscription_id,
                          p_user_id          => p_admin_id,
                          p_usertype_id      => p_usertype_id,
                          x_checkbox_code    => l_checkbox_code,
                          x_can_assign       => l_can_assign
                            );

        l_approval_required :=  JTF_UM_WF_DELEGATION_PVT.is_approval_required(
                         p_subscription_id  => l_subscription_id,
                         p_approval_id      => j.APPROVAL_ID,
                         p_activation_mode  => j.SUBSCRIPTION_FLAG,
                         p_is_admin         => p_is_admin,
                         p_can_assign       => l_can_assign
                                 );

        l_is_user_enrolled := is_user_enrolled(
                          p_subscription_id => l_subscription_id,
                          p_user_id         => p_user_id
                                               );


        x_result(i).NAME              := j.SUBSCRIPTION_NAME;
        x_result(i).DESCRIPTION       := j.DESCRIPTION;
        x_result(i).APPROVAL_REQUIRED := l_approval_required;
        x_result(i).APPROVAL_ID       := j.APPROVAL_ID;
        x_result(i).TEMPLATE_HANDLER  := j.TEMPLATE_HANDLER;
        x_result(i).PAGE_NAME         := j.PAGE_NAME;
        x_result(i).IS_USER_ENROLLED  := l_is_user_enrolled;
        x_result(i).ACTIVATION_MODE   := j.SUBSCRIPTION_FLAG;
        x_result(i).SUBSCRIPTION_ID   := l_subscription_id;


     END LOOP;

    i := i + 1;
    sub_index := p_sub_list.next(sub_index);

 END LOOP;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END GET_USERTYPE_SUB;

end JTF_UM_SUBSCRIPTION_INFO;

/
