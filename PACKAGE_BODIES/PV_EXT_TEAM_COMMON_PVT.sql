--------------------------------------------------------
--  DDL for Package Body PV_EXT_TEAM_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_EXT_TEAM_COMMON_PVT" AS
/* $Header: pvxvcomb.pls 120.0 2005/05/27 16:18:25 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_EXT_TEAM_COMMON_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvcomb.pls';


/*============================================================================
--  API name  : chk_oppty_approver
--  Type      : Function.
--  Function  : This function return the value 'Y' or 'N' based on the
--              findings that the given user is a Opportunity Approver
--              or not.
--
--  Pre-reqs  :
--  Parameters  :
--  IN    :
--        p_user_name  In   VARCHAR2
--
--  OUT   :
--
--  Version : Current version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
  FUNCTION chk_oppty_approver(p_user_name IN VARCHAR2 )
  RETURN VARCHAR2
  IS

    l_oppty_approver_flg  VARCHAR2(1) ;

  CURSOR l_optty_approver_csr(cv_user_name VARCHAR2) IS
  SELECT 'Y'
  FROM   jtf_auth_principal_maps jtfpm,
         jtf_auth_principals_b jtfp1,
         jtf_auth_domains_b jtfd,
         jtf_auth_principals_b jtfp2,
         jtf_auth_role_perms jtfrp,
         jtf_auth_permissions_b jtfperm
  WHERE  jtfp1.principal_name = cv_user_name
  AND    jtfp1.is_user_flag=1
  AND    jtfp1.jtf_auth_principal_id = jtfpm.jtf_auth_principal_id
  AND    jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
  AND    jtfp2.is_user_flag=0
  AND    jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
  AND    jtfrp.positive_flag = 1
  AND    jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
  AND    jtfperm.permission_name = 'PV_OPPTY_CONTACT'
  AND    jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
  AND    jtfd.domain_name='CRM_DOMAIN';

  BEGIN

    OPEN l_optty_approver_csr(p_user_name);
    FETCH l_optty_approver_csr INTO l_oppty_approver_flg;
    IF l_optty_approver_csr%NOTFOUND THEN
      l_oppty_approver_flg := 'N';
    END IF;
    CLOSE l_optty_approver_csr;

    return l_oppty_approver_flg;

  END chk_oppty_approver;

END PV_EXT_TEAM_COMMON_PVT;

/
