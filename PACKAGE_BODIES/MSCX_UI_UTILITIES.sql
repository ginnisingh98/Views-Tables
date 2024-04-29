--------------------------------------------------------
--  DDL for Package Body MSCX_UI_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSCX_UI_UTILITIES" AS
-- $Header: MSCXUIPB.pls 120.1 2006/01/05 04:09:13 pragarwa noship $


FUNCTION GET_RESPONSIBILITY_KEY
return varchar2 is
l_resp_key varchar2(30);
begin
select responsibility_key  into l_resp_key
        from fnd_responsibility
        where responsibility_id=fnd_global.resp_id
              and application_id=724;
return  l_resp_key;
end GET_RESPONSIBILITY_KEY;


FUNCTION GET_USER_NAME(grantee_key number)
return varchar2 is
l_user_name varchar2(100);
begin
select user_name  into l_user_name
        from fnd_user
        where user_id=grantee_key;
--dbms_output.put_line('user name is  ' || l_user_name);
return  l_user_name;
end GET_USER_NAME;


FUNCTION GET_RESPONSIBILITY_NAME(grantee_key number)
return varchar2 is
l_resp_name varchar2(100);
begin
select responsibility_name  into l_resp_name
        from fnd_responsibility_vl
        where responsibility_id=grantee_key;
return  l_resp_name;
end GET_RESPONSIBILITY_NAME;

FUNCTION GET_GROUP_NAME(grantee_key number)
return varchar2 is
l_group_name varchar2(100);
begin
select group_name  into l_group_name
        from msc_groups
        where group_id=grantee_key;
return  l_group_name;
end GET_GROUP_NAME;

FUNCTION GET_COMPANY_NAME(grantee_key number)
return varchar2 is
l_company_name varchar2(1000);
begin
select company_name  into l_company_name
        from msc_companies
        where company_id=grantee_key;
return  l_company_name;
end GET_COMPANY_NAME;


 FUNCTION GET_SITE_NAME(p_site_id number)
return varchar2 is
l_site_name varchar2(30);
begin
select distinct(company_site_name)  into l_site_name
        from msc_company_sites
        where company_site_id=p_site_id;
return  l_site_name;
end GET_SITE_NAME;

FUNCTION GET_ITEM_NAME(p_item_id number)
return varchar2 is
l_item_name varchar2(250);
begin
select item_name  into l_item_name
        from msc_items
        where inventory_item_id=p_item_id;
return  l_item_name;
end GET_ITEM_NAME;


FUNCTION GET_ORDER_TYPE_MEANING(p_order_type number)
return varchar2 is
l_meaning varchar2(80);
begin
if p_order_type is null then
return null;
else
select meaning  into l_meaning
        from fnd_lookup_values
        where lookup_type='MSC_X_ORDER_TYPE'
	and language=userenv('lang')
	and lookup_code=to_char(p_order_type);
return  l_meaning;
end if;
end  GET_ORDER_TYPE_MEANING;


FUNCTION GET_GRANTEE_TYPE_MEANING(p_grantee_type varchar2)
return varchar2 is
l_meaning varchar2(80);
begin
select meaning  into l_meaning
        from fnd_lookup_values
        where lookup_type='MSC_X_GRANTEE_TYPE'
	and language=userenv('lang')
	and lookup_code=p_grantee_type;
return  l_meaning;
end  GET_GRANTEE_TYPE_MEANING;

FUNCTION GET_PRIVILEGE_MEANING(p_privilege varchar2)
return varchar2 is
l_meaning varchar2(80);
begin
select meaning  into l_meaning
        from fnd_lookup_values
        where lookup_type='MSC_X_PRIVILEGE_TYPE'
	and language=userenv('lang')
	and lookup_code=p_privilege;
return  l_meaning;
end  GET_PRIVILEGE_MEANING;


END MSCX_UI_UTILITIES ;



/
