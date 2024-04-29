--------------------------------------------------------
--  DDL for Package JTF_TERR_NAMEACC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_NAMEACC_PUB" AUTHID CURRENT_USER AS
/* $Header: jtftrnps.pls 120.3 2005/08/21 23:20:31 spai ship $ */

---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_NAMEACC_PUB
--    ---------------------------------------------------
--    PURPOSE
--      This package is a public API for setting winning territory
--      resources.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is for Territory use only
--
--    HISTORY
--      08/01/02    ARPATEL           Created
--    End of Comments
--

procedure Set_Winners_tbl
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_party_id                 IN    number  ,
    p_party_site_id            IN    number  ,
    p_asof_date                IN    date,
    p_source_id                IN    number,
    p_trans_id                 IN    number,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    p_api_mode                 IN    varchar2,
    x_party_name               OUT NOCOPY  varchar2,
    x_session_id               OUT NOCOPY  number,
    x_return_status            OUT NOCOPY  varchar2,
    x_msg_count                OUT NOCOPY  number,
    x_msg_data                 OUT NOCOPY  varchar2
);

END JTF_TERR_NAMEACC_PUB;

 

/
