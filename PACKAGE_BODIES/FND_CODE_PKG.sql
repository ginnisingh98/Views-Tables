--------------------------------------------------------
--  DDL for Package Body FND_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CODE_PKG" as
/* $Header: AFCPCODB.pls 115.1 99/07/16 23:09:39 porting sh $ */
  function BASE64(VAL in number, NDIGITS in number)
    return varchar2
  is
    STR64    varchar2(64);
    SRESULT  varchar2(2000);
    LCOUNT   binary_integer;
    A1       number;
    A2       number;
  begin

    STR64 :='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    SRESULT := '';
    A1 := VAL;

    for LCOUNT in 1..NDIGITS loop
      A2 := mod(A1,64);
      A1 := (A1 - A2)/64;
      SRESULT := substr(STR64,A2,1)||SRESULT;
    end loop;

    return(SRESULT);
  end BASE64;

end FND_CODE_PKG;

/
