--------------------------------------------------------
--  DDL for Package WIP_WS_EMBEDDED_ANALYTICS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_EMBEDDED_ANALYTICS_PK" AUTHID CURRENT_USER as
/* $Header: wipwseas.pls 120.5 2008/03/18 00:21:17 awongwai noship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| FILE NAME   : WIPWSEAS.sql
| DESCRIPTION :
|              This package contains specification for all APIs related to
               MES First Pass Yield and Parts per Million Defects module
|
| HISTORY     : created   10-DEC-07
|             Nitikorn Tangjeerawong 10-DEC-2007   Creating Initial Version
|

*============================================================================*/

gUserId  number;
gLoginId number;

g_logLevel NUMBER     := FND_LOG.g_current_runtime_level;
g_user_id NUMBER      := FND_GLOBAL.user_id;
g_login_id NUMBER     := FND_GLOBAL.login_id;
g_prog_appid NUMBER   := FND_PROFILE.value('RESP_APPL_ID');
g_prog_id NUMBER      := FND_PROFILE.value('PROGRAM_ID');
g_prog_run_date DATE  := sysdate;
g_request_id NUMBER   := FND_PROFILE.value('REQUEST_ID');
g_init_obj_ver NUMBER := 1;

/* Package constants */

  FUNCTION get_shift_info(
          p_org_id        IN NUMBER,
          p_department_id IN NUMBER,
          p_transaction_date IN DATE) RETURN NUMBER;

  PROCEDURE populate_fpy_raw_data(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_jobop_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_jobop_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_jobop_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);



  PROCEDURE calc_fpy_per_jobop_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_job_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_job_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_job_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_job_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_dept_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_dept_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_dept_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_dept_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_all_depts_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_all_depts_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_all_depts_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_all_depts_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_assm_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_assm_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_assm_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_per_assm_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

---------------------- Group call

  PROCEDURE calc_fpy_for_jobop_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_for_job_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_for_assm_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_for_dept_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calc_fpy_for_all_depts_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  FUNCTION get_start_shift_date_to_calc(p_org_id IN NUMBER,
                       p_department_id IN NUMBER,
                       p_execution_date IN DATE) return DATE;

  PROCEDURE delete_old_and_replacing_data(
              p_calc_start_date IN DATE,
              p_retention_boundary IN DATE,
              p_org_id IN NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE wip_ws_fpykpi_conc_prog(
                               errbuf            out nocopy varchar2,
                               retcode           out nocopy varchar2,
                               p_org_id          in  number);

  PROCEDURE wip_ws_ppmdkpi_conc_prog(
             errbuf            out nocopy varchar2,
             retcode           out nocopy varchar2,
             p_org_id          in  number);

  FUNCTION get_shift_info_for_date (
    p_org_id in number,
    p_dept_id in number,
    p_resource_id in number,
    p_date in date
  ) return varchar2;

  FUNCTION get_shift_seq(p_shift_info VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_shift_num(p_shift_info VARCHAR2) RETURN NUMBER;

  FUNCTION get_shift_start_date(p_shift_info VARCHAR2) RETURN DATE;

  PROCEDURE populate_ppm_defects_data(
              p_start_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);





END WIP_WS_EMBEDDED_ANALYTICS_PK;

/
