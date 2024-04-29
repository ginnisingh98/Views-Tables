--------------------------------------------------------
--  DDL for Package PA_MC_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MC_BILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: PAMCPVTS.pls 120.3 2005/08/07 22:53:47 lveerubh noship $ */


   PROCEDURE get_budget_amount(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_billing_extension_id     IN    NUMBER,
             p_cost_budget_type_code    IN    VARCHAR2 DEFAULT NULL,
             p_rev_budget_type_code     IN    VARCHAR2 DEFAULT NULL,
             x_revenue_amount           OUT   NOCOPY NUMBER,
             x_cost_amount              OUT   NOCOPY NUMBER,
             x_cost_budget_type_code    OUT   NOCOPY VARCHAR2,
             x_rev_budget_type_code     OUT   NOCOPY VARCHAR2,
             x_return_status            OUT   NOCOPY VARCHAR2,
             x_msg_count                OUT   NOCOPY NUMBER,
             x_msg_data                 OUT   NOCOPY VARCHAR2);


   PROCEDURE get_project_task_budget_amount(
             p_budget_version_id        IN       NUMBER,
             p_project_id               IN       NUMBER,
             p_task_id                  IN       NUMBER,
             p_psob_id                  IN       NUMBER,
             p_rsob_id                  IN       NUMBER,
             x_raw_cost_total           IN OUT   NOCOPY NUMBER,
             x_burdened_cost_total      IN OUT   NOCOPY NUMBER,
             x_revenue_total            IN OUT   NOCOPY NUMBER,
             x_return_status            OUT      NOCOPY VARCHAR2,
             x_msg_count                OUT      NOCOPY NUMBER,
             x_msg_data                 OUT      NOCOPY VARCHAR2);


   PROCEDURE get_cost_amount(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_accrue_through_date      IN    DATE,
             x_cost_amount              OUT   NOCOPY NUMBER,
             x_return_status            OUT   NOCOPY VARCHAR2,
             x_msg_count                OUT   NOCOPY NUMBER,
             x_msg_data                 OUT   NOCOPY VARCHAR2);


   PROCEDURE get_pot_event_amount(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             p_accrue_through_date      IN    DATE,
             x_event_amount             OUT  NOCOPY  NUMBER,
             x_return_status            OUT  NOCOPY VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT   NOCOPY VARCHAR2);



   PROCEDURE get_Lowest_amount_left(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             x_funding_amount           OUT   NOCOPY NUMBER,
             x_return_status            OUT   NOCOPY VARCHAR2,
             x_msg_count                OUT   NOCOPY NUMBER,
             x_msg_data                 OUT   NOCOPY VARCHAR2);


   PROCEDURE get_revenue_amount(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             x_revenue_amount           OUT   NOCOPY NUMBER,
             x_return_status            OUT   NOCOPY VARCHAR2,
             x_msg_count                OUT   NOCOPY NUMBER,
             x_msg_data                 OUT   NOCOPY VARCHAR2);



END pa_mc_billing_pvt;

 

/
