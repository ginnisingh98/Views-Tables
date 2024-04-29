--------------------------------------------------------
--  DDL for Package Body GR_GRRPT908_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_GRRPT908_XMLP_PKG" AS
/* $Header: GRRPT908B.pls 120.0 2007/12/24 12:40:12 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREREPORT;

  PROCEDURE GR_GRRPT908_XMLP_PKG_HEADER IS
  BEGIN
    NULL;
  END GR_GRRPT908_XMLP_PKG_HEADER;

END GR_GRRPT908_XMLP_PKG;



/
