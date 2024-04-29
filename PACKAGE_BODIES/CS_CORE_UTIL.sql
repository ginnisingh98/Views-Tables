--------------------------------------------------------
--  DDL for Package Body CS_CORE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CORE_UTIL" AS
/* $Header: csucoreb.pls 120.4 2006/06/21 19:25:09 spusegao noship $ */

------------------------------------------------------------------------------
--  Procedure	: Add_Desc_Flex_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Desc_Flex_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_dfm	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('CS', 'CS_API_SR_DESC_FLEX_ERROR');
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
      fnd_message.set_name('CS', 'CS_API_ALL_DUPLICATE_VALUE');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('DUPLICATE_VAL_PARAM', p_token_p);
      fnd_msg_pub.add;
   END IF;
END Add_Duplicate_Value_Msg;

------------------------------------------------------------------------------
--  Procedure	: Add_Invalid_Argument_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Invalid_Argument_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_v	IN	VARCHAR2,
    p_token_p	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('VALUE', p_token_v);
      fnd_message.set_token('PARAMETER', p_token_p);
      fnd_msg_pub.add;
   END IF;
END Add_Invalid_Argument_Msg;

------------------------------------------------------------------------------
--  Procedure	: Add_Missing_Param_Msg
------------------------------------------------------------------------------

PROCEDURE Add_Missing_Param_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_mp	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('CS', 'CS_API_ALL_MISSING_PARAM');
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
      fnd_message.set_name('CS', 'CS_API_ALL_NULL_PARAMETER');
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
      fnd_message.set_name('CS', 'CS_API_ALL_PARAM_IGNORED');
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
      fnd_message.set_name('CS', 'CS_API_ALL_SAME_VAL_UPDATE');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('SAME_VAL_PARAM', p_token_p);
      fnd_msg_pub.add;
   END IF;
END Add_Same_Val_Update_Msg;

------------------------------------------------------------------------------
--  Procedure	: Convert_Contact_To_ID
------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/08/05 smisra   bug 4532643
--                   The procedure is being stubbed as it is not used
-- -----------------------------------------------------------------------------
PROCEDURE Convert_Contact_To_ID
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name_ln	IN	VARCHAR2,
    p_parameter_name_fn	IN	VARCHAR2,
    p_contact_lastname	IN	VARCHAR2,
    p_contact_firstname	IN	VARCHAR2 DEFAULT fnd_api.g_miss_char,
    x_contact_id	OUT NOCOPY	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
/****
   IF p_contact_firstname <> fnd_api.g_miss_char THEN
      SELECT contact_id INTO x_contact_id
	FROM ra_contacts
	WHERE last_name = p_contact_lastname
	AND first_name = p_contact_firstname;
   ELSE
      SELECT contact_id INTO x_contact_id
	FROM ra_contacts
	WHERE last_name = p_contact_lastname;
   END IF;
***/
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF p_contact_firstname <> fnd_api.g_miss_char THEN
	 cs_core_util.add_invalid_argument_msg
	   ( p_token_an	=> p_api_name,
	     p_token_v	=> p_contact_lastname||', '||p_contact_firstname,
	     p_token_p	=> p_parameter_name_ln||', '||p_parameter_name_fn );
      ELSE
	 cs_core_util.add_invalid_argument_msg
	   ( p_token_an	=> p_api_name,
	     p_token_v	=> p_contact_lastname,
	     p_token_p	=> p_parameter_name_ln );
      END IF;
   WHEN too_many_rows THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF p_contact_firstname <> fnd_api.g_miss_char THEN
	 cs_core_util.add_duplicate_value_msg
	   ( p_token_an	=> p_api_name,
	     p_token_p	=> p_parameter_name_ln||', '||p_parameter_name_fn );
      ELSE
	 cs_core_util.add_duplicate_value_msg
	   ( p_token_an	=> p_api_name,
	     p_token_p	=> p_parameter_name_ln );
      END IF;
END Convert_Contact_To_ID;

------------------------------------------------------------------------------
--  Procedure	: Convert_Customer_To_ID
------------------------------------------------------------------------------

PROCEDURE Convert_Customer_To_ID
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name_nb	IN	VARCHAR2,
    p_parameter_name_n	IN	VARCHAR2,
    p_customer_number	IN	VARCHAR2 DEFAULT fnd_api.g_miss_char,
    p_customer_name	IN	VARCHAR2 DEFAULT fnd_api.g_miss_char,
    x_customer_id	OUT NOCOPY	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF p_customer_number <> fnd_api.g_miss_char THEN
      BEGIN
	 SELECT party_id INTO x_customer_id
	   FROM hz_parties
	   WHERE party_number = p_customer_number;
      EXCEPTION
	 WHEN no_data_found THEN
	    x_return_status := fnd_api.g_ret_sts_error;
	    cs_core_util.add_invalid_argument_msg(p_api_name,
						  p_customer_number,
						  p_parameter_name_nb);
      END;
      IF p_customer_name <> fnd_api.g_miss_char THEN
	 cs_core_util.add_param_ignored_msg(p_api_name, p_parameter_name_n);
      END IF;
   ELSE
      BEGIN
	 SELECT party_id INTO x_customer_id
	   FROM hz_parties
	   WHERE party_name = p_customer_name;
      EXCEPTION
	 WHEN no_data_found THEN
	    x_return_status := fnd_api.g_ret_sts_error;
	    cs_core_util.add_invalid_argument_msg(p_api_name, p_customer_name,
						  p_parameter_name_n);
	 WHEN too_many_rows THEN
	    x_return_status := fnd_api.g_ret_sts_error;
	    cs_core_util.add_duplicate_value_msg(p_api_name,
						 p_parameter_name_n);
      END;
   END IF;
END Convert_Customer_To_ID;

------------------------------------------------------------------------------
--  Procedure	: Convert_Customer_To_Name
------------------------------------------------------------------------------

PROCEDURE Convert_Customer_To_Name
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_customer_id	IN	NUMBER,
    x_customer_name	OUT NOCOPY	VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Fetch name from database.
   SELECT party_name INTO x_customer_name
     FROM hz_parties
     WHERE party_id = p_customer_id;

EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg(p_api_name, To_char(p_customer_id),
			       p_parameter_name);
END Convert_Customer_To_Name;

------------------------------------------------------------------------------
--  Procedure	: Convert_Employee_To_ID
------------------------------------------------------------------------------

PROCEDURE Convert_Employee_To_ID
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name_nb	IN	VARCHAR2,
    p_parameter_name_n	IN	VARCHAR2,
    p_employee_number	IN	VARCHAR2 DEFAULT fnd_api.g_miss_char,
    p_employee_name	IN	VARCHAR2 DEFAULT fnd_api.g_miss_char,
    x_employee_id	OUT NOCOPY	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF p_employee_number <> fnd_api.g_miss_char THEN
      BEGIN
	 SELECT person_id INTO x_employee_id
	   FROM per_people_x
	   WHERE employee_number = p_employee_number;
      EXCEPTION
	 WHEN no_data_found THEN
	    x_return_status := fnd_api.g_ret_sts_error;
	    cs_core_util.add_invalid_argument_msg(p_api_name,
						  p_employee_number,
						  p_parameter_name_nb);
	 WHEN too_many_rows THEN
	    x_return_status := fnd_api.g_ret_sts_error;
	    cs_core_util.add_duplicate_value_msg(p_api_name,
						 p_parameter_name_nb);
      END;
      IF p_employee_name <> fnd_api.g_miss_char THEN
	 cs_core_util.add_param_ignored_msg(p_api_name, p_parameter_name_n);
      END IF;
   ELSE
      BEGIN
	 SELECT person_id INTO x_employee_id
	   FROM per_people_x
	   WHERE full_name = p_employee_name;
      EXCEPTION
	 WHEN no_data_found THEN
	    x_return_status := fnd_api.g_ret_sts_error;
	    cs_core_util.add_invalid_argument_msg(p_api_name, p_employee_name,
						  p_parameter_name_n);
	 WHEN too_many_rows THEN
	    x_return_status := fnd_api.g_ret_sts_error;
	    cs_core_util.add_duplicate_value_msg(p_api_name,
						 p_parameter_name_n);
      END;
   END IF;
