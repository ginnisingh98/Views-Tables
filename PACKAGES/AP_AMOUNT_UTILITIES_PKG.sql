--------------------------------------------------------
--  DDL for Package AP_AMOUNT_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_AMOUNT_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: apamtuts.pls 120.4 2004/10/27 01:26:26 pjena noship $ */

  FUNCTION ap_convert_number(in_numeral IN NUMBER) RETURN VARCHAR2;
END AP_AMOUNT_UTILITIES_PKG;

 

/
