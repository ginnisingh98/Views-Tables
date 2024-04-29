--------------------------------------------------------
--  DDL for Package XDP_PERF_BM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_PERF_BM_PKG" AUTHID CURRENT_USER AS
/* $Header: XDPPERFS.pls 120.2 2005/07/07 02:05:09 appldev ship $ */

/***********************************************************************************
Name	:	SendOrder
Purpose	:	This Procedure will be called from UI as a concurrent program.
		This will in turn make another call to a concurrent program
		that will actually send the request via FND_REQUEST.SUBMIT_REQUEST.
INPUT	:
		order_number_prefix	Order Number Prefix to be Generated.
		number_of_orders	Number of Orders to be Generated per process.
		number_of_lineitems	Number of LineItems per Order.
		number_of_process	Number of Parallel Process(threads) to run.
		service_name		Performance Test Service Name to execute.
OUTPUT	:
		ERRBUF			Error Text
		RETCODE			Return Code

FIX	:	14-JUN-2005  ksrikant  R12 GSCC Fix: File.SQL.39 (NOCOPY hint added to OUT/IN OUT args)
***********************************************************************************/

PROCEDURE SendOrder(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	number,
	order_number_prefix	IN	varchar2,
	number_of_orders	IN	number DEFAULT 1,
	number_of_lineitems	IN	number DEFAULT 1,
	number_of_process	IN	number DEFAULT 1,
        organization_id         IN      number,
	inventory_item_id	IN	number,
        action_code             IN      varchar2);

PROCEDURE SubmitOrder(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	number,
	p_order_number_prefix	IN	varchar2,
	p_number_of_orders	IN	number DEFAULT 1,
	p_number_of_lineitems	IN	number DEFAULT 1,
	p_process_number	IN	number DEFAULT 1,
        p_organization_id       IN      number,
	p_inventory_item_id	IN	number,
        p_action_code             IN      varchar2);

PROCEDURE PrintSubmitOrderStat(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	number,
	p_total_orders		IN	number,
	p_error_count		IN	number,
	p_total_time_elapsed	IN	number);

PROCEDURE GetReport(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	number,
	order_prefix		IN	varchar2);

PROCEDURE GetFlowthroughStat(
                             order_number_prefix                IN      varchar2,
                             total_processed_orders             OUT NOCOPY     number,
                             total_completed_orders             OUT NOCOPY     number,
                             total_order_elapse_time            OUT NOCOPY     number,
                             total_completed_elapse_time        OUT NOCOPY     number,
                             errbuf                             OUT NOCOPY     varchar2,
                             retcode                            OUT NOCOPY     number);

END XDP_PERF_BM_PKG;


 

/
