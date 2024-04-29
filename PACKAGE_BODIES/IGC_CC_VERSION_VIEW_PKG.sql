--------------------------------------------------------
--  DDL for Package Body IGC_CC_VERSION_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_VERSION_VIEW_PKG" AS
/*$Header: IGCCVVWB.pls 120.2.12000000.1 2007/08/20 12:15:01 mbremkum ship $*/

/*=======================================================================+
 |                       PROCEDURE Initialize_View                       |
 +=======================================================================*/

PROCEDURE Initialize_View (p_version_num   IN NUMBER) IS

  BEGIN
    g_version_num := p_version_num;
  END Initialize_View;

/*=======================================================================+
 |                       PROCEDURE Get_Version_Num                       |
 +=======================================================================*/

FUNCTION Get_Version_Num RETURN NUMBER IS

  BEGIN
     Return g_version_num;
  END Get_Version_Num;

/* ----------------------------------------------------------------------- */

END IGC_CC_VERSION_VIEW_PKG;

/
