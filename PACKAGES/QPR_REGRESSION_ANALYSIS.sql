--------------------------------------------------------
--  DDL for Package QPR_REGRESSION_ANALYSIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_REGRESSION_ANALYSIS" AUTHID CURRENT_USER AS
/* $Header: QPRURGRS.pls 120.4 2008/01/03 10:23:40 kdhabali noship $ */

type num_type is table of number index by binary_integer;

type QPRREGRDATA is ref cursor;


TYPE REGR_DATA_REC_TYPE IS RECORD
(
	product_id		num_type,
	pr_segment_id		num_type,
	regression_slope	num_type,
	regression_intercept	num_type,
	regression_r2		num_type,
	regression_count	num_type
);

procedure reg_transf(
		i_pp_id in number,
		i_item_id in number,
		i_psg_id in number,
		i_value in number,
		o_value in out nocopy number) ;

procedure reg_antitransf(
		i_pp_id in number,
		i_item_id in number,
		i_psg_id in number,
		i_value in number,
		o_value in out nocopy number) ;

procedure do_regress(
	errbuf		out nocopy varchar2,
	retcode		out nocopy varchar2,
	p_price_plan_id	in number,
	p_start_date	in varchar2,
	p_end_date	in varchar2,
	p_i_prd_id	in varchar2,
	p_f_prd_id	in varchar2,
	p_i_psg_id	in varchar2,
	p_f_psg_id	in varchar2);


END QPR_REGRESSION_ANALYSIS ;


/
