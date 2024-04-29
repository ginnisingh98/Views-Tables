--------------------------------------------------------
--  DDL for Package MRP_MRPRUSUR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_MRPRUSUR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: MRPRUSURS.pls 120.2 2007/12/25 08:36:30 nchinnam noship $ */
  P_ORG_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END MRP_MRPRUSUR_XMLP_PKG;


/
