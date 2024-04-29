--------------------------------------------------------
--  DDL for Package GR_GRRPT908_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_GRRPT908_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GRRPT908S.pls 120.0 2007/12/24 12:41:36 nchinnam noship $ */
  P_1 NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  PROCEDURE GR_GRRPT908_XMLP_PKG_HEADER;

END GR_GRRPT908_XMLP_PKG;



/
