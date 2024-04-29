--------------------------------------------------------
--  DDL for Package FND_CRYPTO_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CRYPTO_CONSTANTS" AUTHID CURRENT_USER AS
/* $Header: AFSOCCNS.pls 120.0 2005/09/24 00:26:36 jnurthen noship $ */

-- Character Masks for random Strings
  ASCII_MASK     CONSTANT VARCHAR2(255)    :=
    '!"#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]\^_`abcdefghijklmnopqrstuvwxyz{|}~';
  ALPHANUMERIC_MASK      CONSTANT VARCHAR2(255)    :=
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  ALPHANUMERIC_UPPER_MASK CONSTANT VARCHAR2(255) :=
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  ALPHABETIC_UPPER_MASK CONSTANT VARCHAR2(255) :=
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  ALPHABETIC_MASK CONSTANT VARCHAR2(255) :=
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  DB_MASK            CONSTANT VARCHAR2(255)    :=
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_$#';
  DB_SPECIAL_MASK  CONSTANT VARCHAR2(255)     :=
    '!$%()*+,-./0123456789:;<=>?''@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]\^_`abcdefghijklmnopqrstuvwxyz{|}~';

END fnd_crypto_constants;

 

/
