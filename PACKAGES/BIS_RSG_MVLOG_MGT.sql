--------------------------------------------------------
--  DDL for Package BIS_RSG_MVLOG_MGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RSG_MVLOG_MGT" AUTHID CURRENT_USER AS
/*$Header: BISSNLMS.pls 115.2 2002/11/27 22:44:46 tiwang noship $*/
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE


Type varcharTableType is Table of varchar2(30) index by binary_integer;


/**
Procedure drop_all_snp_logs(Errbuf in out NOCOPY varchar2,
                            Retcode in out NOCOPY varchar2,
                            p_drop_logs in varchar2,
                            p_truncate_mv in varchar2);
**/

Procedure create_snp_log(Errbuf in out NOCOPY varchar2,
                         Retcode in out NOCOPY varchar2,
                         p_object_name in varchar2,
                         p_object_type in varchar2,
                         p_called_by in varchar2);

/**
Procedure reset_complete_flag(Errbuf in out NOCOPY varchar2,
                         Retcode in out NOCOPY varchar2,
                         p_set_name in varchar2,
                         p_set_app in varchar2,
                         p_called_by in varchar2);
  **/


PROCEDURE write_log(p_text in VARCHAR2);

END BIS_RSG_MVLOG_MGT;

 

/
