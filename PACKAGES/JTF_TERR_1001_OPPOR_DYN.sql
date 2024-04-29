--------------------------------------------------------
--  DDL for Package JTF_TERR_1001_OPPOR_DYN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_1001_OPPOR_DYN" AUTHID CURRENT_USER AS
/* $Header: jtfvsods.pls 120.2 2005/09/14 00:08:00 achanda ship $ */
/*===========================================================================+
 |               Copyright (c) 1999 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
+===========================================================================*/
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_1001_OPPOR_DYN
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is used to return a list of winning Territories.
--      The package body is dynamically created when Sales Opportunity Rules
--      are generated.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      12/13/00    JDOCHERT        Created
--
--    End of Comments
--
--*******************************************************
--    Start of Comments
--*******************************************************


PROCEDURE  Search_Terr_Rules( p_Rec             IN          JTF_TERRITORY_PUB.jtf_oppor_bulk_rec_type,
                              x_rec             OUT NOCOPY  JTF_TERRITORY_PUB.winning_bulk_rec_type,
                              p_role            IN          VARCHAR2 := FND_API.G_MISS_CHAR,
                              p_resource_type   IN          VARCHAR2 := FND_API.G_MISS_CHAR);

END JTF_TERR_1001_OPPOR_DYN;

 

/
