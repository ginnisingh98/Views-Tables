--------------------------------------------------------
--  DDL for Package Body JTF_ROLE_VERIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ROLE_VERIFICATION" as
/* $Header: JTFSERVB.pls 115.3 2004/10/19 03:06:30 sfazil noship $ */
--
-- Start of Package Globals

-- End of Package Globals
--
-------------------------------------------------------------------------------
--
procedure update_auth_principal_id(
    old_auth_principal_id in number
  , new_auth_principal_id in number
) is

  l_plsql_block     varchar2(256);

  package_not_found exception;
  line_error exception;
  program_not_found exception;
  package_body_error exception;
  package_not_valid exception;

  pragma exception_init(package_not_found, -6550);
  pragma exception_init(line_error, -6512);
  pragma exception_init(program_not_found, -6508);
  pragma exception_init(package_body_error, -4063);
  pragma exception_init(package_not_valid, -4068);

begin

  l_plsql_block :=
    'begin ' ||
    '  jtf_um_role_verification.update_auth_principal_id(:a, :b);' ||
    'end;';
  execute immediate l_plsql_block using old_auth_principal_id,
    new_auth_principal_id;

exception
  when package_not_found then
--     If there is a logging routine log a message
    null;
  when line_error then
--     If there is a logging routine log a message
    null;
  when program_not_found then
--     If there is a logging routine log a message
    null;
  when package_body_error then
    -- If there is a logging routine log a message
    null;
  when package_not_valid then
    -- If there is a logging routine log a message
    null;

end;
--
-------------------------------------------------------------------------------
--
end jtf_role_verification;

/
