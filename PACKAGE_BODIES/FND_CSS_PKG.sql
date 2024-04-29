--------------------------------------------------------
--  DDL for Package Body FND_CSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CSS_PKG" as
/* $Header: afcssb.pls 115.0 2003/11/10 21:27:24 dehu noship $ */

--
-- Encode
--   Substitutes the occurence of special characters like <, >, ', ", &
--   with their html codes in any arbitrary string.
-- IN
--   some_text - text to be substituted
-- RETURN
--   substituted text
-- EXCEPTION
--   system-defined VALUE_ERROR if length of return string is greater than
--   32767

function Encode(some_text in varchar2)
return varchar2 is
  l_amp     varchar2(1) := '&';
begin
  return replace(replace(replace(replace(replace(some_text, l_amp, l_amp||'amp;'),
                                         '<', l_amp||'lt;'),
                                 '>', l_amp||'gt;'),
                         '''', l_amp||'#39;'),
                 '"', l_amp||'#34;');
end Encode;

End FND_CSS_PKG;

/
