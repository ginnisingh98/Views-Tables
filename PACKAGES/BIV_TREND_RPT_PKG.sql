--------------------------------------------------------
--  DDL for Package BIV_TREND_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_TREND_RPT_PKG" AUTHID CURRENT_USER as
/* $Header: bivsrvctrds.pls 115.0 2003/10/06 01:19:50 kreardon noship $ */

procedure load
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2 );

end biv_trend_rpt_pkg;

 

/
