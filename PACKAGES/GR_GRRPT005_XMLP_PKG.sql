--------------------------------------------------------
--  DDL for Package GR_GRRPT005_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_GRRPT005_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GRRPT005S.pls 120.1 2007/12/24 12:34:08 nchinnam noship $ */
  P_LANGUAGE_SELECT1 VARCHAR2(40);

  P_LANGUAGE_SELECT2 VARCHAR2(40);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

END GR_GRRPT005_XMLP_PKG;


/
