--------------------------------------------------------
--  DDL for Package Body PY_ZA_USERMESG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_USERMESG_PKG" as
/* $Header: pyzamesg.pkb 120.2 2005/08/25 02:47:18 kapalani noship $ */
-------------------------------------------------------------------
function get_message
(
   x_message_name in char
)  return varchar2 is

x_message_text varchar2(2000);

begin

   select distinct(message_text)
   into   x_message_text
   from   fnd_new_messages
   where  message_name = x_message_name
   and    language_code = userenv('LANG');

   return x_message_text;

--   pragma restrict_references(get_message,WNDS); -- Bug 4543522

exception
   when no_data_found then
      null;

end;
end py_za_usermesg_pkg;

/
