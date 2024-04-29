--------------------------------------------------------
--  DDL for Package JTF_ROLE_VERIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ROLE_VERIFICATION" AUTHID CURRENT_USER as
/* $Header: JTFSERVS.pls 115.0 2004/10/18 21:33:57 eelango noship $ */
--
-- Start of Package Globals

-- End of Package Globals
--
-------------------------------------------------------------------------------
/*
** Name      : update_auth_principal_id
** Type      : Public, JTF Internal
** Desc      : Wrapper procedure over procedure,
**  jtf_um_role_verification.update_auth_principal_id. If the package is not
**  found in a older deployment, the procedure ignores the ORA-06550 error. It
**  uses dynamic sql and exception_init to accomplish this.
**
** Parameters:
**  old_auth_principal_id - Same as in the original procedure
**  new_auth_principal_id - Same as in the original procedure
*/
procedure update_auth_principal_id(
    old_auth_principal_id in number
  , new_auth_principal_id in number
);
--
-------------------------------------------------------------------------------
--
end jtf_role_verification;

 

/
