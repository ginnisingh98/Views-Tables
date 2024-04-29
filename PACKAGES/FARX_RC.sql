--------------------------------------------------------
--  DDL for Package FARX_RC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_RC" AUTHID CURRENT_USER as
/* $Header: farxrcs.pls 120.2.12010000.2 2009/07/19 13:43:59 glchen ship $ */

  procedure reclass (
	book		varchar2,
	begin_period	varchar2,
	end_period	varchar2,
	request_id	number,
	user_id		number,
	retcode	 out nocopy number,
	errbuf	 out nocopy varchar2);

END FARX_RC;

/
