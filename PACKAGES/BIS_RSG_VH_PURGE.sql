--------------------------------------------------------
--  DDL for Package BIS_RSG_VH_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RSG_VH_PURGE" AUTHID CURRENT_USER AS
/*$Header: BISVHPUS.pls 115.0 2003/07/18 02:26:42 jwen noship $*/
procedure purge_history_tables(Errbuf out nocopy varchar2, Retcode out nocopy varchar2);
END BIS_RSG_VH_PURGE;

 

/
