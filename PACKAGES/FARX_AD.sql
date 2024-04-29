--------------------------------------------------------
--  DDL for Package FARX_AD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_AD" AUTHID CURRENT_USER as
/* $Header: farxads.pls 120.1.12010000.2 2009/07/19 10:54:49 glchen ship $ */

procedure ADD_BY_PERIOD (
   book		in	varchar2,
   begin_period in	varchar2,
   end_period	in	varchar2,
   from_maj_cat in	varchar2,
   to_maj_cat   in	varchar2,
   from_min_cat in	varchar2,
   to_min_cat   in	varchar2,
   from_cc      in	varchar2,
   to_cc	in	varchar2,
   cat_seg_num  in	varchar2,
   from_cat_seg_val in	varchar2,
   to_cat_seg_val in	varchar2,
   from_asset_num in	varchar2,
   to_asset_num in	varchar2,
   request_id   in	number,
   user_id	in	number,
   retcode out nocopy number,
   errbuf out nocopy varchar2);


procedure add_by_date (
   book		in	varchar2,
   begin_dpis 	in	date,
   end_dpis	in	date,
   request_id   in	number,
   user_id	in	number,
   retcode out nocopy number,
   errbuf out nocopy varchar2);



procedure add_by_resp (
   book		in	varchar2,
   period	in	varchar2,
   begin_cc	in	varchar2,
   end_cc	in	varchar2,
   request_id   in	number,
   user_id	in	number,
   retcode out nocopy number,
   errbuf out nocopy varchar2);


END FARX_AD;

/
