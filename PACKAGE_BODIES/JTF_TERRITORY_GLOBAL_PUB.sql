--------------------------------------------------------
--  DDL for Package Body JTF_TERRITORY_GLOBAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERRITORY_GLOBAL_PUB" AS
/* $Header: jtfxstrb.pls 120.0.12010000.2 2009/06/18 10:26:27 ppillai ship $ */
--    ---------------------------------------------------
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
--      12/01/99    VNEDUNGA        Changing the FND_PROFILE call
--      12/02/99    VNEDUNGA        Changing the reset function to return TRUE
--                                  Add the code to store TERR_NAME is PL/SQL table
--      02/24/00    VNEDUNGA        Overloading add record for the new Terr Engine
--      09/17/00    JDOCHERT        BUG#1408610 FIX +
--                                  remove obsolete overloaded Add_Record procedure
--
--
--
--    End of Comments
--
-- ------------------------------------------------------
-- Global Variables
-- ------------------------------------------------------
--Bug 8582900
--G_Profile_Value VARCHAR2(25) := FND_PROFILE.Value('JTF_TERR_NO_OF_WINNERS');

--*******************************************************
--    Start of Comments
--*******************************************************

/* Reset global variables:
** for each call to Get_Winning_Territory_Members API
*/
FUNCTION   Reset return BOOLEAN
AS
BEGIN

     /* reset number of winners for a
     ** top-level territory node
     ** JDOCHERT 09/17: BUG#1408610 FIX
     */
     g_num_winners := 0;

     /* Reset the global index */
     g_TblIndex := 1;

     /* Reset contents of PL/SQL table */
     G_WinningTerr_Tbl.Delete;

     return TRUE;

END  Reset;

/* Return the count of the winning Terr Table */
FUNCTION   get_RecordCount return NUMBER
as
BEGIN
     return G_WinningTerr_Tbl.Count;
END Get_RecordCount;


/* Add record to table of winners for the Territory Assignment Engine */
PROCEDURE  Add_Record( p_WinningTerr_Rec   IN  JTF_TERRITORY_PUB.WinningTerr_rec_type,
                       p_Number_Of_Winners IN  NUMBER,
                       X_Return_Status     OUT NOCOPY VARCHAR2)
AS
BEGIN

    /* Store winning territory record */
    If (p_WinningTerr_Rec.TERR_ID IS NOT NULL) THEN

       G_WinningTerr_Tbl(G_TblIndex).PARTY_ID                 := g_PARTY_ID;
       G_WinningTerr_Tbl(G_TblIndex).PARTY_SITE_ID            := g_PARTY_SITE_ID;
       G_WinningTerr_Tbl(G_TblIndex).TERR_ID                  := p_WinningTerr_Rec.TERR_ID;
       G_WinningTerr_Tbl(G_TblIndex).TERR_NAME                := p_WinningTerr_Rec.TERR_NAME;
       G_WinningTerr_Tbl(G_TblIndex).RANK                     := p_WinningTerr_Rec.RANK;
       G_WinningTerr_Tbl(G_TblIndex).ORG_ID                   := p_WinningTerr_Rec.ORG_ID;
       G_WinningTerr_Tbl(G_TblIndex).PARENT_TERRITORY_ID      := p_WinningTerr_Rec.PARENT_TERRITORY_ID;
       G_WinningTerr_Tbl(G_TblIndex).TEMPLATE_TERRITORY_ID    := p_WinningTerr_Rec.TEMPLATE_TERRITORY_ID;
       G_WinningTerr_Tbl(G_TblIndex).ESCALATION_TERRITORY_ID  := p_WinningTerr_Rec.ESCALATION_TERRITORY_ID;

       /* Set the status to SUCCESS */
       X_Return_Status :=     FND_API.G_RET_STS_SUCCESS;

       -- Increment the index, if the profile is set to multiple winners
       --If NVL(G_Profile_Value, 'SINGLE') = 'MULTIPLE' Then
       --   g_TblIndex := g_TblIndex + 1;
       --End If;

       /* Increment the index, if the profile is set to multiple winners */
       IF (p_number_of_winners > 1) THEN

          g_TblIndex := g_TblIndex + 1;

          /* track number of winners for a territory node at the
          ** top-level (directly below the Catch_all) in the
          ** territory hierarchy
          ** JDOCHERT 09/17: BUG#1408610 FIX
          */
          g_num_winners := g_num_winners + 1;

       END IF;

    Else
       X_Return_Status :=    FND_API.G_RET_STS_ERROR ;
    END If;

END Add_Record;


END JTF_TERRITORY_GLOBAL_PUB;

/
