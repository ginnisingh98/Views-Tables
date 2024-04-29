--------------------------------------------------------
--  DDL for Package Body FND_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONTEXT" as
/* $Header: AFSCCTXB.pls 115.0 2003/09/24 20:10:21 rsheh noship $ */


--
-- GENERIC_ERROR (Internal)
--
-- Set error message and raise exception for unexpected sql errors
--
procedure GENERIC_ERROR(routine in varchar2,
                        errcode in number,
                        errmsg in varchar2) is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', dbms_utility.format_error_stack);
    fnd_message.raise_error;
end GENERIC_ERROR;

-- Init (PUBLIC)
--   This is generic routine to initialize attribute value inside a given
--   context which its namespace must be created prior than calling this
--   routine.
--
--   Context Areas are defined, and associated with an initialization
--   package/procedure, using the CREATE CONTEXT command.
--   For example, "CREATE CONTEXT XXX using FND_CONTEXT"
--                XXX will be the context name and FND_CONTEXT is the package.
--
--   It calls dbms.session.set_context to set one attribute base on its name
--   and value pair.
--
-- Input
--   context_name: the name of the context area.(VARCHAR2)
--   attr_name:    the name of the attribute. (VARCHAR2)
--   attr_value:   the value of the attribute (VARCHAR2)
--
-- Usage Example:
--   CREATE CONTEXT PO using FND_CONTEXT;
--   begin fnd_context.init('PO', 'my_name', 'my_value'); end;
--
procedure init(context_name in varchar2,
               attr_name in varchar2,
               attr_value in varchar2) is
begin

  dbms_session.set_context(context_name, attr_name, attr_value);

exception
  when others then
        generic_error('FND_CONTEXT.INIT', SQLCODE, SQLERRM);
end init;

end FND_CONTEXT;

/
