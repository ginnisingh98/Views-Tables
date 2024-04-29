--------------------------------------------------------
--  DDL for Package WIP_WS_PTPKPI_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_PTPKPI_PK" AUTHID CURRENT_USER as
/* $Header: WIPWSPPS.pls 120.4.12010000.3 2008/09/03 00:26:43 awongwai ship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| FILE NAME   : WIPWSPPS.sql
| DESCRIPTION :
|              This package contains specification for all APIs related to
               MES production to Plan module
|
| HISTORY     : created   13-SEP-07
|             Renga Kannan 13-Sep-2007   Creating Initial Version
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

Type org_ptpkpi_rec_type is record(
  org_id              NUMBER,
  inc_released_jobs   NUMBER,
  inc_unreleased_jobs NUMBER,
  inc_onhold_jobs     NUMBER,
  inc_completed_jobs  NUMBER,
  inc_standard_jobs   NUMBER,
  inc_nonstd_jobs     NUMBER
);

/* Package constants */

g_pref_id_ptp NUMBER := 40;
g_pref_level_id_site NUMBER := 1;
g_pref_val_mast_org_att       VARCHAR2(30) := 'masterorg';
g_pref_val_dtl_org_att        VARCHAR2(30) := 'detailorg';
g_pref_val_inc_release_att    VARCHAR2(30) := 'released';
g_pref_val_inc_unreleased_att VARCHAR2(30) := 'unreleased';
g_pref_val_inc_onhold_att     VARCHAR2(30) := 'onhold';
g_pref_val_inc_completed_att  VARCHAR2(30) := 'complete';
g_pref_val_inc_standard_att   VARCHAR2(30) := 'standard';
g_pref_val_inc_nonstd_att     VARCHAR2(30) := 'nonstandard';


Procedure wip_ws_PTPKPI_CONC_PROG(
                             errbuf            out nocopy varchar2,
                             retcode           out nocopy varchar2,
                             p_org_id          in  number);

Procedure get_org_ptpkpi_param(
            p_org_id IN NUMBER,
            x_pref_exists  out nocopy varchar2,
            x_org_ptpkpi_rec OUT NOCOPY org_ptpkpi_rec_type);

FUNCTION get_pref_job_statuses(
            p_org_ptpkpi_rec IN org_ptpkpi_rec_type) RETURN VARCHAR2;

FUNCTION get_job_types(
            p_org_ptpkpi_rec IN org_ptpkpi_rec_type) RETURN VARCHAR2;


END WIP_WS_PTPKPI_PK;

/
