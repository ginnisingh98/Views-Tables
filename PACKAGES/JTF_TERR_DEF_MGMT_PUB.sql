--------------------------------------------------------
--  DDL for Package JTF_TERR_DEF_MGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_DEF_MGMT_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpdefs.pls 120.0 2005/06/02 18:20:39 appldev ship $ */

---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_DEF_MGMT_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Defect Management territory manager public api's.
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
--      05/02/01    JDOCHERT         Modified to use new architecture
--    End of Comments
--

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers
--    type           : public.
--    function       : Get winning territories members for
--                     DEFECT MANAGEMENT
--    pre-reqs       : Territories needs to be setup first
--    parameters     :
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--
-- end of comments
procedure Get_WinningTerrMembers
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrDefMgmt_Rec          IN    JTF_TERRITORY_PUB.JTF_Def_Mgmt_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_TerrResource_tbl         OUT NOCOPY   JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
);

END JTF_TERR_DEF_MGMT_PUB;

 

/
