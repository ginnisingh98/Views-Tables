--------------------------------------------------------
--  DDL for Package Body IBU_DAC_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_DAC_CRITERIA_PKG" AS
/* $Header: ibudacb.pls 115.7 2002/11/28 00:23:06 nazhou noship $ */
FUNCTION GetDACCriteria(
  UserName   in  varchar2,
  PermissionName   in  varchar2,
  UserID   in  varchar2
) return varchar2 is
    daccriteria varchar2(2000) :=null;
    l_string varchar2(2000);
    counter integer;
    account_id integer;
    company_id integer;
    customer_id integer;
    company_name varchar(360);
  cursor l_types_csr is
    select property_value from jtf_dac_role_perm_crit where jtf_dac_role_perm_crit.JTF_AUTH_PRINCIPAL_ID in
    (select JTF_AUTH_PRINCIPAL_ID from jtf_auth_principals_b where JTF_AUTH_PRINCIPAL_ID
    in (
    select unique(JTF_AUTH_PRINCIPAL_ID) from jtf_auth_role_perms
    where jtf_auth_role_perms.JTF_AUTH_PERMISSION_ID in(
    select JTF_AUTH_PERMISSION_ID
    from jtf_auth_read_perms where jtf_auth_read_perms.jtf_auth_principal_name  = UserName )
    and jtf_auth_principals_b.DAC_ROLE_FLAG ='1')) and jtf_dac_role_perm_crit.PERMISSION_NAME = PermissionName;
    begin

        account_id := IBU_HOME_PAGE_PVT.get_account_id_from_user(UserID);
        company_id := IBU_HOME_PAGE_PVT.get_company_id_from_user(UserID);
        customer_id := IBU_HOME_PAGE_PVT.get_customer_id_from_user(UserID);
        company_name := IBU_HOME_PAGE_PVT.get_company_name_from_user(UserID);

        counter := 0;

        for rec in l_types_csr loop
            if counter = 0
            then
                l_string := rec.property_value;
            else
                l_string := ' OR ' || rec.property_value;
            end if;
        end loop;

        l_string := replace(l_string, '&'||'&'||'USER_ID', UserID);

        l_string := replace(l_string, '&'||'&'||'COMPANY_ID', company_id);

        l_string := replace(l_string, '&'||'&'||'USER_CURRENT_ACCT_ID', account_id);

        l_string := replace(l_string, '&'||'&'||'PARTY_ID', customer_id);


        daccriteria := l_string;

        return daccriteria;

    end GetDACCriteria;


FUNCTION CheckPermission(
  PermissionName   in  varchar2,
  PRINCIPAL_NAME   in  varchar2
) return boolean is
    result varchar2(2000) := 'FALSE';
    l_string varchar2(2000);
  cursor l_types_csr is
    select jtf_auth_read_perms.JTF_AUTH_PERMISSION_ID from jtf_auth_read_perms where
    jtf_auth_read_perms.JTF_AUTH_PRINCIPAL_NAME in (select jtf_auth_principals_b.PRINCIPAL_NAME
    from jtf_auth_principals_b where jtf_auth_principals_b.PRINCIPAL_NAME = PRINCIPAL_NAME)
    and jtf_auth_read_perms.JTF_AUTH_PERMISSION_NAME = PermissionName;

    begin

        for rec in l_types_csr loop
            return true;

        end loop;

        return false;

    end CheckPermission;



end IBU_DAC_Criteria_PKG;


/
