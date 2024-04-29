--------------------------------------------------------
--  DDL for Package Body IGI_IGIGBHRB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGIGBHRB_XMLP_PKG" AS
/* $Header: IGIGBHRBB.pls 120.0.12010000.1 2008/07/29 08:57:42 appldev ship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_RUN_AOL = 'Y' THEN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END IF;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BeforeReport RETURN BOOLEAN IS
  BEGIN
    IF P_RUN_AOL = 'Y' THEN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END IF;
    RETURN (TRUE);
  END BeforeReport;

END IGI_IGIGBHRB_XMLP_PKG;

/
