--------------------------------------------------------
--  DDL for Package FARX_TF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_TF" AUTHID CURRENT_USER as
/* $Header: farxtfs.pls 120.2.12010000.2 2009/07/19 13:33:43 glchen ship $ */

  procedure transfers (
	book		varchar2,
	begin_period	varchar2,
	end_period	varchar2,
	request_id	number,
	user_id		number,
	retcode	 out nocopy number,
	errbuf	 out nocopy varchar2);

END FARX_TF;

/
