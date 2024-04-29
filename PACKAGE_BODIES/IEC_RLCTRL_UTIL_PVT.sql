--------------------------------------------------------
--  DDL for Package Body IEC_RLCTRL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_RLCTRL_UTIL_PVT" AS
/* $Header: IECPBUTB.pls 115.5 2003/08/22 20:42:12 hhuang noship $ */

------------------------------------------------------------------------------
--  Procedure	: Add_Invalid_Argument_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Invalid_Argument_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_v	IN	VARCHAR2,
    p_token_p	IN	VARCHAR2 )
  IS
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(240);
BEGIN
  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IEC', 'JTF_API_ALL_INVALID_ARGUMENT');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('VALUE', p_token_v);
      fnd_message.set_token('PARAMETER', p_token_p);
      fnd_msg_pub.add;
  END IF;

END Add_Invalid_Argument_Msg;

------------------------------------------------------------------------------
--  Procedure	: Add_Null_Parameter_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Null_Parameter_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_np	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IEC', 'JTF_API_ALL_NULL_PARAMETER');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('NULL_PARAM', p_token_np);
      fnd_msg_pub.add;
   END IF;
END Add_Null_Parameter_Msg;

------------------------------------------------------------------------------
--  Procedure	: Validate_Who_Info
------------------------------------------------------------------------------

PROCEDURE Validate_Who_Info
  ( p_api_name			IN		VARCHAR2,
    p_parameter_name_usr	IN		VARCHAR2,
    p_parameter_name_log	IN		VARCHAR2,
    p_user_id			IN		NUMBER,
    p_login_id			IN		NUMBER,
    p_resp_id			IN		NUMBER   := NULL,
    p_resp_appl_id		IN		NUMBER   := NULL,
    x_return_status		IN OUT NOCOPY	VARCHAR2 )
IS
     l_dummy	VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   BEGIN
      -- Special check to not check the dates when the user ID is (-1).
      IF p_user_id = -1 THEN
	 SELECT 'x' INTO l_dummy
	   FROM fnd_user
	   WHERE user_id = p_user_id;
       ELSE
	 SELECT 'x' INTO l_dummy
	   FROM fnd_user
	   WHERE user_id = p_user_id
	   AND Trunc(Sysdate) BETWEEN Trunc(Nvl(start_date, Sysdate))
			      AND Trunc(Nvl(end_date, Sysdate));
      END IF;
   EXCEPTION
      WHEN no_data_found THEN
	 x_return_status := fnd_api.g_ret_sts_error;
	 add_invalid_argument_msg(p_api_name, To_char(p_user_id),
				  p_parameter_name_usr);
	 RETURN;
   END;

   IF (p_login_id IS NOT NULL)  AND (p_login_id <> -1) THEN   -- remove this line of code once bugdb # 1377488 has been resolved
      -- Do not validate login id if audit level set to NONE
      IF (fnd_profile.value_specific('SIGNONAUDIT:LEVEL', p_user_id,
				     p_resp_id, p_resp_appl_id) <> 'A') THEN
	 BEGIN
	    SELECT 'x' INTO l_dummy
	      FROM fnd_logins
	      WHERE login_id = p_login_id
	      AND user_id = p_user_id;
	 EXCEPTION
	    WHEN no_data_found THEN
	       x_return_status := fnd_api.g_ret_sts_error;
	       add_invalid_argument_msg(p_api_name, To_char(p_login_id),
					p_parameter_name_log);
	 END;
      END IF;
   END IF;

END Validate_Who_Info;

END IEC_RLCTRL_UTIL_PVT;

/
