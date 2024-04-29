--------------------------------------------------------
--  DDL for Package Body XDP_PERF_BM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PERF_BM_PKG" AS
/* $Header: XDPPERFB.pls 120.2 2005/07/07 02:06:06 appldev ship $ */

/***********************************************************************************
Name	:	SendOrder
Purpose	:	This Procedure will be called from UI as a driver concurrent program.
		This will in turn make another call to a concurrent program(SubmitOrder)
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
***********************************************************************************/

PROCEDURE SendOrder(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	number,
	order_number_prefix	IN	varchar2,
	number_of_orders	IN	number DEFAULT 1,
	number_of_lineitems	IN	number DEFAULT 1,
	number_of_process	IN	number DEFAULT 1,
        organization_id         IN      number ,
	inventory_item_id	IN	number,
        action_code             IN      varchar2)
IS
  e_OrderPrefixException	exception;
  req_id			number;
  p_errbuf			varchar2(512);
  msg_out			varchar2(512);
  print_option_set 		boolean;

BEGIN

  req_id := null;
  p_errbuf	:= null;
  errbuf	:= null;
  retcode	:= 0;
  msg_out	:= null;
  print_option_set := FALSE;


  FOR i in 1..number_of_process LOOP

    FND_FILE.put_line(FND_FILE.LOG ,'Spawning Process # '||i||' Of '||number_of_process);

    -- Need to set print option since print is set upon definition of concurrent program
    -- on the UI.

    print_option_set := FND_REQUEST.SET_PRINT_OPTIONS(
			null,
			null,
                        null,
                        TRUE,
                        'N');

    IF print_option_set THEN
	FND_FILE.put_line(FND_FILE.LOG ,'Print Options Set ...');
    ELSE
	FND_FILE.put_line(FND_FILE.LOG ,'ERROR in setting Print Options ...');
	errbuf := substr(fnd_message.get, 1, 240);
	FND_FILE.put_line(FND_FILE.LOG ,'ERR MSG: '||errbuf);
    END IF;

	req_id := FND_REQUEST.SUBMIT_REQUEST(
			'XDP',
			'XDP_PERF_BM_PROG',
			'SFM Performance Benchmark Bulk Order Submission Program',
			null,
			FALSE,
			order_number_prefix,
			number_of_orders,
			number_of_lineitems,
			i,
                        organization_id,
			inventory_item_id ,
                        action_code);

	FND_FILE.put_line(FND_FILE.LOG, 'Request ID: '||req_id);

	IF req_id = 0 THEN
	  FND_FILE.put_line(FND_FILE.LOG ,'Error on SUBMIT_REQUEST for process #'||i);
	  p_errbuf := substr(fnd_message.get, 1, 240);
	  FND_FILE.put_line(FND_FILE.LOG, 'ERR MSG: '||errbuf);
	  --EXIT;
	END IF;

  END LOOP;

EXCEPTION
	WHEN  e_OrderPrefixException THEN
		errbuf := 'Order Prefix given already exists';
		retcode := -1;
  	WHEN OTHERS THEN
    		FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
    		FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_PERF_BM_PKG.SENDORDER');
    		FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
    		errbuf := FND_MESSAGE.GET;
    		retcode := -1;

END SendOrder;

/***********************************************************************************
Name	:	SubmitOrder
Purpose	:	This is a concurrent Program called by the driver concurrent program(SendOrder).
		This Procedure will  call XDP_INTERFACES.PROCESS_ORDER.
INPUT	:
		p_order_number_prefix	Order Number Prefix to be Generated.
		p_number_of_orders	Number of Orders to be Generated per process.
		p_number_of_lineitems	Number of LineItems per Order.
		p_service_name		Performance Test Service Name to execute.
OUTPUT	:
		ERRBUF			Error Text
		RETCODE			Return Code
***********************************************************************************/

