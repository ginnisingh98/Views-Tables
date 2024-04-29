--------------------------------------------------------
--  DDL for Package FARX_AJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_AJ" AUTHID CURRENT_USER as
/* $Header: farxajs.pls 120.2.12010000.2 2009/07/19 10:55:51 glchen ship $ */

  procedure cost_adjust (
	book		in	varchar2,
	begin_period	in	varchar2,
	end_period	in	varchar2,
	request_id	in	number,
	user_id		in	number,
	retcode	 out nocopy number,
	errbuf	 out nocopy varchar2);

  procedure cost_clear_rec (
	book		in	varchar2,
	period		in	varchar2,
	request_id	in	number,
	user_id		in	number,
	retcode	 out nocopy number,
	errbuf	 out nocopy varchar2);


END FARX_AJ;

/
