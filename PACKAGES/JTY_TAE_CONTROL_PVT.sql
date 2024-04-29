--------------------------------------------------------
--  DDL for Package JTY_TAE_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TAE_CONTROL_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfyaecs.pls 120.1 2006/03/30 17:27:13 achanda noship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TAE_CONTROL_PVT
--    ---------------------------------------------------
--    PURPOSE
--
--      Analyses territory data before calling mass assignment cursor generator.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is for public use
--
--    HISTORY
--      06/10/2005  ACHANDA         Created.
--
--    REQIRES / DEPENDENCIES
--
--    MODIFIES
--
--    EFFECTS
--

PROCEDURE set_table_nologging( p_table_name VARCHAR2 );

PROCEDURE Decompose_Terr_Defns
( p_Api_Version_Number     IN  NUMBER,
  p_Init_Msg_List          IN  VARCHAR2,
  p_trans_target           IN  VARCHAR2,
  p_classify_terr_comb     IN  VARCHAR2,
  p_process_tx_oin_sel     IN  VARCHAR2,
  p_generate_indexes       IN  VARCHAR2,
  p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  p_program_name           IN  VARCHAR2,
  p_mode                   IN  VARCHAR2,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2,
  ERRBUF                   OUT NOCOPY VARCHAR2,
  RETCODE                  OUT NOCOPY VARCHAR2 );

PROCEDURE delete_combinations
( p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  p_mode                   IN  VARCHAR2,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2,
  ERRBUF                   OUT NOCOPY VARCHAR2,
  RETCODE                  OUT NOCOPY VARCHAR2 );

PROCEDURE Classify_Territories
( p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  p_mode                   IN  VARCHAR2,
  p_qual_prd_tbl           IN  JTY_TERR_ENGINE_GEN_PVT.qual_prd_tbl_type,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2,
  ERRBUF                   OUT NOCOPY VARCHAR2,
  RETCODE                  OUT NOCOPY VARCHAR2 );

PROCEDURE Classify_dea_Territories
( p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  p_qual_prd_tbl           IN  JTY_TERR_ENGINE_GEN_PVT.qual_prd_tbl_type,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2,
  ERRBUF                   OUT NOCOPY VARCHAR2,
  RETCODE                  OUT NOCOPY VARCHAR2 );

PROCEDURE reduce_dnmval_idx_set
( p_source_id              IN  NUMBER,
  p_mode                   IN VARCHAR2,
  x_Return_Status          OUT NOCOPY VARCHAR2);

PROCEDURE reduce_deaval_idx_set
( p_source_id              IN  NUMBER,
  x_Return_Status          OUT NOCOPY VARCHAR2);
END JTY_TAE_CONTROL_PVT;

 

/
