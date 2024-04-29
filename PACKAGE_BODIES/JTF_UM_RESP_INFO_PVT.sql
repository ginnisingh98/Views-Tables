--------------------------------------------------------
--  DDL for Package Body JTF_UM_RESP_INFO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_RESP_INFO_PVT" as
/*$Header: JTFVRESB.pls 120.2 2006/03/16 22:11:44 vimohan ship $*/

MODULE_NAME  CONSTANT VARCHAR2(50) := 'JTF.UM.PLSQL.JTF_UM_RESP_INFO_PVT';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME);
L_DELIMITING_CHARACTER CONSTANT VARCHAR2(1) := ';';

function format_output(p_input_string in varchar2,
                       p_source_type  in varchar2) return varchar2 is

l_procedure_name CONSTANT varchar2(30) := 'format_output';
l_message_name varchar2(255);
l_token_name varchar2(100);
BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

  if l_is_debug_parameter_on then
  JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_input_string:' || p_input_string || '+' || 'p_source_type:' || p_source_type
                                    );
  end if;

 IF p_source_type = 'USERTYPE' THEN
   l_message_name := 'JTA_UM_USERTYPE_SOURCE';
   l_token_name   :=  'USERTYPE_NAME';
 ELSIF  p_source_type = 'ENROLLMENT' THEN
   l_message_name := 'JTA_UM_ENROLLMENT_SOURCE';
   l_token_name   :=  'ENROLLMENT_NAME';
 ELSE
   l_message_name := 'JTA_UM_UNKNOWN_SOURCE';
 END IF;

   fnd_message.set_name('JTF',l_message_name);

   IF p_source_type = 'USERTYPE' OR p_source_type = 'ENROLLMENT' THEN
      fnd_message.set_token(l_token_name,p_input_string);
   END IF;

   JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

 return fnd_message.get;

END format_output;


/**
  * Procedure   :  GET_RESP_INFO_SOURCE
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Returns the responsibility details and source for a user
  * Parameters  :
  * input parameters
  * @param     p_user_id
  *     description:  The user_id of a user
  *     required   :  Y
  *     validation :  Must be a valid user id
  * output parameters
  *   x_result: RESP_INFO_TABLE_TYPE
 */
procedure GET_RESP_INFO_SOURCE(
                       p_user_id      in  number,
                       x_result       out NOCOPY RESP_INFO_TABLE_TYPE
                       ) IS

l_procedure_name CONSTANT varchar2(30) := 'GET_RESP_INFO_SOURCE';
CURSOR FIND_RESP_INFO IS SELECT FR.RESPONSIBILITY_ID RESP_ID, FR.APPLICATION_ID APP_ID, FR.RESPONSIBILITY_NAME RESP_NAME, FR.RESPONSIBILITY_KEY RESP_KEY
FROM FND_RESPONSIBILITY_VL FR, FND_USER_RESP_GROUPS FG
WHERE FR.RESPONSIBILITY_ID = FG.RESPONSIBILITY_ID
AND  FR.APPLICATION_ID = FG.RESPONSIBILITY_APPLICATION_ID
AND   FG.USER_ID = p_user_id
AND   NVL(FG.END_DATE, SYSDATE +1) > SYSDATE
AND   FG.START_DATE < SYSDATE
AND   FR.VERSION = 'W'
ORDER BY FR.RESPONSIBILITY_NAME;

l_resp_key FND_RESPONSIBILITY_VL.RESPONSIBILITY_KEY%TYPE;

CURSOR FIND_RESP_SOURCE IS
SELECT SOURCE_TYPE, SOURCE_NAME FROM
(
  SELECT 'USERTYPE' SOURCE_TYPE, UT.USERTYPE_SHORTNAME SOURCE_NAME
  FROM JTF_UM_USERTYPES_VL UT, JTF_UM_USERTYPE_RESP UTRESP, JTF_UM_USERTYPE_REG UTREG
  WHERE UT.USERTYPE_ID  = UTRESP.USERTYPE_ID
  AND   UT.USERTYPE_ID  = UTREG.USERTYPE_ID
  AND   UTREG.USER_ID   = p_user_id
  AND   UTRESP.RESPONSIBILITY_KEY = l_resp_key
  AND   NVL(UTRESP.EFFECTIVE_END_DATE, SYSDATE +1) > SYSDATE
  AND   NVL(UTREG.EFFECTIVE_END_DATE, SYSDATE +1) > SYSDATE
  AND   UTRESP.EFFECTIVE_START_DATE < SYSDATE
  AND   UTREG.EFFECTIVE_START_DATE < SYSDATE
  AND   UTREG.STATUS_CODE = 'APPROVED'

  UNION ALL

  SELECT 'ENROLLMENT' SOURCE_TYPE, SUB.SUBSCRIPTION_NAME SOURCE_NAME
  FROM JTF_UM_SUBSCRIPTIONS_VL SUB, JTF_UM_SUBSCRIPTION_RESP SUBRESP, JTF_UM_SUBSCRIPTION_REG SUBREG
  WHERE SUB.SUBSCRIPTION_ID = SUBRESP.SUBSCRIPTION_ID
  AND   SUB.SUBSCRIPTION_ID = SUBREG.SUBSCRIPTION_ID
  AND   SUBREG.USER_ID  = p_user_id
  AND   SUBRESP.RESPONSIBILITY_KEY = l_resp_key
  AND   NVL(SUBRESP.EFFECTIVE_END_DATE, SYSDATE +1) > SYSDATE
  AND   NVL(SUBREG.EFFECTIVE_END_DATE, SYSDATE +1) > SYSDATE
  AND   SUBRESP.EFFECTIVE_START_DATE < SYSDATE
  AND   SUBREG.EFFECTIVE_START_DATE < SYSDATE
  AND   SUBREG.STATUS_CODE = 'APPROVED'
) respSources order by SOURCE_TYPE,SOURCE_NAME;

i NUMBER := 1;
l_formatted_output varchar2(200);
l_delimiter varchar2(1) := '';

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'p_user_id:' || p_user_id
                                    );
end if;


  FOR j in FIND_RESP_INFO LOOP

    x_result(i).RESP_ID    := j.RESP_ID;
    x_result(i).APP_ID     := j.APP_ID;
    x_result(i).RESP_NAME  := j.RESP_NAME;
    x_result(i).RESP_KEY   := j.RESP_KEY;
    l_resp_key             := j.RESP_KEY;
    x_result(i).RESP_SOURCE := '';

        -- Set the source

        FOR k in FIND_RESP_SOURCE LOOP

           l_formatted_output     := format_output(k.SOURCE_NAME,RTRIM(k.SOURCE_TYPE));
           x_result(i).RESP_SOURCE := x_result(i).RESP_SOURCE || l_delimiter || l_formatted_output;

           l_delimiter := L_DELIMITING_CHARACTER;

        END LOOP;

        l_delimiter := '';

        -- Set the source to Unknown, if we do not know it.

        IF  x_result(i).RESP_SOURCE IS NULL THEN

          x_result(i).RESP_SOURCE := format_output('','');

        END IF;

    i := i + 1;

  END LOOP;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END GET_RESP_INFO_SOURCE;
end JTF_UM_RESP_INFO_PVT;

/
