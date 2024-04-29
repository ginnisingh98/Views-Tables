--------------------------------------------------------
--  DDL for Package JTY_TERR_ENGINE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TERR_ENGINE_GEN_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfytegs.pls 120.2.12010000.2 2009/03/06 10:18:43 gmarwah ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TERR_ENGINE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to generate the complete territory
--      Engine based on tha data setup in the JTF territory tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      07/17/05    ACHANDA          Created
--
--    End of Comments

TYPE Terr_Package_Spec       IS RECORD
(
    TERR_ID                 NUMBER,
    PACKAGE_COUNT           NUMBER
);
TYPE Terr_PkgSpec_Tbl_Type IS TABLE OF  Terr_Package_Spec INDEX BY BINARY_INTEGER;


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

TYPE terr_change_type IS RECORD (
  terr_id               jtf_terr_number_list  := jtf_terr_number_list(),
  rank_calc_flag        jtf_terr_char_360list := jtf_terr_char_360list(),
  attr_processing_flag  jtf_terr_char_360list := jtf_terr_char_360list(),
  hier_processing_flag  jtf_terr_char_360list := jtf_terr_char_360list(),
  matching_sql_flag     jtf_terr_char_360list := jtf_terr_char_360list(),
  terr_rank             jtf_terr_number_list  := jtf_terr_number_list(),
  parent_terr_id        jtf_terr_number_list  := jtf_terr_number_list(),
  level_from_root       jtf_terr_number_list  := jtf_terr_number_list(),
  num_winners           jtf_terr_number_list  := jtf_terr_number_list(),
  org_id                jtf_terr_number_list  := jtf_terr_number_list(),
  parent_num_winners    jtf_terr_number_list  := jtf_terr_number_list(),
  start_date            jtf_terr_date_list    := jtf_terr_date_list(),
  end_date              jtf_terr_date_list    := jtf_terr_date_list()
);

TYPE qual_prd_tbl_type IS TABLE OF jtf_terr_qtype_usgs_all.qual_relation_product%TYPE;

PROCEDURE gen_rule_engine(ERRBUF       OUT NOCOPY VARCHAR2,
                          RETCODE      OUT NOCOPY VARCHAR2,
                          p_Source_Id  IN         NUMBER,
                          p_mode       IN         VARCHAR2,
                          p_start_date IN         VARCHAR2,
                          p_end_date   IN         VARCHAR2);

PROCEDURE update_resource_person_id(p_terr_id  IN NUMBER);

END JTY_TERR_ENGINE_GEN_PVT;

/
