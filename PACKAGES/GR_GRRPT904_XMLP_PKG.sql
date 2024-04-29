--------------------------------------------------------
--  DDL for Package GR_GRRPT904_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_GRRPT904_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GRRPT904S.pls 120.0 2007/12/24 12:39:49 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  PROCEDURE GR_GRRPT904_XMLP_PKG_HEADER;

END GR_GRRPT904_XMLP_PKG;


/
