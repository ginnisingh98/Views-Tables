--------------------------------------------------------
--  DDL for Package FARX_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_TAX_PKG" AUTHID CURRENT_USER as
/* $Header: farxpts.pls 120.2.12010000.2 2009/07/19 13:43:03 glchen ship $ */

  procedure property_tax(
	book		in	varchar2,
	end_date	in	date,
        segment1	in      varchar2,
        segment2	in      varchar2,
        segment3	in      varchar2,
        segment4	in      varchar2,
        segment5	in      varchar2,
        segment6	in      varchar2,
        segment7	in      varchar2,
        property_type	in      varchar2,
        company		in      varchar2,
        cost_center	in      varchar2,
        cost_account	in      varchar2,
	request_id	in	number,
 	user_id		in	number,
	retcode	 out nocopy varchar2,
	errbuf	 out nocopy varchar2);

END FARX_TAX_PKG;

/
