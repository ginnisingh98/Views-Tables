--------------------------------------------------------
--  DDL for Package FPA_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_PROCESS_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVPRCS.pls 120.2 2005/11/22 13:51:04 appldev noship $ */

/************************************************************************************/
-- PC procedures

   PROCEDURE Create_Pc
     ( p_api_version        IN NUMBER,
       p_commit             IN VARCHAR2 := FND_API.G_FALSE,
       p_pc_all_obj         IN fpa_pc_all_obj,
       x_planning_cycle_id  OUT NOCOPY NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

   PROCEDURE Update_Pc
     ( p_api_version        IN NUMBER,
       p_commit             IN VARCHAR2 := FND_API.G_FALSE,
       p_pc_all_obj         IN fpa_pc_all_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

   PROCEDURE Set_Pc_Initiate
     ( p_api_version        IN NUMBER,
       p_commit             IN VARCHAR2 := FND_API.G_FALSE,
       p_pc_id              IN NUMBER,
       p_pc_name            IN VARCHAR2,
       p_pc_desc            IN VARCHAR2,
       p_sub_due_date       IN DATE,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

   PROCEDURE Pa_Dist_List_Items_Delete_Row (
        p_api_version         IN NUMBER,
        p_commit              IN VARCHAR2 := FND_API.G_FALSE,
        P_LIST_ITEM_ID        IN NUMBER,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_data            OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER );


/************************************************************************************/
-- Portfolio procedure
     PROCEDURE Create_Portfolio
     (
        p_api_version       IN      NUMBER,
        p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
        p_portfolio_obj     IN  FPA_PORTFO_ALL_OBJ,
        x_portfolio_id      OUT NOCOPY  VARCHAR2,
        x_return_status     OUT NOCOPY  VARCHAR2,
        x_msg_data          OUT NOCOPY  VARCHAR2,
        x_msg_count         OUT NOCOPY  NUMBER
    );


    portfolio_rec     FPA_Portfolio_PVT.portfolio_rec_type;

    PROCEDURE Update_Portfolio
     (
        p_api_version       IN      NUMBER,
        p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
        p_portfolio_obj     IN  FPA_PORTFO_ALL_OBJ,
        x_return_status     OUT NOCOPY  VARCHAR2,
        x_msg_data          OUT NOCOPY  VARCHAR2,
        x_msg_count         OUT NOCOPY  NUMBER
    );

    PROCEDURE delete_Portfolio_user
     (
        p_api_version       IN      NUMBER,
        p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
        p_project_party_id    IN      NUMBER,
        x_return_status     OUT NOCOPY  VARCHAR2,
        x_msg_data          OUT NOCOPY  VARCHAR2,
        x_msg_count         OUT NOCOPY  NUMBER
    );

    PROCEDURE Delete_Portfolio
     (
       p_api_version        IN          NUMBER,
       p_commit            IN           VARCHAR2 := FND_API.G_FALSE,
       p_portfolio_id       IN          NUMBER,
       x_return_status      OUT NOCOPY  VARCHAR2,
       x_msg_data           OUT NOCOPY  VARCHAR2,
       x_msg_count          OUT NOCOPY  NUMBER
    ) ;

/************************************************************************************/
-- Collect projects procedures


   PROCEDURE Collect_Projects
     (  p_api_version           IN NUMBER,
        p_commit                IN VARCHAR2 := FND_API.G_FALSE,
        p_pc_id                 IN NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER
     );


   PROCEDURE Add_Projects
     (  p_api_version           IN NUMBER,
        p_commit                IN VARCHAR2,
        p_scenario_id               IN NUMBER,
        p_proj_id_str           IN varchar2,
        p_project_source        IN VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER
     );

   PROCEDURE Refresh_Projects
     (  p_api_version           IN NUMBER,
        p_commit                IN VARCHAR2,
        p_scenario_id           IN NUMBER,
        p_proj_id_str           IN varchar2,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER
     );

   PROCEDURE Remove_Projects
     (  p_api_version           IN NUMBER,
        p_commit                IN VARCHAR2,
        p_scenario_id           IN NUMBER,
        p_proj_id               IN NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER
     );


   PROCEDURE update_strategicobj_weight
     ( p_api_version        IN NUMBER
      ,p_commit             IN VARCHAR2 := FND_API.G_FALSE
      ,p_strategic_weights_string    IN              varchar2
      ,x_return_status               OUT NOCOPY      varchar2
      ,x_msg_count                   OUT NOCOPY      number
      ,x_msg_data                    OUT NOCOPY      varchar2
     );

   PROCEDURE update_strategicobj
   ( p_api_version        IN NUMBER,
     p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
     p_strategic_obj_id              IN              NUMBER,
     p_strategic_obj_name       IN      VARCHAR2,
     p_strategic_obj_desc       IN      VARCHAR2,
     x_return_status                OUT NOCOPY      VARCHAR2,
     x_msg_count                    OUT NOCOPY      NUMBER,
     x_msg_data                     OUT NOCOPY      VARCHAR2
   );

PROCEDURE create_strategicobj
(   p_api_version       IN      NUMBER,
    p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
    p_strategic_obj_name        IN      VARCHAR2,
    p_strategic_obj_desc        IN      VARCHAR2,
    p_strategic_obj_parent      IN      number,
    p_strategic_obj_level       IN      varchar2,
    x_return_status                 OUT NOCOPY      varchar2,
    x_msg_count                     OUT NOCOPY      number,
    x_msg_data                      OUT NOCOPY      varchar2
);

PROCEDURE delete_strategicobj
(   p_api_version       IN      NUMBER,
    p_commit            IN      VARCHAR2 := FND_API.G_FALSE,
    p_strategic_obj_shortname   IN      VARCHAR2,
    x_return_status                 OUT NOCOPY      VARCHAR2,
    x_msg_count                     OUT NOCOPY      NUMBER,
    x_msg_data                      OUT NOCOPY      VARCHAR2
);

PROCEDURE create_scenario
(
        p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
        p_api_version                   IN              NUMBER,
        p_scenario_id_source            IN              NUMBER,
        p_pc_id                         IN              NUMBER,
        p_scenario_name         IN      VARCHAR2,
        p_scenario_desc         IN      VARCHAR2,
        p_copy_proposed_proj        IN      VARCHAR2,
        p_sce_disc_rate         IN      VARCHAR2,
        p_sce_funds_avail       IN      VARCHAR2,
        x_scenario_id                   OUT NOCOPY      VARCHAR2,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
);

procedure set_scenario_action_flag
(
        p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
        p_api_version                   IN              NUMBER,
        p_scenario_id               IN              NUMBER,
        p_scenario_action               IN              VARCHAR2,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
);

procedure update_scenario_reccom_status
(
  p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  p_project_id                  IN              VARCHAR2,
  p_scenario_reccom_value       IN              VARCHAR2,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
);

PROCEDURE Submit_Project_Aw
(   p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_project_id            IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2);

PROCEDURE Load_Project_Details_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2,
    p_type                  IN              VARCHAR2,
    p_scenario_id           IN              NUMBER,
    p_projects              IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2);


PROCEDURE Close_Pc
(   p_api_version           IN              NUMBER,
    p_commit                IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_pc_id                 IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2);

PROCEDURE Update_Scen_Proj_User_Ranks
     ( p_api_version        IN NUMBER,
       p_commit             IN VARCHAR2 := FND_API.G_FALSE,
       p_projs              IN fpa_scen_proj_userrank_all_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );


PROCEDURE update_pjt_proj_funding_status
     (  p_api_version        IN NUMBER,
        p_init_msg_list      IN VARCHAR2,
        p_commit             IN VARCHAR2,
        p_scenario_id        IN NUMBER,
        x_return_status      OUT NOCOPY      VARCHAR2,
        x_msg_count          OUT NOCOPY      NUMBER,
        x_msg_data           OUT NOCOPY      VARCHAR2);

FUNCTION proj_scorecard_link_enabled
(   p_function_name     IN  VARCHAR2,
    p_project_id        IN  NUMBER)
 RETURN VARCHAR2;

END FPA_PROCESS_PVT; -- Package spec

 

/
