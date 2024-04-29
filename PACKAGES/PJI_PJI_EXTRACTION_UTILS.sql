--------------------------------------------------------
--  DDL for Package PJI_PJI_EXTRACTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PJI_EXTRACTION_UTILS" AUTHID CURRENT_USER as
  /* $Header: PJIUT07S.pls 120.0 2005/12/08 16:37:55 svermett noship $ */

  procedure UPDATE_PJI_EXTR_SCOPE;

  procedure POPULATE_ORG_EXTR_INFO;

  procedure UPDATE_ORG_EXTR_INFO;

  procedure MVIEW_REFRESH
  (
      errbuf                  out nocopy varchar2
    , retcode                 out nocopy varchar2
    , p_name                  in         varchar2 default 'All'
    , p_method                in         varchar2 default 'C'
    , p_refresh_mview_lookups in         varchar2 default 'Y'
  );

  procedure ANALYZE_PJI_FACTS;

  procedure SEED_PJI_RM_STATS;

  procedure UPDATE_PJI_RM_WORK_TYPE_INFO(p_process in varchar2);

  procedure UPDATE_PJI_ORG_HRCHY;

  procedure UPDATE_RESOURCE_DATA(p_process in varchar2);

  procedure TRUNCATE_PJI_TABLES
  (
    errbuf                out nocopy varchar2,
    retcode               out nocopy varchar2,
    p_check               in         varchar2 default 'N'
  );

end PJI_PJI_EXTRACTION_UTILS;

 

/