END Convert_Employee_To_ID;

------------------------------------------------------------------------------
--  Procedure	: Convert_Lookup_To_Code
------------------------------------------------------------------------------

PROCEDURE Convert_Lookup_To_Code
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_meaning		IN	VARCHAR2,
    p_lookup_type	IN	VARCHAR2,
    x_lookup_code	OUT NOCOPY	VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2 )
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
--  Procedure	: Convert_Org_To_ID
------------------------------------------------------------------------------

PROCEDURE Convert_Org_To_ID
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_org_name		IN	VARCHAR2,
    x_org_id		OUT NOCOPY	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   SELECT organization_id INTO x_org_id
     FROM hr_operating_units
     WHERE name = p_org_name;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      cs_core_util.add_invalid_argument_msg(p_api_name, p_org_name,
					    p_parameter_name);
   WHEN too_many_rows THEN
      x_return_status := fnd_api.g_ret_sts_error;
      cs_core_util.add_duplicate_value_msg(p_api_name, p_parameter_name);
END Convert_Org_To_ID;

------------------------------------------------------------------------------
--  Procedure	: Default_Common_Attributes
------------------------------------------------------------------------------
/*
PROCEDURE Default_Common_Attributes
  ( p_api_name		IN	VARCHAR2,
    p_resp_appl_id	IN OUT	NUMBER,
    p_resp_id		IN OUT	NUMBER,
    p_user_id		IN OUT	NUMBER,
    p_login_id		IN OUT	NUMBER,
    p_org_id		IN OUT	NUMBER,
    p_inventory_org_id	IN OUT	NUMBER)
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
*/
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
    x_str		OUT NOCOPY	VARCHAR2 )
  IS
     l_len	NUMBER;
BEGIN
   l_len := lengthb(p_str);
   IF (l_len > p_len) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
	 fnd_message.set_name('CS', 'CS_API_ALL_VALUE_TRUNCATED');
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
--  Procedure	: Validate_Bill_To_Site
------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/08/05 smisra   bug 4532643
--                   The procedure is being stubbed as it is not used
-- -----------------------------------------------------------------------------
PROCEDURE Validate_Bill_To_Site
  ( p_api_name			IN	VARCHAR2,
    p_parameter_name		IN	VARCHAR2,
    p_bill_to_site_id		IN	NUMBER,
    p_customer_id		IN	NUMBER,
    p_org_id			IN	NUMBER   := NULL,
    x_bill_to_customer_id	OUT NOCOPY	NUMBER,
    x_return_status		OUT NOCOPY	VARCHAR2 )
  IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
/*****
   -- Find the customer of the given site
   SELECT a.customer_id INTO x_bill_to_customer_id
     FROM ra_site_uses_all su, ra_addresses_all a
     WHERE Nvl(su.org_id,-99) = Decode(su.org_id,NULL,-99,p_org_id)
     AND su.site_use_id = p_bill_to_site_id
     AND su.site_use_code = 'BILL_TO'
     AND su.address_id = a.address_id
     -- Verify that the bill-to site customer is the same as the customer
     AND ( a.customer_id = p_customer_id
	   -- or one of its related customers
	   OR a.customer_id IN
	   ( SELECT ra.related_customer_id
	     FROM ra_customer_relationships_all ra
	     WHERE ra.customer_id = p_customer_id
	     AND ra.status = 'A'
	     AND Nvl(ra.org_id,-99) = Decode(ra.org_id,NULL,-99,p_org_id) ) );
*****/
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg(p_api_name, To_char(p_bill_to_site_id),
			       p_parameter_name);
END Validate_Bill_To_Site;

------------------------------------------------------------------------------
--  Procedure	: Validate_Comment
------------------------------------------------------------------------------
/*** bug 4887572 smisra. Removed this procedure
PROCEDURE Validate_Comment
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_comment_id	IN	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
     l_dummy	VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Validate against cs_comments, which contains all notes across
   -- multiple source object types
   SELECT 'x' INTO l_dummy
     FROM cs_comments
     WHERE comment_id = p_comment_id;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      cs_core_util.add_invalid_argument_msg(p_api_name, p_comment_id,
					    p_parameter_name);
END Validate_Comment;
**********************************/
------------------------------------------------------------------------------
--  Procedure	: Validate_Customer
------------------------------------------------------------------------------

PROCEDURE Validate_Customer
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_customer_id	IN	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
     l_dummy 	VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   SELECT 'x' INTO l_dummy
     FROM hz_parties
     WHERE party_id = p_customer_id
     AND status = 'A';
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg(p_api_name, To_char(p_customer_id),
			       p_parameter_name);
END Validate_Customer;

------------------------------------------------------------------------------
--  Procedure	: Validate_Customer_Contact
------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/08/05 smisra   bug 4532643
--                   The procedure is being stubbed as it is not used
-- -----------------------------------------------------------------------------
PROCEDURE Validate_Customer_Contact
  ( p_api_name			IN	VARCHAR2,
    p_parameter_name		IN	VARCHAR2,
    p_customer_contact_id	IN	NUMBER,
    p_customer_id		IN	NUMBER,
    p_org_id			IN	NUMBER   := NULL,
    x_return_status		OUT NOCOPY	VARCHAR2 )
  IS
     l_dummy  VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
/********
   SELECT 'x' INTO l_dummy
     FROM ra_contacts
     WHERE contact_id = p_customer_contact_id
     AND status = 'A'
     AND customer_id IN
     ( SELECT p_customer_id
       FROM dual
       UNION
       SELECT related_customer_id
       FROM ra_customer_relationships_all
       WHERE customer_id = p_customer_id
       AND status = 'A'
       AND Nvl(org_id,-99) = Decode(org_id,NULL,-99,p_org_id) );
*****/
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg(p_api_name, To_char(p_customer_contact_id),
			       p_parameter_name);
END Validate_Customer_Contact;

