--------------------------------------------------------
--  DDL for Package PJI_PJP_EXTRACTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PJP_EXTRACTION_UTILS" AUTHID CURRENT_USER as
  /* $Header: PJIUT06S.pls 120.1 2006/11/10 13:33:37 akgupta noship $ */

  procedure SET_WORKER_ID (p_worker_id in number);

  function GET_WORKER_ID return number;

  procedure UPDATE_EXTR_SCOPE;

  procedure POPULATE_ORG_EXTR_INFO;

  procedure UPDATE_ORG_EXTR_INFO;

  procedure SEED_PJI_PJP_STATS(p_worker_id in number);

  procedure ANALYZE_PJP_FACTS;

  procedure TRUNCATE_PJP_TABLES
  (
    errbuf        out nocopy varchar2,
    retcode       out nocopy varchar2,
    p_check       in         varchar2 default 'N',
    p_fpm_upgrade in         varchar2 default 'Y',
    p_recover     in         varchar2 default 'N'
  );

  function LAST_PJP_EXTR_DATE (p_project_id in number default null ) return date;

end PJI_PJP_EXTRACTION_UTILS;

 

/