PROCEDURE SubmitOrder(
	errbuf			OUT NOCOPY	VARCHAR2,
	retcode			OUT NOCOPY	NUMBER,
	p_order_number_prefix	IN	VARCHAR2,
	p_number_of_orders	IN	NUMBER DEFAULT 1,
	p_number_of_lineitems	IN	NUMBER DEFAULT 1,
	-- Need this as part of unique order NUMBER PREFIX
	p_process_number	IN	NUMBER DEFAULT 1,
        p_organization_id       IN      NUMBER,
	p_inventory_item_id	IN	NUMBER,
        p_action_code             IN      varchar2)

IS
  sdp_order_id        	        number;
  return_code         	        number;
  p_external_id		        varchar2(40);
  p_action	      	        varchar2(30);

  -- Needed for                 XDP_INTERFACES_PUB call
  msg_count		        number;
  msg_data		        varchar2(2000);
  return_status		        varchar2(1);
  --
  parm_count		        number;
  time_start		        number;
  time_end		        number;
  time_elapsed		        number;
  total_time		        number;
  error_count		        number;
  resultout           	        varchar2(512);
  search_prefix			varchar2(40);
  search_rec			varchar2(5);
  ParameterName  		varchar2(30);
  ParameterValue	        varchar2(40);
  l_service_name                varchar2(80);

 l_msg_count                    NUMBER;
 l_return_status                varchar2(20);
 l_err_code                     varchar2(20);
 l_msg_list                     varchar2(20);
 l_error_message                VARCHAR(512);

  r_order_header      	        XDP_TYPES.SERVICE_ORDER_HEADER     ;
  l_oparm_list        	        XDP_TYPES.SERVICE_ORDER_PARAM_LIST ;
  l_line_list         	        XDP_TYPES.SERVICE_ORDER_LINE_LIST  ;
  l_lparm_list        	        XDP_TYPES.SERVICE_LINE_PARAM_LIST  ;

  -- To be used for XDP_INTERFACES_PUB.Process_Order
  l_api_version                 CONSTANT NUMBER := 11.5;

  e_organization_id_null        exception;
  e_OrderPrefixException	exception;
  e_SubmitOrderException	exception;
  e_ActionCodeException		exception;

  cursor cCheckUniquePrefix(p_prefix varchar2) IS
	select	null
	from	xdp_order_headers xoh
	where
		xoh.external_order_number like (p_prefix)
		and xoh.external_order_version = '1'
		and xoh.order_type = 'BENCHMARK'
	;

  cursor cGetActionCode(p_organization_id IN NUMBER,
                        p_inventory_item_id IN VARCHAR2) IS
         SELECT sva.action_code
           FROM xdp_service_val_acts sva
          WHERE sva.organization_id       = p_organization_id
            AND sva.inventory_item_id     = p_inventory_item_id  ;

  cursor c_get_service_name (p_organization_id IN NUMBER,
                           p_inventory_item_id IN  NUMBER) IS
         SELECT concatenated_segments  service_name
           FROM mtl_system_items_vl  msi
          WHERE msi.organization_id       = p_organization_id
            AND msi.inventory_item_id     = p_inventory_item_id  ;

