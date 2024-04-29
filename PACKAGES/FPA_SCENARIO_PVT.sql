--------------------------------------------------------
--  DDL for Package FPA_SCENARIO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_SCENARIO_PVT" AUTHID CURRENT_USER AS
/* $Header: FPAVSCES.pls 120.1 2005/08/18 11:49:23 appldev ship $ */

TYPE scenario_rec_type IS RECORD
(
  	sce_shortname			VARCHAR2(30), -- shortname of scenario.
	sce_name			VARCHAR2(50), -- name of scenario.
	sce_description			VARCHAR2(255), -- description of scenario.
	sce_status	        	VARCHAR2(30), -- status of scenario.
	sce_planning_cycle   		VARCHAR2(30), -- planning cycle of scenario.
	sce_org_id			VARCHAR2(30), -- Organization shortname
	copy_flag			VARCHAR2(1),  -- flag used to tell the API new scenario
        sce_new_capital			number	      -- value for new capital.
);

-- Creates a new scenario
PROCEDURE create_scenario
(
  	p_api_version                  	IN              NUMBER,
        p_scenario_name                 IN              VARCHAR2,
        p_scenario_desc                 IN              VARCHAR2,
	p_pc_id		      		IN              NUMBER,
        x_scenario_id                   OUT NOCOPY      NUMBER,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
);

PROCEDURE copy_scenario_data
(
        p_api_version                   IN              NUMBER,
        p_scenario_id_source            IN              NUMBER,
        p_scenario_id_target            IN              NUMBER,
        p_copy_proposed_proj	        IN              VARCHAR2,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
);

PROCEDURE lock_scenario
(
  	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_scenario_rec           	IN              fpa_scenario_pvt.scenario_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
);

function check_scenario_name
(
        p_scenario_name			IN		VARCHAR2,
        p_pc_id				IN		NUMBER,
        x_return_status              OUT NOCOPY      VARCHAR2,
        x_msg_count                  OUT NOCOPY      NUMBER,
        x_msg_data                   OUT NOCOPY      VARCHAR2
    ) RETURN NUMBER;

PROCEDURE update_scen_approved_flag
(
       p_scenario_id                   IN              NUMBER,
       p_approved_flag                 IN                          VARCHAR2 :='NA',
       x_return_status                 OUT NOCOPY      VARCHAR2,
       x_msg_count                     OUT NOCOPY      NUMBER,
       x_msg_data                      OUT NOCOPY      VARCHAR2
);

procedure update_scenario_disc_rate
(
  p_api_version			IN		NUMBER,
  p_scenario_id			IN		NUMBER,
  p_discount_rate		IN		NUMBER,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
);

procedure update_scenario_funds_avail
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  p_scenario_funds              IN              NUMBER,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
);

procedure update_scenario_initial_flag
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
);

procedure update_scenario_working_flag
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
);

procedure update_scenario_reccom_flag
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  p_scenario_reccom_status	IN		VARCHAR2,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
);

procedure update_scenario_reccom_status
(
  p_api_version                 IN              NUMBER,
  p_scenario_id                 IN              NUMBER,
  p_project_id                  IN              VARCHAR2,
  p_scenario_reccom_value       IN              VARCHAR2,
  x_return_status               OUT NOCOPY      VARCHAR2,
  x_msg_count                   OUT NOCOPY      NUMBER,
  x_msg_data                    OUT NOCOPY      VARCHAR2
);

PROCEDURE copy_sce_project_data
(
    p_api_version           IN              NUMBER,
    p_commit                IN              VARCHAR2,
    p_target_scen_id        IN              NUMBER,
    p_project_id_str        IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

PROCEDURE remove_project_from_scenario
  (
    p_api_version           IN              NUMBER,
    p_commit                IN              VARCHAR2,
    p_scenario_id           IN              NUMBER,
    p_project_id        	IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
  );

PROCEDURE Update_Proj_User_Ranks
     (
	   p_api_version        IN NUMBER,
       p_proj_metrics       IN fpa_scen_proj_userrank_tbl,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER
	 );

PROCEDURE calc_scenario_data
(
        p_api_version                   IN              NUMBER,
        p_scenario_id                   IN              NUMBER,
        p_project_id                    IN              NUMBER,
        p_class_code_id                 IN              NUMBER,
        p_data_to_calc                  IN              VARCHAR2,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
);

END fpa_scenario_pvt;

 

/
