--------------------------------------------------------
--  DDL for Package PJI_FM_SUM_ROLLUP_ACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_SUM_ROLLUP_ACT" AUTHID CURRENT_USER as
  /* $Header: PJISF05S.pls 120.2 2005/11/10 20:20:08 appldev noship $ */

  procedure ACT_ROWID_TABLE (p_worker_id in number);

  procedure AGGREGATE_ACT_SLICES (p_worker_id in number);

  procedure PURGE_ACT_DATA (p_worker_id in number);

  procedure EXPAND_ACT_CAL_EN (p_worker_id in number,
                               p_backlog_flag in varchar2 default 'N');

  procedure EXPAND_ACT_CAL_PA (p_worker_id in number,
                               p_backlog_flag in varchar2 default 'N');

  procedure EXPAND_ACT_CAL_GL (p_worker_id in number,
                               p_backlog_flag in varchar2 default 'N');

  procedure EXPAND_ACT_CAL_WK (p_worker_id in number,
                               p_backlog_flag in varchar2 default 'N');

  procedure MERGE_ACT_INTO_ACP (p_worker_id in number,
                                p_backlog_flag in varchar2 default 'N');

  procedure PROJECT_ORGANIZATION (p_worker_id in number);

  procedure REFRESH_MVIEW_ACO (p_worker_id in number);

  procedure REFRESH_MVIEW_ACC (p_worker_id in number);

end PJI_FM_SUM_ROLLUP_ACT;

 

/
