--------------------------------------------------------
--  DDL for Package JTF_TAE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TAE_GEN_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtaes.pls 120.0 2005/06/02 18:22:35 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This packe is used to generate the complete territory
--      Engine based on tha data setup in the JTF TAE tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      02/25/02    SBEHERA         Created
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

  TYPE terr_sql_typ is record (
        terr_id     number,
        terr_sql       varchar2(32767));
   TYPE Terrsql_tbl_type   IS TABLE OF   terr_sql_typ
        INDEX BY BINARY_INTEGER;


PROCEDURE Generate_API(ERRBUF                 OUT NOCOPY    VARCHAR2,
                         RETCODE              OUT NOCOPY    VARCHAR2,
                         p_source_id             IN       NUMBER,
                         p_trans_object_type_id IN     NUMBER,
                         p_target_type        IN     VARCHAR2,
                         p_Debug_Flag         IN     VARCHAR2,
                         p_SQL_Trace          IN     VARCHAR2);


PROCEDURE gen_details_for_terr_change (
      p_source_id             IN       NUMBER,
      p_qual_type_id        IN       NUMBER,
      p_view_name           IN       VARCHAR2,
      p_sql                 OUT  NOCOPY terrsql_tbl_type
      );

--ARPATEL bug#3194930 fix
PROCEDURE write_buffer_content(
      l_qual_rules   VARCHAR2
   );

-- Package spec
END JTF_TAE_GEN_PVT;

 

/
