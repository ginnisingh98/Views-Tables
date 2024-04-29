--------------------------------------------------------
--  DDL for Package Body PJM_SCHED_INT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_SCHED_INT_WF" AS
/* $Header: PJMSIWFB.pls 120.4.12000000.2 2007/07/25 21:56:09 exlin ship $ */

--  ---------------------------------------------------------------------
--  Public Functions / Procedures
--  ---------------------------------------------------------------------

PROCEDURE start_wf
( c_document_type     varchar2
, n_tolerance_days    number
, c_requestor         varchar2
, c_ntf_proj_mgr      varchar2
, c_ntf_task_mgr      varchar2
, c_item_from         varchar2
, c_item_to           varchar2
, c_project_from      varchar2
, c_project_to        varchar2
, d_date_from         varchar2
, d_date_to           varchar2
, c_oe_or_ont         varchar2
) IS

   c_item_type           varchar2(80) :='PJMINTWF';
   c_process             varchar2(80) :='PJMINTWF_P';
   c_exception_subject   varchar2(2000) :='';
   c_exception_body      varchar2(2000) :='';
   c_owner               varchar2(80) :=c_requestor;

/*---------------------------------------------------------------------------
   Define WIP,SO,MPS,MDS,FORECAST,RFQ,QTN,PO,PR cursors
  ---------------------------------------------------------------------------*/

   cursor cu_wip is
      select 'WIP'                          document_type
      ,      hou.name                       organization_name
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      we.wip_entity_name             wip_job_name
      ,      wdj.wip_entity_id              job_id
      ,      ml1.meaning                    job_type
      ,      ml2.meaning                    status
      ,      wdj.scheduled_start_date       job_start_date
      ,      wdj.scheduled_completion_date  job_end_date
      ,      wdj.start_quantity             start_quantity
      ,      wdj.quantity_completed         quantity_completed
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      wdj.project_id                 project_id
      ,      wdj.task_id                    task_id
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(wdj.scheduled_start_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date,pp.completion_date
                                                        ,pt.start_date,pt.completion_date
                                                        ) exception_days1
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(wdj.scheduled_completion_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date,pp.completion_date
                                                        ,pt.start_date,pt.completion_date
                                                        ) exception_days2
      from   wip_discrete_jobs              wdj
      ,      wip_entities                   we
      ,      fnd_lookup_values              ml1
      ,      fnd_lookup_values              ml2
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      ,      hr_all_organization_units_tl   hou
      ,      mtl_item_flexfields            mif
      where  wdj.project_id > 0
      and    wdj.status_type not in (4,5,7,12)
      and    we.wip_entity_id              = wdj.wip_entity_id
      and    ml1.view_application_id       = 700
      and    ml1.language                  = userenv('LANG')
      and    ml1.lookup_type               = 'WIP_DISCRETE_JOB'
      and    ml1.lookup_code               = wdj.job_type
      and    ml2.view_application_id       = 700
      and    ml2.language                  = userenv('LANG')
      and    ml2.lookup_type               = 'WIP_JOB_STATUS'
      and    ml2.lookup_code               = wdj.status_type
      and    pp.project_id                 = wdj.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    ((
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(wdj.scheduled_start_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <> 0
             and wdj.scheduled_start_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), wdj.scheduled_start_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , wdj.scheduled_start_date + 1)
             ) or (
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(wdj.scheduled_completion_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and wdj.scheduled_completion_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), wdj.scheduled_completion_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , wdj.scheduled_completion_date + 1)
             ))
      and    pt.task_id (+)                = wdj.task_id
      and    hou.organization_id           = wdj.organization_id
      and    hou.language                  = userenv('LANG')
      and    mif.organization_id           = wdj.organization_id
      and    mif.inventory_item_id         = wdj.primary_item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      order by hou.name , we.wip_entity_name
       ;
   lr_wip  cu_wip%rowtype;

   cursor cu_so is
      select 'SO'                           document_type
      ,      ooh.order_number               so_number
      ,      ool.line_id                    so_line_id
      ,      ool.line_number                line_number
      ,      hou.name                       warehouse
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      nvl(ool.ordered_quantity,0)    quantity
      ,      ool.request_date               requested_date
      ,      ool.promise_date               promised_date
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ool.request_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days1
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ool.promise_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days2
      ,      ool.project_id                 project_id
      ,      ool.task_id                    task_id
      from   oe_order_lines_all             ool
      ,      hr_all_organization_units_tl   hou
      ,      oe_order_headers_all           ooh
      ,      mtl_item_flexfields            mif
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      where  ool.project_id > 0
      and    nvl(ool.cancelled_flag,'N')  <> 'Y'
      and    nvl(ool.open_flag,'Y')       <> 'N'
      and    nvl(ool.shipped_quantity,0)+nvl(ool.cancelled_quantity,0) < ool.ordered_quantity
      and    ooh.header_id                 = ool.header_id
      and    hou.organization_id           = ool.ship_from_org_id
      and    hou.language                  = userenv('LANG')
      and    mif.organization_id           = ool.ship_from_org_id
      and    mif.inventory_item_id         = ool.inventory_item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      and    pp.project_id                 = ool.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    ((
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ool.request_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and ool.request_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), ool.request_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , ool.request_date + 1)
             ) or (
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ool.promise_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and ool.promise_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), ool.promise_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , ool.promise_date + 1)
             ))
      and    pt.task_id (+)                = ool.task_id
      order by 2
       ;
   lr_so  cu_so%rowtype;

   cursor cu_forecast is
      select 'FORECAST'                     document_type
      ,      mfdes.forecast_set             forecast_set
      ,      mfd.forecast_designator        forecast_name
      ,      hou.name                       organization_name
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      mfd.forecast_date              forecast_start_date
      ,      mfd.rate_end_date              forecast_end_date
      ,      mfd.current_forecast_quantity  quantity
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      mfd.transaction_id             transaction_id
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(mfd.forecast_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days1
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(mfd.rate_end_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days2
      ,      mfd.project_id                 project_id
      ,      mfd.task_id                    task_id
      from   mrp_forecast_dates             mfd
      ,      hr_all_organization_units_tl   hou
      ,      mtl_item_flexfields            mif
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      ,      mrp_forecast_designators       mfdes
      where  mfd.project_id > 0
      and    nvl(mfd.current_forecast_quantity,0) <>0
      and    mif.organization_id           = mfd.organization_id
      and    mif.inventory_item_id         = mfd.inventory_item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      and    pp.project_id                 = mfd.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    ((
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(mfd.forecast_date
                                                       ,'BETWEEN'
                                                       ,n_tolerance_days
                                                       ,pp.start_date
                                                       ,pp.completion_date
                                                       ,pt.start_date
                                                       ,pt.completion_date
                                                       ) <>0
             and mfd.forecast_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), mfd.forecast_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , mfd.forecast_date + 1)
             ) or (
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(mfd.rate_end_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and mfd.rate_end_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), mfd.rate_end_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , mfd.rate_end_date + 1)
             ))
      and    pt.task_id (+)                = mfd.task_id
      and    hou.organization_id           = mfd.organization_id
      and    hou.language                  = userenv('LANG')
      and    mfdes.forecast_designator     = mfd.forecast_designator
      and    mfdes.organization_Id         = mfd.organization_id
      order by mfd.forecast_designator
       ;
   lr_forecast  cu_forecast%rowtype;

   cursor cu_pr is
      select 'PR'                           document_type
      ,      prh.segment1                   pr_number
      ,      hou.name                       ship_to_location
      ,      nvl(prh.closed_code,prh.authorization_status) status
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      prd.req_line_quantity          quantity
      ,      prl.need_by_date               need_by_date
      ,      prd.distribution_id            distribution_id
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(prl.need_by_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days1
      ,      prd.project_id                 project_id
      ,      prd.task_id                    task_id
      from   po_requisition_lines_all           prl
      ,      po_req_distributions_all           prd
      ,      po_requisition_headers_all         prh
      ,      mtl_item_flexfields            mif
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      ,      hr_all_organization_units_tl   hou
      ,      financials_system_params_all   fsp
      where  prd.project_id > 0
      and    prd.requisition_line_id       = prl.requisition_line_id
      and    prh.requisition_header_id     = prl.requisition_header_id
      and    nvl(prh.closed_code,'OPEN') not like '%CLOSED%'
      and    nvl(prh.authorization_status,'NOT')  not in ('CANCELLED','REJECTED','RETURNED')
      and    mif.organization_id           = fsp.inventory_organization_id
      and    mif.inventory_item_id         = prl.item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      and    pp.project_id                 = prd.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(prl.need_by_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
      and    prl.need_by_date
             between nvl( fnd_date.canonical_to_date(d_date_from), prl.need_by_date - 1)
                 and nvl( fnd_date.canonical_to_date(d_date_to)  , prl.need_by_date + 1)
      and    pt.task_id (+)                = prd.task_id
      and    hou.organization_id (+)       = prl.destination_organization_id
      and    hou.language (+)              = userenv('LANG')
      and    fsp.org_id = prh.org_id
      order by prh.segment1
       ;

   lr_pr  cu_pr%rowtype;

   cursor cu_rfq is
      select 'RFQ'                          document_type
      ,      ph.segment1                    rfq_number
      ,      hl.location_code               ship_to_location
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      ph.reply_date                  due_date
      ,      pl.po_line_id                  po_line_id
      ,      plc.displayed_field            status
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ph.reply_date
                                                        ,'BEFORE_END'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days1
      ,      pl.project_id                  project_id
      ,      pl.task_id                     task_id
      from   po_lines_all                       pl
      ,      po_headers_all                     ph
      ,      po_lookup_codes                plc
      ,      hr_locations                   hl
      ,      mtl_item_flexfields            mif
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      ,      financials_system_params_all   fsp
      where  pl.project_id > 0
      and    ph.po_header_id               = pl.po_header_id
      and    ph.type_lookup_code           = 'RFQ'
      and    ph.status_lookup_code         <> 'C'
      and    plc.lookup_type               = 'RFQ/QUOTE STATUS'
      and    plc.lookup_code               = ph.status_lookup_code
      and    hl.location_id (+)            = ph.ship_to_location_id
      and    mif.organization_id           = fsp.inventory_organization_id
      and    mif.inventory_item_id         = pl.item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      and    pp.project_id                 = pl.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ph.reply_date
                                                        ,'BEFORE_END'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
      and    ph.reply_date
             between nvl( fnd_date.canonical_to_date(d_date_from), ph.reply_date - 1)
                 and nvl( fnd_date.canonical_to_date(d_date_to)  , ph.reply_date + 1)
      and    pt.task_id (+)                = pl.task_id
      and    pl.org_id = ph.org_id
      and    fsp.org_id = pl.org_id
      order by ph.segment1
       ;

   lr_rfq  cu_rfq%rowtype;

   cursor cu_quotation is
      select 'QUOTATION'                    document_type
      ,      ph.segment1                    quotation_number
      ,      hl.location_code               ship_to_location
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      ph.start_date                  eff_start_date
      ,      ph.end_date                    eff_end_date
      ,      pl.po_line_id                  po_line_id
      ,      plc.displayed_field            status
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ph.start_date
                                                        ,'BEFORE_END'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days1
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ph.end_date
                                                        ,'AFTER_END'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days2
      ,      pl.project_id                  project_id
      ,      pl.task_id                     task_id
      from   po_lines_all                       pl
      ,      po_headers_all                     ph
      ,      po_lookup_codes                plc
      ,      hr_locations                   hl
      ,      mtl_item_flexfields            mif
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      ,      financials_system_params_all   fsp
      where  pl.project_id > 0
      and    ph.po_header_id               = pl.po_header_id
      and    ph.type_lookup_code           = 'QUOTATION'
      and    ph.status_lookup_code         <> 'C'
      and    plc.lookup_type               = 'RFQ/QUOTE STATUS'
      and    plc.lookup_code               = ph.status_lookup_code
      and    hl.location_id (+)            = ph.ship_to_location_id
      and    mif.organization_id           = fsp.inventory_organization_id
      and    mif.inventory_item_id         = pl.item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      and    pp.project_id                 = pl.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    ((
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ph.start_date
                                                        ,'BEFORE_END'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and ph.start_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), ph.start_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , ph.start_date + 1)
             ) or (
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(ph.end_date
                                                        ,'AFTER_END'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and ph.end_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), ph.end_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , ph.end_date + 1)
             ))
      and    pt.task_id (+)                = pl.task_id
      and    pl.org_id = ph.org_id
      and    fsp.org_id = pl.org_id
      order by ph.segment1
       ;

   lr_quotation  cu_quotation%rowtype;

   cursor cu_mds is
      select 'MDS'                          document_type
      ,      msd.schedule_designator        mds_name
      ,      msd.mps_transaction_id         transaction_id
      ,      msd.schedule_level             schedule_level
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      msd.schedule_date              schedule_date
      ,      msd.rate_end_date              schedule_end_date
      ,      msd.original_schedule_quantity quantity
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      hou.name                       organization_name
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(msd.schedule_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days1
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(msd.rate_end_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days2
      ,      msd.project_id                 project_id
      ,      msd.task_id                    task_id
      from   mrp_schedule_dates             msd
      ,      hr_all_organization_units_tl   hou
      ,      mtl_item_flexfields            mif
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      where  msd.project_id > 0
      and    nvl(decode(mif.repetitive_planning_flag,
                        'Y',msd.repetitive_daily_rate
                           ,msd.schedule_quantity),0) <>0
      and    msd.supply_demand_type        = 1
      and    msd.schedule_level            = 2
      and    mif.organization_id           = msd.organization_id
      and    mif.inventory_item_id         = msd.inventory_item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      and    hou.organization_id           = msd.organization_id
      and    hou.language                  = userenv('LANG')
      and    pp.project_id                 = msd.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    ((
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(msd.schedule_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and msd.schedule_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), msd.schedule_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , msd.schedule_date + 1)
             ) or (
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(msd.rate_end_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and msd.rate_end_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), msd.rate_end_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , msd.rate_end_date + 1)
             ))
      and    pt.task_id (+)                = msd.task_id
      order by msd.schedule_designator
           ;
   lr_mds  cu_mds%rowtype;

   cursor cu_mps is
      select 'MPS'                          document_type
      ,      msd.schedule_designator        mps_name
      ,      msd.mps_transaction_id         transaction_id
      ,      msd.schedule_level             schedule_level
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      msd.schedule_date              schedule_date
      ,      msd.rate_end_date              schedule_end_date
      ,      msd.original_schedule_quantity quantity
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      hou.name                       organization_name
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(msd.schedule_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days1
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(msd.rate_end_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days2
      ,      msd.project_id                 project_id
      ,      msd.task_id                    task_id
      from   mrp_schedule_dates             msd
      ,      hr_all_organization_units_tl   hou
      ,      mtl_item_flexfields            mif
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      where  msd.project_id > 0
      and    nvl(decode(mif.repetitive_planning_flag,
                        'Y',msd.repetitive_daily_rate
                           ,msd.schedule_quantity),0) <>0
      and    msd.supply_demand_type        = 2
      and    msd.schedule_level            = 2
      and    mif.organization_id           = msd.organization_id
      and    mif.inventory_item_id         = msd.inventory_item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      and    hou.organization_id           = msd.organization_id
      and    hou.language                  = userenv('LANG')
      and    pp.project_id                 = msd.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    ((
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(msd.schedule_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and msd.schedule_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), msd.schedule_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , msd.schedule_date + 1)
             ) or (
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(msd.rate_end_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and msd.rate_end_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), msd.rate_end_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , msd.rate_end_date + 1)
             ))
      and    pt.task_id (+)                = msd.task_id
      order by msd.schedule_designator
           ;
   lr_mps  cu_mps%rowtype;

   cursor cu_po is
      select 'PO'                           document_type
      ,      ph.segment1                    po_number
      ,      PO_HEADERS_SV3.GET_PO_STATUS(ph.po_header_id)  status
      ,      hou.name                       ship_to_location
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      pd.quantity_ordered            ordered_quantity
      ,      pd.quantity_delivered          delivered_quantity
      ,      pd.po_distribution_id          po_distribution_id
      ,      pll.promised_date              promised_date
      ,      pll.need_by_date               need_by_date
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(pll.promised_date
                                                       ,'BETWEEN'
                                                       ,0
                                                       ,pp.start_date
                                                       ,pp.completion_date
                                                       ,pt.start_date
                                                       ,pt.completion_date
                                                       ) exception_days1
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(pll.need_by_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days2
      ,      pd.project_id                  project_id
      ,      pd.task_id                     task_id
      from   po_distributions_all               pd
      ,      po_line_locations_all              pll
      ,      po_lines_all                       pl
      ,      po_headers_all                     ph
      ,      mtl_item_flexfields            mif
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      ,      hr_all_organization_units_tl   hou
      ,      financials_system_params_all   fsp
      where  pd.project_id > 0
      and    pd.po_release_id is null
      and    pll.line_location_id          = pd.line_location_id
      and    pl.po_line_id                 = pll.po_line_id
      and    ph.po_header_id               = pl.po_header_id
      and    nvl(pl.cancel_flag, 'N') <> 'Y' /* Bug 6262080; base bug 5757447 */
      and    nvl(ph.closed_code,'OPEN') not like '%CLOSED%'
      and    nvl(ph.authorization_status,'N') not in ('CANCELLED','REJECTED')
      and    mif.organization_id           = fsp.inventory_organization_id
      and    mif.inventory_item_id         = pl.item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      and    pp.project_id                 = pd.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    ((
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(pll.promised_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and pll.promised_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), pll.promised_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , pll.promised_date + 1)
             ) or (
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(pll.need_by_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and pll.need_by_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), pll.need_by_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , pll.need_by_date + 1)
             ))
      and    pt.task_id (+)                = pd.task_id
      and    hou.organization_id (+)       = pd.destination_organization_id
      and    hou.language (+)              = userenv('LANG')
      and    ph.org_id = pl.org_id
      and    pl.org_id = pd.org_id
      and    pl.org_id = fsp.org_id
      and    pl.org_id = pll.org_id
      order by ph.segment1
       ;
   lr_po  cu_po%rowtype;

   cursor cu_po_release is
      select 'BLANKET_RELEASE'              document_type
      ,      ph.segment1                    po_number
      ,      PO_HEADERS_SV3.GET_PO_STATUS(ph.po_header_id)  status
      ,      hou.name                       ship_to_location
      ,      pr.release_num                 release_number
      ,      mif.item_number                item_number
      ,      mif.description                description
      ,      pd.quantity_ordered            ordered_quantity
      ,      pd.quantity_delivered          delivered_quantity
      ,      pd.po_distribution_id          po_distribution_id
      ,      pll.promised_date              promised_date
      ,      pll.need_by_date               need_by_date
      ,      pp.segment1                    project_number
      ,      pp.name                        project_name
      ,      pp.start_date                  project_start_date
      ,      pp.completion_date             project_end_date
      ,      pt.task_number                 task_number
      ,      pt.task_name                   task_name
      ,      pt.start_date                  task_start_date
      ,      pt.completion_date             task_end_date
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(pll.promised_date
                                                        ,'BETWEEN'
                                                        ,0
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) exception_days1
      ,      PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(pll.need_by_date
                                                       ,'BETWEEN'
                                                       ,0
                                                       ,pp.start_date
                                                       ,pp.completion_date
                                                       ,pt.start_date
                                                       ,pt.completion_date
                                                       ) exception_days2
      ,      pd.project_id                  project_id
      ,      pd.task_id                     task_id
      from   po_distributions_all               pd
      ,      po_releases_all                    pr
      ,      po_line_locations_all              pll
      ,      po_lines_all                       pl
      ,      po_headers_all                     ph
      ,      mtl_item_flexfields            mif
      ,      pa_projects_all                pp
      ,      pa_tasks                       pt
      ,      hr_all_organization_units_tl   hou
      ,      financials_system_params_all   fsp
      where  pd.project_id > 0
      and    pd.po_release_id is not null
      and    pr.po_release_id              = pd.po_release_id
      and    pll.line_location_id          = pd.line_location_id
      and    pl.po_line_id                 = pll.po_line_id
      and    ph.po_header_id               = pl.po_header_id
      and    nvl(ph.closed_code,'OPEN') not like '%CLOSED%'
      and    nvl(ph.authorization_status,'N') not in ('CANCELLED','REJECTED')
      and    nvl(pr.closed_code,'OPEN') not like '%CLOSED%'
      and    nvl(pr.authorization_status,'N') not in ('CANCELLED','REJECTED')
      and    nvl(pr.cancel_flag,'N') <> 'Y'
      and    mif.organization_id           = fsp.inventory_organization_id
      and    mif.inventory_item_id         = pl.item_id
      and    ( c_item_from is null or mif.item_number >= c_item_from )
      and    ( c_item_to   is null or mif.item_number <= c_item_to )
      and    pp.project_id                 = pd.project_id
      and    ( c_project_from is null or pp.project_id >= c_project_from )
      and    ( c_project_to   is null or pp.project_id <= c_project_to )
      and    ((
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(pll.promised_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and pll.promised_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), pll.promised_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , pll.promised_date + 1)
             ) or (
             PJM_INTEGRATION_PROJ_MFG.PJM_EXCEPTION_DAYS(pll.need_by_date
                                                        ,'BETWEEN'
                                                        ,n_tolerance_days
                                                        ,pp.start_date
                                                        ,pp.completion_date
                                                        ,pt.start_date
                                                        ,pt.completion_date
                                                        ) <>0
             and pll.need_by_date
                 between nvl( fnd_date.canonical_to_date(d_date_from), pll.need_by_date - 1)
                     and nvl( fnd_date.canonical_to_date(d_date_to)  , pll.need_by_date + 1)
             ))
      and    pt.task_id (+)                = pd.task_id
      and    hou.organization_id (+)       = pd.destination_organization_id
      and    hou.language (+)              = userenv('LANG')
      and    ph.org_id = pl.org_id
      and    pl.org_id = pd.org_id
      and    pl.org_id = fsp.org_id
      and    pl.org_id = pll.org_id
      and    pl.org_id = pr.org_id
      order by ph.segment1
       ;
   lr_po_release  cu_po_release%rowtype;

   procedure timestamp ( mesg varchar2 ) is
   begin
     PJM_CONC.put_line( rpad( mesg || ' ' , 50 , '.' ) || ' ' ||
                        fnd_date.date_to_displaydt(sysdate) );
   end timestamp;

