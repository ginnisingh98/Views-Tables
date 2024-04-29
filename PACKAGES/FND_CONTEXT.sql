--------------------------------------------------------
--  DDL for Package FND_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONTEXT" AUTHID CURRENT_USER as
/* $Header: AFSCCTXS.pls 115.0 2003/09/24 20:10:00 rsheh noship $ */


-- Init (PUBLIC)
--   This is generic routine to initialize attribute value inside a given
--   context which its namespace must be created prior than calling this
--   routine.
--
--   Context Areas are defined, and associated with an initialization
--   package/procedure, using the CREATE CONTEXT command.
--   For example, "CREATE CONTEXT XXX using FND_CONTEXT".
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
procedure INIT(context_name in varchar2,
               attr_name    in varchar2,
               attr_value   in varchar2);

end FND_CONTEXT;

 

/
