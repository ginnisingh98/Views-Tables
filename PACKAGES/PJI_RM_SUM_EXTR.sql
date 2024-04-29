--------------------------------------------------------
--  DDL for Package PJI_RM_SUM_EXTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_RM_SUM_EXTR" AUTHID CURRENT_USER as
/* $Header: PJISR02S.pls 120.1 2005/10/17 12:05:22 appldev noship $ */

  procedure PROCESS_DANGLING_ROWS (p_worker_id in number);

  procedure PURGE_DANGLING_ROWS (p_worker_id in number);

  procedure RES_ROWID_TABLE (p_worker_id in number);

  procedure EXTRACT_BATCH_FID_FULL(p_worker_id IN NUMBER);

  procedure EXTRACT_BATCH_FID_ROWIDS(p_worker_id IN NUMBER);

  procedure EXTRACT_BATCH_FID (p_worker_id IN NUMBER);

  procedure MOVE_DANGLING_ROWS (p_worker_id in number);

  procedure PURGE_RES_DATA (p_worker_id in number);

  procedure GET_JOB_ID_LOOKUPS (p_worker_id in number);

  procedure PROCESS_JOB_ID (p_worker_id in number);

  procedure MARK_EXTRACTED_ROWS_PRE (p_worker_id in number);

  procedure MARK_EXTRACTED_ROWS (p_worker_id in number);

  procedure MARK_EXTRACTED_ROWS_POST (p_worker_id in number);

  procedure CLEANUP_WORKER (p_worker_id in number);

  procedure WRAPUP_FAILURE;

  procedure START_HELPER (p_worker_id in number);

  procedure WORKER (p_worker_id in number);

  procedure HELPER (errbuf      out nocopy varchar2,
                    retcode     out nocopy varchar2,
                    p_worker_id in         number);

  function  WORKER_STATUS (p_worker_id in number,
                           p_mode      in varchar2) return boolean;

  procedure WAIT_FOR_WORKER (p_worker_id in number);

end PJI_RM_SUM_EXTR;

 

/
