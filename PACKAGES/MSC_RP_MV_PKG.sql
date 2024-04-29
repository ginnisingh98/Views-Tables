--------------------------------------------------------
--  DDL for Package MSC_RP_MV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_RP_MV_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCRPMVS.pls 120.0.12010000.1 2010/03/17 22:33:14 hulu noship $ */


type object_names is table of varchar2(30);


procedure log(p_message varchar2) ;
procedure refresh_one_mv(p_name varchar2);
procedure refresh_rp_mvs(errbuf out nocopy varchar2, retcode out nocopy
varchar2);
procedure refresh_rp_mvs ;
END msc_rp_mv_pkg;

/