BEGIN

  errbuf 	:= 'NO ERRORS';
  retcode 	:= 0;
  error_count	:= 0;
  total_time      := 0;

  p_external_id := 'XDPPERFBM_'||p_order_number_prefix||'_'||to_char(p_process_number)||'_';
  search_prefix :=  p_external_id || '%';


  IF cCheckUniquePrefix%ISOPEN THEN
	close cCheckUniquePrefix;
  END IF;
  open cCheckUniquePrefix(search_prefix);
  fetch cCheckUniquePrefix into search_rec;

  IF cCheckUniquePrefix%FOUND THEN
	close cCheckUniquePrefix;
	errbuf := 'Order Prefix given already exists';
	RAISE e_SubmitOrderException;
  END IF;

  IF cCheckUniquePrefix%ISOPEN THEN
	close cCheckUniquePrefix;
  END IF;

  r_order_header.required_fulfillment_date 	:= sysdate;
  r_order_header.due_date		        := sysdate + 1;
  r_order_header.jeopardy_enabled_flag	        := 'Y';
  r_order_header.order_type		        := 'BENCHMARK';
  r_order_header.order_version		        := '1';
  r_order_header.execution_mode 		:= 'ASYNC';

  IF cGetActionCode%ISOPEN THEN
	close cGetActionCode;
  END IF;

  for c_get_service_name_rec IN c_get_service_name (p_organization_id,
                                                    p_inventory_item_id )
      loop
         l_service_name := c_get_service_name_rec.service_name ;
      end loop ;

  parm_count := 1;

  FOR i in 1..p_number_of_lineitems LOOP

    l_line_list(i).line_number                := i;
    l_line_list(i).inventory_item_id          := p_inventory_item_id;
    l_line_list(i).service_item_name          := l_service_name;
    l_line_list(i).action_code	              := p_action_code;
    l_line_list(1).organization_id            := p_organization_id;
    l_line_list(1).fulfillment_required_flag := 'Y';
    l_line_list(1).ib_source                  := 'NONE';
    l_line_list(1).site_use_id                := NULL;


    FOR j in 1..10 LOOP -- There are 10 defined parameters for this WorkItem .

    -- Parameter names/values hard-coded because these are referenced from the publish
    -- test message.
	IF j = 1 THEN
	  ParameterName	        := 'SUBSCRIPTION_TN';
	  ParameterValue	:= '650-633-5000';
	ELSIF j = 2 THEN
	  ParameterName	        := 'CUSTOMER_NAME';
	  ParameterValue	:= 'Johnny Smith';
	ELSIF j = 3 THEN
	  ParameterName	:= 'ADDRESS_LINE1';
	  ParameterValue	:= '600 Oracle Parkway';
	ELSIF j = 4 THEN
	  ParameterName	:= 'ADDRESS_LINE2';
	  ParameterValue	:= '6th Floor';
	ELSIF j = 5 THEN
	  ParameterName	:= 'CITY';
	  ParameterValue	:= 'Redwood Shores';
	ELSIF j = 6 THEN
	  ParameterName	:= 'ZIP_CODE';
	  ParameterValue	:= '94565';
	ELSIF j = 7 THEN
	  ParameterName	:= 'SERVICE_TYPE';
	  ParameterValue	:= 'ISDN Line';
	ELSIF j = 8 THEN
	  ParameterName	:= 'STATUS';
	  ParameterValue	:= 'WORKING';
	ELSIF j = 9 THEN
	  ParameterName	:= 'CUSTOMER_TYPE';
	  ParameterValue	:= 'RESIDENTIAL';
	ELSE
	  ParameterName	:= 'FEATURE_TYPE';
	  ParameterValue	:= 'Custom Calling Feature';
	END IF;

    	l_lparm_list(parm_count).line_number	:= i;
	l_lparm_list(parm_count).parameter_name := ParameterName;
	l_lparm_list(parm_count).parameter_value := ParameterValue;


	parm_count := parm_count + 1;
    END LOOP;

  END LOOP;

  FOR i in 1..p_number_of_orders LOOP
    r_order_header.order_number := p_external_id || to_char(i);

    time_start := dbms_utility.get_time;

 XDP_INTERFACES_PUB.PROCESS_ORDER(11,
                                  l_msg_list,
                                  FND_API.G_FALSE,
                                  FND_API.G_VALID_LEVEL_FULL,
                                  return_status,
                                  msg_count,
                                  msg_data,
                                  l_err_code,
                                  r_order_header,
                                  l_oparm_list,
                                  l_line_list,
                                  l_lparm_list,
                                  sdp_order_id);

    time_end := dbms_utility.get_time;
    time_elapsed := time_end - time_start ;

    -- Gather timed stats only for successful orders.
    IF (return_status <> FND_API.G_RET_STS_ERROR) THEN
      total_time := total_time + time_elapsed;

      IF (i = 1) THEN
	FND_FILE.put_line(FND_FILE.LOG, 'Start Order ID	: '||sdp_order_id|| '	Order Number : '
		||r_order_header.order_number);
      ELSIF (i = p_number_of_orders) THEN
	FND_FILE.put_line(FND_FILE.LOG, 'End Order ID	: '||sdp_order_id|| '	Order Number : '
		||r_order_header.order_number);
      END IF;

    ELSE
      error_count := error_count +1;
      FND_FILE.put_line(FND_FILE.LOG, 'SFM Order ID	: '||sdp_order_id|| '	Order Number : '
			||r_order_header.order_number||' Return Code : '||return_status||
			' Error Desc : '||msg_data);

    END IF;

  END LOOP;

  IF (p_number_of_orders = error_count) THEN
    errbuf := 'No Orders Successfully Submitted';
    retcode := -1;

  ELSE
    XDP_PERF_BM_PKG.PrintSubmitOrderStat(resultout,
			 return_code,
			 p_number_of_orders,
			 error_count,
	    	         total_time);

    IF (return_code <> 0) THEN
      errbuf := resultout;
      retcode := return_code;
    END IF;

  END IF;


