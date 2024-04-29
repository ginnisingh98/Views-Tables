--------------------------------------------------------
--  DDL for Package ISC_FS_TASK_BAC_AGE_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_TASK_BAC_AGE_ETL_PKG" 
/* $Header: iscfsbacageetls.pls 120.1 2005/10/18 19:19:45 kreardon noship $ */
AUTHID CURRENT_USER as

  type t_period_bit_rec is record (curr number, prior_period number, prior_year number);
  type t_period_bit_tbl is table of t_period_bit_rec index by varchar2(10);

  G_WTD      constant number := power(2, 1);
  G_WTD_PP   constant number := power(2, 5);
  G_WTD_PY   constant number := power(2, 9);

  G_MTD      constant number := power(2, 2);
  G_MTD_PP   constant number := power(2, 6);
  G_MTD_PY   constant number := power(2, 10);

  G_QTD      constant number := power(2, 3);
  G_QTD_PP   constant number := power(2, 7);
  G_QTD_PY   constant number := power(2, 11);

  G_YTD      constant number := power(2, 4);
  G_YTD_PP   constant number := power(2, 8);
  G_YTD_PY   constant number := power(2, 12);

  G_DAY      constant number := power(2, 13);
  G_DAY_PP   constant number := power(2, 14);
  G_DAY_PY   constant number := power(2, 15);

procedure initial_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

procedure incremental_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

function get_period_bit_tbl
return t_period_bit_tbl;

end isc_fs_task_bac_age_etl_pkg;

 

/
