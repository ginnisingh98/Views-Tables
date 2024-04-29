--------------------------------------------------------
--  DDL for Package PY_ZA_USERMESG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_USERMESG_PKG" AUTHID CURRENT_USER as
/* $Header: pyzamesg.pkh 120.1 2005/06/24 05:00:40 kapalani noship $ */
function get_message(x_message_name in char) return varchar2;
pragma restrict_references(get_message, WNDS);
end py_za_usermesg_pkg;

 

/
