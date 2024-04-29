--------------------------------------------------------
--  DDL for Package FPA_PLANNINGCYCLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_PLANNINGCYCLE_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVPCPS.pls 120.2 2005/11/09 15:35:30 appldev ship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
--Monika Bansal
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE Create_Pc
     ( p_api_version        IN NUMBER,
       p_pc_all_obj         IN fpa_pc_all_obj,
       x_planning_cycle_id  OUT NOCOPY NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Update_Pc_Invest_Mix
     ( p_api_version        IN NUMBER,
       p_inv_matrix         IN fpa_pc_inv_matrix_tbl,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Update_Pc_Fin_Targets
     ( p_api_version        IN NUMBER,
       p_fin_targets_tbl    IN fpa_pc_fin_targets_tbl,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Update_Pc_Inv_Criteria_Data
     ( p_api_version        IN NUMBER,
       p_inv_crit_tbl       IN fpa_pc_inv_criteria_tbl,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Update_Pc_Desc_Fields
     ( p_api_version        IN NUMBER,
       p_pc_all_obj         IN fpa_pc_all_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Update_Pc_Class_Category
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       p_catg_id            IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );


PROCEDURE Update_Pc_Calendar
     ( p_api_version        IN NUMBER,
       p_pc_info            IN fpa_pc_info_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Update_Pc_Currency
     ( p_api_version        IN NUMBER,
       p_pc_info            IN fpa_pc_info_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Update_Pc_Sub_Due_Date
     ( p_api_version        IN NUMBER,
       p_pc_info            IN fpa_pc_info_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Set_Pc_Status
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       p_pc_status_code     IN VARCHAR2,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Set_Pc_Initiate_Date
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Update_Pc_Discount_funds
     ( p_api_version        IN NUMBER,
       p_disc_funds         IN fpa_pc_discount_obj,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

FUNCTION Check_Pc_Name
     ( p_api_version        IN NUMBER,
       p_portfolio_id       IN NUMBER,
       p_pc_name            IN VARCHAR2,
       p_pc_id              IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER)
       RETURN number;

PROCEDURE Pa_Distrb_Lists_Insert_Row (
       p_api_version    IN NUMBER,
       p_distr_list     IN fpa_pc_distr_list_obj,
       p_list_id 		IN OUT NOCOPY NUMBER,
       x_return_status  OUT NOCOPY VARCHAR2,
       x_msg_data       OUT NOCOPY VARCHAR2,
       x_msg_count      OUT NOCOPY NUMBER );

PROCEDURE Pa_Dist_List_Items_Update_Row (
       p_api_version           IN NUMBER,
       p_distr_list_items_tbl  fpa_pc_distr_list_items_tbl,
       x_return_status         OUT NOCOPY VARCHAR2,
       x_msg_data              OUT NOCOPY VARCHAR2,
       x_msg_count             OUT NOCOPY NUMBER );

PROCEDURE Set_Pc_Investment_Criteria (
       p_api_version           IN NUMBER,
       p_pc_id			IN NUMBER,
       x_return_status         OUT NOCOPY VARCHAR2,
       x_msg_data              OUT NOCOPY VARCHAR2,
       x_msg_count             OUT NOCOPY NUMBER );

PROCEDURE Set_Pc_Approved_Flag
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Set_Pc_Last_Flag
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

PROCEDURE Update_Pc_Annual_Disc_Rates
     ( p_api_version        IN NUMBER,
       p_pc_id              IN NUMBER,
       p_period		    IN VARCHAR2,
       p_rate		    IN VARCHAR2,
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER );

END FPA_PlanningCycle_Pvt; -- Package spec

 

/
