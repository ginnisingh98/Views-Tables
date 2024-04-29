--------------------------------------------------------
--  DDL for Package PA_MC_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MC_BILLING_PUB" AUTHID CURRENT_USER AS
/* $Header: PAMCPUBS.pls 120.3 2005/08/07 21:31:06 lveerubh noship $ */


   PROCEDURE get_budget_amount(
             p_project_id               IN    NUMBER,
             p_project_number           IN    VARCHAR2  DEFAULT NULL,
             p_task_id                  IN    NUMBER    DEFAULT NULL,
             P_task_number              IN    VARCHAR2  DEFAULT NULL,
             p_psob_id                  IN    NUMBER    DEFAULT NULL,
             p_rsob_id                  IN    NUMBER,
             p_billing_extension_id     IN    NUMBER,
             p_billing_extension_name   IN    VARCHAR2 DEFAULT NULL,
             p_cost_budget_type_code    IN    VARCHAR2 DEFAULT NULL,
             p_rev_budget_type_code     IN    VARCHAR2 DEFAULT NULL,
             x_revenue_amount           OUT   NOCOPY NUMBER,
             x_cost_amount              OUT   NOCOPY NUMBER,
             x_cost_budget_type_code    OUT   NOCOPY VARCHAR2,
             x_rev_budget_type_code     OUT   NOCOPY VARCHAR2,
             x_error_message            OUT   NOCOPY VARCHAR2,
             x_status                   OUT   NOCOPY NUMBER);


   PROCEDURE get_cost_amount(
             p_project_id               IN    NUMBER,
             p_project_number           IN    VARCHAR2 DEFAULT NULL,
             p_task_id                  IN    NUMBER   DEFAULT NULL,
             P_task_number              IN    VARCHAR2 DEFAULT NULL,
             p_psob_id                  IN    NUMBER   DEFAULT NULL,
             p_rsob_id                  IN    NUMBER,
             p_accrue_through_date      IN    DATE     DEFAULT NULL,
             x_cost_amount              OUT   NOCOPY NUMBER,
             x_error_message            OUT   NOCOPY VARCHAR2,
             x_status                   OUT   NOCOPY NUMBER);


   PROCEDURE get_pot_event_amount(
             p_project_id               IN    NUMBER,
             p_project_number           IN    VARCHAR2 DEFAULT NULL,
             p_task_id                  IN    NUMBER   DEFAULT NULL,
             P_task_number              IN    VARCHAR2 DEFAULT NULL,
             p_psob_id                  IN    NUMBER   DEFAULT NULL,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             p_accrue_through_date      IN    DATE     DEFAULT NULL,
             x_event_amount             OUT   NOCOPY NUMBER,
             x_error_message            OUT   NOCOPY VARCHAR2,
             x_status                   OUT   NOCOPY NUMBER);



   PROCEDURE get_Lowest_amount_left(
             p_project_id               IN    NUMBER,
             p_project_number           IN    VARCHAR2 DEFAULT NULL,
             p_task_id                  IN    NUMBER   DEFAULT NULL,
             P_task_number              IN    VARCHAR2 DEFAULT NULL,
             p_psob_id                  IN    NUMBER   DEFAULT NULL,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             x_funding_amount           OUT   NOCOPY NUMBER,
             x_error_message            OUT   NOCOPY VARCHAR2,
             x_status                   OUT   NOCOPY NUMBER);


   PROCEDURE get_revenue_amount(
             p_project_id               IN    NUMBER,
             p_project_number           IN    VARCHAR2 DEFAULT NULL,
             p_task_id                  IN    NUMBER   DEFAULT NULL,
             P_task_number              IN    VARCHAR2 DEFAULT NULL,
             p_psob_id                  IN    NUMBER   DEFAULT NULL,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             x_revenue_amount           OUT   NOCOPY NUMBER,
             x_error_message            OUT   NOCOPY VARCHAR2,
             x_status                   OUT   NOCOPY NUMBER);



END pa_mc_billing_pub;

 

/
