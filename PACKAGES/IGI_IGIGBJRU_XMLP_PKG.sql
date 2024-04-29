--------------------------------------------------------
--  DDL for Package IGI_IGIGBJRU_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGIGBJRU_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGIGBJRUS.pls 120.0.12010000.1 2008/07/29 08:58:00 appldev ship $ */
  P_SOB NUMBER;

  P_BE_BATCH NUMBER;

  P_FLEXDATA VARCHAR2(600);

  P_COA VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER;

  P_RUN_AOL VARCHAR2(1);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

END IGI_IGIGBJRU_XMLP_PKG;

/