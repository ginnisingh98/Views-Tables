--------------------------------------------------------
--  DDL for Package PJI_EXTRACTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_EXTRACTION_UTIL" AUTHID CURRENT_USER as
  /* $Header: PJIUT02S.pls 120.2 2005/12/07 21:38:28 appldev noship $ */

  procedure UPDATE_EXTR_SCOPE;

  procedure POPULATE_ORG_EXTR_INFO;

  procedure UPDATE_ORG_EXTR_INFO;

  procedure SEED_PJI_FM_STATS;

  procedure TRUNCATE_PJI_TABLES
  (
    errbuf                out nocopy varchar2,
    retcode               out nocopy varchar2,
    p_check               in         varchar2 default 'N',
    p_truncate_pji_tables in         varchar2 default 'Y',
    p_truncate_pjp_tables in         varchar2 default 'Y',
    p_run_fpm_upgrade     in         varchar2 default 'N'
  );

  function GET_PARALLEL_PROCESSES return number;

  function GET_BATCH_SIZE return number;

end PJI_EXTRACTION_UTIL;

 

/
