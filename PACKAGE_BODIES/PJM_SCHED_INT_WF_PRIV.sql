--------------------------------------------------------
--  DDL for Package Body PJM_SCHED_INT_WF_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_SCHED_INT_WF_PRIV" AS
/* $Header: PJMSIWPB.pls 115.8 2003/04/10 21:46:42 alaw ship $ */
--  ---------------------------------------------------------------------
--  Private Functions / Procedures
--  ---------------------------------------------------------------------

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
                      ) is
   c_project_manager  varchar2(80) :='';
   c_task_manager     varchar2(80) :='';

BEGIN

   if c_ntf_proj_mgr='Y' then
      c_project_manager:= PJM_INTEGRATION_PROJ_MFG.PJM_SELECT_PROJECT_MANAGER(
                             PJM_PROJECT.val_proj_numtoid(c_project_number));
      if c_project_manager = c_requestor then
         c_project_manager:='';
      end if;
   end if;

   if c_ntf_task_mgr='Y' then
      c_task_manager:= PJM_INTEGRATION_PROJ_MFG.PJM_SELECT_TASK_MANAGER(
                             PJM_PROJECT.val_task_numtoid(c_project_number, c_task_number));
      if c_task_manager = c_requestor then
         c_task_manager:='';
      end if;
   end if;

   wf_purge.total(c_item_type,c_item_key,sysdate);

   begin
     wf_engine.CreateProcess(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,process  => c_process
                            );
   exception
     when others then
       PJM_CONC.put_line( sqlerrm );
       null;
   end;

   wf_engine.SetItemOwner(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,owner    => c_owner
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'REQUESTOR'
                            ,avalue   => c_requestor
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'TOLERANCE_DAYS'
                            ,avalue   => n_tolerance_days
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PROJECT_NUMBER'
                            ,avalue   => c_project_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PROJECT_NAME'
                            ,avalue   => c_project_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PROJECT_START_DATE'
                            ,avalue   => d_project_start_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PROJECT_END_DATE'
                            ,avalue   => d_project_end_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'TASK_NUMBER'
                            ,avalue   => c_task_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'TASK_NAME'
                            ,avalue   => c_task_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'TASK_START_DATE'
                            ,avalue   => d_task_start_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'TASK_END_DATE'
                            ,avalue   => d_task_end_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PROJECT_MANAGER'
                            ,avalue   => c_project_manager
                            );
   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'TASK_MANAGER'
                            ,avalue   => c_task_manager
                            );


   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'EXCEPTION_SUBJECT'
                            ,avalue   => c_exception_subject
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'EXCEPTION_BODY'
                            ,avalue   => c_exception_body
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'DOCUMENT_TYPE'
                            ,avalue   => c_document_type
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'ITEM_NUMBER'
                            ,avalue   => c_item_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'ITEM_DESCRIPTION'
                            ,avalue   => c_item_description
                            );

END;


/*---------------------------------------------------------------------------
   For WIP exception process
  ---------------------------------------------------------------------------*/

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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'WIP_JOB_NAME'
                            ,avalue   => c_wip_job_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'ORGANIZATION_NAME'
                            ,avalue   => c_organization_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'JOB_START_DATE'
                            ,avalue   => d_job_start_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'JOB_END_DATE'
                            ,avalue   => d_job_end_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'STATUS'
                            ,avalue   => c_status
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'JOB_TYPE'
                            ,avalue   => c_job_type
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'START_QUANTITY'
                            ,avalue   => n_start_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'QUANTITY_COMPLETED'
                            ,avalue   => n_quantity_completed
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

/*---------------------------------------------------------------------------
   For SO exception process
  ---------------------------------------------------------------------------*/
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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SO_NUMBER'
                            ,avalue   => c_so_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'LINE_NUMBER'
                            ,avalue   => c_line_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'WAREHOUSE'
                            ,avalue   => c_warehouse
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'QUANTITY'
                            ,avalue   => n_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'REQUESTED_DATE'
                            ,avalue   => d_requested_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PROMISED_DATE'
                            ,avalue   => d_promised_date
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

/*---------------------------------------------------------------------------
   For FORECAST exception process
  ---------------------------------------------------------------------------*/
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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'FORECAST_SET'
                            ,avalue   => c_forecast_set
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'FORECAST_NAME'
                            ,avalue   => c_forecast_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'ORGANIZATION_NAME'
                            ,avalue   => c_organization_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'QUANTITY'
                            ,avalue   => n_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'FORECAST_START_DATE'
                            ,avalue   => d_forecast_start_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'FORECAST_END_DATE'
                            ,avalue   => d_forecast_end_date
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