EXCEPTION
  WHEN  e_SubmitOrderException THEN
	retcode := -1;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
    FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_PERF_BM_PKG.SUBMITORDER');
    FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
    errbuf := FND_MESSAGE.GET;
    retcode := -1;

END SubmitOrder ;

/***********************************************************************************
Name	:	PrintSubmitOrderStat
Purpose	:	This Procedure prints timed statistics of processed orders.
INPUT	:
		p_total_orders
		p_total_time_elapsed
OUTPUT	:
		ERRBUF
		RETCODE
***********************************************************************************/

PROCEDURE PrintSubmitOrderStat(
		    errbuf			OUT NOCOPY	varchar2,
		    retcode			OUT NOCOPY	number,
		    p_total_orders		IN	number,
		    p_error_count		IN	number,
		    p_total_time_elapsed	IN	number)
IS

 average	float(10) := 0;

BEGIN

errbuf := null;
retcode := 0;

  average := p_total_orders / (p_total_time_elapsed / 100);
  FND_FILE.put_line(FND_FILE.OUTPUT,'These Figures Represent Orders Successfully Sent to the Process Orders Queue.');
  FND_FILE.put_line(FND_FILE.OUTPUT,'=============================================================================');
  FND_FILE.put_line(FND_FILE.OUTPUT,'Total Number of Orders Requested			: '
		|| p_total_orders);
  FND_FILE.put_line(FND_FILE.OUTPUT,'Total Number of Successful Orders Processed	: '
		|| to_number(p_total_orders - p_error_count));
  FND_FILE.put_line(FND_FILE.OUTPUT,'Total Elapsed Time (Successful Orders)		: '
		|| p_total_time_elapsed / 100 ||' seconds');
  FND_FILE.put_line(FND_FILE.OUTPUT,'Average						: '||average||' Orders per Second.');
  FND_FILE.put_line(FND_FILE.OUTPUT,'==============================================================');
  FND_FILE.put_line(FND_FILE.OUTPUT,'Total Number of Orders in Error			: ' || p_error_count);
  FND_FILE.put_line(FND_FILE.OUTPUT,'==============================================================');

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
    FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_PERF_BM_PKG.PRINTSUBMITORDERSTAT');
    FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
    errbuf := FND_MESSAGE.GET;
    retcode := -1;

END PrintSubmitOrderStat;


/***********************************************************************************
Name	:	GetReport
Purpose	:	This Procedure is a concurrent program that will generate stats for
		performance benchmark.
INPUT	:
		order prefix	-- Unique Service Order Prefix
OUTPUT	:
		ERRBUF
		RETCODE
***********************************************************************************/
PROCEDURE GetReport(
		    errbuf		OUT NOCOPY	varchar2,
		    retcode		OUT NOCOPY	number,
		    order_prefix	IN	varchar2)
