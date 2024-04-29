--------------------------------------------------------
--  DDL for Package Body GML_ITEM_AUTOLOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_ITEM_AUTOLOT" AS
/* $Header: GMLATLTB.pls 115.1 2003/05/06 16:08:46 pbamb noship $ */

  /*##########################################################################
  #
  #  FUNCTION
  #   item_autolot_enabled
  #
  #  DESCRIPTION
  #
  #      This package contains a function which determines
  #	 whether opm item is autlot active or not
  # 	 The Zeroth version of the package function will
  #      return FALSE indicating that item is not autlot
  #      enabled and the next version will return check
  #      ic_item_mst indicating that item is autolot active
  #
  # MODIFICATION HISTORY
  # 05-MAY-2003  PBamb Created
  #########################################################################*/

FUNCTION item_autolot_enabled(P_item_id IN NUMBER) RETURN BOOLEAN IS

Cursor Cr_autolot IS
Select	AUTOLOT_ACTIVE_INDICATOR
From	ic_item_mst
Where	item_id = p_item_id;

v_autolot_active NUMBER;

BEGIN
	Open  Cr_autolot;
	Fetch Cr_autolot into v_autolot_active;
	If Cr_autolot%NOTFOUND THEN
	  Close Cr_autolot;
	  RETURN FALSE;
	ELSE
	  Close Cr_autolot;
	  IF v_autolot_active = 1 THEN
	     RETURN TRUE;
	  ELSE
	     RETURN FALSE;
	  END IF;
	END IF;

EXCEPTION
 WHEN OTHERS THEN
   RETURN (FALSE);

END item_autolot_enabled ;

END GML_ITEM_AUTOLOT;

/
