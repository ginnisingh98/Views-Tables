--------------------------------------------------------
--  DDL for Package FND_HASH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_HASH_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPHSHS.pls 115.4 2002/02/08 19:46:24 nbhambha ship $ */

  /*
  ** XOR two numbers
  */
  function XOR32(B1 in number, B2 in number)
    return number;

  /*
  ** Compute CRC-32 for a string
  */
  function CRC32(DATASTRING in varchar2)
    return number;

end FND_HASH_PKG;

 

/