/*---------------------------------------------------------------------------
   For PR exception process
  ---------------------------------------------------------------------------*/
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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PR_NUMBER'
                            ,avalue   => c_pr_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SHIP_TO_LOCATION'
                            ,avalue   => c_ship_to_location
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'STATUS'
                            ,avalue   => c_status
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'QUANTITY'
                            ,avalue   => n_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'NEED_BY_DATE'
                            ,avalue   => d_need_by_date
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

/*---------------------------------------------------------------------------
   For RFQ exception process
  ---------------------------------------------------------------------------*/
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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'RFQ_NUMBER'
                            ,avalue   => c_rfq_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SHIP_TO_LOCATION'
                            ,avalue   => c_ship_to_location
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'STATUS'
                            ,avalue   => c_status
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'DUE_DATE'
                            ,avalue   => d_due_date
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

/*---------------------------------------------------------------------------
   For QUOTATION exception process
  ---------------------------------------------------------------------------*/
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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'QUOTATION_NUMBER'
                            ,avalue   => c_quotation_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SHIP_TO_LOCATION'
                            ,avalue   => c_ship_to_location
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'STATUS'
                            ,avalue   => c_status
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'EFF_START_DATE'
                            ,avalue   => d_eff_start_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'EFF_END_DATE'
                            ,avalue   => d_eff_end_date
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

/*---------------------------------------------------------------------------
   For MDS exception process
  ---------------------------------------------------------------------------*/
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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'MDS_NAME'
                            ,avalue   => c_mds_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'ORGANIZATION_NAME'
                            ,avalue   => c_organization_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'QUANTITY'
                            ,avalue   => n_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SCHEDULE_DATE'
                            ,avalue   => d_schedule_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SCHEDULE_END_DATE'
                            ,avalue   => d_schedule_end_date
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

/*---------------------------------------------------------------------------
   For MPS exception process
  ---------------------------------------------------------------------------*/
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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'MPS_NAME'
                            ,avalue   => c_mps_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'ORGANIZATION_NAME'
                            ,avalue   => c_organization_name
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'QUANTITY'
                            ,avalue   => n_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SCHEDULE_DATE'
                            ,avalue   => d_schedule_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SCHEDULE_END_DATE'
                            ,avalue   => d_schedule_end_date
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

/*---------------------------------------------------------------------------
   For PO exception process
  ---------------------------------------------------------------------------*/
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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PO_NUMBER'
                            ,avalue   => c_po_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SHIP_TO_LOCATION'
                            ,avalue   => c_ship_to_location
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'STATUS'
                            ,avalue   => c_status
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'ORDERED_QUANTITY'
                            ,avalue   => n_ordered_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'DELIVERED_QUANTITY'
                            ,avalue   => n_delivered_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PROMISED_DATE'
                            ,avalue   => d_promised_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'NEED_BY_DATE'
                            ,avalue   => d_need_by_date
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

/*---------------------------------------------------------------------------
   For PO_RELEASE exception process
  ---------------------------------------------------------------------------*/
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
                      ) is
BEGIN
   common_start(c_item_type
               ,c_item_key
               ,c_process
               ,c_owner
               ,c_requestor
               ,n_tolerance_days
               ,c_ntf_proj_mgr
               ,c_ntf_task_mgr
               ,c_project_number
               ,c_project_name
               ,d_project_start_date
               ,d_project_end_date
               ,c_task_number
               ,c_task_name
               ,d_task_start_date
               ,d_task_end_date
               ,c_exception_subject
               ,c_exception_body
               ,c_document_type
               ,c_item_number
               ,c_item_description
               );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PO_NUMBER'
                            ,avalue   => c_po_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'RELEASE_NUMBER'
                            ,avalue   => c_release_number
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'SHIP_TO_LOCATION'
                            ,avalue   => c_ship_to_location
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'STATUS'
                            ,avalue   => c_status
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'ORDERED_QUANTITY'
                            ,avalue   => n_ordered_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'DELIVERED_QUANTITY'
                            ,avalue   => n_delivered_quantity
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'PROMISED_DATE'
                            ,avalue   => d_promised_date
                            );

   wf_engine.SetItemAttrText(itemtype => c_item_type
                            ,itemkey  => c_item_key
                            ,aname    => 'NEED_BY_DATE'
                            ,avalue   => d_need_by_date
                            );

   wf_engine.StartProcess (itemtype => c_item_type
                          ,itemkey  => c_item_key
                          );
END;

END PJM_SCHED_INT_WF_PRIV;

/
