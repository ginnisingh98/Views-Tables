--------------------------------------------------------
--  DDL for Package IGI_IGIGBPCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGIGBPCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGIGBPCRS.pls 120.0.12010000.1 2008/07/29 08:58:03 appldev ship $ */
  P_SOB_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER := 0;

  P_DEBUG_SWITCH VARCHAR2(1);

  P_RUN_AOL VARCHAR2(1);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END IGI_IGIGBPCR_XMLP_PKG;

/
