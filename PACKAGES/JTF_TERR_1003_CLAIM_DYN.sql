--------------------------------------------------------
--  DDL for Package JTF_TERR_1003_CLAIM_DYN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_1003_CLAIM_DYN" AUTHID CURRENT_USER AS
/* $Header: jtfvtcds.pls 120.2 2005/09/14 00:17:18 achanda ship $ */

--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_1003_CLAIM_DYN
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is used to return a list of winning Resources.
--      The package body is dynamically created when DEMS Rules
--      are generated.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      07/23/01    ARPATEL        Created
--
--    End of Comments
--
--*******************************************************
--    Start of Comments
--*******************************************************

PROCEDURE  Search_Terr_Rules( p_Rec                 IN          JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type,
                              x_rec                 OUT NOCOPY  JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type,
                              p_role                IN          VARCHAR2 := FND_API.G_MISS_CHAR,
                              p_resource_type       IN          VARCHAR2 := FND_API.G_MISS_CHAR
);

END JTF_TERR_1003_CLAIM_DYN;

 

/
