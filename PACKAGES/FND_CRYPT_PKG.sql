--------------------------------------------------------
--  DDL for Package FND_CRYPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CRYPT_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPCRYS.pls 115.1 99/07/16 23:09:59 porting sh $ */
  /*
  ** RC4-encrypt the DATASTRING using the KEYSTRING.  The result
  ** is a hexadecimal string representing the encrypted value of
  ** up to NCHARS of the DATASTRING.
  */
  function ENCRYPT(KEYSTRING in varchar2, DATASTRING in varchar2,
                   NCHARS in number)
    return varchar2;

  /*
  ** RC4-decrypt the hexadecimal DATAHEX string using the KEYSTRING.
  ** The reverse of ENCRYPT.  Trailing zeros are stripped from the
  ** return value (on the assumption that they were added during the
  ** ENCRYPT process).
  */
  function DECRYPT(KEYSTRING in varchar2, DATAHEX in varchar2,
                   NCHARS in number)
    return varchar2;

end FND_CRYPT_PKG;

 

/
