--------------------------------------------------------
--  DDL for Package AS_RTTAP_OPPTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_RTTAP_OPPTY" AUTHID CURRENT_USER as
/* $Header: asxrtops.pls 120.3 2005/10/10 03:46:06 subabu noship $ */
-- Start of Comments
-- Package name     : AS_RTTAP_OPPTY
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Opp_Terr_Assignment
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN:
--      p_api_version_number IN NUMBER   Required
--      p_init_msg_list      IN VARCHAR2 Optional Default = FND_API_G_FALSE
--      p_commit             IN VARCHAR2 Optional Default = FND_API.G_FALSE
--      p_validation_level   IN NUMBER   Optional Default =
--                                                   FND_API.G_VALID_LEVEL_FULL
--   OUT:
--      x_return_status      OUT  VARCHAR2
--      x_msg_count          OUT  NUMBER
--      x_msg_data           OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments



PROCEDURE RTTAP_WRAPPER(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    p_LEAD_ID			 IN  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE EXPLODE_TEAMS_OPPTYS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);
PROCEDURE EXPLODE_GROUPS_OPPTYS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);
PROCEDURE SET_TEAM_LEAD_OPPTYS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2 );
PROCEDURE INSERT_ACCESSES_OPPTYS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);
PROCEDURE INSERT_TERR_ACCESSES_OPPTYS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);
PROCEDURE PERFORM_OPPTY_CLEANUP(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);
PROCEDURE ASSIGN_OPPTY_OWNER(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);
PROCEDURE RAISE_BUSINESS_EVENT(
    x_errbuf        OUT NOCOPY VARCHAR2,
    x_retcode       OUT NOCOPY VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2);
END AS_RTTAP_OPPTY;


 

/
