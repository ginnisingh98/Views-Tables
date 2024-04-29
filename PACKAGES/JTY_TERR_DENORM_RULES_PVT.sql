--------------------------------------------------------
--  DDL for Package JTY_TERR_DENORM_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TERR_DENORM_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfytdrs.pls 120.2.12010000.1 2008/07/24 18:32:26 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TERR_DENORM_RULES_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package is used for the following prposes :
--      a) denormalize the territory hierarchy
--      b) denormalize the territory qualifier values
--      c) calculate absolute rank, number of qualifiers and qual relation product
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/13/05    ACHANDA          CREATED
--
--
--    End of Comments
--

PROCEDURE process_attr_and_rank (
  p_source_id        IN  NUMBER,
  p_mode             IN  VARCHAR2,
  p_terr_change_tab  IN  JTY_TERR_ENGINE_GEN_PVT.terr_change_type,
  errbuf             OUT NOCOPY VARCHAR2,
  retcode            OUT NOCOPY VARCHAR2);

PROCEDURE CREATE_DNMVAL_INDEX (
  p_table_name    IN  VARCHAR2,
  p_source_id     IN  NUMBER,
  p_mode          IN  VARCHAR2,
  x_Return_Status OUT NOCOPY VARCHAR2);

FUNCTION get_level_from_root(p_terr_id IN number) RETURN NUMBER;

END JTY_TERR_DENORM_RULES_PVT;

/