BEGIN

   IF upper(c_document_type) = 'WIP' or c_document_type is null then

      timestamp('Processing Work in Process');

      OPEN cu_wip;
      LOOP
         FETCH cu_wip INTO lr_wip;
         EXIT WHEN cu_wip%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_wip.exception_days1 <> 0 THEN
            IF lr_wip.exception_days1 > 0 THEN
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ JOB SDATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY JOB SDATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_wip.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            ELSE
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ JOB SDATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY JOB SDATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_wip.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            END IF;
         END IF;

         IF lr_wip.exception_days2 <> 0 THEN
            IF lr_wip.exception_days2 > 0 THEN
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ JOB CDATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY JOB CDATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_wip.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            ELSE
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ JOB CDATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY JOB CDATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_wip.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            END IF;
         END IF;

         PJM_SCHED_INT_WF_PRIV.launch_wip(c_item_type
                   ,c_requestor || '.WIP.' || to_char(lr_wip.job_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_wip.project_number
                   ,lr_wip.project_name
                   ,lr_wip.project_start_date
                   ,lr_wip.project_end_date
                   ,lr_wip.task_number
                   ,lr_wip.task_name
                   ,lr_wip.task_start_date
                   ,lr_wip.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_wip.document_type
                   ,lr_wip.item_number
                   ,lr_wip.description
                   ,lr_wip.wip_job_name
                   ,lr_wip.organization_name
                   ,lr_wip.job_start_date
                   ,lr_wip.job_end_date
                   ,lr_wip.status
                   ,lr_wip.job_type
                   ,lr_wip.start_quantity
                   ,lr_wip.quantity_completed
                   );

      END LOOP;

      PJM_CONC.put_line(cu_wip%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_wip;
   END IF;

   IF upper(c_document_type) = 'SO' or c_document_type is null then

      timestamp('Processing Sales Order');

      OPEN cu_so;
      LOOP
         FETCH cu_so INTO lr_so;
         EXIT WHEN cu_so%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_so.exception_days1 <> 0 THEN
            IF lr_so.exception_days1 > 0 THEN
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ REQ DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY REQ DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_so.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            ELSE
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ REQ DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY REQ DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_so.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            END IF;
         END IF;

         IF lr_so.exception_days2 <> 0 THEN
            IF lr_so.exception_days2 > 0 THEN
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ PROMISED DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY PROMISED DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_so.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            ELSE
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ PROMISED DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY PROMISED DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_so.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            END IF;
         END IF;


         PJM_SCHED_INT_WF_PRIV.launch_so (c_item_type
                   ,c_requestor || '.SO.' || to_char(lr_so.so_line_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_so.project_number
                   ,lr_so.project_name
                   ,lr_so.project_start_date
                   ,lr_so.project_end_date
                   ,lr_so.task_number
                   ,lr_so.task_name
                   ,lr_so.task_start_date
                   ,lr_so.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_so.document_type
                   ,lr_so.item_number
                   ,lr_so.description
                   ,to_char(lr_so.so_number)
                   ,to_char(lr_so.line_number)
                   ,lr_so.warehouse
                   ,lr_so.quantity
                   ,lr_so.requested_date
                   ,lr_so.promised_date
                  );


      END LOOP;

      PJM_CONC.put_line(cu_so%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_so;
   END IF;

   IF upper(c_document_type) = 'FORECAST' or c_document_type is null then

      timestamp('Processing Forecast');

      OPEN cu_forecast;
      LOOP
         FETCH cu_forecast INTO lr_forecast;
         EXIT WHEN cu_forecast%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_forecast.exception_days1 <> 0 THEN
            IF lr_forecast.exception_days1 > 0 THEN
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ FC DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY FC DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_forecast.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            ELSE
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ FC DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY FC DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_forecast.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            END IF;
         END IF;

         IF lr_forecast.exception_days2 <> 0 THEN
            IF lr_forecast.exception_days2 > 0 THEN
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ FC EDATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY FC EDATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_forecast.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            ELSE
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ FC EDATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY FC EDATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_forecast.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            END IF;
         END IF;

         PJM_SCHED_INT_WF_PRIV.launch_forecast(c_item_type
                   ,c_requestor || '.FCST.' || to_char(lr_forecast.transaction_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_forecast.project_number
                   ,lr_forecast.project_name
                   ,lr_forecast.project_start_date
                   ,lr_forecast.project_end_date
                   ,lr_forecast.task_number
                   ,lr_forecast.task_name
                   ,lr_forecast.task_start_date
                   ,lr_forecast.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_forecast.document_type
                   ,lr_forecast.item_number
                   ,lr_forecast.description
                   ,lr_forecast.forecast_set
                   ,lr_forecast.forecast_name
                   ,lr_forecast.organization_name
                   ,lr_forecast.quantity
                   ,lr_forecast.forecast_start_date
                   ,lr_forecast.forecast_end_date
                   );

      END LOOP;

      PJM_CONC.put_line(cu_forecast%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_forecast;
   END IF;

   IF upper(c_document_type) = 'PR' or c_document_type is null then

      timestamp('Processing Purchase Requisition');

      OPEN cu_pr;
      LOOP
         FETCH cu_pr INTO lr_pr;
         EXIT WHEN cu_pr%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_pr.exception_days1 <> 0 THEN
            IF lr_pr.exception_days1 > 0 THEN
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ NEEDBY DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY NEEDBY DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_pr.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            ELSE
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ NEEDBY DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY NEEDBY DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_pr.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            END IF;
         END IF;

         PJM_SCHED_INT_WF_PRIV.launch_pr(c_item_type
                   ,c_requestor || '.PR.' || to_char(lr_pr.distribution_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_pr.project_number
                   ,lr_pr.project_name
                   ,lr_pr.project_start_date
                   ,lr_pr.project_end_date
                   ,lr_pr.task_number
                   ,lr_pr.task_name
                   ,lr_pr.task_start_date
                   ,lr_pr.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_pr.document_type
                   ,lr_pr.item_number
                   ,lr_pr.description
                   ,lr_pr.pr_number
                   ,lr_pr.ship_to_location
                   ,lr_pr.status
                   ,lr_pr.quantity
                   ,lr_pr.need_by_date
                   );
      END LOOP;

      PJM_CONC.put_line(cu_pr%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_pr;
   END IF;

   IF upper(c_document_type) = 'RFQ' or c_document_type is null then

      timestamp('Processing Request for Quotation');

      OPEN cu_rfq;
      LOOP
         FETCH cu_rfq INTO lr_rfq;
         EXIT WHEN cu_rfq%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_rfq.exception_days1 <> 0 THEN
            c_exception_subject:=
               FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ DUE DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY DUE DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_rfq.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
         END IF;

         PJM_SCHED_INT_WF_PRIV.launch_rfq(c_item_type
                   ,c_requestor || '.RFQ.' || to_char(lr_rfq.po_line_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_rfq.project_number
                   ,lr_rfq.project_name
                   ,lr_rfq.project_start_date
                   ,lr_rfq.project_end_date
                   ,lr_rfq.task_number
                   ,lr_rfq.task_name
                   ,lr_rfq.task_start_date
                   ,lr_rfq.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_rfq.document_type
                   ,lr_rfq.item_number
                   ,lr_rfq.description
                   ,lr_rfq.rfq_number
                   ,lr_rfq.ship_to_location
                   ,lr_rfq.status
                   ,lr_rfq.due_date
                   );

      END LOOP;

      PJM_CONC.put_line(cu_rfq%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_rfq;
   END IF;

   IF upper(c_document_type) = 'QUOTATION' or c_document_type is null then

      timestamp('Processing Quotation');

      OPEN cu_quotation;
      LOOP
         FETCH cu_quotation INTO lr_quotation;
         EXIT WHEN cu_quotation%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_quotation.exception_days1 <> 0 THEN
            c_exception_subject:=
               FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ EFF DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY EFF DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_quotation.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
         END IF;

         IF lr_quotation.exception_days2 <> 0 THEN
               c_exception_subject:= c_exception_subject || ' / ' ||
               FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ EFF DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY EFF DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_quotation.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
         END IF;

         PJM_SCHED_INT_WF_PRIV.launch_quotation(c_item_type
                   ,c_requestor || '.QUOTE.' || to_char(lr_quotation.po_line_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_quotation.project_number
                   ,lr_quotation.project_name
                   ,lr_quotation.project_start_date
                   ,lr_quotation.project_end_date
                   ,lr_quotation.task_number
                   ,lr_quotation.task_name
                   ,lr_quotation.task_start_date
                   ,lr_quotation.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_quotation.document_type
                   ,lr_quotation.item_number
                   ,lr_quotation.description
                   ,lr_quotation.quotation_number
                   ,lr_quotation.ship_to_location
                   ,lr_quotation.status
                   ,lr_quotation.eff_start_date
                   ,lr_quotation.eff_end_date
                   );

      END LOOP;

      PJM_CONC.put_line(cu_quotation%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_quotation;
   END IF;

   IF upper(c_document_type) = 'MDS' or c_document_type is null then

      timestamp('Processing Master Demand Schedule');

      OPEN cu_mds;
      LOOP
         FETCH cu_mds INTO lr_mds;
         EXIT WHEN cu_mds%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_mds.exception_days1 <> 0 THEN
            IF lr_mds.exception_days1 > 0 THEN
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ SCHED DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY SCHED DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_mds.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            ELSE
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ SCHED DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY SCHED DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_mds.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            END IF;
         END IF;

         IF lr_mds.exception_days2 <> 0 THEN
            IF lr_mds.exception_days2 > 0 THEN
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ SCHED EDATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY SCHED EDATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_mds.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            ELSE
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ SCHED EDATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY SCHED EDATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_mds.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            END IF;
         END IF;

         PJM_SCHED_INT_WF_PRIV.launch_mds(c_item_type
                   ,c_requestor || '.MDS.' || to_char(lr_mds.transaction_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_mds.project_number
                   ,lr_mds.project_name
                   ,lr_mds.project_start_date
                   ,lr_mds.project_end_date
                   ,lr_mds.task_number
                   ,lr_mds.task_name
                   ,lr_mds.task_start_date
                   ,lr_mds.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_mds.document_type
                   ,lr_mds.item_number
                   ,lr_mds.description
                   ,lr_mds.mds_name
                   ,lr_mds.organization_name
                   ,lr_mds.quantity
                   ,lr_mds.schedule_date
                   ,lr_mds.schedule_end_date
                   );

      END LOOP;

      PJM_CONC.put_line(cu_mds%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_mds;
   END IF;

   IF upper(c_document_type) = 'MPS' or c_document_type is null then

      timestamp('Processing Master Production Schedule');

      OPEN cu_mps;
      LOOP
         FETCH cu_mps INTO lr_mps;
         EXIT WHEN cu_mps%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_mps.exception_days1 <> 0 THEN
            IF lr_mps.exception_days1 > 0 THEN
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ SCHED DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY SCHED DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_mps.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            ELSE
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ SCHED DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY SCHED DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_mps.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            END IF;
         END IF;

         IF lr_mps.exception_days2 <> 0 THEN
            IF lr_mps.exception_days2 > 0 THEN
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ SCHED EDATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY SCHED EDATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_mps.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            ELSE
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ SCHED EDATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY SCHED EDATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_mps.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            END IF;
         END IF;

         PJM_SCHED_INT_WF_PRIV.launch_mps(c_item_type
                   ,c_requestor || '.MPS.' || to_char(lr_mps.transaction_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_mps.project_number
                   ,lr_mps.project_name
                   ,lr_mps.project_start_date
                   ,lr_mps.project_end_date
                   ,lr_mps.task_number
                   ,lr_mps.task_name
                   ,lr_mps.task_start_date
                   ,lr_mps.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_mps.document_type
                   ,lr_mps.item_number
                   ,lr_mps.description
                   ,lr_mps.mps_name
                   ,lr_mps.organization_name
                   ,lr_mps.quantity
                   ,lr_mps.schedule_date
                   ,lr_mps.schedule_end_date
                   );

      END LOOP;

      PJM_CONC.put_line(cu_mps%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_mps;
   END IF;

   IF upper(c_document_type) = 'PO' or c_document_type is null then

      timestamp('Processing Purchase Order');

      OPEN cu_po;
      LOOP
         FETCH cu_po INTO lr_po;
         EXIT WHEN cu_po%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_po.exception_days1 <> 0 THEN
            IF lr_po.exception_days1 > 0 THEN
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ PROMISED DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY PROMISED DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_po.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            ELSE
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ PROMISED DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY PROMISED DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_po.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            END IF;
         END IF;

         IF lr_po.exception_days2 <> 0 THEN
            IF lr_po.exception_days2 > 0 THEN
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ NEEDBY DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY NEEDBY DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_po.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            ELSE
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ NEEDBY DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY NEEDBY DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_po.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            END IF;
         END IF;

         PJM_SCHED_INT_WF_PRIV.launch_po (c_item_type
                   ,c_requestor || '.PO.' || to_char(lr_po.po_distribution_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_po.project_number
                   ,lr_po.project_name
                   ,lr_po.project_start_date
                   ,lr_po.project_end_date
                   ,lr_po.task_number
                   ,lr_po.task_name
                   ,lr_po.task_start_date
                   ,lr_po.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_po.document_type
                   ,lr_po.item_number
                   ,lr_po.description
                   ,lr_po.po_number
                   ,lr_po.ship_to_location
                   ,lr_po.status
                   ,lr_po.ordered_quantity
                   ,lr_po.delivered_quantity
                   ,lr_po.promised_date
                   ,lr_po.need_by_date
                   );
      END LOOP;

      PJM_CONC.put_line(cu_po%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_po;
   END IF;

   IF upper(c_document_type) = 'BLANKET_RELEASE' or c_document_type is null then

      timestamp('Processing Blanket Release');

      OPEN cu_po_release;
      LOOP
         FETCH cu_po_release INTO lr_po_release;
         EXIT WHEN cu_po_release%NOTFOUND;

         c_exception_subject :='';
         c_exception_body    :='';

         IF lr_po_release.exception_days1 <> 0 THEN
            IF lr_po_release.exception_days1 > 0 THEN
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ PROMISED DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY PROMISED DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_po_release.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            ELSE
               c_exception_subject:=
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ PROMISED DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY PROMISED DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_po_release.exception_days1));
               c_exception_body := FND_MESSAGE.GET;
            END IF;
         END IF;

         IF lr_po_release.exception_days2 <> 0 THEN
            IF lr_po_release.exception_days2 > 0 THEN
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ NEEDBY DATE EARLY');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY NEEDBY DATE EARLY');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_po_release.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            ELSE
               c_exception_subject:= c_exception_subject || ' / ' ||
                  FND_MESSAGE.GET_STRING('PJM','SCHED-SUBJ NEEDBY DATE LATE');

               FND_MESSAGE.SET_NAME('PJM','SCHED-BODY NEEDBY DATE LATE');
               FND_MESSAGE.SET_TOKEN('NUM', abs(lr_po_release.exception_days2));
               c_exception_body := c_exception_body || fnd_global.newline || FND_MESSAGE.GET;
            END IF;
         END IF;


         PJM_SCHED_INT_WF_PRIV.launch_po_release (c_item_type
                   ,c_requestor || '.BR.' || to_char(lr_po_release.po_distribution_id)
                   ,c_process
                   ,c_owner
                   ,c_requestor
                   ,n_tolerance_days
                   ,c_ntf_proj_mgr
                   ,c_ntf_task_mgr
                   ,lr_po_release.project_number
                   ,lr_po_release.project_name
                   ,lr_po_release.project_start_date
                   ,lr_po_release.project_end_date
                   ,lr_po_release.task_number
                   ,lr_po_release.task_name
                   ,lr_po_release.task_start_date
                   ,lr_po_release.task_end_date
                   ,c_exception_subject
                   ,c_exception_body
                   ,lr_po_release.document_type
                   ,lr_po_release.item_number
                   ,lr_po_release.description
                   ,lr_po_release.po_number
                   ,to_char(lr_po_release.release_number)
                   ,lr_po_release.ship_to_location
                   ,lr_po_release.status
                   ,lr_po_release.ordered_quantity
                   ,lr_po_release.delivered_quantity
                   ,lr_po_release.promised_date
                   ,lr_po_release.need_by_date
                   );

      END LOOP;

      PJM_CONC.put_line(cu_po_release%rowcount || ' exception(s) found.' || fnd_global.newline);

      CLOSE cu_po_release;
   END IF;

   commit;

END start_wf;


END PJM_SCHED_INT_WF;

/
