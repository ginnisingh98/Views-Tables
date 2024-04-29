--------------------------------------------------------
--  DDL for Package Body GML_PO_FOR_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_FOR_PROCESS" AS
/* $Header: GMLPOPRB.pls 120.1 2005/09/30 13:41:49 pbamb noship $ */

  /*##########################################################################
  #
  #  FUNCTION
  #   check_po_for_proc
  #
  #  DESCRIPTION
  #
  #      This package contains a function which determines
  #	 whether Common Receiving is installed in db or not
  # 	 The 1st  version of the package function will
  #      return FALSE indicating that Common Receiving is
  #      not installed and the next version will return
  #       TRUE indicating that Common Receiving is installed
  #
  # MODIFICATION HISTORY
  # 08-AUG-2001  PBamb Created
  #########################################################################*/

FUNCTION check_po_for_proc RETURN BOOLEAN IS

BEGIN

         RETURN (TRUE);

EXCEPTION
 WHEN OTHERS THEN
   RETURN (FALSE);

END check_po_for_proc ;

END GML_PO_FOR_PROCESS;

/
