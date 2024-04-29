--------------------------------------------------------
--  DDL for Package Body JTF_IH_CORE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_CORE_UTIL_PVT" AS
/* $Header: JTFIHCRB.pls 120.1 2005/07/02 02:05:44 appldev ship $ */

------------------------------------------------------------------------------
--  Procedure	: Add_Desc_Flex_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Desc_Flex_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_dfm	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('JTF', 'JTF_API_SR_DESC_FLEX_ERROR');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('DESC_FLEX_MSG', p_token_dfm);
      fnd_msg_pub.add;
   END IF;
END Add_Desc_Flex_Msg;

------------------------------------------------------------------------------
--  Procedure	: Add_Duplicate_Value_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Duplicate_Value_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_p	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('JTF', 'JTF_API_ALL_DUPLICATE_VALUE');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('DUPLICATE_VAL_PARAM', p_token_p);
      fnd_msg_pub.add;
   END IF;
END Add_Duplicate_Value_Msg;

------------------------------------------------------------------------------
--  Procedure	: Add_Invalid_Argument_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Invalid_Argument_Msg
  ( p_token_an IN VARCHAR2,
    p_token_v IN VARCHAR2,
    p_token_p IN VARCHAR2 )
  IS
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(240);
  x_token_value VARCHAR2(2000);
BEGIN
  x_token_value := SUBSTR(p_token_v,1,2000);
  IF (x_token_value = fnd_api.g_miss_char) THEN
    x_token_value := '';
  END IF;
  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('JTF', 'JTF_API_ALL_INVALID_ARGUMENT');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('VALUE', x_token_value);
      fnd_message.set_token('PARAMETER', p_token_p);
      fnd_msg_pub.add;
  END IF;

END Add_Invalid_Argument_Msg;

------------------------------------------------------------------------------
--  Procedure	: Add_Invalid_Argument_Msg_Gen
------------------------------------------------------------------------------
PROCEDURE Add_Invalid_Argument_Msg_Gen
(
    p_msg_code   IN VARCHAR2,
    p_msg_param  IN param_tbl_type)
    IS
    x_token_value VARCHAR2(2000);
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('JTF', p_msg_code);

     FOR i IN 1..p_msg_param.COUNT LOOP
	    x_token_value := SUBSTR(p_msg_param(i).token_value,1,2000);
  	    IF (x_token_value = fnd_api.g_miss_char) THEN
	  	    x_token_value := '';
	    END IF;
	    fnd_message.set_token(p_msg_param(i).token_name, x_token_value);
     END LOOP;
     fnd_msg_pub.add;
  END IF;

END Add_Invalid_Argument_Msg_Gen;

------------------------------------------------------------------------------
--  Procedure	: Add_Missing_Param_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Missing_Param_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_mp	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('JTF', 'JTF_API_ALL_MISSING_PARAM');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('MISSING_PARAM', p_token_mp);
      fnd_msg_pub.add;
   END IF;
END Add_MIssing_Param_Msg;

------------------------------------------------------------------------------
--  Procedure	: Add_Null_Parameter_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Null_Parameter_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_np	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('JTF', 'JTF_API_ALL_NULL_PARAMETER');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('NULL_PARAM', p_token_np);
      fnd_msg_pub.add;
   END IF;
END Add_Null_Parameter_Msg;

------------------------------------------------------------------------------
--  Procedure	: Add_Param_Ignored_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Param_Ignored_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_ip	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
      fnd_message.set_name('JTF', 'JTF_API_ALL_PARAM_IGNORED');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('IGNORED_PARAM', p_token_ip);
      fnd_msg_pub.add;
   END IF;
END Add_Param_Ignored_Msg;

------------------------------------------------------------------------------
--  Procedure	: Add_Same_Val_Update_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Same_Val_Update_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_p	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
      fnd_message.set_name('JTF', 'JTF_API_ALL_SAME_VAL_UPDATE');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('SAME_VAL_PARAM', p_token_p);
      fnd_msg_pub.add;
   END IF;
END Add_Same_Val_Update_Msg;


------------------------------------------------------------------------------
--  Procedure	: Convert_Lookup_To_Code
------------------------------------------------------------------------------

PROCEDURE Convert_Lookup_To_Code
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_meaning		IN	VARCHAR2,
    p_lookup_type	IN	VARCHAR2,
    x_lookup_code	OUT NOCOPY VARCHAR2,
    x_return_status	OUT NOCOPY VARCHAR2 )
  IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   SELECT lookup_code INTO x_lookup_code
     FROM cs_lookups
     WHERE lookup_type = p_lookup_type
     AND meaning = p_meaning;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      cs_core_util.add_invalid_argument_msg(p_api_name, p_meaning,
					    p_parameter_name);
END Convert_Lookup_To_Code;


------------------------------------------------------------------------------
--  Procedure	: Default_Common_Attributes
------------------------------------------------------------------------------

