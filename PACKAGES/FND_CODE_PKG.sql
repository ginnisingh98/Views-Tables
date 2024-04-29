--------------------------------------------------------
--  DDL for Package FND_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CODE_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPCODS.pls 115.1 99/07/16 23:09:43 porting sh $ */
  /*
  ** Convert a number to a base-64 string
  */
  function BASE64(VAL in number, NDIGITS in number)
    return varchar2;

end FND_CODE_PKG;

 

/
