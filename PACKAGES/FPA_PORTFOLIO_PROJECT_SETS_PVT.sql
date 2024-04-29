--------------------------------------------------------
--  DDL for Package FPA_PORTFOLIO_PROJECT_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_PORTFOLIO_PROJECT_SETS_PVT" AUTHID CURRENT_USER AS
/* $Header: FPAVPRSS.pls 120.1 2005/08/18 11:45:32 appldev noship $ */

    PROCEDURE create_project_set
     ( p_api_version    IN      NUMBER,
       p_pc_id          IN      fpa_aw_pc_info_v.planning_cycle%TYPE,
       x_return_status  OUT     NOCOPY VARCHAR2,
       x_msg_data       OUT     NOCOPY VARCHAR2,
       x_msg_count      OUT     NOCOPY NUMBER);

    PROCEDURE add_project_set_lines
     ( p_api_version    IN      NUMBER,
       p_scen_id        IN      fpa_aw_sce_info_v.scenario%TYPE,
       x_return_status  OUT     NOCOPY VARCHAR2,
       x_msg_data       OUT     NOCOPY VARCHAR2,
       x_msg_count      OUT     NOCOPY NUMBER);

END fpa_portfolio_project_sets_pvt; -- Package spec

 

/
