--------------------------------------------------------
--  DDL for Package FARX_MAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_MAD" AUTHID CURRENT_USER as
/* $Header: farxmds.pls 120.2.12010000.2 2009/07/19 13:41:10 glchen ship $ */


PROCEDURE MASS_ADDITIONS (
	book		in	varchar2,
	queue_name	in	varchar2,
	request_id	in	number,
	user_id		in	number,
	retcode	 out nocopy varchar2,
	errbuf	 out nocopy varchar2);


END FARX_MAD;

/
