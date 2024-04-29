--------------------------------------------------------
--  DDL for Package HZ_PHONE_NUMBER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PHONE_NUMBER_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPHNMS.pls 120.1 2005/06/16 21:14:16 jhuang noship $ */

  FUNCTION transpose (
          p_phone_number  IN      VARCHAR2)
  RETURN VARCHAR2;

END HZ_PHONE_NUMBER_PKG;

 

/
