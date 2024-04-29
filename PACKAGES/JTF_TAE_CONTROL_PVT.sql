--------------------------------------------------------
--  DDL for Package JTF_TAE_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TAE_CONTROL_PVT" AUTHID CURRENT_USER AS
/* $Header: jtftaecs.pls 120.0 2005/06/02 18:21:10 appldev ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_CONTROL_PUB
--    ---------------------------------------------------
--    PURPOSE
--
--      Control Packages for JTF_TERR_AE packages.
--          Analyses territory data before calling
--          mass assignment cursor generator.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is for public use
--
--    HISTORY
--      02/10/2002  EIHSU           Created.
--      02/12/2002  EIHSU           Add AE CONTROL
--                                  build_qual_rel_multiple
--      03/13/2002  EIHSU           Add source parameter
--
--    REQIRES / DEPENDENCIES
--
--    MODIFIES
--
--    EFFECTS
--

G_DEBUG   BOOLEAN  := FALSE;

PROCEDURE Write_Log(which number, mssg  varchar2 );

PROCEDURE set_table_nologging( p_table_name VARCHAR2 );

PROCEDURE set_session_parameters ( p_sort_area_size     NUMBER
                                 , p_hash_area_size     NUMBER );

PROCEDURE Decompose_Terr_Defns
   (p_Api_Version_Number     IN  NUMBER,
    p_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
    p_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_Return_Status          OUT NOCOPY VARCHAR2,
    x_Msg_Count              OUT NOCOPY NUMBER,
    x_Msg_Data               OUT NOCOPY VARCHAR2,
    p_run_mode               IN  VARCHAR2     := 'FULL',
    p_classify_terr_comb     IN  VARCHAR2     := 'Y',
    p_process_tx_oin_sel     IN  VARCHAR2     := 'Y',
    p_generate_indexes       IN  VARCHAR2     := 'Y',
    p_source_id              IN  NUMBER,
    p_trans_id               IN  NUMBER,
    ERRBUF                   OUT NOCOPY VARCHAR2,
    RETCODE                  OUT NOCOPY VARCHAR2 );

END JTF_TAE_CONTROL_PVT;


 

/
