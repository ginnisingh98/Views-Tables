--------------------------------------------------------
--  DDL for Package JTF_TERR_ENGINE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_ENGINE_GEN_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtegs.pls 120.1 2005/07/02 01:44:57 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_ENGINE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This packe is used to generate the complete territory
--      Engine based on tha data setup in the JTF territory tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      01/27/00    VNEDUNGA         Created
--
--    End of Comments

-- Identifies the Package associated with
-- a territory with child nodes
--
TYPE Terr_Package_Spec       IS RECORD
(
    TERR_ID                 NUMBER,
    PACKAGE_COUNT           NUMBER
);
TYPE Terr_PkgSpec_Tbl_Type         IS TABLE OF  Terr_Package_Spec
                                   INDEX BY BINARY_INTEGER;


TYPE TERR_VALUE_REC_TYPE IS RECORD
(
     COMPARISON_OPERATOR            VARCHAR2(30),
     INCLUDE_FLAG                   VARCHAR2(15),
     QUAL_COL1                      VARCHAR2(30),
     QUAL_COL1_TABLE                VARCHAR2(30),
     QUAL_COL1_ALIAS                VARCHAR2(60),
     PRIM_INT_CDE_COL_ALIAS         VARCHAR2(60),
     SEC_INT_CDE_COL_ALIAS          VARCHAR2(60),
     LOW_VALUE_CHAR                 VARCHAR2(60),
     HIGH_VALUE_CHAR                VARCHAR2(60),
     LOW_VALUE_NUMBER               NUMBER,
     HIGH_VALUE_NUMBER              NUMBER,
     INTEREST_TYPE_ID               NUMBER,
     PRIMARY_INTEREST_CODE_ID       NUMBER,
     SECONDARY_INTEREST_CODE_ID     NUMBER,
     DISPLAY_TYPE                   VARCHAR2(40),
     CONVERT_TO_ID_FLAG             VARCHAR2(1),
     ID_USED_FLAG                   VARCHAR2(01),
     CURRENCY_CODE                  VARCHAR2(10),
     LOW_VALUE_CHAR_ID              NUMBER
);


PROCEDURE Generate_API(ERRBUF                 OUT NOCOPY    VARCHAR2,
                         RETCODE              OUT NOCOPY    VARCHAR2,
                         p_Source_Id          IN     NUMBER, --may want to pass the source Id to make things faster
                         p_Qualifier_Type_Id  IN     NUMBER,
                         p_Record_Limit       IN     NUMBER DEFAULT 100,
                         p_Debug_Flag         IN     VARCHAR2,
                         p_SQL_Trace          IN     VARCHAR2);

FUNCTION  Build_Rule_Expression(p_Terr_Id       IN NUMBER,
                                p_Start_Date    IN DATE,
                                p_End_Date      IN DATE)
return  BOOLEAN;

-- Package spec
END JTF_TERR_ENGINE_GEN_PVT;

/
