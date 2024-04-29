--------------------------------------------------------
--  DDL for Package UMX_FGA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_FGA_UTILS_PKG" AUTHID CURRENT_USER as
   /* $Header: UMXFGAUTILS.pls 120.5.12010000.6 2009/09/09 10:36:51 kkasibha noship $ */

    procedure convert_All_Grants_to_roleSets;

    procedure create_roleSet_from_grants(adminRole varchar2);

    procedure create_global_privileges(adminRole varchar2,
                                        canCreate number,
                                        GLOBALPRIV2 number default 1,
                                        GLOBALPRIV3 number default 1,
                                        GLOBALPRIV4 number default 1,
                                        GLOBALPRIV5 number default 1,
                                        GLOBALPRIV6 number default 1,
                                        GLOBALPRIV7 number default 1,
                                        GLOBALPRIV8 number default 1,
                                        GLOBALPRIV9 number default 1);

	procedure create_assign_roleSet(adminRole varchar2,
                                    roleSetName varchar2 default null,
                                    roleName varchar2 default '%',
                                    roleAapl varchar2 default '',
                                    roleCat varchar2 default '',
                                    canUpdate number default 1,
                                    canManageGrants number default 1,
                                    canAlterHierarchy number default 1,
                                    canAssign number default 1,
                                    canRevoke number default 1,
                                    securityWizard number default 1,
                                    PRIVILEGE7 number default 1,
                                    PRIVILEGE8 number default 1,
                                    PRIVILEGE9 number default 1,
                                    PRIVILEGE10 number default 1,
                                    PRIVILEGE11 number default 1,
                                    PRIVILEGE12 number default 1,
                                    PRIVILEGE13 number default 1,
                                    PRIVILEGE14 number default 1);

    function create_roleSet_criteria(roleSetId number default null,
                                     roleSetName varchar2 default null,
                                     roleName varchar2 default '%',
                                     roleAapl varchar2 default null,
                                     roleCat varchar2 default null)
    return number;

    procedure assign_roleSet_to_adminRole(adminRole varchar2,
                                        roleSetId number,
                                        canUpdate number default 1,
                                        canManageGrants number default 1,
                                        canAlterHierarchy number default 1,
                                        canAssign number default 1,
                                        canRevoke number default 1,
                                        securityWizard number default 1,
                                        PRIV7 number default 1,
                                        PRIV8 number default 1,
                                        PRIV9 number default 1,
                                        PRIV10 number default 1,
                                        PRIV11 number default 1,
                                        PRIV12 number default 1,
                                        PRIV13 number default 1,
                                        PRIV14 number default 1);

    procedure create_all_roles_roleset;

    procedure bulk_add_all(p_role_set_id varchar2);

    procedure bulk_add_all_for_new(p_role_set_id varchar2, p_role_name varchar2, p_role_appl varchar2, p_role_cat varchar2);

    procedure bulk_remove_all(p_role_set_id varchar2);

    procedure delete_role_Set(p_role_set_id varchar2,p_admin_role varchar2 default null);

    function get(code in varchar2) return varchar2;

    procedure set(code in varchar2, value in varchar2);

    procedure clearViewParams;

end;

/
