--------------------------------------------------------
--  DDL for Package JTF_TERR_TASK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_TASK_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpttss.pls 120.0 2005/06/02 18:21:02 appldev ship $ */

---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_TASK_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core Sales territory manager public api's.
--      This package is a public API for getting winning territories
--      or territory resources.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      11/14/99    VNEDUNGA         Created
--      05/07/01    EIHSU            GetWinningTerritories removed
--
--    End of Comments
--
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers
--    type           : public.
--    function       : Get winning territories members for an TASK
--    pre-reqs       : Territories needs to be setup first
--    parameters     :
--
--    IN:
--        p_api_version_number   IN  number               required
--        p_init_msg_list        IN  varchar2             optional --default = fnd_api.g_false
--        p_commit               IN  varchar2             optional --default = fnd_api.g_false
--        p_Org_Id               IN  number               required
--        p_TerrTask_Rec         IN  JTF_ServiceReqst_rec_type
--        p_Resource_Type        IN  varchar2
--        p_Role                 IN  varchar2
--
--    out:
--        x_return_status        out varchar2(1)
--        x_msg_count            out number
--        x_msg_data             out varchar2(2000)
--        x_TerrRes_tbl          out TerrRes_tbl_type
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retreving a set of winning
--                        territories resources. This is an overloaded
--                        procedure for accounts,lead, oppor, service
--                        requests, and collections.
--
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrTask_Rec             IN    JTF_TERRITORY_PUB.JTF_Task_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_TerrResource_tbl         OUT NOCOPY   JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
);

END JTF_TERR_TASK_PUB;

 

/
