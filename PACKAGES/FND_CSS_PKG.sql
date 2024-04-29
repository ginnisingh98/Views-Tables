--------------------------------------------------------
--  DDL for Package FND_CSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CSS_PKG" AUTHID CURRENT_USER as
/* $Header: afcsss.pls 115.1 2003/11/10 22:06:33 dehu noship $ */

--
-- Encode
--   Substitutes the occurence of special characters like <, >, ', ", &
--   with their html codes in any arbitrary string.
-- IN
--   some_text - text to be substituted
-- RETURN
--   substituted text

function Encode(some_text in varchar2)
return varchar2;

end FND_CSS_PKG;

 

/
