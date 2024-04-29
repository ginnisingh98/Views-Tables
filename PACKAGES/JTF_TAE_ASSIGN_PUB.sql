--------------------------------------------------------
--  DDL for Package JTF_TAE_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TAE_ASSIGN_PUB" AUTHID CURRENT_USER AS
/* $Header: jtftaeas.pls 120.0 2005/06/02 18:21:09 appldev ship $ */
---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_ASSIGN_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force applications territory manager public api's.
--      This package is a public API for getting winning territories
--      or territory resources using an input objects table as an assignment
--      target.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      03/22/2002  EIHSU    CREATED
--

-- ***************************************************
--    GLOBAL VARIABLES and RECORD TYPE DEFINITIONS
-- ***************************************************


    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : Get_Winners
    --    type           : public.
    --    function       : For all Territory Assignment request purposes.
    --    pre-reqs       : Territories needs to be setup first
    --    notes:              Generic public API for retreving any of the following
    --                        * Winning Resource Id's
    --                        * Winning Resource Names + Details
    --                        * Winning terr_id's
    --
    PROCEDURE get_winners
    (   p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        x_return_status         OUT NOCOPY         VARCHAR2,
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        p_request_id            IN          NUMBER,
        p_source_id             IN          NUMBER,
        p_trans_object_type_id  IN          NUMBER,
        p_target_type           IN          VARCHAR2 := 'TAP',
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
    );


    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : Drop_TAE_TRANS_Indexes
    --    type           : public.
    --    function       : Drop_TAE_TRANS_Indexes
    --    pre-reqs       :
    --    notes:
    --
    PROCEDURE Drop_TAE_TRANS_Indexes
    (   p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        x_return_status         OUT NOCOPY         VARCHAR2,
        p_source_id             IN          NUMBER,
        p_trans_object_type_id  IN          NUMBER,
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
    );

    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : NM_TABLE_TRUNCATE_DROP_INDEX
    --    type           : public.
    --    function       : NM_TABLE_TRUNCATE_DROP_INDEX
    --    pre-reqs       :
    --    notes: BELOW API for NEW MODE TAP
    --

    PROCEDURE NM_TABLE_TRUNCATE_DROP_INDEX
    (   p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        p_table_name            IN          VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
    );


    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : FETCH_NM_REASSIGN_TRANS
    --    type           : public.
    --    function       : FETCH_NM_REASSIGN_TRANS
    --    pre-reqs       :
    --    notes          :
    --

    PROCEDURE FETCH_NM_REASSIGN_TRANS (
        p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        p_destination_table     IN          VARCHAR2,
        p_source_id             IN       NUMBER,
        p_qual_type_id          IN       NUMBER,
        p_request_id            IN       NUMBER,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
        );

    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : DELETE_CHANGED_TERR_RECS
    --    type           : public.
    --    function       : DELETE_CHANGED_TERR_RECS
    --    pre-reqs       :
    --    notes          :
    --

    PROCEDURE DELETE_CHANGED_TERR_RECS (
        p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        p_request_id             IN          VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
        );

    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : --
    --    type           : public.
    --    function       : --
    --    pre-reqs       :
    --    notes: BELOW API for MULTI-NUM MULTI-LEVEL PROCESSING
    --
    PROCEDURE Process_Level_Winners (
        p_terr_LEVEL_target_tbl  IN       VARCHAR2,
        p_terr_PARENT_LEVEL_tbl  IN       VARCHAR2,
        p_UPPER_LEVEL_FROM_ROOT  IN       NUMBER,
        p_LOWER_LEVEL_FROM_ROOT  IN       NUMBER,
        p_matches_target         IN       VARCHAR2,
        p_source_id              IN       NUMBER,
        p_qual_type_id           IN       NUMBER,
        x_return_status        OUT NOCOPY         VARCHAR2,
        p_worker_id              IN       NUMBER := 1
        );

    PROCEDURE Process_Final_Level_Winners (
        p_terr_LEVEL_target_tbl  IN       VARCHAR2,
        p_terr_L5_target_tbl     IN       VARCHAR2,
        p_matches_target         IN       VARCHAR2,
        p_source_id              IN       NUMBER,
        p_qual_type_id           IN       NUMBER,
        x_return_status        OUT NOCOPY         VARCHAR2,
        p_worker_id              IN       NUMBER := 1
        );

    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : Get_SQL_For_Changes
    --    type           : public.
    --    function       : Get_SQL_For_Changes
    --    pre-reqs       :
    --    notes:
    --
    PROCEDURE Get_SQL_For_Changes (
        p_source_id            IN       NUMBER,
        p_trans_object_type_id IN       NUMBER,
        p_view_name            IN       VARCHAR2,
        x_return_status        OUT NOCOPY         VARCHAR2,
        p_sql                  OUT NOCOPY       JTF_TAE_GEN_PVT.terrsql_tbl_type,
        x_msg_count            OUT NOCOPY         NUMBER,
        x_msg_data             OUT NOCOPY         VARCHAR2,
        ERRBUF                 OUT NOCOPY         VARCHAR2,
        RETCODE                OUT NOCOPY         VARCHAR2
        );


    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : Clear_trans_data
    --    type           : public.
    --    function       : Truncate Trans Table, and Drop_TAE_TRANS_Indexes
    --    pre-reqs       :
    --    notes:
PROCEDURE Clear_Trans_Data
    (   p_api_version_number    IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
        p_SQL_Trace             IN          VARCHAR2,
        p_Debug_Flag            IN          VARCHAR2,
        x_return_status         OUT NOCOPY         VARCHAR2,
        p_source_id             IN          NUMBER,
        p_trans_object_type_id  IN          NUMBER,
        --ARPATEL 09/12/2003
        p_target_type           IN          VARCHAR2 := 'TAP',
        x_msg_count             OUT NOCOPY         NUMBER,
        x_msg_data              OUT NOCOPY         VARCHAR2,
        ERRBUF                  OUT NOCOPY         VARCHAR2,
        RETCODE                 OUT NOCOPY         VARCHAR2
    );

    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : GET_WINNERS_PARALLEL_SETUP
    --    type           : public.
    --    function       :
    --    pre-reqs       :
    --    notes:
    --
PROCEDURE get_winners_parallel_setup
    ( p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
      p_SQL_Trace             IN          VARCHAR2,
      p_Debug_Flag            IN          VARCHAR2,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_request_id            IN          NUMBER,
      p_source_id             IN          NUMBER,
      p_trans_object_type_id  IN          NUMBER,
      p_target_type           IN          VARCHAR2 := 'TAP',
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2
    );


    -- ***************************************************
    --    API Specifications
    -- ***************************************************
    --    api name       : GET_WINNERS_PARALLEL
    --    type           : public.
    --    function       :
    --    pre-reqs       :
    --    notes:  API designed to be called from multiple sessions
    --            to parallel process assignment of transactions to territories
    --
PROCEDURE GET_WINNERS_PARALLEL
    ( p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
      p_SQL_Trace             IN          VARCHAR2,
      p_Debug_Flag            IN          VARCHAR2,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_request_id            IN          NUMBER,
      p_source_id             IN          NUMBER,
      p_trans_object_type_id  IN          NUMBER,
      p_target_type           IN          VARCHAR2 := 'TAP',
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2,
      p_worker_id             IN          NUMBER := 1,
      p_total_workers         IN          NUMBER
    );

END JTF_TAE_ASSIGN_PUB;


 

/
