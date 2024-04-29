--------------------------------------------------------
--  DDL for Package FARX_AL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_AL" AUTHID CURRENT_USER as
  /* $Header: farxals.pls 120.2.12010000.3 2009/07/19 10:56:28 glchen ship $ */

  PROCEDURE asset_listing_run( book           in   varchar2,
			       period         in   varchar2,
			       from_bal	      in   varchar2,
			       to_bal	      in   varchar2,
			       from_acct      in   varchar2,
			       to_acct	      in   varchar2,
			       from_cc	      in   varchar2,
			       to_cc	      in   varchar2,
			       major_category in   varchar2,
			       minor_category in   varchar2,
			       cat_seg_num    in   varchar2,
			       cat_seg_val    in   varchar2,
			       prop_type      in   varchar2,
			       fully_reserved in   varchar2,
			       nbv            in   number,
			       cat_deprn_flag in   varchar2,
			       bought         in   varchar2,
			       sob_id         in   varchar2 default NULL,
			       request_id     in   number,
			       login_id	      in   number,
			       retcode	      out nocopy  number,
			       errbuf	      out nocopy  VARCHAR2);
END FARX_AL;

/
