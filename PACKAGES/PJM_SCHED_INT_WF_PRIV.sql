--------------------------------------------------------
--  DDL for Package PJM_SCHED_INT_WF_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_SCHED_INT_WF_PRIV" AUTHID CURRENT_USER AS
/* $Header: PJMSIWPS.pls 115.4 99/09/19 11:03:57 porting shi $ */
/*---------------------------------------------------------------------------
   Workflow common start procedure
  ---------------------------------------------------------------------------*/

PROCEDURE common_start(c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      );

--  ---------------------------------------------------------------------
--  Public Functions / Procedures
--  ---------------------------------------------------------------------

PROCEDURE   launch_wip(c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_wip_job_name         varchar2
                      ,c_organization_name    varchar2
                      ,d_job_start_date       date
                      ,d_job_end_date         date
                      ,c_status               varchar2
                      ,c_job_type             varchar2
                      ,n_start_quantity       number
                      ,n_quantity_completed   number
                      );

PROCEDURE   launch_so (c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_so_number            number
                      ,c_line_number          number
                      ,c_warehouse            varchar2
                      ,n_quantity             number
                      ,d_requested_date       date
                      ,d_promised_date        date
                      );

PROCEDURE   launch_forecast(c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_forecast_set         varchar2
                      ,c_forecast_name        varchar2
                      ,c_organization_name    varchar2
                      ,n_quantity             number
                      ,d_forecast_start_date  date
                      ,d_forecast_end_date    date
                      );

PROCEDURE   launch_pr (c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_pr_number            varchar2
                      ,c_ship_to_location     varchar2
                      ,c_status               varchar2
                      ,n_quantity             number
                      ,d_need_by_date         date
                      );

PROCEDURE   launch_rfq(c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_rfq_number           varchar2
                      ,c_ship_to_location     varchar2
                      ,c_status               varchar2
                      ,d_due_date             date
                      );

PROCEDURE launch_quotation (c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_quotation_number     varchar2
                      ,c_ship_to_location     varchar2
                      ,c_status               varchar2
                      ,d_eff_start_date       date
                      ,d_eff_end_date         date
                      );

PROCEDURE   launch_mds(c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_mds_name             varchar2
                      ,c_organization_name    varchar2
                      ,n_quantity             number
                      ,d_schedule_date        date
                      ,d_schedule_end_date    date
                      );

PROCEDURE   launch_mps(c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_mps_name             varchar2
                      ,c_organization_name    varchar2
                      ,n_quantity             number
                      ,d_schedule_date        date
                      ,d_schedule_end_date    date
                      );

PROCEDURE   launch_po (c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_po_number            varchar2
                      ,c_ship_to_location     varchar2
                      ,c_status               varchar2
                      ,n_ordered_quantity     number
                      ,n_delivered_quantity   number
                      ,d_promised_date        date
                      ,d_need_by_date         date
                      );

PROCEDURE   launch_po_release (c_item_type            varchar2
                      ,c_item_key             varchar2
                      ,c_process              varchar2
                      ,c_owner                varchar2
                      ,c_requestor            varchar2
                      ,n_tolerance_days       number
                      ,c_ntf_proj_mgr         varchar2
                      ,c_ntf_task_mgr         varchar2
                      ,c_project_number       varchar2
                      ,c_project_name         varchar2
                      ,d_project_start_date   date
                      ,d_project_end_date     date
                      ,c_task_number          varchar2
                      ,c_task_name            varchar2
                      ,d_task_start_date      date
                      ,d_task_end_date        date
                      ,c_exception_subject    varchar2
                      ,c_exception_body       varchar2
                      ,c_document_type        varchar2
                      ,c_item_number          varchar2
                      ,c_item_description     varchar2
                      ,c_po_number            varchar2
                      ,c_release_number       varchar2
                      ,c_ship_to_location     varchar2
                      ,c_status               varchar2
                      ,n_ordered_quantity     number
                      ,n_delivered_quantity   number
                      ,d_promised_date        date
                      ,d_need_by_date         date
                      );



END PJM_SCHED_INT_WF_PRIV;

 

/
