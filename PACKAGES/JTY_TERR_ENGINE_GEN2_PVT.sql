--------------------------------------------------------
--  DDL for Package JTY_TERR_ENGINE_GEN2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TERR_ENGINE_GEN2_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfytses.pls 120.0 2005/08/21 23:07:59 achanda noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TERR_ENGINE_GEN2_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to generate the real time matching SQL
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      07/13/00    ACHANDA         Created
--
--    End of Comments

PROCEDURE gen_real_time_sql (
  p_source_id  IN  NUMBER,
  p_trans_id   IN  NUMBER,
  p_mode       IN  VARCHAR2,
  p_start_date IN  DATE,
  p_end_date   IN  DATE,
  errbuf       OUT NOCOPY VARCHAR2,
  retcode      OUT NOCOPY VARCHAR2
);

END JTY_TERR_ENGINE_GEN2_PVT;

 

/