IS
  e_OrderPrefixException	exception;
  p_total_processed_orders	number;
  p_total_completed_orders	number;
  p_completed_orders_ave	number;
  p_total_orders_ave		number;
  p_errbuf			varchar2(150);
  p_retcode			number;
  p_order_prefix		varchar2(20);
  p_total_order_elapse_time	number;
  --p_total_completed_elapse_time	number;
  p_total_completed_elapse_time	float(15);
  all_ave			float(15);
  comp_ave			float(15);

BEGIN

  IF (order_prefix is NULL) THEN
	RAISE e_OrderPrefixException;
  END IF;

  p_order_prefix := UPPER(order_prefix);

  GetFlowthroughStat(order_number_prefix	=> p_order_prefix,
		     total_processed_orders	=> p_total_processed_orders,
		     total_completed_orders	=> p_total_completed_orders,
		     total_order_elapse_time	=> p_total_order_elapse_time,
	 	     total_completed_elapse_time=> p_total_completed_elapse_time,
		     errbuf			=> p_errbuf,
		     retcode			=> p_retcode);


  IF p_retcode = 0 THEN

    comp_ave  := p_total_completed_orders/p_total_completed_elapse_time;
    --all_ave := p_total_completed_orders/p_total_order_elapse_time;
    all_ave := p_total_order_elapse_time / p_total_completed_orders;

    IF (p_total_completed_orders <> p_total_processed_orders) THEN
      FND_FILE.put_line(FND_FILE.OUTPUT,'These are Partial Thoroughput Stats. Some orders '||
      'with Prefix '||p_order_prefix||' Not yet Successfully Completed.');
    ELSE
      FND_FILE.put_line(FND_FILE.OUTPUT,'These are Complete Thoroughput Stats. All Test '||
      'Orders with Prefix XDPPERFBM_'||p_order_prefix||' Successfully Completed.');
    END IF;
    FND_FILE.put_line(FND_FILE.OUTPUT,'============================================================================================');

    FND_FILE.put_line(FND_FILE.OUTPUT,'Total Processed Orders		:	'||p_total_processed_orders);
    FND_FILE.put_line(FND_FILE.OUTPUT,'Total Completed Orders		:	'||p_total_completed_orders);
    FND_FILE.put_line(FND_FILE.OUTPUT,'Total Process Duration		:	'
				||p_total_completed_elapse_time||' seconds');
    FND_FILE.put_line(FND_FILE.OUTPUT,'Order Throughput');
    FND_FILE.put_line(FND_FILE.OUTPUT,'		Orders Per Second	:	'||comp_ave);
    FND_FILE.put_line(FND_FILE.OUTPUT,'		Orders Per Hour		:	'||comp_ave * 3600);
    FND_FILE.put_line(FND_FILE.OUTPUT,'		Orders Per Day		:	'||comp_ave * 86400);

    FND_FILE.put_line(FND_FILE.OUTPUT,'Average Order Completion Rate.(Based on Individual Process Time)');
    FND_FILE.put_line(FND_FILE.OUTPUT,'		Seconds Per Order:	'||all_ave);

  ELSE
    errbuf := p_errbuf;
    retcode := p_retcode;
  END IF;

EXCEPTION
  WHEN  e_OrderPrefixException THEN
	errbuf := 'Order Prefix Not Found';
	retcode := -1;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
    FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_PERF_BM_PKG.GETREPORT');
    FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
    errbuf := FND_MESSAGE.GET;
    retcode := -1;
END GetReport;

/***********************************************************************************
Name	:	GetFlowthroughStat
Purpose	:	This Procedure prints timed statistics of processed orders.
INPUT	:
		order_number_prefix	-- Unique Service Order Prefix
OUTPUT	:
		total_processed_orders
		total_completed_orders
		total_order_elapse_time		-- taken for each order(excludes lags)
		total_completed_elapse_time	-- including lags between orders
		ERRBUF
		RETCODE
***********************************************************************************/

PROCEDURE GetFlowthroughStat(
			     order_number_prefix		IN	varchar2,
			     total_processed_orders		OUT NOCOPY	number,
			     total_completed_orders		OUT NOCOPY	number,
			     total_order_elapse_time		OUT NOCOPY	number,
	 		     total_completed_elapse_time	OUT NOCOPY	number,
			     errbuf				OUT NOCOPY	varchar2,
			     retcode				OUT NOCOPY	number)