PROCEDURE Default_Common_Attributes
  ( p_api_name		IN	VARCHAR2,
    p_resp_appl_id	IN OUT	NOCOPY NUMBER,
    p_resp_id		IN OUT	NOCOPY NUMBER,
    p_user_id		IN OUT	NOCOPY NUMBER,
    p_login_id		IN OUT	NOCOPY NUMBER,
    p_org_id		IN OUT	NOCOPY NUMBER,
    p_inventory_org_id	IN OUT	NOCOPY NUMBER)
  IS
BEGIN
   -------------------------------------------------------------------------
   -- FND_GLOBAL.RESP_APPL_ID, FND_GLOBAL.RESP_ID, and FND_GLOBAL.LOGIN_ID
   -- returns -1 by default, which is an invalid value. FND_GLOBAL.USER_ID
   -- is okay, because user ID -1 corresponds to user 'ANONYMOUS.'  If
   -- FND_GLOBAL returns -1, the variables are set to NULL instead.
   -------------------------------------------------------------------------
   IF p_resp_appl_id = fnd_api.g_miss_num THEN
      IF fnd_global.resp_appl_id <> -1 THEN
	 p_resp_appl_id := fnd_global.resp_appl_id;
      ELSE
	 p_resp_appl_id := NULL;
      END IF;
   END IF;

   IF p_resp_id = fnd_api.g_miss_num THEN
      IF fnd_global.resp_id <> -1 THEN
	 p_resp_id := fnd_global.resp_id;
      ELSE
	 p_resp_id := NULL;
      END IF;
   END IF;

   IF p_user_id = fnd_api.g_miss_num THEN
      p_user_id := fnd_global.user_id;
   END IF;

   IF p_login_id = fnd_api.g_miss_num THEN
      IF fnd_global.login_id NOT IN (-1,0) THEN
	 p_login_id := fnd_global.login_id;
      ELSE
	 p_login_id := NULL;
      END IF;
   END IF;

   --
   -- If Multi-Org is enabled, get the default from the session variable
   -- CLIENT_INFO. If it is not set, get the default from the ORG_ID profile
   -- option.
   --
   IF cs_core_util.is_multiorg_enabled THEN
      IF p_org_id = fnd_api.g_miss_num THEN
	 SELECT To_number(Decode(substrb(userenv('CLIENT_INFO'),1,1), ' ',
				 NULL, substrb(userenv('CLIENT_INFO'),1,10)))
	   INTO p_org_id
	   FROM dual;
	 IF p_org_id IS NULL THEN
	    p_org_id := To_number(fnd_profile.value_specific('ORG_ID',
							     p_user_id,
							     p_resp_id,
							     p_resp_appl_id));
	 END IF;
      END IF;
   END IF;

   IF p_inventory_org_id = fnd_api.g_miss_num THEN
      p_inventory_org_id :=
	To_number(fnd_profile.value_specific('SO_ORGANIZATION_ID', p_user_id,
					     p_resp_id, p_resp_appl_id));
   END IF;
END Default_Common_Attributes;

------------------------------------------------------------------------------
--  Function	: Is_MultiOrg_Enabled
------------------------------------------------------------------------------

FUNCTION Is_MultiOrg_Enabled RETURN BOOLEAN IS
   l_multiorg_enabled  VARCHAR2(1);
BEGIN
   SELECT multi_org_flag INTO l_multiorg_enabled
     FROM fnd_product_groups;

   IF l_multiorg_enabled = 'Y' THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END Is_MultiOrg_Enabled;

------------------------------------------------------------------------------
--  Procedure	: Trunc_String_Length
------------------------------------------------------------------------------

PROCEDURE Trunc_String_length
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_str		IN	VARCHAR2,
    p_len		IN	NUMBER,
    x_str		OUT NOCOPY VARCHAR2 )
  IS
     l_len	NUMBER;
BEGIN
   l_len := lengthb(p_str);
   IF (l_len > p_len) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
	 fnd_message.set_name('JTF', 'JTF_API_ALL_VALUE_TRUNCATED');
	 fnd_message.set_token('API_NAME', p_api_name);
	 fnd_message.set_token('TRUNCATED_PARAM', p_parameter_name);
	 fnd_message.set_token('VAL_LEN', l_len);
	 fnd_message.set_token('DB_LEN', p_len);
	 fnd_msg_pub.add;
      END IF;
      x_str := substrb(p_str, 1, p_len);
    ELSE
      x_str := p_str;
   END IF;
END Trunc_String_Length;


