--------------------------------------------------------
--  DDL for Package JTY_TAE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TAE_GEN_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfytaes.pls 120.0 2005/08/21 23:07:54 achanda noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TAE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to generate batch matching SQLs for all qualifier combinations
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      07/25/05    ACHANDA         Created
--
--    End of Comments

PROCEDURE gen_batch_sql (
  p_source_id       IN NUMBER,
  p_trans_id        IN NUMBER,
  p_mode            IN VARCHAR2,
  p_qual_prd_tbl    IN JTY_TERR_ENGINE_GEN_PVT.qual_prd_tbl_type,
  x_Return_Status   OUT NOCOPY VARCHAR2,
  x_Msg_Count       OUT NOCOPY NUMBER,
  x_Msg_Data        OUT NOCOPY VARCHAR2,
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2);

END JTY_TAE_GEN_PVT;

 

/
