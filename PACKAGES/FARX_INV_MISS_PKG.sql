--------------------------------------------------------
--  DDL for Package FARX_INV_MISS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_INV_MISS_PKG" AUTHID CURRENT_USER as
/* $Header: farxims.pls 120.2.12010000.2 2009/07/19 13:40:08 glchen ship $ */

  procedure miss_asset(
	inventory_name	   in	varchar2,
	request_id in	number,
 	user_id    in	number,
	retcode    out nocopy number,
	errbuf     out nocopy  varchar2);


  procedure comparison (
	inventory_name	in	varchar2,
	location	in	varchar2,
	category	in	varchar2,
	request_id	in	number,
	user_id		in	number,
	retcode	 out nocopy number,
	errbuf	 out nocopy varchar2);

END FARX_INV_MISS_PKG;

/
