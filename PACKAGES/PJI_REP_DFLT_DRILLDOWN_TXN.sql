--------------------------------------------------------
--  DDL for Package PJI_REP_DFLT_DRILLDOWN_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_REP_DFLT_DRILLDOWN_TXN" AUTHID CURRENT_USER AS
/* $Header: PJIRX13S.pls 120.0 2005/05/29 13:01:38 appldev noship $ */

TYPE number_nestedtb IS TABLE OF NUMBER;

/*
**   History
**   04-FEB-2004    EPASQUIN    Created
**
** This procedure derives default values for the parameters used in the
** drilldown to transactions pages.
**
*/
PROCEDURE derive_parameters(
   p_project_id                   NUMBER
  ,p_calendar_type                VARCHAR2
  ,p_calendar_id                  NUMBER
  ,p_time_id                      NUMBER
  ,p_wbs_element_id               NUMBER
  ,p_rbs_element_id               NUMBER
  ,p_commitment_flag              VARCHAR2
  ,p_time_flag                    VARCHAR2
  ,x_start_date                   OUT NOCOPY DATE
  ,x_end_date                     OUT NOCOPY DATE
  ,x_task_id                      OUT NOCOPY NUMBER
  ,x_rev_categ_code               OUT NOCOPY VARCHAR2
  ,x_event_type_id                OUT NOCOPY NUMBER
  ,x_event_type                   OUT NOCOPY VARCHAR2
  ,x_inventory_item_ids           OUT NOCOPY VARCHAR2
  ,x_org_id                       OUT NOCOPY NUMBER
  ,x_expenditure_category_id      OUT NOCOPY NUMBER
  ,x_expenditure_type_id          OUT NOCOPY NUMBER
  ,x_item_category_id             OUT NOCOPY NUMBER
  ,x_job_id                       OUT NOCOPY NUMBER
  ,x_person_type_id               OUT NOCOPY NUMBER
  ,x_person_id                    OUT NOCOPY NUMBER
  ,x_non_labor_resource_id        OUT NOCOPY NUMBER
  ,x_bom_equipment_resource_id    OUT NOCOPY NUMBER
  ,x_bom_labor_resource_id        OUT NOCOPY NUMBER
  ,x_vendor_id                    OUT NOCOPY NUMBER
  ,x_resource_class_id            OUT NOCOPY NUMBER
  ,x_resource_class_code          OUT NOCOPY VARCHAR2
  ,x_person_type                  OUT NOCOPY VARCHAR2
  ,x_expenditure_type             OUT NOCOPY VARCHAR2
  ,x_prg_project_id               OUT NOCOPY NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
);

/*
**   History
**   13-JUL-2004    EPASQUIN    Created
**
** This procedure determines whether the events and costs table have to
** be displayed in the TransactionEventsCosts drilldown page.
**
*/
PROCEDURE determine_events_costs_display(
   p_wbs_element_id               NUMBER
  ,x_task_id                      OUT NOCOPY NUMBER
  ,x_show_costs_flag              OUT NOCOPY VARCHAR2
  ,x_show_events_flag             OUT NOCOPY VARCHAR2
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
);

END Pji_Rep_Dflt_Drilldown_Txn;

 

/
