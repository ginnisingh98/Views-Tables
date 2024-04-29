--------------------------------------------------------
--  DDL for Package PRP_RTTAP_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PRP_RTTAP_INT_PVT" AUTHID CURRENT_USER as
/* $Header: PRPVRTPS.pls 120.1 2005/10/17 17:33 hekkiral noship $ */

PROCEDURE LOG_MESSAGES(
    P_LOG_MESSAGE		IN   VARCHAR2,
    P_MODULE_NAME		IN   VARCHAR2,
    P_LOG_LEVEL			IN   NUMBER);

PROCEDURE CALL_RUNTIME_TAP(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    p_Proposal_id		 IN  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE EXPLODE_TEAMS(
    x_errbuf           		OUT NOCOPY VARCHAR2,
    x_retcode          		OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    		OUT NOCOPY VARCHAR2);

PROCEDURE EXPLODE_GROUPS(
    x_errbuf           		OUT NOCOPY VARCHAR2,
    x_retcode          		OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    		OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_ACCESSES(
    x_errbuf           		OUT NOCOPY VARCHAR2,
    x_retcode          		OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    		OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_TERR_ACCESSES(
    x_errbuf           		OUT NOCOPY VARCHAR2,
    x_retcode          		OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    		OUT NOCOPY VARCHAR2);

PROCEDURE PERFORM_CLEANUP(
    x_errbuf           		OUT NOCOPY VARCHAR2,
    x_retcode          		OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    		OUT NOCOPY VARCHAR2);

END PRP_RTTAP_INT_PVT;


 

/
