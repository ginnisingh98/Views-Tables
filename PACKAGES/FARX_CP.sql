--------------------------------------------------------
--  DDL for Package FARX_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_CP" AUTHID CURRENT_USER as
/* $Header: farxcps.pls 120.2.12010000.2 2009/07/19 13:48:49 glchen ship $ */

  procedure cap (
	book		varchar2,
	begin_period	varchar2,
	end_period	varchar2,
	request_id	number default null,
	user_id		number default null,
	retcode	 out nocopy  number,
	errbuf	 out nocopy  varchar2);

END FARX_CP;

/
