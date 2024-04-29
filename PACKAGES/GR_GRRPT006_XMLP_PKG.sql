--------------------------------------------------------
--  DDL for Package GR_GRRPT006_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_GRRPT006_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GRRPT006S.pls 120.0 2007/12/24 12:34:48 nchinnam noship $ */
  P_LANGUAGE_SELECT1 VARCHAR2(40);

  P_LANGUAGE_SELECT2 VARCHAR2(40);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

END GR_GRRPT006_XMLP_PKG;


/
