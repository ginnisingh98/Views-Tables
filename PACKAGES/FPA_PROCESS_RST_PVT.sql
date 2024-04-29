--------------------------------------------------------
--  DDL for Package FPA_PROCESS_RST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_PROCESS_RST_PVT" AUTHID CURRENT_USER AS
/* $Header: FPAVRSTS.pls 120.1 2005/08/18 11:48:47 appldev ship $ */

PROCEDURE Update_Calc_Pjt_Scorecard_Aw
(   p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2 := FND_API.G_FALSE,
    p_planning_cycle_id     IN              NUMBER,
    p_project_id            IN              NUMBER,
    p_scorecard_tbl         IN              FPA_SCORECARDS_PVT.FPA_SCORECARD_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2);

PROCEDURE Update_Calc_Scen_Scorecard_Aw
(   p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2 := FND_API.G_FALSE,
    p_planning_cycle_id     IN              NUMBER,
    p_scenario_id           IN              NUMBER,
    p_project_id            IN              NUMBER,
    p_scorecard_tbl         IN              FPA_SCORECARDS_PVT.FPA_SCORECARD_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2);

END FPA_PROCESS_RST_PVT; -- Package spec

 

/
