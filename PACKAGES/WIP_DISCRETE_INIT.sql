--------------------------------------------------------
--  DDL for Package WIP_DISCRETE_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DISCRETE_INIT" AUTHID CURRENT_USER as
/* $Header: wipdjins.pls 115.9 2003/09/05 21:30:55 kboonyap ship $ */

/* This procedure is run whenever the Define Discrete Job form is started.
   It fetches information from WIP_PARAMETERS, WIP_ACCOUNTING_CLASSES, and
   MTL_PARAMETERS
 */

PROCEDURE get_parameters(p_organization_id               NUMBER,
                        p_default_class                 IN OUT NOCOPY VARCHAR2,
                        p_lot_number_default_type       OUT NOCOPY NUMBER,
                        p_wip_param_count               OUT NOCOPY NUMBER,
                        p_acct_class_flag               IN OUT NOCOPY NUMBER,
                        p_disable_date                  OUT NOCOPY DATE,
                        p_default_ma                    OUT NOCOPY NUMBER,
                        p_default_mva                   OUT NOCOPY NUMBER,
                        p_default_moa                   OUT NOCOPY NUMBER,
                        p_default_ra                    OUT NOCOPY NUMBER,
                        p_default_rva                   OUT NOCOPY NUMBER,
                        p_default_opa                   OUT NOCOPY NUMBER,
                        p_default_opva                  OUT NOCOPY NUMBER,
                        p_default_oa                    OUT NOCOPY NUMBER,
                        p_default_ova                   OUT NOCOPY NUMBER,
                        p_default_scaa                  OUT NOCOPY NUMBER,
                        p_org_locator_control           OUT NOCOPY NUMBER,
                        p_demand_class_mp               OUT NOCOPY VARCHAR2,
                        p_mp_calendar_code              OUT NOCOPY VARCHAR2,
                        p_mp_exception_set_id           OUT NOCOPY NUMBER,
                        p_project_ref                   OUT NOCOPY NUMBER,
                        p_project_control               OUT NOCOPY NUMBER,
                        p_pm_cost_collection            OUT NOCOPY NUMBER,
                        p_primary_cost_method           OUT NOCOPY NUMBER,
                        p_po_creation_time              OUT NOCOPY NUMBER);

PROCEDURE get_parameters(p_organization_id               NUMBER,
                        p_default_class                  IN OUT NOCOPY VARCHAR2,
                        p_lot_number_default_type        OUT NOCOPY NUMBER,
                        p_wip_param_count                OUT NOCOPY NUMBER,
                        p_acct_class_flag                IN OUT NOCOPY NUMBER,
                        p_disable_date                   OUT NOCOPY DATE,
                        p_default_ma                     OUT NOCOPY NUMBER,
                        p_default_mva                    OUT NOCOPY NUMBER,
                        p_default_moa                    OUT NOCOPY NUMBER,
                        p_default_ra                     OUT NOCOPY NUMBER,
                        p_default_rva                    OUT NOCOPY NUMBER,
                        p_default_opa                    OUT NOCOPY NUMBER,
                        p_default_opva                   OUT NOCOPY NUMBER,
                        p_default_oa                     OUT NOCOPY NUMBER,
                        p_default_ova                    OUT NOCOPY NUMBER,
                        p_default_scaa                   OUT NOCOPY NUMBER,
                        p_org_locator_control            OUT NOCOPY NUMBER,
                        p_demand_class_mp                OUT NOCOPY VARCHAR2,
                        p_mp_calendar_code               OUT NOCOPY VARCHAR2,
                        p_mp_exception_set_id            OUT NOCOPY NUMBER,
                        p_project_ref                    OUT NOCOPY NUMBER,
                        p_project_control                OUT NOCOPY NUMBER,
                        p_pm_cost_collection             OUT NOCOPY NUMBER,
                        p_primary_cost_method            OUT NOCOPY NUMBER,
                        p_po_creation_time               OUT NOCOPY NUMBER,
                        p_def_serialization_start_op     OUT NOCOPY NUMBER);

PROCEDURE get_parameters(p_organization_id               NUMBER,
                        p_default_class                  IN OUT NOCOPY VARCHAR2,
                        p_lot_number_default_type        OUT NOCOPY NUMBER,
                        p_wip_param_count                OUT NOCOPY NUMBER,
                        p_acct_class_flag                IN OUT NOCOPY NUMBER,
                        p_disable_date                   OUT NOCOPY DATE,
                        p_default_ma                     OUT NOCOPY NUMBER,
                        p_default_mva                    OUT NOCOPY NUMBER,
                        p_default_moa                    OUT NOCOPY NUMBER,
                        p_default_ra                     OUT NOCOPY NUMBER,
                        p_default_rva                    OUT NOCOPY NUMBER,
                        p_default_opa                    OUT NOCOPY NUMBER,
                        p_default_opva                   OUT NOCOPY NUMBER,
                        p_default_oa                     OUT NOCOPY NUMBER,
                        p_default_ova                    OUT NOCOPY NUMBER,
                        p_default_scaa                   OUT NOCOPY NUMBER,
                        p_org_locator_control            OUT NOCOPY NUMBER,
                        p_demand_class_mp                OUT NOCOPY VARCHAR2,
                        p_mp_calendar_code               OUT NOCOPY VARCHAR2,
                        p_mp_exception_set_id            OUT NOCOPY NUMBER,
                        p_project_ref                    OUT NOCOPY NUMBER,
                        p_project_control                OUT NOCOPY NUMBER,
                        p_pm_cost_collection             OUT NOCOPY NUMBER,
                        p_primary_cost_method            OUT NOCOPY NUMBER,
                        p_po_creation_time               OUT NOCOPY NUMBER,
                        p_def_serialization_start_op     OUT NOCOPY NUMBER,
                        p_propagate_job_change_to_po     OUT NOCOPY NUMBER);

END WIP_DISCRETE_INIT;

 

/
