--------------------------------------------------------
--  DDL for Package FPA_SCORECARDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_SCORECARDS_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVSCRS.pls 120.2 2005/08/18 11:50:19 appldev noship $ */
G_API_NAME         CONSTANT VARCHAR2(80) := 'FPA_SCORECARDS_PVT';

TYPE FPA_SCORECARD_REC_TYPE IS RECORD  (
     STRATEGIC_OBJ_ID         NUMBER,
     NEW_SCORE                NUMBER,
     COMMENTS                 VARCHAR2(2000)
);

TYPE FPA_SCORECARD_TBL_TYPE IS TABLE OF FPA_SCORECARD_REC_TYPE
INDEX BY BINARY_INTEGER;

SUBTYPE FPA_SCORECARDS_TL_REC IS FPA_SCORECARDS_TL%ROWTYPE;

/* ***********************************************************************
Desc:
parameters:
return:
***************************************************************************/

PROCEDURE Update_Calc_Pjt_Scorecard_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2 := FND_API.G_FALSE,
    p_planning_cycle_id     IN              NUMBER,
    p_project_id            IN              NUMBER,
    p_scorecard_tbl         IN              FPA_SCORECARDS_PVT.FPA_SCORECARD_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

PROCEDURE Update_Calc_Scen_Scorecard_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2 := FND_API.G_FALSE,
    p_planning_cycle_id     IN              NUMBER,
    p_scenario_id           IN              NUMBER,
    p_project_id            IN              NUMBER,
    p_scorecard_tbl         IN              FPA_SCORECARDS_PVT.FPA_SCORECARD_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

PROCEDURE Calc_Scenario_Wscores_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_scenario_id           IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

PROCEDURE Update_Scenario_App_Scores
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_scenario_id           IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

PROCEDURE insert_tl_rec
(
    p_init_msg_list                IN VARCHAR2,
    p_scorecards_tl_rec            IN  FPA_SCORECARDS_TL_REC,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2
 );

PROCEDURE Handle_Comments
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_scenario_id           IN              NUMBER,
    p_type                  IN              VARCHAR2,
    p_source_scenario_id    IN              NUMBER,
    p_delete_project_id     IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

FUNCTION Read_Only
(
   p_planning_cycle_id  IN  NUMBER,
   p_scenario_id        IN  NUMBER) RETURN VARCHAR2;

END FPA_SCORECARDS_PVT;

 

/
