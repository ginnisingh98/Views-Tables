--------------------------------------------------------
--  DDL for Package IEX_STRY_CHECKLIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRY_CHECKLIST_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpschs.pls 120.0 2004/01/24 03:19:48 appldev noship $ */

PROCEDURE create_checklist_strategy
(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_StrategyID                 IN   NUMBER
) ;

END IEX_STRY_CHECKLIST_PUB;

 

/
