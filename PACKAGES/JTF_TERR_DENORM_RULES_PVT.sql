--------------------------------------------------------
--  DDL for Package JTF_TERR_DENORM_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_DENORM_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtdrs.pls 120.0 2005/06/02 18:22:43 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_DENORM_RULES_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This packe is used to denormalise the complete territory
--      rules based on tha data setup in the JTF territory tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      12/13/00    JDOCHERT         CREATED
--
--
--    End of Comments
--

PROCEDURE Populate_API(
		  P_ERROR_CODE      OUT NOCOPY  NUMBER
		, P_ERROR_MSG       OUT NOCOPY  VARCHAR2
        , P_SOURCE_ID       IN   NUMBER
        , P_qual_type_ID       IN   NUMBER
	);

END JTF_TERR_DENORM_RULES_PVT;

 

/
