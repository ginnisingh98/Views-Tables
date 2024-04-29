--------------------------------------------------------
--  DDL for Package JTY_TERR_SPARES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TERR_SPARES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtftsprmgs.pls 120.0.12010000.3 2010/03/09 06:12:15 rajukum noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30):='JTY_ASSIGN_REALTIME_PUB';

--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TERR_SPARES_PVT
--    PURPOSE  : Creation of seeded data and wrapper procedure for Spares use
--
--      Procedures:
--         (see below for specification)
--
--
--    NOTES
--
--
--
--    HISTORY
--      03/03/2010    RAJUKUM         CREATED
--
--
--    End of Comments
--


 Procedure run_r12_seeded_terr_for_spares;

 -- ***************************************************
  --    API Specifications
  -- ***************************************************
  --    api name       : Process_match_terr_spares
  --    type           : public.
  --    function       : Called by spares  APIs
  --    pre-reqs       : Territories needs to be setup first
  --    notes          :
  --
  PROCEDURE process_match_terr_spares
 (  p_api_version_number      IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrServReq_Rec          IN    JTF_TERRITORY_PUB.JTF_Serv_Req_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    p_plan_start_date          IN    DATE DEFAULT NULL,
    p_plan_end_date            IN    DATE DEFAULT NULL,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2
 );


END  JTY_TERR_SPARES_PVT;

/
