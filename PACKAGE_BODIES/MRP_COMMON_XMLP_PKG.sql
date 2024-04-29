--------------------------------------------------------
--  DDL for Package Body MRP_COMMON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_COMMON_XMLP_PKG" As
/* $Header: MRPCOMMONB.pls 120.0 2008/01/01 13:41:13 dwkrishn noship $ */
  -- Private type declarations
  -- Function and procedure implementations
function get_precision(qty_precision in number) return VARCHAR2 is
begin

if qty_precision = 0 then return('999G999G999G990');

elsif qty_precision = 1 then return('999G999G999G990D0');

elsif qty_precision = 3 then return('999G999G999G990D000');

elsif qty_precision = 4 then return('999G999G999G990D0000');

elsif qty_precision = 5 then return('999G999G999G990D00000');

elsif qty_precision = 6 then  return('999G999G999G990D000000');

else return('999G999G999G990D00');

end if;

end;

end MRP_COMMON_XMLP_PKG;

/
