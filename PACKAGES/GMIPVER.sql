--------------------------------------------------------
--  DDL for Package GMIPVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIPVER" AUTHID CURRENT_USER as
/* $Header: GMIPVERS.pls 115.0 2002/08/01 21:48:47 jsrivast noship $          */

/* ========================================================
   This package would be used to ascertain the OPM 11i
   patchset level.
   ======================================================== */
/* ========================================================
   This function would be return OPM 11i family pack on the
   installation .
   Returns:
	   0 -- Base 11i or undetermined
	   1 -- 11i.GMI.A
	   2--  11i.GMI.B
	   3--  11i.GMI.C
	   4--  11i.GMI.D
	   5--  11i.GMI.E
	   6--  11i.GMI.F
	   7--  11i.GMI.G
	   8--  11i.GMI.H
	   9--  11i.GMI.I
	  10--  11i.GMI.J
	  11--  11i.GMI.K
	  12--  11i.GMI.L
	  13--  11i.GMI.M
	  14--  11i.GMI.N
	  15--  11i.GMI.O
   ======================================================== */

FUNCTION get_opm_11i_family_pack RETURN NUMBER;

END GMIPVER;

 

/
