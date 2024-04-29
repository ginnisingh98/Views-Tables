--------------------------------------------------------
--  DDL for Package WIP_MRP_RELIEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MRP_RELIEF" AUTHID CURRENT_USER AS
/* $Header: wipmrps.pls 120.0.12010000.2 2010/02/11 04:10:58 pding ship $ */

PROCEDURE WIP_DISCRETE_JOBS_PROC
 (item_id               IN NUMBER,
  org_id                IN NUMBER,
  last_upd_date         IN DATE,
  last_upd_by           IN NUMBER,
  creat_date            IN DATE,
  creat_by              IN NUMBER,
  new_mps_quantity      IN NUMBER,
  old_mps_quantity      IN NUMBER,
  new_start_quantity    IN NUMBER, /*add for bug 8979443 (FP of 8420494)*/
  old_start_quantity    IN NUMBER, /*add for bug 8979443 (FP of 8420494)*/
  new_sched_compl_date  IN DATE,
  old_sched_compl_date  IN DATE,
  wip_enty_id           IN NUMBER,
  srce_code             IN VARCHAR2,
  srce_line_id          IN NUMBER,
  new_bill_desig        IN VARCHAR2,
  old_bill_desig        IN VARCHAR2,
  new_bill_rev_date     IN DATE,
  old_bill_rev_date     IN DATE,
  new_dmd_class         IN VARCHAR2,
  old_dmd_class         IN VARCHAR2,
  new_status_type       IN NUMBER,
  old_status_type       IN NUMBER,
  new_qty_completed     IN NUMBER,
  old_qty_completed     IN NUMBER,
  new_date_completed    IN DATE,
  old_date_completed    IN DATE,
  new_project_id	IN NUMBER,
  old_project_id	IN NUMBER,
  new_task_id		IN NUMBER,
  old_task_id		IN NUMBER);

PROCEDURE WIP_FLOW_SCHEDULES_PROC
 (item_id               IN NUMBER,
  org_id                IN NUMBER,
  last_upd_date         IN DATE,
  last_upd_by           IN NUMBER,
  creat_date            IN DATE,
  creat_by              IN NUMBER,
  new_request_id        IN NUMBER,
  old_request_id        IN NUMBER,
  dmd_src_type    	IN NUMBER,
  dmd_src_line      	IN VARCHAR2,
  new_mps_quantity      IN NUMBER,
  old_mps_quantity      IN NUMBER,
  new_sched_compl_date  IN DATE,
  old_sched_compl_date  IN DATE,
  wip_enty_id           IN NUMBER,
  new_dmd_class         IN VARCHAR2,
  old_dmd_class         IN VARCHAR2,
  new_bill_desig        IN VARCHAR2,
  old_bill_desig        IN VARCHAR2,
  new_status_type       IN NUMBER,
  old_status_type       IN NUMBER,
  new_qty_completed     IN NUMBER,
  old_qty_completed     IN NUMBER,
  new_date_completed    IN DATE,
  old_date_completed    IN DATE,
  new_project_id	IN NUMBER,
  old_project_id	IN NUMBER,
  new_task_id		IN NUMBER,
  old_task_id		IN NUMBER);

END WIP_MRP_RELIEF;

/
