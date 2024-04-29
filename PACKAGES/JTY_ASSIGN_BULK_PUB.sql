--------------------------------------------------------
--  DDL for Package JTY_ASSIGN_BULK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_ASSIGN_BULK_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfyaeas.pls 120.1.12010000.4 2009/04/08 12:47:29 ppillai ship $ */
---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_ASSIGN_BULK_PUB
--    ---------------------------------------------------
--    PURPOSE
--      This package is a public API for getting winning territories
--      or territory resources for bulk transaction objects
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/22/2005  achanda    CREATED
--

-- ***************************************************
--    GLOBAL VARIABLES and RECORD TYPE DEFINITIONS
-- ***************************************************


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
      p_terr_LEVEL_target_tbl  IN          VARCHAR2,
      p_terr_PARENT_LEVEL_tbl  IN          VARCHAR2,
      p_UPPER_LEVEL_FROM_ROOT  IN          NUMBER,
      p_LOWER_LEVEL_FROM_ROOT  IN          NUMBER,
      p_matches_target         IN          VARCHAR2,
      p_source_id              IN          NUMBER,
      p_run_mode               IN          VARCHAR2,
      p_date_effective         IN          BOOLEAN,
      x_return_status          OUT NOCOPY  VARCHAR2,
      p_worker_id              IN          NUMBER);

PROCEDURE Process_Final_Level_Winners (
    p_terr_LEVEL_target_tbl  IN         VARCHAR2,
    p_terr_L5_target_tbl     IN         VARCHAR2,
    p_matches_target         IN         VARCHAR2,
    p_source_id              IN         NUMBER,
    p_run_mode               IN         VARCHAR2,
    p_date_effective         IN         BOOLEAN,
    x_return_status          OUT NOCOPY VARCHAR2,
    p_worker_id              IN         NUMBER);


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : collect_trans_data
--    type           : public.
--    function       :
--    pre-reqs       :
--    notes:  API designed to insert transaction objects into TRANS table
--            for "TOTAL", "INCREMENTAL" and "DATE EFFECTIVE" mode.
--
PROCEDURE collect_trans_data
    ( p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
      p_source_id             IN          NUMBER,
      p_trans_id              IN          NUMBER,
      p_program_name          IN          VARCHAR2,
      p_mode                  IN          VARCHAR2,
      p_where                 IN          VARCHAR2,
      p_no_of_workers         IN          NUMBER,
      p_percent_analyzed      IN          NUMBER,
      p_request_id            IN          NUMBER,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2,
      p_oic_mode              IN          VARCHAR2 DEFAULT 'NOOIC'
    );

-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : get_winners
--    type           : public.
--    function       :
--    pre-reqs       :
--    notes:  API designed to get the winning territories for the
--            transaction objs, it supports multiple worker architecture
--
PROCEDURE get_winners
    ( p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
      p_source_id             IN          NUMBER,
      p_trans_id              IN          NUMBER,
      p_program_name          IN          VARCHAR2,
      p_mode                  IN          VARCHAR2,
      p_percent_analyzed      IN          NUMBER,
      p_worker_id             IN          NUMBER,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2,
      p_oic_mode              IN          VARCHAR2 DEFAULT 'NOOIC',
	  p_terr_id               IN          NUMBER DEFAULT NULL);


END JTY_ASSIGN_BULK_PUB;

/
