--------------------------------------------------------
--  DDL for Package Body CS_KB_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_PROFILES_PKG" AS
/* $Header: cskbprob.pls 115.4 2003/12/18 23:17:31 mkettle noship $ */

FUNCTION isCategorymember(
  m_user_id  	IN  NUMBER,
  m_category_id IN  NUMBER
  ) RETURN NUMBER IS

  x_profile_name VARCHAR2(60);
  x_temp number;
BEGIN
	x_profile_name := 'CS_KB_PERZ_WF_' || to_char(m_user_id);

	select 1
	into x_temp
	from JTF_PERZ_PROFILE profile,
	     JTF_PERZ_DATA data,
	     JTF_PERZ_DATA_ATTRIB attrib
	where profile.profile_name = x_profile_name
	and   profile.profile_id = data.profile_id
	and   data.application_id = 170
	and   data.perz_data_name = 'CS_KB_WF_CATEGORY'
	and   data.perz_data_id = attrib.perz_data_id
	and   attrib.attribute_name = to_char(m_category_id);

        return x_temp;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
             return 0;

END isCategorymember;

FUNCTION isProductmember(
  m_user_id  	   IN  NUMBER,
  m_product_id 	   IN  NUMBER,
  m_product_org_id IN NUMBER
  ) RETURN NUMBER IS

  x_profile_name VARCHAR2(60);
  x_temp	 number;
BEGIN
        x_profile_name := 'CS_KB_PERZ_WF_' || to_char(m_user_id);

        select 1
	    into x_temp
        from JTF_PERZ_PROFILE profile,
             JTF_PERZ_DATA data,
             JTF_PERZ_DATA_ATTRIB attrib
        where profile.profile_name = x_profile_name
        and   profile.profile_id = data.profile_id
        and   data.application_id = 170
        and   data.perz_data_name = 'CS_KB_WF_PRODUCT'
        and   data.perz_data_id = attrib.perz_data_id
        and   attrib.attribute_name = to_char(m_product_id)
        and   decode(substr(attrib.attribute_value,1,4),
             'org_', to_number(replace(attrib.attribute_value, 'org_','')) ,
             cs_std.get_item_valdn_orgzn_id) = m_product_org_id;

        return x_temp;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
             return 0;

END isProductmember;

 -- Package Body CS_KB_PROFILES_PKG
END;

/
