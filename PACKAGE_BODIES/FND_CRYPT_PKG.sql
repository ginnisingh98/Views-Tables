--------------------------------------------------------
--  DDL for Package Body FND_CRYPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CRYPT_PKG" as
/* $Header: AFCPCRYB.pls 115.7 99/08/26 14:01:48 porting ship $ */

  function ENCRYPT(KEYSTRING in varchar2, DATASTRING in varchar2,
                   NCHARS in number)
    return varchar2
  is
  begin
    return('Obsolete');
  end ENCRYPT;

  function DECRYPT(KEYSTRING in varchar2, DATAHEX in varchar2,
                   NCHARS in number)
    return varchar2
  is
  begin
    return('Obsolete');
  end DECRYPT;

end FND_CRYPT_PKG;

/
