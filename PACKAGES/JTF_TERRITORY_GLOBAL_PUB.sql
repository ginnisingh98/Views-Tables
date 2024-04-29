--------------------------------------------------------
--  DDL for Package JTF_TERRITORY_GLOBAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERRITORY_GLOBAL_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfxstrs.pls 120.0 2005/06/02 18:23:20 appldev ship $ */
/*===========================================================================+
 |               Copyright (c) 1999 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
+===========================================================================*/
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_GLOBAL_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is used to return a list of winning Territories.
--      Reason to go with this approach is because of limitation in
--      pl/sql wrt binding user defined data types to return a list
--      of winning Territories
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/09/99    VNEDUNGA        Created
--      02/24/00    VNEDUNGA        Overloading add record for the new
--                                  Terr Engine
--      09/15/00    jdochert        BUG#1408610 FIX
--      09/15/00    jdochert        Removed obsolete overloaded Add_Record procedure
--                                  that had 2 parameters
--
--    End of Comments
--
--*******************************************************
--    Start of Comments
--*******************************************************
-- Store the winning territory records
G_WinningTerr_Tbl       JTF_TERRITORY_PUB.WinningTerr_Tbl_type;

-- Current table location pointer
g_TblIndex              NUMBER  := 1;

/* JDOCHERT 09/15: BUG#1408610 FIX */
g_num_winners              NUMBER  := 0;


/* JDOCHERT 11/10 */
g_party_id                  NUMBER;
g_party_site_id             NUMBER;

-- Resets the table
FUNCTION   reset return BOOLEAN;


FUNCTION   get_RecordCount return NUMBER;

/* Add record to the global table */
PROCEDURE  Add_Record( p_WinningTerr_Rec   IN  JTF_TERRITORY_PUB.WinningTerr_rec_type,
                       p_Number_Of_Winners IN  NUMBER,
                       X_Return_Status     OUT NOCOPY VARCHAR2);

END JTF_TERRITORY_GLOBAL_PUB;

 

/
