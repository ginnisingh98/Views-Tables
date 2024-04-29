--------------------------------------------------------
--  DDL for Package Body IGI_IGIGBIPB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGIGBIPB_XMLP_PKG" AS
/* $Header: IGIGBIPBB.pls 120.0.12010000.1 2008/07/29 08:57:48 appldev ship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_RUN_AOL = 'Y' THEN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END IF;
    RETURN (TRUE);
  END AFTERREPORT;

   FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_RUN_AOL = 'Y' THEN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION P_RUN_AOLVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_RUN_AOLVALIDTRIGGER;

  FUNCTION P_FLEXDATAVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_FLEXDATAVALIDTRIGGER;

END IGI_IGIGBIPB_XMLP_PKG;

/