------------------------------------------------------------------------------
--  Procedure	: Validate_Desc_Flex
------------------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
  ( p_api_name		IN	VARCHAR2,
    p_desc_flex_name	IN	VARCHAR2,
    p_column_name1	IN	VARCHAR2,
    p_column_name2	IN	VARCHAR2,
    p_column_name3	IN	VARCHAR2,
    p_column_name4	IN	VARCHAR2,
    p_column_name5	IN	VARCHAR2,
    p_column_name6	IN	VARCHAR2,
    p_column_name7	IN	VARCHAR2,
    p_column_name8	IN	VARCHAR2,
    p_column_name9	IN	VARCHAR2,
    p_column_name10	IN	VARCHAR2,
    p_column_name11	IN	VARCHAR2,
    p_column_name12	IN	VARCHAR2,
    p_column_name13	IN	VARCHAR2,
    p_column_name14	IN	VARCHAR2,
    p_column_name15	IN	VARCHAR2,
    p_column_value1	IN	VARCHAR2,
    p_column_value2	IN	VARCHAR2,
    p_column_value3	IN	VARCHAR2,
    p_column_value4	IN	VARCHAR2,
    p_column_value5	IN	VARCHAR2,
    p_column_value6	IN	VARCHAR2,
    p_column_value7	IN	VARCHAR2,
    p_column_value8	IN	VARCHAR2,
    p_column_value9	IN	VARCHAR2,
    p_column_value10	IN	VARCHAR2,
    p_column_value11	IN	VARCHAR2,
    p_column_value12	IN	VARCHAR2,
    p_column_value13	IN	VARCHAR2,
    p_column_value14	IN	VARCHAR2,
    p_column_value15	IN	VARCHAR2,
    p_context_value	IN	VARCHAR2,
    p_resp_appl_id	IN	NUMBER   := NULL,
    p_resp_id		IN	NUMBER   := NULL,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
     l_error_message	VARCHAR2(2000);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   fnd_flex_descval.set_column_value(p_column_name1, p_column_value1);
   fnd_flex_descval.set_column_value(p_column_name2, p_column_value2);
   fnd_flex_descval.set_column_value(p_column_name3, p_column_value3);
   fnd_flex_descval.set_column_value(p_column_name4, p_column_value4);
   fnd_flex_descval.set_column_value(p_column_name5, p_column_value5);
   fnd_flex_descval.set_column_value(p_column_name6, p_column_value6);
   fnd_flex_descval.set_column_value(p_column_name7, p_column_value7);
   fnd_flex_descval.set_column_value(p_column_name8, p_column_value8);
   fnd_flex_descval.set_column_value(p_column_name9, p_column_value9);
   fnd_flex_descval.set_column_value(p_column_name10, p_column_value10);
   fnd_flex_descval.set_column_value(p_column_name11, p_column_value11);
   fnd_flex_descval.set_column_value(p_column_name12, p_column_value12);
   fnd_flex_descval.set_column_value(p_column_name13, p_column_value13);
   fnd_flex_descval.set_column_value(p_column_name14, p_column_value14);
   fnd_flex_descval.set_column_value(p_column_name15, p_column_value15);
   fnd_flex_descval.set_context_value(p_context_value);
   --IF NOT fnd_flex_descval.validate_desccols
   --  ( appl_short_name	=> 'JTF',
    --   desc_flex_name	=> p_desc_flex_name,
    --   resp_appl_id	=> p_resp_appl_id,
    --   resp_id		=> p_resp_id ) THEN
    --  l_error_message := fnd_flex_descval.error_message;
    --  add_desc_flex_msg(p_api_name, l_error_message);
    --  x_return_status := fnd_api.g_ret_sts_error;
   --END IF;
END Validate_Desc_Flex;


------------------------------------------------------------------------------
--  Procedure	: Validate_Later_Date
------------------------------------------------------------------------------

PROCEDURE Validate_Later_Date
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_later_date	IN	DATE,
    p_earlier_date      IN	DATE,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
BEGIN
   IF p_later_date >= p_earlier_date THEN
      x_return_status := fnd_api.g_ret_sts_success;
   ELSE
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg(p_api_name, To_char(p_later_date),
			       p_parameter_name);
   END IF;
END Validate_Later_Date;

------------------------------------------------------------------------------
--  Procedure	: Validate_Lookup_Code
------------------------------------------------------------------------------

PROCEDURE Validate_Lookup_Code
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_lookup_code  	IN	VARCHAR2,
    p_lookup_type  	IN	VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
     l_dummy  VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   SELECT 'x' INTO l_dummy
     FROM cs_lookups
     WHERE lookup_code = p_lookup_code
     AND lookup_type = p_lookup_type
     AND enabled_flag = 'Y'
     AND Trunc(Sysdate) BETWEEN Trunc(Nvl(start_date_active, Sysdate))
			AND Trunc(Nvl(end_date_active, Sysdate));
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg(p_api_name, p_lookup_code, p_parameter_name);
END Validate_Lookup_Code;

------------------------------------------------------------------------------
--  Procedure	: Validate_Who_Info
------------------------------------------------------------------------------

--
--	Author			Date			Description
--	------			----			-----------
--
--	Jim Zheng		01SEP1999		Initial Implementation
--	Jim Baldo		09MAR2001		Implementation work around for bugdb # 1679511
--	Igor Aleshin		13May2004		Fixed Bug#3627777

PROCEDURE Validate_Who_Info
  ( p_api_name			IN	VARCHAR2,
    p_parameter_name_usr	IN	VARCHAR2,
    p_parameter_name_log	IN	VARCHAR2,
    p_user_id			IN	NUMBER,
    p_login_id			IN	NUMBER,
    p_resp_id			IN	NUMBER   := NULL,
    p_resp_appl_id		IN	NUMBER   := NULL,
    x_return_status		OUT NOCOPY	VARCHAR2 )
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
END Validate_Who_Info;

END JTF_IH_CORE_UTIL_PVT;

/