IS
	cursor orders_all(OrderPrefix varchar2) is
		select	SUM(XOH.COMPLETION_DATE - XOH.PROVISIONING_DATE) ElapseTime,
			count(*) OrderCount
		from	xdp_order_headers XOH
		where	XOH.EXTERNAL_ORDER_NUMBER like (OrderPrefix)
			AND XOH.status_code = 'SUCCESS'
			AND XOH.EXTERNAL_ORDER_VERSION = '1'
			AND XOH.ORDER_TYPE = 'BENCHMARK'
		;

	cursor orders_complete(OrderPrefix varchar2) is
		select	min(XOH.provisioning_date) ProvDate,
			max(XOH.completion_date) CompDate
		from	xdp_order_headers XOH
		where	XOH.EXTERNAL_ORDER_NUMBER like (OrderPrefix)
			AND XOH.status_code = 'SUCCESS'
			AND XOH.EXTERNAL_ORDER_VERSION = '1'
			AND XOH.ORDER_TYPE = 'BENCHMARK'
		;

	AllOrdersRec			orders_all%ROWTYPE;
	CompOrdersRec			orders_complete%ROWTYPE;
	search_prefix			varchar2(40);
	order_elapse_time		number;		-- in seconds
  	e_OrderPrefixException		exception;

BEGIN

  errbuf			:= null;
  retcode			:= 0;
  total_completed_elapse_time	:= 0;
  total_order_elapse_time	:= 0;
  order_elapse_time		:= 0;
  total_completed_orders	:= 0;
  total_processed_orders	:= 0;

  search_prefix := 'XDPPERFBM_' || order_number_prefix||'_%';

  SELECT count(*) INTO total_processed_orders
  FROM	xdp_order_headers h
  WHERE
	h.external_order_number like search_prefix
	and h.external_order_version = '1'
	and h.order_type = 'BENCHMARK';

  IF (total_processed_orders = 0) THEN
	errbuf := 'No Orders Found with Prefix '|| order_number_prefix;
	RAISE e_OrderPrefixException;
  END IF;

  IF orders_all%ISOPEN THEN
	close orders_all;
  END IF;

  open orders_all(search_prefix) ;
  fetch orders_all into AllOrdersRec;

  IF orders_all%NOTFOUND THEN
	errbuf := 'No Completed Orders Found for Prefix '|| order_number_prefix;
	RAISE e_OrderPrefixException;
  END IF;

  total_order_elapse_time := AllOrdersRec.ElapseTime * 86400;
  total_completed_orders := AllOrdersRec.OrderCount;

  IF orders_all%ISOPEN THEN
	close orders_all;
  END IF;


  IF orders_complete%ISOPEN THEN
	close orders_complete;
  END IF;

  open orders_complete(search_prefix) ;
    fetch orders_complete into CompOrdersRec;
    -- Got to check for CompOrdersRec.ProvDate since min/max returns null row when no record found
    IF (orders_complete%NOTFOUND OR CompOrdersRec.ProvDate IS NULL  AND CompOrdersRec.CompDate IS NULL) THEN
	-- No orders completed, no use in getting stats!
	errbuf := 'No Completed Orders Found for Prefix '|| order_number_prefix;
	RAISE e_OrderPrefixException;
    ELSE
        total_completed_elapse_time := (CompOrdersRec.CompDate - CompOrdersRec.ProvDate)*86400;
    END IF;

  IF orders_complete%ISOPEN THEN
	close orders_complete;
  END IF;

EXCEPTION
  WHEN  e_OrderPrefixException THEN
	retcode := -1;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
    FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_PERF_BM_PKG.GETFLOWTHROUGHSTAT');
    FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
    errbuf := FND_MESSAGE.GET;
    retcode := -1;

END GetFlowthroughStat;

END XDP_PERF_BM_PKG;


/
