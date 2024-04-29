--------------------------------------------------------
--  DDL for Package IGI_IGIRTAUD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGIRTAUD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGIRTAUDS.pls 120.0.12010000.1 2008/07/29 08:59:33 appldev ship $ */
  P_SOB_ID NUMBER;

  P_DATE_LOW varchar2(20);

  P_DATE_HIGH varchar2(20);

  CP_DATE_LOW date;

  CP_DATE_HIGH date;

  P_CONC_REQUEST_ID NUMBER;

  P_CUST_ID VARCHAR2(40);

  P_DEBUG_SWITCH VARCHAR2(1);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END IGI_IGIRTAUD_XMLP_PKG;

/