------------------------------------------------------------------------------
--  Procedure	: Validate_Desc_Flex
------------------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
  ( p_api_name		IN	VARCHAR2,
    p_appl_short_name	IN	VARCHAR2 DEFAULT 'CS',
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
   IF NOT fnd_flex_descval.validate_desccols
     ( appl_short_name	=> p_appl_short_name,
       desc_flex_name	=> p_desc_flex_name,
       resp_appl_id	=> p_resp_appl_id,
       resp_id		=> p_resp_id ) THEN
      l_error_message := fnd_flex_descval.error_message;
      add_desc_flex_msg(p_api_name, l_error_message);
      x_return_status := fnd_api.g_ret_sts_error;
   END IF;
END Validate_Desc_Flex;

------------------------------------------------------------------------------
--  Procedure	: Validate_Price_Attribs
------------------------------------------------------------------------------

PROCEDURE Validate_Price_Attribs
  ( p_api_name		IN	VARCHAR2,
    p_appl_short_name	IN	VARCHAR2 DEFAULT 'CS',
    p_desc_flex_name	IN	VARCHAR2,
	p_column_name1		IN VARCHAR2,
	p_column_name2		IN VARCHAR2,
	p_column_name3		IN VARCHAR2,
	p_column_name4		IN VARCHAR2,
	p_column_name5		IN VARCHAR2,
	p_column_name6		IN VARCHAR2,
	p_column_name7		IN VARCHAR2,
	p_column_name8		IN VARCHAR2,
	p_column_name9		IN VARCHAR2,
	p_column_name10		IN VARCHAR2,
	p_column_name11		IN VARCHAR2,
	p_column_name12		IN VARCHAR2,
	p_column_name13		IN VARCHAR2,
	p_column_name14		IN VARCHAR2,
	p_column_name15		IN VARCHAR2,
	p_column_name16		IN VARCHAR2,
	p_column_name17		IN VARCHAR2,
	p_column_name18		IN VARCHAR2,
	p_column_name19		IN VARCHAR2,
	p_column_name20		IN VARCHAR2,
	p_column_name21		IN VARCHAR2,
	p_column_name22		IN VARCHAR2,
	p_column_name23		IN VARCHAR2,
	p_column_name24		IN VARCHAR2,
	p_column_name25		IN VARCHAR2,
	p_column_name26		IN VARCHAR2,
	p_column_name27		IN VARCHAR2,
	p_column_name28		IN VARCHAR2,
	p_column_name29		IN VARCHAR2,
	p_column_name30		IN VARCHAR2,
	p_column_name31		IN VARCHAR2,
	p_column_name32		IN VARCHAR2,
	p_column_name33		IN VARCHAR2,
	p_column_name34		IN VARCHAR2,
	p_column_name35		IN VARCHAR2,
	p_column_name36		IN VARCHAR2,
	p_column_name37		IN VARCHAR2,
	p_column_name38		IN VARCHAR2,
	p_column_name39		IN VARCHAR2,
	p_column_name40		IN VARCHAR2,
	p_column_name41		IN VARCHAR2,
	p_column_name42		IN VARCHAR2,
	p_column_name43		IN VARCHAR2,
	p_column_name44		IN VARCHAR2,
	p_column_name45		IN VARCHAR2,
	p_column_name46		IN VARCHAR2,
	p_column_name47		IN VARCHAR2,
	p_column_name48		IN VARCHAR2,
	p_column_name49		IN VARCHAR2,
	p_column_name50		IN VARCHAR2,
	p_column_name51		IN VARCHAR2,
	p_column_name52		IN VARCHAR2,
	p_column_name53		IN VARCHAR2,
	p_column_name54		IN VARCHAR2,
	p_column_name55		IN VARCHAR2,
	p_column_name56		IN VARCHAR2,
	p_column_name57		IN VARCHAR2,
	p_column_name58		IN VARCHAR2,
	p_column_name59		IN VARCHAR2,
	p_column_name60		IN VARCHAR2,
	p_column_name61		IN VARCHAR2,
	p_column_name62		IN VARCHAR2,
	p_column_name63		IN VARCHAR2,
	p_column_name64		IN VARCHAR2,
	p_column_name65		IN VARCHAR2,
	p_column_name66		IN VARCHAR2,
	p_column_name67		IN VARCHAR2,
	p_column_name68		IN VARCHAR2,
	p_column_name69		IN VARCHAR2,
	p_column_name70		IN VARCHAR2,
	p_column_name71		IN VARCHAR2,
	p_column_name72		IN VARCHAR2,
	p_column_name73		IN VARCHAR2,
	p_column_name74		IN VARCHAR2,
	p_column_name75		IN VARCHAR2,
	p_column_name76		IN VARCHAR2,
	p_column_name77		IN VARCHAR2,
	p_column_name78		IN VARCHAR2,
	p_column_name79		IN VARCHAR2,
	p_column_name80		IN VARCHAR2,
	p_column_name81		IN VARCHAR2,
	p_column_name82		IN VARCHAR2,
	p_column_name83		IN VARCHAR2,
	p_column_name84		IN VARCHAR2,
	p_column_name85		IN VARCHAR2,
	p_column_name86		IN VARCHAR2,
	p_column_name87		IN VARCHAR2,
	p_column_name88		IN VARCHAR2,
	p_column_name89		IN VARCHAR2,
	p_column_name90		IN VARCHAR2,
	p_column_name91		IN VARCHAR2,
	p_column_name92		IN VARCHAR2,
	p_column_name93		IN VARCHAR2,
	p_column_name94		IN VARCHAR2,
	p_column_name95		IN VARCHAR2,
	p_column_name96		IN VARCHAR2,
	p_column_name97		IN VARCHAR2,
	p_column_name98		IN VARCHAR2,
	p_column_name99		IN VARCHAR2,
	p_column_name100	IN VARCHAR2,
	p_column_value1		IN VARCHAR2,
	p_column_value2		IN VARCHAR2,
	p_column_value3		IN VARCHAR2,
	p_column_value4		IN VARCHAR2,
	p_column_value5		IN VARCHAR2,
	p_column_value6		IN VARCHAR2,
	p_column_value7		IN VARCHAR2,
	p_column_value8		IN VARCHAR2,
	p_column_value9		IN VARCHAR2,
	p_column_value10		IN VARCHAR2,
	p_column_value11		IN VARCHAR2,
	p_column_value12		IN VARCHAR2,
	p_column_value13		IN VARCHAR2,
	p_column_value14		IN VARCHAR2,
	p_column_value15		IN VARCHAR2,
	p_column_value16		IN VARCHAR2,
	p_column_value17		IN VARCHAR2,
	p_column_value18		IN VARCHAR2,
	p_column_value19		IN VARCHAR2,
	p_column_value20		IN VARCHAR2,
	p_column_value21		IN VARCHAR2,
	p_column_value22		IN VARCHAR2,
	p_column_value23		IN VARCHAR2,
	p_column_value24		IN VARCHAR2,
	p_column_value25		IN VARCHAR2,
	p_column_value26		IN VARCHAR2,
	p_column_value27		IN VARCHAR2,
	p_column_value28		IN VARCHAR2,
	p_column_value29		IN VARCHAR2,
	p_column_value30		IN VARCHAR2,
	p_column_value31		IN VARCHAR2,
	p_column_value32		IN VARCHAR2,
	p_column_value33		IN VARCHAR2,
	p_column_value34		IN VARCHAR2,
	p_column_value35		IN VARCHAR2,
	p_column_value36		IN VARCHAR2,
	p_column_value37		IN VARCHAR2,
	p_column_value38		IN VARCHAR2,
	p_column_value39		IN VARCHAR2,
	p_column_value40		IN VARCHAR2,
	p_column_value41		IN VARCHAR2,
	p_column_value42		IN VARCHAR2,
	p_column_value43		IN VARCHAR2,
	p_column_value44		IN VARCHAR2,
	p_column_value45		IN VARCHAR2,
	p_column_value46		IN VARCHAR2,
	p_column_value47		IN VARCHAR2,
	p_column_value48		IN VARCHAR2,
	p_column_value49		IN VARCHAR2,
	p_column_value50		IN VARCHAR2,
	p_column_value51		IN VARCHAR2,
	p_column_value52		IN VARCHAR2,
	p_column_value53		IN VARCHAR2,
	p_column_value54		IN VARCHAR2,
	p_column_value55		IN VARCHAR2,
	p_column_value56		IN VARCHAR2,
	p_column_value57		IN VARCHAR2,
	p_column_value58		IN VARCHAR2,
	p_column_value59		IN VARCHAR2,
	p_column_value60		IN VARCHAR2,
	p_column_value61		IN VARCHAR2,
	p_column_value62		IN VARCHAR2,
	p_column_value63		IN VARCHAR2,
	p_column_value64		IN VARCHAR2,
	p_column_value65		IN VARCHAR2,
	p_column_value66		IN VARCHAR2,
	p_column_value67		IN VARCHAR2,
	p_column_value68		IN VARCHAR2,
	p_column_value69		IN VARCHAR2,
	p_column_value70		IN VARCHAR2,
	p_column_value71		IN VARCHAR2,
	p_column_value72		IN VARCHAR2,
	p_column_value73		IN VARCHAR2,
	p_column_value74		IN VARCHAR2,
	p_column_value75		IN VARCHAR2,
	p_column_value76		IN VARCHAR2,
	p_column_value77		IN VARCHAR2,
	p_column_value78		IN VARCHAR2,
	p_column_value79		IN VARCHAR2,
	p_column_value80		IN VARCHAR2,
	p_column_value81		IN VARCHAR2,
	p_column_value82		IN VARCHAR2,
	p_column_value83		IN VARCHAR2,
	p_column_value84		IN VARCHAR2,
	p_column_value85		IN VARCHAR2,
	p_column_value86		IN VARCHAR2,
	p_column_value87		IN VARCHAR2,
	p_column_value88		IN VARCHAR2,
	p_column_value89		IN VARCHAR2,
	p_column_value90		IN VARCHAR2,
	p_column_value91		IN VARCHAR2,
	p_column_value92		IN VARCHAR2,
	p_column_value93		IN VARCHAR2,
	p_column_value94		IN VARCHAR2,
	p_column_value95		IN VARCHAR2,
	p_column_value96		IN VARCHAR2,
	p_column_value97		IN VARCHAR2,
	p_column_value98		IN VARCHAR2,
	p_column_value99		IN VARCHAR2,
	p_column_value100		IN VARCHAR2,
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
	fnd_flex_descval.set_column_value(p_column_name16, p_column_value16);
	fnd_flex_descval.set_column_value(p_column_name17, p_column_value17);
	fnd_flex_descval.set_column_value(p_column_name18, p_column_value18);
	fnd_flex_descval.set_column_value(p_column_name19, p_column_value19);
	fnd_flex_descval.set_column_value(p_column_name20, p_column_value20);
	fnd_flex_descval.set_column_value(p_column_name21, p_column_value21);
	fnd_flex_descval.set_column_value(p_column_name22, p_column_value22);
	fnd_flex_descval.set_column_value(p_column_name23, p_column_value23);
	fnd_flex_descval.set_column_value(p_column_name24, p_column_value24);
	fnd_flex_descval.set_column_value(p_column_name25, p_column_value25);
	fnd_flex_descval.set_column_value(p_column_name26, p_column_value26);
	fnd_flex_descval.set_column_value(p_column_name27, p_column_value27);
	fnd_flex_descval.set_column_value(p_column_name28, p_column_value28);
	fnd_flex_descval.set_column_value(p_column_name29, p_column_value29);
	fnd_flex_descval.set_column_value(p_column_name30, p_column_value30);
	fnd_flex_descval.set_column_value(p_column_name31, p_column_value31);
	fnd_flex_descval.set_column_value(p_column_name32, p_column_value32);
	fnd_flex_descval.set_column_value(p_column_name33, p_column_value33);
	fnd_flex_descval.set_column_value(p_column_name34, p_column_value34);
	fnd_flex_descval.set_column_value(p_column_name35, p_column_value35);
	fnd_flex_descval.set_column_value(p_column_name36, p_column_value36);
	fnd_flex_descval.set_column_value(p_column_name37, p_column_value37);
	fnd_flex_descval.set_column_value(p_column_name38, p_column_value38);
	fnd_flex_descval.set_column_value(p_column_name39, p_column_value39);
	fnd_flex_descval.set_column_value(p_column_name40, p_column_value40);
	fnd_flex_descval.set_column_value(p_column_name41, p_column_value41);
	fnd_flex_descval.set_column_value(p_column_name42, p_column_value42);
	fnd_flex_descval.set_column_value(p_column_name43, p_column_value43);
	fnd_flex_descval.set_column_value(p_column_name44, p_column_value44);
	fnd_flex_descval.set_column_value(p_column_name45, p_column_value45);
	fnd_flex_descval.set_column_value(p_column_name46, p_column_value46);
	fnd_flex_descval.set_column_value(p_column_name47, p_column_value47);
	fnd_flex_descval.set_column_value(p_column_name48, p_column_value48);
	fnd_flex_descval.set_column_value(p_column_name49, p_column_value49);
	fnd_flex_descval.set_column_value(p_column_name50, p_column_value50);
	fnd_flex_descval.set_column_value(p_column_name51, p_column_value51);
	fnd_flex_descval.set_column_value(p_column_name52, p_column_value52);
	fnd_flex_descval.set_column_value(p_column_name53, p_column_value53);
	fnd_flex_descval.set_column_value(p_column_name54, p_column_value54);
	fnd_flex_descval.set_column_value(p_column_name55, p_column_value55);
	fnd_flex_descval.set_column_value(p_column_name56, p_column_value56);
	fnd_flex_descval.set_column_value(p_column_name57, p_column_value57);
	fnd_flex_descval.set_column_value(p_column_name58, p_column_value58);
	fnd_flex_descval.set_column_value(p_column_name59, p_column_value59);
	fnd_flex_descval.set_column_value(p_column_name60, p_column_value60);
	fnd_flex_descval.set_column_value(p_column_name61, p_column_value61);
	fnd_flex_descval.set_column_value(p_column_name62, p_column_value62);
	fnd_flex_descval.set_column_value(p_column_name63, p_column_value63);
	fnd_flex_descval.set_column_value(p_column_name64, p_column_value64);
	fnd_flex_descval.set_column_value(p_column_name65, p_column_value65);
	fnd_flex_descval.set_column_value(p_column_name66, p_column_value66);
	fnd_flex_descval.set_column_value(p_column_name67, p_column_value67);
	fnd_flex_descval.set_column_value(p_column_name68, p_column_value68);
	fnd_flex_descval.set_column_value(p_column_name69, p_column_value69);
	fnd_flex_descval.set_column_value(p_column_name70, p_column_value70);
	fnd_flex_descval.set_column_value(p_column_name71, p_column_value71);
	fnd_flex_descval.set_column_value(p_column_name72, p_column_value72);
	fnd_flex_descval.set_column_value(p_column_name73, p_column_value73);
	fnd_flex_descval.set_column_value(p_column_name74, p_column_value74);
	fnd_flex_descval.set_column_value(p_column_name75, p_column_value75);
	fnd_flex_descval.set_column_value(p_column_name76, p_column_value76);
	fnd_flex_descval.set_column_value(p_column_name77, p_column_value77);
	fnd_flex_descval.set_column_value(p_column_name78, p_column_value78);
	fnd_flex_descval.set_column_value(p_column_name79, p_column_value79);
	fnd_flex_descval.set_column_value(p_column_name80, p_column_value80);
	fnd_flex_descval.set_column_value(p_column_name81, p_column_value81);
	fnd_flex_descval.set_column_value(p_column_name82, p_column_value82);
	fnd_flex_descval.set_column_value(p_column_name83, p_column_value83);
	fnd_flex_descval.set_column_value(p_column_name84, p_column_value84);
	fnd_flex_descval.set_column_value(p_column_name85, p_column_value85);
	fnd_flex_descval.set_column_value(p_column_name86, p_column_value86);
	fnd_flex_descval.set_column_value(p_column_name87, p_column_value87);
	fnd_flex_descval.set_column_value(p_column_name88, p_column_value88);
	fnd_flex_descval.set_column_value(p_column_name89, p_column_value89);
	fnd_flex_descval.set_column_value(p_column_name90, p_column_value90);
	fnd_flex_descval.set_column_value(p_column_name91, p_column_value91);
	fnd_flex_descval.set_column_value(p_column_name92, p_column_value92);
	fnd_flex_descval.set_column_value(p_column_name93, p_column_value93);
	fnd_flex_descval.set_column_value(p_column_name94, p_column_value94);
	fnd_flex_descval.set_column_value(p_column_name95, p_column_value95);
	fnd_flex_descval.set_column_value(p_column_name96, p_column_value96);
	fnd_flex_descval.set_column_value(p_column_name97, p_column_value97);
	fnd_flex_descval.set_column_value(p_column_name98, p_column_value98);
	fnd_flex_descval.set_column_value(p_column_name99, p_column_value99);
	fnd_flex_descval.set_column_value(p_column_name100, p_column_value100);
   fnd_flex_descval.set_context_value(p_context_value);
   IF NOT fnd_flex_descval.validate_desccols
     ( appl_short_name	=> p_appl_short_name,
       desc_flex_name	=> p_desc_flex_name,
       resp_appl_id	=> p_resp_appl_id,
       resp_id		=> p_resp_id ) THEN
      l_error_message := fnd_flex_descval.error_message;
      add_desc_flex_msg(p_api_name, l_error_message);
      x_return_status := fnd_api.g_ret_sts_error;
   END IF;
END Validate_Price_Attribs;



-------------------------------------------------------------------------------
--  Procedure	: Validate_Employee
-------------------------------------------------------------------------------

PROCEDURE Validate_Employee
 ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_employee_id	IN	NUMBER,
    p_org_id		IN	NUMBER	:= NULL,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
     l_orig_org_id	NUMBER;
     l_dummy	VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Store the old value of the multi-org context
   SELECT To_number(Decode(substrb(userenv('CLIENT_INFO'),1,1), ' ', NULL,
			   substrb(userenv('CLIENT_INFO'),1,10)))
     INTO l_orig_org_id
     FROM dual;

   IF (p_org_id IS NOT NULL) THEN
      -- Set the multi-org context using p_org_id
      fnd_client_info.set_org_context(p_org_id);
   END IF;

   -- Validate against hr_employees_current_v, which contains all active
   -- employees assigned to the business group stored in
   -- financials_system_parameters

   SELECT 'X' INTO l_dummy
     FROM per_workforce_x hr
    WHERE hr.person_id = p_employee_id
      AND NVL(hr.termination_date,SYSDATE) >= SYSDATE ;

/**** commented and replaced by the sql statement above for bug # 5201278
   SELECT 'x' INTO l_dummy
     FROM hr_employees_current_v
     WHERE employee_id = p_employee_id;
**********/

   IF (p_org_id IS NOT NULL) THEN
      -- Restore the original multi-org context
      fnd_client_info.set_org_context(l_orig_org_id);
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF (p_org_id IS NOT NULL) THEN
	 -- Restore the original multi-org context
	 fnd_client_info.set_org_context(l_orig_org_id);
      END IF;
      add_invalid_argument_msg(p_api_name, p_employee_id, p_parameter_name);
   WHEN OTHERS THEN
      IF (p_org_id IS NOT NULL) THEN
	 -- Restore the original multi-org context
	 fnd_client_info.set_org_context(l_orig_org_id);
      END IF;
      -- Reraise the exception so the calling subprogram can handle it
      RAISE;
END Validate_Employee;

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
--  Procedure	: Validate_Operating_Unit
------------------------------------------------------------------------------

PROCEDURE Validate_Operating_Unit
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_org_id		IN	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
     l_dummy	VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   SELECT 'x' INTO l_dummy
     FROM hr_operating_units
     WHERE organization_id = p_org_id;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      cs_core_util.add_invalid_argument_msg(p_api_name, p_org_id,
					    p_parameter_name);
END Validate_Operating_Unit;

------------------------------------------------------------------------------
--  Procedure	: Validate_Person
------------------------------------------------------------------------------

PROCEDURE Validate_Person
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_person_id		IN	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2 )
  IS
     l_dummy	VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Validate against per_people_x, which contains all employees across
   -- multiple business groups
   SELECT 'x' INTO l_dummy
     FROM per_people_x p, per_assignments_x a
     WHERE a.person_id = p_person_id
     AND a.person_id = p.person_id
     AND a.assignment_type = 'E'
     AND a.primary_flag = 'Y'
     AND p.employee_number IS NOT NULL;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      cs_core_util.add_invalid_argument_msg(p_api_name, p_person_id,
					    p_parameter_name);
END Validate_Person;

------------------------------------------------------------------------------
--  Procedure	: Validate_Ship_To_Site
------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/08/05 smisra   bug 4532643
--                   The procedure is being stubbed as it is not used
-- -----------------------------------------------------------------------------
PROCEDURE Validate_Ship_To_Site
  ( p_api_name			IN	VARCHAR2,
    p_parameter_name		IN	VARCHAR2,
    p_ship_to_site_use_id	IN	NUMBER,
    p_customer_id		IN	NUMBER,
    p_org_id			IN	NUMBER    := NULL,
    x_ship_to_customer_id	OUT NOCOPY	NUMBER,
    x_return_status		OUT NOCOPY	VARCHAR2 )
  IS
/****
     CURSOR l_ship_to_site_csr IS
	SELECT a.customer_id
	  FROM ra_addresses_all a, ra_site_uses_all su
	  WHERE su.site_use_id = p_ship_to_site_use_id
	  AND su.site_use_code = 'SHIP_TO'
	  AND su.status = 'A'
	  AND Nvl(su.org_id,-99) = Decode(su.org_id,NULL,-99,p_org_id)
	  AND a.address_id = su.address_id
	  AND Nvl(a.org_id,-99) = Decode(a.org_id,NULL,-99,p_org_id)
	  AND a.customer_id IN
	  ( SELECT p_customer_id
	    FROM dual
	    UNION
	    SELECT related_customer_id
	    FROM ra_customer_relationships_all
	    WHERE customer_id = p_customer_id
	    AND status = 'A'
	    AND Nvl(org_id,-99) = Decode(org_id,NULL,-99,p_org_id) );
******/
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

/****
   OPEN l_ship_to_site_csr;
   FETCH l_ship_to_site_csr INTO x_ship_to_customer_id;
   IF l_ship_to_site_csr%notfound THEN
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg(p_api_name, To_char(p_ship_to_site_use_id),
			       p_parameter_name);
   END IF;
   CLOSE l_ship_to_site_csr;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_ship_to_site_csr%isopen) THEN
	 CLOSE l_ship_to_site_csr;
      END IF;
      RAISE;
*****/
END Validate_Ship_To_Site;

-------------------------------------------------------------------------------
--  Procedure	: Validate_Source_Object_ID
-------------------------------------------------------------------------------

PROCEDURE Validate_Source_Object_ID
  ( p_api_name			IN	VARCHAR2,
    p_parameter_name		IN	VARCHAR2,
    p_source_object_id		IN	NUMBER,
    p_source_object_code	IN	VARCHAR2 := 'INC',
    p_org_id			IN	NUMBER	 := NULL,
    x_return_status		OUT NOCOPY	VARCHAR2 )
  IS
     l_dummy	VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF (p_source_object_code = 'INT') THEN
      SELECT 'x' INTO l_dummy
	FROM cs_interactions
	WHERE interaction_id = p_source_object_id
	AND Nvl(org_id, -99) = Decode(org_id, NULL, -99, p_org_id);
    ELSE
      SELECT 'x' INTO l_dummy
	FROM cs_incidents_all
	WHERE incident_id = p_source_object_id
	AND Nvl(org_id, -99) = Decode(org_id, NULL, -99, p_org_id);
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg(p_api_name, p_source_object_id,
			       p_parameter_name);
END Validate_Source_Object_ID;

------------------------------------------------------------------------------
--  Procedure	: Validate_Who_Info
------------------------------------------------------------------------------

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

   IF p_login_id IS NOT NULL THEN
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

PROCEDURE Is_DescFlex_Valid
(
	p_api_name			IN	VARCHAR2,
	p_appl_short_name		IN	VARCHAR2	DEFAULT	'CS',
	p_desc_flex_name		IN	VARCHAR2,
	p_seg_partial_name		IN	VARCHAR2,
	p_num_of_attributes		IN	NUMBER,
	p_seg_values			IN	DFF_Rec_Type,
	p_stack_err_msg		IN	BOOLEAN	DEFAULT	TRUE
) IS

  p_desc_context	VARCHAR2(30);
  p_desc_col_name1	VARCHAR2(30)	:=	p_seg_partial_name||'1';
  p_desc_col_name2	VARCHAR2(30)	:=	p_seg_partial_name||'2';
  p_desc_col_name3	VARCHAR2(30)	:=	p_seg_partial_name||'3';
  p_desc_col_name4	VARCHAR2(30)	:=	p_seg_partial_name||'4';
  p_desc_col_name5	VARCHAR2(30)	:=	p_seg_partial_name||'5';
  p_desc_col_name6	VARCHAR2(30)	:=	p_seg_partial_name||'6';
  p_desc_col_name7	VARCHAR2(30)	:=	p_seg_partial_name||'7';
  p_desc_col_name8	VARCHAR2(30)	:=	p_seg_partial_name||'8';
  p_desc_col_name9	VARCHAR2(30)	:=	p_seg_partial_name||'9';
  p_desc_col_name10	VARCHAR2(30)	:=	p_seg_partial_name||'10';
  p_desc_col_name11	VARCHAR2(30)	:=	p_seg_partial_name||'11';
  p_desc_col_name12	VARCHAR2(30)	:=	p_seg_partial_name||'12';
  p_desc_col_name13	VARCHAR2(30)	:=	p_seg_partial_name||'13';
  p_desc_col_name14	VARCHAR2(30)	:=	p_seg_partial_name||'14';
  p_desc_col_name15	VARCHAR2(30)	:=	p_seg_partial_name||'15';
  l_return_status	VARCHAR2(1);
  l_resp_appl_id	NUMBER;
  l_resp_id		NUMBER;
  l_return_value	BOOLEAN		:=	TRUE;

BEGIN
	IF p_num_of_attributes > 15 THEN
		/* More than 15 attributes not currently supported. Please contact developer. */
		FND_MESSAGE.SET_NAME('CS','CS_API_NUM_OF_DESCFLEX_GT_MAX');
		FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

    Validate_Desc_Flex
    (
		p_api_name,
		p_appl_short_name,
      	p_desc_flex_name,
      	p_desc_col_name1,
      	p_desc_col_name2,
      	p_desc_col_name3,
      	p_desc_col_name4,
      	p_desc_col_name5,
      	p_desc_col_name6,
      	p_desc_col_name7,
      	p_desc_col_name8,
      	p_desc_col_name9,
      	p_desc_col_name10,
      	p_desc_col_name11,
      	p_desc_col_name12,
      	p_desc_col_name13,
      	p_desc_col_name14,
      	p_desc_col_name15,
      	p_seg_values.attribute1,
      	p_seg_values.attribute2,
      	p_seg_values.attribute3,
      	p_seg_values.attribute4,
      	p_seg_values.attribute5,
      	p_seg_values.attribute6,
      	p_seg_values.attribute7,
      	p_seg_values.attribute8,
      	p_seg_values.attribute9,
      	p_seg_values.attribute10,
      	p_seg_values.attribute11,
      	p_seg_values.attribute12,
      	p_seg_values.attribute13,
      	p_seg_values.attribute14,
      	p_seg_values.attribute15,
      	p_seg_values.context,
      	l_resp_appl_id,
      	l_resp_id,
      	l_return_status );

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		RAISE FND_API.G_EXC_ERROR;
	end if;
END Is_DescFlex_Valid;

PROCEDURE Is_PriceAttribs_Valid
(
	p_api_name			IN	VARCHAR2,
	p_appl_short_name		IN	VARCHAR2	DEFAULT	'CS',
	p_Price_Attrib_name		IN	VARCHAR2,
	p_seg_partial_name		IN	VARCHAR2,
	p_seg_values			IN	PRICE_ATT_Rec_Type,
	p_stack_err_msg		IN	BOOLEAN	DEFAULT	TRUE
) IS

  p_desc_context	VARCHAR2(30);
	p_desc_col_name1 VARCHAR2(30) := p_seg_partial_name||'1';
	p_desc_col_name2 VARCHAR2(30) := p_seg_partial_name||'2';
	p_desc_col_name3 VARCHAR2(30) := p_seg_partial_name||'3';
	p_desc_col_name4 VARCHAR2(30) := p_seg_partial_name||'4';
	p_desc_col_name5 VARCHAR2(30) := p_seg_partial_name||'5';
	p_desc_col_name6 VARCHAR2(30) := p_seg_partial_name||'6';
	p_desc_col_name7 VARCHAR2(30) := p_seg_partial_name||'7';
	p_desc_col_name8 VARCHAR2(30) := p_seg_partial_name||'8';
	p_desc_col_name9 VARCHAR2(30) := p_seg_partial_name||'9';
	p_desc_col_name10 VARCHAR2(30) := p_seg_partial_name||'10';
	p_desc_col_name11 VARCHAR2(30) := p_seg_partial_name||'11';
	p_desc_col_name12 VARCHAR2(30) := p_seg_partial_name||'12';
	p_desc_col_name13 VARCHAR2(30) := p_seg_partial_name||'13';
	p_desc_col_name14 VARCHAR2(30) := p_seg_partial_name||'14';
	p_desc_col_name15 VARCHAR2(30) := p_seg_partial_name||'15';
	p_desc_col_name16 VARCHAR2(30) := p_seg_partial_name||'16';
	p_desc_col_name17 VARCHAR2(30) := p_seg_partial_name||'17';
	p_desc_col_name18 VARCHAR2(30) := p_seg_partial_name||'18';
	p_desc_col_name19 VARCHAR2(30) := p_seg_partial_name||'19';
	p_desc_col_name20 VARCHAR2(30) := p_seg_partial_name||'20';
	p_desc_col_name21 VARCHAR2(30) := p_seg_partial_name||'21';
	p_desc_col_name22 VARCHAR2(30) := p_seg_partial_name||'22';
	p_desc_col_name23 VARCHAR2(30) := p_seg_partial_name||'23';
	p_desc_col_name24 VARCHAR2(30) := p_seg_partial_name||'24';
	p_desc_col_name25 VARCHAR2(30) := p_seg_partial_name||'25';
	p_desc_col_name26 VARCHAR2(30) := p_seg_partial_name||'26';
	p_desc_col_name27 VARCHAR2(30) := p_seg_partial_name||'27';
	p_desc_col_name28 VARCHAR2(30) := p_seg_partial_name||'28';
	p_desc_col_name29 VARCHAR2(30) := p_seg_partial_name||'29';
	p_desc_col_name30 VARCHAR2(30) := p_seg_partial_name||'30';
	p_desc_col_name31 VARCHAR2(30) := p_seg_partial_name||'31';
	p_desc_col_name32 VARCHAR2(30) := p_seg_partial_name||'32';
	p_desc_col_name33 VARCHAR2(30) := p_seg_partial_name||'33';
	p_desc_col_name34 VARCHAR2(30) := p_seg_partial_name||'34';
	p_desc_col_name35 VARCHAR2(30) := p_seg_partial_name||'35';
	p_desc_col_name36 VARCHAR2(30) := p_seg_partial_name||'36';
	p_desc_col_name37 VARCHAR2(30) := p_seg_partial_name||'37';
	p_desc_col_name38 VARCHAR2(30) := p_seg_partial_name||'38';
	p_desc_col_name39 VARCHAR2(30) := p_seg_partial_name||'39';
	p_desc_col_name40 VARCHAR2(30) := p_seg_partial_name||'40';
	p_desc_col_name41 VARCHAR2(30) := p_seg_partial_name||'41';
	p_desc_col_name42 VARCHAR2(30) := p_seg_partial_name||'42';
	p_desc_col_name43 VARCHAR2(30) := p_seg_partial_name||'43';
	p_desc_col_name44 VARCHAR2(30) := p_seg_partial_name||'44';
	p_desc_col_name45 VARCHAR2(30) := p_seg_partial_name||'45';
	p_desc_col_name46 VARCHAR2(30) := p_seg_partial_name||'46';
	p_desc_col_name47 VARCHAR2(30) := p_seg_partial_name||'47';
	p_desc_col_name48 VARCHAR2(30) := p_seg_partial_name||'48';
	p_desc_col_name49 VARCHAR2(30) := p_seg_partial_name||'49';
	p_desc_col_name50 VARCHAR2(30) := p_seg_partial_name||'50';
	p_desc_col_name51 VARCHAR2(30) := p_seg_partial_name||'51';
	p_desc_col_name52 VARCHAR2(30) := p_seg_partial_name||'52';
	p_desc_col_name53 VARCHAR2(30) := p_seg_partial_name||'53';
	p_desc_col_name54 VARCHAR2(30) := p_seg_partial_name||'54';
	p_desc_col_name55 VARCHAR2(30) := p_seg_partial_name||'55';
	p_desc_col_name56 VARCHAR2(30) := p_seg_partial_name||'56';
	p_desc_col_name57 VARCHAR2(30) := p_seg_partial_name||'57';
	p_desc_col_name58 VARCHAR2(30) := p_seg_partial_name||'58';
	p_desc_col_name59 VARCHAR2(30) := p_seg_partial_name||'59';
	p_desc_col_name60 VARCHAR2(30) := p_seg_partial_name||'60';
	p_desc_col_name61 VARCHAR2(30) := p_seg_partial_name||'61';
	p_desc_col_name62 VARCHAR2(30) := p_seg_partial_name||'62';
	p_desc_col_name63 VARCHAR2(30) := p_seg_partial_name||'63';
	p_desc_col_name64 VARCHAR2(30) := p_seg_partial_name||'64';
	p_desc_col_name65 VARCHAR2(30) := p_seg_partial_name||'65';
	p_desc_col_name66 VARCHAR2(30) := p_seg_partial_name||'66';
	p_desc_col_name67 VARCHAR2(30) := p_seg_partial_name||'67';
	p_desc_col_name68 VARCHAR2(30) := p_seg_partial_name||'68';
	p_desc_col_name69 VARCHAR2(30) := p_seg_partial_name||'69';
	p_desc_col_name70 VARCHAR2(30) := p_seg_partial_name||'70';
	p_desc_col_name71 VARCHAR2(30) := p_seg_partial_name||'71';
	p_desc_col_name72 VARCHAR2(30) := p_seg_partial_name||'72';
	p_desc_col_name73 VARCHAR2(30) := p_seg_partial_name||'73';
	p_desc_col_name74 VARCHAR2(30) := p_seg_partial_name||'74';
	p_desc_col_name75 VARCHAR2(30) := p_seg_partial_name||'75';
	p_desc_col_name76 VARCHAR2(30) := p_seg_partial_name||'76';
	p_desc_col_name77 VARCHAR2(30) := p_seg_partial_name||'77';
	p_desc_col_name78 VARCHAR2(30) := p_seg_partial_name||'78';
	p_desc_col_name79 VARCHAR2(30) := p_seg_partial_name||'79';
	p_desc_col_name80 VARCHAR2(30) := p_seg_partial_name||'80';
	p_desc_col_name81 VARCHAR2(30) := p_seg_partial_name||'81';
	p_desc_col_name82 VARCHAR2(30) := p_seg_partial_name||'82';
	p_desc_col_name83 VARCHAR2(30) := p_seg_partial_name||'83';
	p_desc_col_name84 VARCHAR2(30) := p_seg_partial_name||'84';
	p_desc_col_name85 VARCHAR2(30) := p_seg_partial_name||'85';
	p_desc_col_name86 VARCHAR2(30) := p_seg_partial_name||'86';
	p_desc_col_name87 VARCHAR2(30) := p_seg_partial_name||'87';
	p_desc_col_name88 VARCHAR2(30) := p_seg_partial_name||'88';
	p_desc_col_name89 VARCHAR2(30) := p_seg_partial_name||'89';
	p_desc_col_name90 VARCHAR2(30) := p_seg_partial_name||'90';
	p_desc_col_name91 VARCHAR2(30) := p_seg_partial_name||'91';
	p_desc_col_name92 VARCHAR2(30) := p_seg_partial_name||'92';
	p_desc_col_name93 VARCHAR2(30) := p_seg_partial_name||'93';
	p_desc_col_name94 VARCHAR2(30) := p_seg_partial_name||'94';
	p_desc_col_name95 VARCHAR2(30) := p_seg_partial_name||'95';
	p_desc_col_name96 VARCHAR2(30) := p_seg_partial_name||'96';
	p_desc_col_name97 VARCHAR2(30) := p_seg_partial_name||'97';
	p_desc_col_name98 VARCHAR2(30) := p_seg_partial_name||'98';
	p_desc_col_name99 VARCHAR2(30) := p_seg_partial_name||'99';
	p_desc_col_name100 VARCHAR2(30) := p_seg_partial_name||'100';
  l_return_status	VARCHAR2(1);
  l_resp_appl_id	NUMBER;
  l_resp_id		NUMBER;
  l_return_value	BOOLEAN		:=	TRUE;

BEGIN
    Validate_Price_Attribs
    (
		p_api_name,
		p_appl_short_name,
      	p_price_attrib_name,
		p_desc_col_name1,
		p_desc_col_name2,
		p_desc_col_name3,
		p_desc_col_name4,
		p_desc_col_name5,
		p_desc_col_name6,
		p_desc_col_name7,
		p_desc_col_name8,
		p_desc_col_name9,
		p_desc_col_name10,
		p_desc_col_name11,
		p_desc_col_name12,
		p_desc_col_name13,
		p_desc_col_name14,
		p_desc_col_name15,
		p_desc_col_name16,
		p_desc_col_name17,
		p_desc_col_name18,
		p_desc_col_name19,
		p_desc_col_name20,
		p_desc_col_name21,
		p_desc_col_name22,
		p_desc_col_name23,
		p_desc_col_name24,
		p_desc_col_name25,
		p_desc_col_name26,
		p_desc_col_name27,
		p_desc_col_name28,
		p_desc_col_name29,
		p_desc_col_name30,
		p_desc_col_name31,
		p_desc_col_name32,
		p_desc_col_name33,
		p_desc_col_name34,
		p_desc_col_name35,
		p_desc_col_name36,
		p_desc_col_name37,
		p_desc_col_name38,
		p_desc_col_name39,
		p_desc_col_name40,
		p_desc_col_name41,
		p_desc_col_name42,
		p_desc_col_name43,
		p_desc_col_name44,
		p_desc_col_name45,
		p_desc_col_name46,
		p_desc_col_name47,
		p_desc_col_name48,
		p_desc_col_name49,
		p_desc_col_name50,
		p_desc_col_name51,
		p_desc_col_name52,
		p_desc_col_name53,
		p_desc_col_name54,
		p_desc_col_name55,
		p_desc_col_name56,
		p_desc_col_name57,
		p_desc_col_name58,
		p_desc_col_name59,
		p_desc_col_name60,
		p_desc_col_name61,
		p_desc_col_name62,
		p_desc_col_name63,
		p_desc_col_name64,
		p_desc_col_name65,
		p_desc_col_name66,
		p_desc_col_name67,
		p_desc_col_name68,
		p_desc_col_name69,
		p_desc_col_name70,
		p_desc_col_name71,
		p_desc_col_name72,
		p_desc_col_name73,
		p_desc_col_name74,
		p_desc_col_name75,
		p_desc_col_name76,
		p_desc_col_name77,
		p_desc_col_name78,
		p_desc_col_name79,
		p_desc_col_name80,
		p_desc_col_name81,
		p_desc_col_name82,
		p_desc_col_name83,
		p_desc_col_name84,
		p_desc_col_name85,
		p_desc_col_name86,
		p_desc_col_name87,
		p_desc_col_name88,
		p_desc_col_name89,
		p_desc_col_name90,
		p_desc_col_name91,
		p_desc_col_name92,
		p_desc_col_name93,
		p_desc_col_name94,
		p_desc_col_name95,
		p_desc_col_name96,
		p_desc_col_name97,
		p_desc_col_name98,
		p_desc_col_name99,
		p_desc_col_name100,
		p_seg_values.pricing_attribute1,
		p_seg_values.pricing_attribute2,
		p_seg_values.pricing_attribute3,
		p_seg_values.pricing_attribute4,
		p_seg_values.pricing_attribute5,
		p_seg_values.pricing_attribute6,
		p_seg_values.pricing_attribute7,
		p_seg_values.pricing_attribute8,
		p_seg_values.pricing_attribute9,
		p_seg_values.pricing_attribute10,
		p_seg_values.pricing_attribute11,
		p_seg_values.pricing_attribute12,
		p_seg_values.pricing_attribute13,
		p_seg_values.pricing_attribute14,
		p_seg_values.pricing_attribute15,
		p_seg_values.pricing_attribute16,
		p_seg_values.pricing_attribute17,
		p_seg_values.pricing_attribute18,
		p_seg_values.pricing_attribute19,
		p_seg_values.pricing_attribute20,
		p_seg_values.pricing_attribute21,
		p_seg_values.pricing_attribute22,
		p_seg_values.pricing_attribute23,
		p_seg_values.pricing_attribute24,
		p_seg_values.pricing_attribute25,
		p_seg_values.pricing_attribute26,
		p_seg_values.pricing_attribute27,
		p_seg_values.pricing_attribute28,
		p_seg_values.pricing_attribute29,
		p_seg_values.pricing_attribute30,
		p_seg_values.pricing_attribute31,
		p_seg_values.pricing_attribute32,
		p_seg_values.pricing_attribute33,
		p_seg_values.pricing_attribute34,
		p_seg_values.pricing_attribute35,
		p_seg_values.pricing_attribute36,
		p_seg_values.pricing_attribute37,
		p_seg_values.pricing_attribute38,
		p_seg_values.pricing_attribute39,
		p_seg_values.pricing_attribute40,
		p_seg_values.pricing_attribute41,
		p_seg_values.pricing_attribute42,
		p_seg_values.pricing_attribute43,
		p_seg_values.pricing_attribute44,
		p_seg_values.pricing_attribute45,
		p_seg_values.pricing_attribute46,
		p_seg_values.pricing_attribute47,
		p_seg_values.pricing_attribute48,
		p_seg_values.pricing_attribute49,
		p_seg_values.pricing_attribute50,
		p_seg_values.pricing_attribute51,
		p_seg_values.pricing_attribute52,
		p_seg_values.pricing_attribute53,
		p_seg_values.pricing_attribute54,
		p_seg_values.pricing_attribute55,
		p_seg_values.pricing_attribute56,
		p_seg_values.pricing_attribute57,
		p_seg_values.pricing_attribute58,
		p_seg_values.pricing_attribute59,
		p_seg_values.pricing_attribute60,
		p_seg_values.pricing_attribute61,
		p_seg_values.pricing_attribute62,
		p_seg_values.pricing_attribute63,
		p_seg_values.pricing_attribute64,
		p_seg_values.pricing_attribute65,
		p_seg_values.pricing_attribute66,
		p_seg_values.pricing_attribute67,
		p_seg_values.pricing_attribute68,
		p_seg_values.pricing_attribute69,
		p_seg_values.pricing_attribute70,
		p_seg_values.pricing_attribute71,
		p_seg_values.pricing_attribute72,
		p_seg_values.pricing_attribute73,
		p_seg_values.pricing_attribute74,
		p_seg_values.pricing_attribute75,
		p_seg_values.pricing_attribute76,
		p_seg_values.pricing_attribute77,
		p_seg_values.pricing_attribute78,
		p_seg_values.pricing_attribute79,
		p_seg_values.pricing_attribute80,
		p_seg_values.pricing_attribute81,
		p_seg_values.pricing_attribute82,
		p_seg_values.pricing_attribute83,
		p_seg_values.pricing_attribute84,
		p_seg_values.pricing_attribute85,
		p_seg_values.pricing_attribute86,
		p_seg_values.pricing_attribute87,
		p_seg_values.pricing_attribute88,
		p_seg_values.pricing_attribute89,
		p_seg_values.pricing_attribute90,
		p_seg_values.pricing_attribute91,
		p_seg_values.pricing_attribute92,
		p_seg_values.pricing_attribute93,
		p_seg_values.pricing_attribute94,
		p_seg_values.pricing_attribute95,
		p_seg_values.pricing_attribute96,
		p_seg_values.pricing_attribute97,
		p_seg_values.pricing_attribute98,
		p_seg_values.pricing_attribute99,
		p_seg_values.pricing_attribute100,
        p_seg_values.pricing_context,
      	l_resp_appl_id,
      	l_resp_id,
      	l_return_status );

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		RAISE FND_API.G_EXC_ERROR;
	end if;
END Is_PriceAttribs_Valid;
------------------------------------------------------------------------------
--  Procedure	: get_g_false
------------------------------------------------------------------------------

function get_g_false return varchar2 is

  begin
    return (fnd_api.g_false);

end get_g_false;

------------------------------------------------------------------------------
--  Procedure	: get_g_true
------------------------------------------------------------------------------

function get_g_true return varchar2 is

  begin
    return (fnd_api.g_true);

end get_g_true;

------------------------------------------------------------------------------
--  Procedure	: get_g_valid_level_full
------------------------------------------------------------------------------

function get_g_valid_level_full return varchar2 is

  begin
    return (fnd_api.g_valid_level_full);

end get_g_valid_level_full;

------------------------------------------------------------------------------
--  Procedure	: get_g_miss_num
------------------------------------------------------------------------------

function get_g_miss_num return number is

  begin
    return (fnd_api.g_miss_num);

end get_g_miss_num;

------------------------------------------------------------------------------
--  Procedure	: get_g_miss_char
------------------------------------------------------------------------------

function get_g_miss_char return varchar2 is

  begin
    return (fnd_api.g_miss_char);

end get_g_miss_char;

------------------------------------------------------------------------------
--  Procedure	: get_g_miss_date
------------------------------------------------------------------------------

function get_g_miss_date return date is

  begin
    return (fnd_api.g_miss_date);

end get_g_miss_date;

----------------------------------- End of Code -----------------------------

END CS_CORE_UTIL;

/
