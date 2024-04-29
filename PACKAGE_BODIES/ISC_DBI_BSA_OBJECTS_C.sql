--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BSA_OBJECTS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BSA_OBJECTS_C" as
/* $Header: ISCSCFAB.pls 120.12 2006/09/15 12:03:39 achandak noship $ */

  g_batch_size			number;
  g_global_currency		varchar2(30);
  g_global_rate_type   		varchar2(80);
  g_sec_global_currency		varchar2(30);
  g_sec_global_rate_type   	varchar2(80);
  g_global_start_date		date;
  g_treasury_rate_type		varchar2(80);

  g_errbuf			varchar2(2000);
  g_retcode			varchar2(200);
  g_row_count         		number;
  g_push_from_date		date;
  g_push_to_date		date;
  g_incre_start_date		date;
  g_load_mode			varchar2(30);
  g_isc_schema			varchar2(50);
  g_sec_curr_def  		varchar2(1);

function check_setup return number is

  l_list 		dbms_sql.varchar2_table;
  l_status       	varchar2(30);
  l_industry     	varchar2(30);
  l_setup		number;

begin

  l_list(1) := 'BIS_GLOBAL_START_DATE';
  if (not bis_common_parameters.check_global_parameters(l_list)) then
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Error! Collection aborted because the global start date has not been set up.');
    bis_collection_utilities.put_line(' ');
    l_setup := -999;
  end if;

  g_sec_curr_def := isc_dbi_currency_pkg.is_sec_curr_defined;
  if (g_sec_curr_def = 'E') then
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Error! Collection aborted because the set-up of the DBI Global Parameter "Secondary Global Currency" is incomplete. Please verify the proper set-up of the Global Currency Rate Type and the Global Currency Code.');
    bis_collection_utilities.put_line(' ');
    l_setup := -999;
  end if;

  g_batch_size := bis_common_parameters.get_batch_size(bis_common_parameters.high);
  bis_collection_utilities.put_line('The batch size is ' || g_batch_size);

  g_global_start_date := bis_common_parameters.get_global_start_date;
  bis_collection_utilities.put_line('The global start date is ' || g_global_start_date);

  g_global_currency := bis_common_parameters.get_currency_code;
  bis_collection_utilities.put_line('The global currency code is ' || g_global_currency);

  g_global_rate_type := bis_common_parameters.get_rate_type;
  bis_collection_utilities.put_line('The primary rate type is ' || g_global_rate_type);

  g_sec_global_currency := bis_common_parameters.get_secondary_currency_code;
  bis_collection_utilities.put_line('The secondary global currency code is ' || g_sec_global_currency);

  g_sec_global_rate_type := bis_common_parameters.get_secondary_rate_type;
  bis_collection_utilities.put_line('The secondary rate type is ' || g_sec_global_rate_type);

  g_treasury_rate_type := bis_common_parameters.get_treasury_rate_type;
  bis_collection_utilities.put_line('The treasury rate type is ' || g_treasury_rate_type);

  if (not fnd_installation.get_app_info('ISC', l_status, l_industry, g_isc_schema)) then
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Error! Collection aborted while retrieving schema information.');
    bis_collection_utilities.put_line(' ');
    l_setup := -999;
  end if;

  if (l_setup = -999) then
    g_errbuf  := 'Collection aborted because the setup has not been completed. Please refer to the log file for the details.';
    return(-1);
  end if;

  bis_collection_utilities.put_line('Truncating the temp tables');
  fii_util.start_timer;

  execute immediate 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_BSA_ORDER_LINES';
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_CURR_BSA_ORDER_LINES';

  fii_util.stop_timer;
  fii_util.print_timer('Truncated the temp tables in');
  bis_collection_utilities.put_line(' ');

  return(1);

exception
  when others then
    g_errbuf  := 'Error in function CHECK_SETUP : '||sqlerrm;
    return(-1);

end check_setup;

function identify_change_init return number is

  l_bsa_count           number;

begin

  l_bsa_count := 0;

  bis_collection_utilities.put_line('Identifying blanket sales agreements');
  fii_util.start_timer;

  insert /*+ APPEND PARALLEL(F) */ into isc_dbi_tmp_bsa_order_lines f (
    order_line_id,
    order_line_header_id,
    order_number,
    line_number,
    inventory_item_id,
    item_inv_org_id,
    blanket_line_id,
    blanket_header_id,
    blanket_number,
    blanket_line_number,
    org_id,
    salesrep_id,
    agreement_type_id,
    sold_to_org_id,
    time_activation_date_id,
    time_expiration_date_id,
    time_termination_date_id,
    time_fulfilled_date_id,
    time_effective_end_date_id,
    h_start_date_active,
    l_start_date_active,
    h_end_date_active,
    l_end_date_active,
    termination_date,
    blanket_min_amt,
    blanket_line_min_amt,
    fulfilled_amt_g,
    fulfilled_amt_g1,
    accumulated_fulfilled_amt_g,
    accumulated_fulfilled_amt_g1,
    h_cnt,
    l_cnt,
    transactional_curr_code,
    transaction_phase_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    program_id,
    program_login_id,
    program_application_id,
    request_id
  )
  select /*+ USE_HASH(bh,bhe,bl,ble,r,book) PARALLEL(bh) PARALLEL(bhe) PARALLEL(bl) PARALLEL(ble) PARALLEL(r) PARALLEL(book) FULL(bh) FULL(bhe)*/
         book.line_id,
         book.header_id,
         book.order_number,
         book.line_number,
         book.inventory_item_id,
         book.item_inv_org_id,
	 bl.line_id,
	 bh.header_id,
	 bh.order_number,
	 ble.line_number,
         bh.org_id,
	 bh.salesrep_id,
	 bh.order_type_id,
	 bh.sold_to_org_id,
	 trunc(decode(bhe.blanket_min_amount, null, ble.start_date_active, bhe.start_date_active)),
	 trunc(decode(bhe.blanket_min_amount, null, ble.end_date_active, bhe.end_date_active)),
         trunc(r.creation_date),
         book.time_fulfilled_date_id,
         least(nvl(trunc(r.creation_date), trunc(decode(bhe.blanket_min_amount, null, ble.end_date_active, bhe.end_date_active))),
               nvl(trunc(decode(bhe.blanket_min_amount, null, ble.end_date_active, bhe.end_date_active)), trunc(r.creation_date))),
	 bhe.start_date_active,
         ble.start_date_active,
         bhe.end_date_active,
         ble.end_date_active,
         r.creation_date,
         bhe.blanket_min_amount,
         ble.blanket_line_min_amount,
         book.fulfilled_amt_g,
         book.fulfilled_amt_g1,
         sum(book.fulfilled_amt_g) over (partition by bh.header_id order by book.time_fulfilled_date_id, book.line_id range unbounded preceding),
         sum(book.fulfilled_amt_g1) over (partition by bh.header_id order by book.time_fulfilled_date_id, book.line_id range unbounded preceding),
         count(1) over (partition by bh.header_id),
         count(1) over (partition by bl.line_id),
	 bh.transactional_curr_code,
         bh.transaction_phase_code,
	 bh.created_by,
	 bh.creation_date,
	 bh.last_updated_by,
	 bh.last_update_date,
	 bh.last_update_login,
	 null,
	 null,
	 null,
	 null
    from oe_blanket_headers_all bh,
         oe_blanket_headers_ext bhe,
         oe_blanket_lines_all bl,
         oe_blanket_lines_ext ble,
         oe_reasons r,
         isc_book_sum2_f book
   where bh.order_number = bhe.order_number
     and bh.header_id = bl.header_id
     and bl.line_id = ble.line_id
     and r.entity_code(+) = 'BLANKET_HEADER'
     and r.reason_type(+) = 'CONTRACT_TERMINATION'
     and r.entity_id(+) = bh.header_id
     and book.blanket_number(+) = ble.order_number
     and book.blanket_line_number(+) = ble.line_number
     and bh.transaction_phase_code = 'F'
     and bh.sold_to_org_id is not null
     and (bhe.blanket_min_amount is not null or ble.blanket_line_min_amount is not null)
     and nvl(r.creation_date,bhe.start_date_active+1) >= bhe.start_date_active
     and book.line_category_code(+) <> 'RETURN'
     and book.order_source_id(+) <> 10
     and book.order_source_id(+) <> 27
     and book.ordered_quantity(+) <> 0
     and book.unit_selling_price(+) <> 0
     and book.charge_periodicity_code(+) is null;

  l_bsa_count := sql%rowcount;
  fii_util.stop_timer;
  fii_util.print_timer('Identified ' || l_bsa_count || ' blanket sales agreement in');
  commit;

  insert /*+ APPEND */ into isc_curr_bsa_order_lines f (
    from_currency,
    conversion_date,
    rate1,
    rate2
  )
  select transactional_curr_code   from_currency,
  	 time_activation_date_id   conversion_date,
	 decode(transactional_curr_code, g_global_currency, 1,
	 	fii_currency.get_global_rate_primary(transactional_curr_code, time_activation_date_id)) rate1,
         decode(transactional_curr_code, g_sec_global_currency, 1,
                fii_currency.get_global_rate_secondary(transactional_curr_code, time_activation_date_id)) rate2
    from (select /*+ PARALLEL(tmp) */ distinct transactional_curr_code, time_activation_date_id
	    from isc_dbi_tmp_bsa_order_lines tmp);

  return(l_bsa_count);

exception
  when others then
    g_errbuf  := 'Error in Function IDENTIFY_CHANGE_INIT : '||sqlerrm;
    g_retcode := sqlcode;
    return(-1);

end identify_change_init;

function report_missing_rate return number is

  cursor missing_currency_conversion is
    select distinct decode(rate1, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) curr_conv_date,
	  from_currency,
 	  g_global_currency to_currency,
	  g_global_rate_type rate_type,
 	  decode(rate1, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') status
     FROM isc_curr_bsa_order_lines tmp
    WHERE rate1 < 0
   UNION
   SELECT distinct decode(rate2, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  from_currency,
 	  g_sec_global_currency to_currency,
	  g_sec_global_rate_type rate_type,
 	  decode(rate2, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') status
     FROM isc_curr_bsa_order_lines tmp
    WHERE rate2 < 0
      AND g_sec_curr_def = 'Y';


  l_record      missing_currency_conversion%rowtype;
  l_total	number;

begin

  l_total := 0;

  open missing_currency_conversion;
  fetch missing_currency_conversion into l_record;

  if missing_currency_conversion%rowcount <> 0 then
    bis_collection_utilities.put_line('Collection failed because there are missing currency conversion rates.');
    bis_collection_utilities.put_line(fnd_message.get_string('BIS', 'BIS_DBI_CURR_NO_LOAD'));

    bis_collection_utilities.writeMissingRateHeader;
    while missing_currency_conversion%found loop
      l_total := l_total + 1;
      bis_collection_utilities.writeMissingRate(
        l_record.rate_type,
        l_record.from_currency,
        l_record.to_currency,
        l_record.curr_conv_date);
      fetch missing_currency_conversion into l_record;
    end loop;
    bis_collection_utilities.put_line_out(' ');
    bis_collection_utilities.put_line_out(' ');

  else -- missing_currency_conversion%rowcount = 0
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('           THERE IS NO MISSING CURRENCY CONVERSION RATE        ');
    bis_collection_utilities.put_line('+---------------------------------------------------------------------------+');
    bis_collection_utilities.put_line(' ');
  end if;

  close missing_currency_conversion;

  return(l_total);

exception
  when others then
    g_errbuf  := 'Error in Function REPORT_MISSING_RATE : '||sqlerrm;
    g_retcode := sqlcode;
    return(-1);

end report_missing_rate;

function check_time_continuity_init return number is

  l_min_act_date	date;
  l_max_act_date	date;
  l_min_exp_date	date;
  l_max_exp_date	date;
  l_min_trm_date	date;
  l_max_trm_date	date;
  l_min			date;
  l_max			date;
  l_is_missing		boolean;
  l_time_min		date;
  l_time_max		date;
  l_time_missing	boolean;

  cursor lines_missing_date is
    select order_number,
	   line_number,
	   order_line_id,
	   blanket_number,
	   to_char(time_activation_date_id, 'MM/DD/YYYY') time_activation_date_id,
	   to_char(time_expiration_date_id, 'MM/DD/YYYY') time_expiration_date_id,
	   to_char(time_termination_date_id,'MM/DD/YYYY') time_termination_date_id
      from isc_dbi_tmp_bsa_order_lines
     where (least(time_activation_date_id,
                  nvl(time_expiration_date_id,time_activation_date_id),
                  nvl(time_termination_date_id,time_activation_date_id)) < l_time_min
        or greatest(time_activation_date_id,
                    nvl(time_expiration_date_id,time_activation_date_id),
                    nvl(time_termination_date_id,time_activation_date_id)) > l_time_max);

  l_line	lines_missing_date%rowtype;

begin

  fii_util.start_timer;

  bis_collection_utilities.put_line('Begin to retrieve the time boundary for the initial load');
  select /*+ PARALLEL(tmp) */
         min(time_activation_date_id), max(time_activation_date_id),
         min(time_expiration_date_id), max(time_expiration_date_id),
         min(time_termination_date_id), max(time_termination_date_id)
    into l_min_act_date, l_max_act_date,
         l_min_exp_date, l_max_exp_date,
         l_min_trm_date, l_max_trm_date
    from isc_dbi_tmp_bsa_order_lines tmp;

  l_min := least(l_min_act_date,
                 nvl(l_min_exp_date,l_min_act_date),
                 nvl(l_min_trm_date,l_min_act_date));
  l_max := greatest(l_max_act_date,
                    nvl(l_max_exp_date,l_max_act_date),
                    nvl(l_max_trm_date, l_max_act_date));

  fii_util.stop_timer;
  fii_util.print_timer('Retrieved the time boundary in ');

  fii_util.start_timer;

  bis_collection_utilities.put_line_out(' ');
  bis_collection_utilities.put_line_out(' ');
  fii_time_api.check_missing_date(l_min, l_max, l_is_missing);

  if (l_is_missing) then
    bis_collection_utilities.put_line('Collection failed because there are dangling keys for time dimension.');
    bis_collection_utilities.put_line('No records were loaded.');

    select min(report_date), max(report_date)
      into l_time_min, l_time_max
      from fii_time_day;

    open lines_missing_date;
    fetch lines_missing_date into l_line;
    bis_collection_utilities.put_line_out(fnd_message.get_string('ISC', 'ISC_DBI_DATE_NO_LOAD'));
    bis_collection_utilities.put_line_out(' ');
    bis_collection_utilities.put_line_out(rpad(fnd_message.get_string('ISC','ISC_DBI_ORDER_NUMBER'),18,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_LINE_NUMBER'),18,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_LINE_ID'),18,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_BLANKET_NUMBER'),18,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_ACTIVATION_DATE'),15,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_EXPIRATION_DATE'),19,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_TERMINATION_DATE'),16,' '));
    bis_collection_utilities.put_line_out('------------------ - ------------------ - ------------------ - --------------- - ------------------- - ---------------- - ------------------------');

    while lines_missing_date%found loop
      bis_collection_utilities.put_line_out(rpad(l_line.order_number,18,' ')
			      ||' - '||rpad(l_line.line_number,18,' ')
			      ||' - '||rpad(l_line.order_line_id,18,' ')
			      ||' - '||rpad(l_line.blanket_number,18,' ')
			      ||' - '||rpad(l_line.time_activation_date_id,15,' ')
			      ||' - '||rpad(nvl(l_line.time_expiration_date_id,' '),19,' ')
			      ||' - '||rpad(nvl(l_line.time_termination_date_id,' '),16,' '));
      fetch lines_missing_date into l_line;
    end loop;

    close lines_missing_date;
    bis_collection_utilities.put_line_out('+------------------------------------------------------------------------------------------------------------------------------------------------+');
    return (-999);
  else
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('           THERE IS NO DANGLING TIME ATTRIBUTES    ');
    bis_collection_utilities.put_line('+---------------------------------------------------------------------------+');
    bis_collection_utilities.put_line(' ');
  end if;

  fii_util.stop_timer;
  fii_util.print_timer('Completed time continuity check in');

  return(1);

exception
  when others then
    g_errbuf  := 'Error in Function CHECK_TIME_CONTINUITY_INIT : '||sqlerrm;
    g_retcode := sqlcode;
    return(-1);

end check_time_continuity_init;

function dangling_check_init return number is

  l_time_danling	number;
  l_item_count		number;
  l_miss_conv		number;
  l_dangling		number;

begin

  l_time_danling := 0;
  l_item_count := 0;
  l_miss_conv := 0;
  l_dangling := 0;

  bis_collection_utilities.put_line(' ');
  bis_collection_utilities.put_line('Identifying the missing currency conversion rates');
  fii_util.start_timer;

  l_miss_conv := REPORT_MISSING_RATE;

  fii_util.stop_timer;
  fii_util.print_timer('Completed missing currency check in');

  if (l_miss_conv = -1) then
    return(-1);
  elsif (l_miss_conv > 0) then
    g_errbuf  := g_errbuf || 'Collection aborted due to missing currency conversion rates. ';
    l_dangling := -999;
  end if;

--  bis_collection_utilities.put_line(' ');
--  bis_collection_utilities.put_line('Checking Time Continuity');
--
--  l_time_danling := CHECK_TIME_CONTINUITY_INIT;
--
--  if (l_time_danling = -1) then
--    return(-1);
--  elsif (l_time_danling = -999) then
--    g_errbuf  := g_errbuf || 'Collection aborted due to dangling keys for time dimension. ';
--    l_dangling := -999;
--  end if;

  if (l_dangling = -999) then
    return(-1);
  end if;

  return(1);

exception
  when others then
    g_errbuf  := 'Error in Function DANGLING_CHECK_INIT : '||sqlerrm;
    g_retcode	:= sqlcode;
    return(-1);

end dangling_check_init;

function insert_fact return number is

  l_bsa_count	number;

begin

  bis_collection_utilities.put_line(' ');
  bis_collection_utilities.put_line('Inserting data into isc_dbi_bsa_order_lines_f');
  fii_util.start_timer;

  insert /*+ APPEND PARALLEL(F) */ into isc_dbi_bsa_order_lines_f f (
    order_line_id,
    order_line_header_id,
    order_number,
    line_number,
    inventory_item_id,
    item_inv_org_id,
    blanket_line_id,
    blanket_header_id,
    blanket_number,
    blanket_line_number,
    org_id,
    salesrep_id,
    sales_grp_id,
    agreement_type_id,
    sold_to_org_id,
    customer_id,
    time_activation_date_id,
    time_expiration_date_id,
    time_termination_date_id,
    time_fulfilled_date_id,
    time_effective_end_date_id,
    h_start_date_active,
    l_start_date_active,
    h_end_date_active,
    l_end_date_active,
    termination_date,
    blanket_min_amt,
    blanket_line_min_amt,
    fulfilled_amt_g,
    fulfilled_amt_g1,
    h_cnt,
    l_cnt,
    commit_prorated_amt_g,
    commit_prorated_amt_g1,
    fulfilled_outstand_amt_g,
    fulfilled_outstand_amt_g1,
    transaction_phase_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    program_id,
    program_login_id,
    program_application_id,
    request_id
  )
  select /*+  use_hash(curr,tmp,sg,cust_acct) PARALLEL(curr) PARALLEL(tmp) PARALLEL(sg) PARALLEL(cust_acct)  */
  	 tmp.order_line_id,
         tmp.order_line_header_id,
  	 tmp.order_number,
	 tmp.line_number,
	 tmp.inventory_item_id,
	 tmp.item_inv_org_id,
	 tmp.blanket_line_id,
	 tmp.blanket_header_id,
	 tmp.blanket_number,
	 tmp.blanket_line_number,
         tmp.org_id,
	 sg.resource_id,
	 sg.group_id,
	 tmp.agreement_type_id,
	 tmp.sold_to_org_id,
	 cust_acct.party_id,
	 tmp.time_activation_date_id,
	 tmp.time_expiration_date_id,
	 tmp.time_termination_date_id,
	 tmp.time_fulfilled_date_id,
	 tmp.time_effective_end_date_id,
	 tmp.h_start_date_active,
	 tmp.l_start_date_active,
	 tmp.h_end_date_active,
	 tmp.l_end_date_active,
	 tmp.termination_date,
	 tmp.blanket_min_amt,
	 tmp.blanket_line_min_amt,
	 tmp.fulfilled_amt_g,
	 tmp.fulfilled_amt_g1,
	 tmp.h_cnt,
	 tmp.l_cnt,
	 nvl(tmp.blanket_min_amt*curr.rate1/tmp.h_cnt, tmp.blanket_line_min_amt*curr.rate1/tmp.l_cnt),
	 nvl(tmp.blanket_min_amt*curr.rate2/tmp.h_cnt, tmp.blanket_line_min_amt*curr.rate2/tmp.l_cnt),
	 decode((tmp.accumulated_fulfilled_amt_g - nvl(tmp.blanket_min_amt*curr.rate1,tmp.blanket_line_min_amt*curr.rate1) - tmp.fulfilled_amt_g),
                abs(tmp.accumulated_fulfilled_amt_g - nvl(tmp.blanket_min_amt*curr.rate1,tmp.blanket_line_min_amt*curr.rate1) - tmp.fulfilled_amt_g),
                0,
                decode((nvl(tmp.blanket_min_amt*curr.rate1, tmp.blanket_line_min_amt*curr.rate1) - tmp.accumulated_fulfilled_amt_g),
                       abs(nvl(tmp.blanket_min_amt*curr.rate1, tmp.blanket_line_min_amt*curr.rate1) - tmp.accumulated_fulfilled_amt_g),
                       tmp.fulfilled_amt_g,
                       (nvl(tmp.blanket_min_amt*curr.rate1, tmp.blanket_line_min_amt*curr.rate1) - tmp.accumulated_fulfilled_amt_g + tmp.fulfilled_amt_g))),
	 decode((tmp.accumulated_fulfilled_amt_g1 - nvl(tmp.blanket_min_amt*curr.rate2,tmp.blanket_line_min_amt*curr.rate2) - tmp.fulfilled_amt_g1),
                abs(tmp.accumulated_fulfilled_amt_g1 - nvl(tmp.blanket_min_amt*curr.rate2,tmp.blanket_line_min_amt*curr.rate2) - tmp.fulfilled_amt_g1),
                0,
                decode((nvl(tmp.blanket_min_amt*curr.rate2, tmp.blanket_line_min_amt*curr.rate2) - tmp.accumulated_fulfilled_amt_g1),
                       abs(nvl(tmp.blanket_min_amt*curr.rate2, tmp.blanket_line_min_amt*curr.rate2) - tmp.accumulated_fulfilled_amt_g1),
                       tmp.fulfilled_amt_g1,
                       (nvl(tmp.blanket_min_amt*curr.rate2, tmp.blanket_line_min_amt*curr.rate2) - tmp.accumulated_fulfilled_amt_g1 + tmp.fulfilled_amt_g1))),
         tmp.transaction_phase_code,
    	 tmp.created_by,
    	 tmp.creation_date,
    	 tmp.last_updated_by,
    	 tmp.last_update_date,
    	 tmp.last_update_login,
    	 tmp.program_id,
    	 tmp.program_login_id,
    	 tmp.program_application_id,
    	 tmp.request_id
    from isc_dbi_tmp_bsa_order_lines tmp,
         isc_curr_bsa_order_lines curr,
         jtf_rs_srp_groups sg,
         hz_cust_accounts cust_acct
   where tmp.transactional_curr_code = curr.from_currency
     and tmp.time_activation_date_id = curr.conversion_date
     and tmp.salesrep_id = sg.salesrep_id
     and tmp.org_id = sg.org_id
     and tmp.h_start_date_active between sg.start_date and sg.end_date
     and tmp.sold_to_org_id = cust_acct.cust_account_id;

  l_bsa_count := sql%rowcount;
  fii_util.stop_timer;
  fii_util.print_timer('Inserted '|| l_bsa_count ||' rows into isc_dbi_bsa_order_lines_f in');

  commit;

  return(l_bsa_count);

exception
  when others then
    g_errbuf  := 'Error in Function INSERT_FACT : '||sqlerrm;
    g_retcode	:= sqlcode;
    return(-1);

end insert_fact;

function wrapup return number is

begin

  bis_collection_utilities.put_line('Truncating the temp tables');
  fii_util.start_timer;

  execute immediate 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_TMP_BSA_ORDER_LINES';
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_CURR_BSA_ORDER_LINES';

  fii_util.stop_timer;
  fii_util.print_timer('Truncated the temp tables in');
  bis_collection_utilities.put_line(' ');

  bis_collection_utilities.wrapup(
  true,
  g_row_count,
  null,
  isc_dbi_bsa_objects_c.g_push_from_date,
  isc_dbi_bsa_objects_c.g_push_to_date
  );

  return (1);

exception
  when others then
    g_errbuf  := 'Error in Function WRAPUP : '||sqlerrm;
    g_retcode := sqlcode;
    return(-1);
end wrapup;

procedure load_fact(errbuf		in out nocopy varchar2,
                    retcode		in out nocopy varchar2) is

  l_failure		exception;
  l_start		date;
  l_end			date;
  l_period_from		date;
  l_period_to		date;
  l_row_count		number;

begin

  errbuf := null;
  retcode := '0';
  g_load_mode := 'INITIAL';

  bis_collection_utilities.put_line(' ');
  bis_collection_utilities.put_line('Begin the ' || g_load_mode || ' load');

  if (not bis_collection_utilities.setup('ISC_DBI_BSA_ORDER_LINES_INIT')) then
    raise_application_error (-20000,'Error in SETUP: ' || errbuf);
    return;
  end if;

  if (CHECK_SETUP = -1)
    then raise l_failure;
  end if;

  isc_dbi_bsa_objects_c.g_push_from_date := g_global_start_date;
  isc_dbi_bsa_objects_c.g_push_to_date := sysdate;

  bis_collection_utilities.put_line( 'The collection date range is from '||
    to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
    to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
  bis_collection_utilities.put_line(' ');

  execute immediate 'alter session set hash_area_size=104857600';
  execute immediate 'alter session set sort_area_size=104857600';

  l_row_count := IDENTIFY_CHANGE_INIT;

  if (l_row_count = -1) then
    raise l_failure;

  elsif (l_row_count = 0) then
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Truncating the fact tables');
    fii_util.start_timer;

    execute immediate 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_BSA_ORDER_LINES_F';

    fii_util.stop_timer;
    fii_util.print_timer('Truncated the fact tables in');
    g_row_count := 0;

  else
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Analyzing temp tables');
    fii_util.start_timer;

    fnd_stats.gather_table_stats(ownname => g_isc_schema,
    			         tabname => 'ISC_DBI_TMP_BSA_ORDER_LINES');
    fnd_stats.gather_table_stats(ownname => g_isc_schema,
    			         tabname => 'ISC_CURR_BSA_ORDER_LINES');

    fii_util.stop_timer;
    fii_util.print_timer('Analyzed the temp tables in ');

    if (DANGLING_CHECK_INIT = -1) then
      raise l_failure;
    end if;

    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Truncating the fact tables');
    fii_util.start_timer;

    execute immediate 'TRUNCATE TABLE ' || g_isc_schema ||'.ISC_DBI_BSA_ORDER_LINES_F';

    fii_util.stop_timer;
    fii_util.print_timer('Truncated the fact tables in');

    g_row_count := INSERT_FACT;

    if (g_row_count = -1) then
      raise l_failure;
    end if;

  end if;

  if (WRAPUP = -1) then
    raise l_failure;
  end if;

  retcode := g_retcode;
  errbuf := g_errbuf;

exception

  when l_failure then
    rollback;
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    bis_collection_utilities.wrapup(
    false,
    g_row_count,
    g_errbuf,
    isc_dbi_bsa_objects_c.g_push_from_date,
    isc_dbi_bsa_objects_c.g_push_to_date
    );

  when others then
    rollback;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    bis_collection_utilities.wrapup(
    false,
    g_row_count,
    g_errbuf,
    isc_dbi_bsa_objects_c.g_push_from_date,
    isc_dbi_bsa_objects_c.g_push_to_date
    );

end load_fact;

function identify_change_icrl return number is

  l_total		number;

begin

  l_total := 0;

  -- insert into log table

  -- analyze log table

  -- delete obsoleted records from base summary

  fii_util.start_timer;

  insert /*+ APPEND PARALLEL(F) */ into isc_dbi_tmp_bsa_order_lines f (
    order_line_id,
    order_line_header_id,
    order_number,
    line_number,
    inventory_item_id,
    item_inv_org_id,
    blanket_line_id,
    blanket_header_id,
    blanket_number,
    blanket_line_number,
    org_id,
    salesrep_id,
    agreement_type_id,
    sold_to_org_id,
    time_activation_date_id,
    time_expiration_date_id,
    time_termination_date_id,
    time_fulfilled_date_id,
    time_effective_end_date_id,
    h_start_date_active,
    l_start_date_active,
    h_end_date_active,
    l_end_date_active,
    termination_date,
    blanket_min_amt,
    blanket_line_min_amt,
    fulfilled_amt_g,
    fulfilled_amt_g1,
    accumulated_fulfilled_amt_g,
    accumulated_fulfilled_amt_g1,
    h_cnt,
    l_cnt,
    transactional_curr_code,
    transaction_phase_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    program_id,
    program_login_id,
    program_application_id,
    request_id
  )
  select /*+ USE_HASH(bh,bhe,bl,ble,r,book) PARALLEL(bh) PARALLEL(bhe) PARALLEL(bl) PARALLEL(ble) PARALLEL(r) PARALLEL(book) */
         book.line_id,
         book.header_id,
         book.order_number,
         book.line_number,
         book.inventory_item_id,
         book.item_inv_org_id,
	 bl.line_id,
	 bh.header_id,
	 bh.order_number,
	 ble.line_number,
         bh.org_id,
	 bh.salesrep_id,
	 bh.order_type_id,
	 bh.sold_to_org_id,
	 trunc(decode(bhe.blanket_min_amount, null, ble.start_date_active, bhe.start_date_active)),
	 trunc(decode(bhe.blanket_min_amount, null, ble.end_date_active, bhe.end_date_active)),
         trunc(r.creation_date),
         book.time_fulfilled_date_id,
         least(nvl(trunc(r.creation_date), trunc(decode(bhe.blanket_min_amount, null, ble.end_date_active, bhe.end_date_active))),
               nvl(trunc(decode(bhe.blanket_min_amount, null, ble.end_date_active, bhe.end_date_active)), trunc(r.creation_date))),
	 bhe.start_date_active,
         ble.start_date_active,
         bhe.end_date_active,
         ble.end_date_active,
         r.creation_date,
         bhe.blanket_min_amount,
         ble.blanket_line_min_amount,
         book.fulfilled_amt_g,
         book.fulfilled_amt_g1,
         sum(book.fulfilled_amt_g) over (partition by bh.header_id order by book.time_fulfilled_date_id, book.line_id range unbounded preceding),
         sum(book.fulfilled_amt_g1) over (partition by bh.header_id order by book.time_fulfilled_date_id, book.line_id range unbounded preceding),
         count(1) over (partition by bh.header_id),
         count(1) over (partition by bl.line_id),
	 bh.transactional_curr_code,
         bh.transaction_phase_code,
	 bh.created_by,
	 bh.creation_date,
	 bh.last_updated_by,
	 bh.last_update_date,
	 bh.last_update_login,
	 null,
	 null,
	 null,
	 null
    from oe_blanket_headers_all bh,
         oe_blanket_headers_ext bhe,
         oe_blanket_lines_all bl,
         oe_blanket_lines_ext ble,
         oe_reasons r,
         isc_book_sum2_f book
   where bh.order_number = bhe.order_number
     and bh.header_id = bl.header_id
     and bl.line_id = ble.line_id
     and r.entity_code(+) = 'BLANKET_HEADER'
     and r.reason_type(+) = 'CONTRACT_TERMINATION'
     and r.entity_id(+) = bh.header_id
     and book.blanket_number(+) = ble.order_number
     and book.blanket_line_number(+) = ble.line_number
     and bh.transaction_phase_code = 'F'
     and bh.sold_to_org_id is not null
     and (bhe.blanket_min_amount is not null or ble.blanket_line_min_amount is not null)
     and nvl(r.creation_date,bhe.start_date_active+1) >= bhe.start_date_active
     and book.line_category_code(+) <> 'RETURN'
     and book.order_source_id(+) <> 10
     and book.order_source_id(+) <> 27
     and book.ordered_quantity(+) <> 0
     and book.unit_selling_price(+) <> 0
     and book.charge_periodicity_code(+) is null;

  fii_util.stop_timer;
  fii_util.print_timer('Identified '|| sql%rowcount || ' blanket sales agreement in');
  commit;

  fii_util.start_timer;

  insert /*+ APPEND */ into isc_curr_bsa_order_lines f (
    from_currency,
    conversion_date,
    rate1,
    rate2
  )
  select transactional_curr_code   from_currency,
  	 time_activation_date_id   conversion_date,
	 decode(transactional_curr_code, g_global_currency, 1,
	 	fii_currency.get_global_rate_primary(transactional_curr_code, time_activation_date_id)) rate1,
         decode(transactional_curr_code, g_sec_global_currency, 1,
                fii_currency.get_global_rate_secondary(transactional_curr_code, time_activation_date_id)) rate2
    from (select /*+ PARALLEL(tmp) */ distinct transactional_curr_code, time_activation_date_id
	    from isc_dbi_tmp_bsa_order_lines tmp);

  fii_util.stop_timer;
  fii_util.print_timer('Retrieved '||sql%rowcount||' currency rates in');
  commit;

  fii_util.start_timer;

  update isc_dbi_tmp_bsa_order_lines set batch_id = ceil(rownum/g_batch_size);
  l_total := sql%rowcount;
  commit;

  fii_util.stop_timer;
  fii_util.print_timer('Updated the batch id for '|| l_total || ' rows in');

  return(l_total);

exception
  when others then
    g_errbuf  := 'Error in Function IDENTIFY_CHANGE_ICRL : '||sqlerrm;
    g_retcode := sqlcode;
    return(-1);

end identify_change_icrl;

function check_time_continuity_icrl return number is

  l_min_act_date	date;
  l_max_act_date	date;
  l_min_exp_date	date;
  l_max_exp_date	date;
  l_min_trm_date	date;
  l_max_trm_date	date;
  l_min			date;
  l_max			date;
  l_is_missing		boolean;
  l_time_min		date;
  l_time_max		date;
  l_time_missing	boolean;

  cursor lines_missing_date is
    select order_number,
	   line_number,
	   order_line_id,
	   blanket_number,
	   to_char(time_activation_date_id, 'MM/DD/YYYY') time_activation_date_id,
	   to_char(time_expiration_date_id, 'MM/DD/YYYY') time_expiration_date_id,
	   to_char(time_termination_date_id,'MM/DD/YYYY') time_termination_date_id
      from isc_dbi_tmp_bsa_order_lines
     where (least(time_activation_date_id,
                  nvl(time_expiration_date_id,time_activation_date_id),
                  nvl(time_termination_date_id,time_activation_date_id)) < l_time_min
        or greatest(time_activation_date_id,
                    nvl(time_expiration_date_id,time_activation_date_id),
                    nvl(time_termination_date_id,time_activation_date_id)) > l_time_max);

  l_line	lines_missing_date%rowtype;

begin

  fii_util.start_timer;

  bis_collection_utilities.put_line('Begin to retrieve the time boundary for the initial load');
  select /*+ PARALLEL(tmp) */
         min(time_activation_date_id), max(time_activation_date_id),
         min(time_expiration_date_id), max(time_expiration_date_id),
         min(time_termination_date_id), max(time_termination_date_id)
    into l_min_act_date, l_max_act_date,
         l_min_exp_date, l_max_exp_date,
         l_min_trm_date, l_max_trm_date
    from isc_dbi_tmp_bsa_order_lines tmp;

  l_min := least(l_min_act_date,
                 nvl(l_min_exp_date,l_min_act_date),
                 nvl(l_min_trm_date,l_min_act_date));
  l_max := greatest(l_max_act_date,
                    nvl(l_max_exp_date,l_max_act_date),
                    nvl(l_max_trm_date, l_max_act_date));

  fii_util.stop_timer;
  fii_util.print_timer('Retrieved the time boundary in ');

  fii_util.start_timer;

  bis_collection_utilities.put_line_out(' ');
  bis_collection_utilities.put_line_out(' ');
  fii_time_api.check_missing_date(l_min, l_max, l_is_missing);

  if (l_is_missing) then
    bis_collection_utilities.put_line('Collection failed because there are dangling keys for time dimension.');
    bis_collection_utilities.put_line('No records were loaded.');

    select min(report_date), max(report_date)
      into l_time_min, l_time_max
      from fii_time_day;

    open lines_missing_date;
    fetch lines_missing_date into l_line;
    bis_collection_utilities.put_line_out(fnd_message.get_string('ISC', 'ISC_DBI_DATE_NO_LOAD'));
    bis_collection_utilities.put_line_out(' ');
    bis_collection_utilities.put_line_out(rpad(fnd_message.get_string('ISC','ISC_DBI_ORDER_NUMBER'),18,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_LINE_NUMBER'),18,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_LINE_ID'),18,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_BLANKET_NUMBER'),18,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_ACTIVATION_DATE'),15,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_EXPIRATION_DATE'),19,' ')
	||' - '||rpad(fnd_message.get_string('ISC','ISC_DBI_TERMINATION_DATE'),16,' '));
    bis_collection_utilities.put_line_out('------------------ - ------------------ - ------------------ - --------------- - ------------------- - ---------------- - ------------------------');

    while lines_missing_date%found loop
      bis_collection_utilities.put_line_out(rpad(l_line.order_number,18,' ')
			      ||' - '||rpad(l_line.line_number,18,' ')
			      ||' - '||rpad(l_line.order_line_id,18,' ')
			      ||' - '||rpad(l_line.blanket_number,18,' ')
			      ||' - '||rpad(l_line.time_activation_date_id,15,' ')
			      ||' - '||rpad(nvl(l_line.time_expiration_date_id,' '),19,' ')
			      ||' - '||rpad(nvl(l_line.time_termination_date_id,' '),16,' '));
      fetch lines_missing_date into l_line;
    end loop;

    close lines_missing_date;
    bis_collection_utilities.put_line_out('+------------------------------------------------------------------------------------------------------------------------------------------------+');
    return (-999);
  else
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('           THERE IS NO DANGLING TIME ATTRIBUTES    ');
    bis_collection_utilities.put_line('+---------------------------------------------------------------------------+');
    bis_collection_utilities.put_line(' ');
  end if;

  fii_util.stop_timer;
  fii_util.print_timer('Completed time continuity check in');

  return(1);

exception
  when others then
    g_errbuf  := 'Error in Function CHECK_TIME_CONTINUITY_ICRL : '||sqlerrm;
    g_retcode := sqlcode;
    return(-1);

END check_time_continuity_icrl;

function dangling_check_icrl return number is

  l_time_danling	number;
  l_miss_conv		number;
  l_dangling		number;

begin

  l_time_danling := 0;
  l_miss_conv := 0;
  l_dangling := 0;

  bis_collection_utilities.put_line(' ');
  bis_collection_utilities.put_line('Identifying the missing currency conversion rates');
  fii_util.start_timer;

  l_miss_conv := REPORT_MISSING_RATE;

  fii_util.stop_timer;
  fii_util.print_timer('Completed missing currency check in');

  if (l_miss_conv = -1) then
    return(-1);
  elsif (l_miss_conv > 0) then
    g_errbuf  := g_errbuf || 'Collection aborted due to missing currency conversion rates. ';
    l_dangling := -999;
  end if;

--  bis_collection_utilities.put_line(' ');
--  bis_collection_utilities.put_line('Checking Time Continuity');
--
--  l_time_danling := CHECK_TIME_CONTINUITY_ICRL;
--
--  if (l_time_danling = -1) then
--    return(-1);
--  elsif (l_time_danling = -999) then
--    g_errbuf  := g_errbuf || 'Collection aborted due to dangling keys for time dimension. ';
--    l_dangling := -999;
--  end if;

  if (l_dangling = -999) then
    return(-1);
  end if;

  return(1);

exception
  when others then
    g_errbuf  := 'Error in Function DANGLING_CHECK_ICRL : '||sqlerrm;
    g_retcode	:= sqlcode;
    return(-1);

end dangling_check_icrl;

function merge_fact(p_batch number) return number is

  cursor unfulfilled_bsa is
  select blanket_line_id,
         order_line_id
    from (select f.blanket_line_id,
	         t.order_line_id,
	         rank() over (partition by f.blanket_line_id order by t.order_line_id) rnk
            from isc_dbi_bsa_order_lines_f f,
                 isc_dbi_tmp_bsa_order_lines t
           where f.blanket_line_id = t.blanket_line_id
             and f.order_line_id is null
             and t.order_line_id is not null)
   where rnk = 1;

  l_record              unfulfilled_bsa%rowtype;
  l_count		number;
  l_total		number;
  l_max_batch		number;
  l_date		date;

begin

  open unfulfilled_bsa;
  fetch unfulfilled_bsa into l_record;

  if unfulfilled_bsa%rowcount <> 0 then
    while unfulfilled_bsa%found loop
      update isc_dbi_bsa_order_lines_f
         set order_line_id = l_record.order_line_id
       where blanket_line_id = l_record.blanket_line_id;
      fetch unfulfilled_bsa into l_record;
    end loop;
  end if;
  commit;
  close unfulfilled_bsa;

  l_total := 0;
  l_date := to_date('01/01/0001','DD/MM/YYYY');

  for v_batch_id in 1..p_batch loop
    fii_util.start_timer;
    bis_collection_utilities.put_line('Merging batch '||v_batch_id);

    l_count := 0;

    merge into isc_dbi_bsa_order_lines_f f using
    (select new.*
        from (select tmp.batch_id,
         tmp.order_line_id,
         tmp.order_line_header_id,
  	 tmp.order_number,
	 tmp.line_number,
	 tmp.inventory_item_id,
	 tmp.item_inv_org_id,
	 tmp.blanket_line_id,
	 tmp.blanket_header_id,
	 tmp.blanket_number,
	 tmp.blanket_line_number,
         tmp.org_id,
	 sg.resource_id salesrep_id,
	 sg.group_id  sales_grp_id,
	 tmp.agreement_type_id,
	 tmp.sold_to_org_id,
	 cust_acct.party_id  customer_id,
	 tmp.time_activation_date_id,
	 tmp.time_expiration_date_id,
	 tmp.time_termination_date_id,
	 tmp.time_fulfilled_date_id,
	 tmp.time_effective_end_date_id,
	 tmp.h_start_date_active,
	 tmp.l_start_date_active,
	 tmp.h_end_date_active,
	 tmp.l_end_date_active,
	 tmp.termination_date,
	 tmp.blanket_min_amt,
	 tmp.blanket_line_min_amt,
	 tmp.fulfilled_amt_g,
	 tmp.fulfilled_amt_g1,
	 tmp.h_cnt,
	 tmp.l_cnt,
	 nvl(tmp.blanket_min_amt*curr.rate1/tmp.h_cnt, tmp.blanket_line_min_amt*curr.rate1/tmp.l_cnt)  commit_prorated_amt_g,
	 nvl(tmp.blanket_min_amt*curr.rate2/tmp.h_cnt, tmp.blanket_line_min_amt*curr.rate2/tmp.l_cnt)  commit_prorated_amt_g1,
	 decode((tmp.accumulated_fulfilled_amt_g - nvl(tmp.blanket_min_amt*curr.rate1,tmp.blanket_line_min_amt*curr.rate1) - tmp.fulfilled_amt_g),
                abs(tmp.accumulated_fulfilled_amt_g - nvl(tmp.blanket_min_amt*curr.rate1,tmp.blanket_line_min_amt*curr.rate1) - tmp.fulfilled_amt_g),
                0,
                decode((nvl(tmp.blanket_min_amt*curr.rate1, tmp.blanket_line_min_amt*curr.rate1) - tmp.accumulated_fulfilled_amt_g),
                       abs(nvl(tmp.blanket_min_amt*curr.rate1, tmp.blanket_line_min_amt*curr.rate1) - tmp.accumulated_fulfilled_amt_g),
                       tmp.fulfilled_amt_g,
                       (nvl(tmp.blanket_min_amt*curr.rate1, tmp.blanket_line_min_amt*curr.rate1) - tmp.accumulated_fulfilled_amt_g + tmp.fulfilled_amt_g)))
            fulfilled_outstand_amt_g,
	 decode((tmp.accumulated_fulfilled_amt_g1 - nvl(tmp.blanket_min_amt*curr.rate2,tmp.blanket_line_min_amt*curr.rate2) - tmp.fulfilled_amt_g1),
                abs(tmp.accumulated_fulfilled_amt_g1 - nvl(tmp.blanket_min_amt*curr.rate2,tmp.blanket_line_min_amt*curr.rate2) - tmp.fulfilled_amt_g1),
                0,
                decode((nvl(tmp.blanket_min_amt*curr.rate2, tmp.blanket_line_min_amt*curr.rate2) - tmp.accumulated_fulfilled_amt_g1),
                       abs(nvl(tmp.blanket_min_amt*curr.rate2, tmp.blanket_line_min_amt*curr.rate2) - tmp.accumulated_fulfilled_amt_g1),
                       tmp.fulfilled_amt_g1,
                       (nvl(tmp.blanket_min_amt*curr.rate2, tmp.blanket_line_min_amt*curr.rate2) - tmp.accumulated_fulfilled_amt_g1 + tmp.fulfilled_amt_g1)))
            fulfilled_outstand_amt_g1,
         tmp.transaction_phase_code,
    	 tmp.created_by,
    	 tmp.creation_date,
    	 tmp.last_updated_by,
    	 tmp.last_update_date,
    	 tmp.last_update_login,
    	 tmp.program_id,
    	 tmp.program_login_id,
    	 tmp.program_application_id,
    	 tmp.request_id
    from isc_dbi_tmp_bsa_order_lines tmp,
         isc_curr_bsa_order_lines curr,
         jtf_rs_srp_groups sg,
         hz_cust_accounts cust_acct
   where tmp.transactional_curr_code = curr.from_currency
     and tmp.time_activation_date_id = curr.conversion_date
     and tmp.salesrep_id = sg.salesrep_id
     and tmp.org_id = sg.org_id
     and tmp.h_start_date_active between sg.start_date and sg.end_date
     and tmp.sold_to_org_id = cust_acct.cust_account_id) new, isc_dbi_bsa_order_lines_f old
       where new.batch_id = v_batch_id
         and new.blanket_line_id = old.blanket_line_id(+)
         and nvl(new.order_line_id,-1) = nvl(old.order_line_id(+),-1)
	 and (old.blanket_line_id is null
           or nvl(new.order_line_header_id,-1) <> nvl(old.order_line_header_id,-1)
           or nvl(new.order_number,-1) <> nvl(old.order_number,-1)
           or nvl(new.line_number,'na') <> nvl(old.line_number,'na')
           or nvl(new.inventory_item_id,-1) <> nvl(old.inventory_item_id,-1)
           or nvl(new.item_inv_org_id,-1) <> nvl(old.item_inv_org_id,-1)
           or nvl(new.org_id,-1) <> nvl(old.org_id,-1)
           or nvl(new.salesrep_id,-1) <> nvl(old.salesrep_id,-1)
           or nvl(new.sales_grp_id,-1) <> nvl(old.sales_grp_id,-1)
           or nvl(new.agreement_type_id,-1) <> nvl(old.agreement_type_id,-1)
           or nvl(new.sold_to_org_id,-1) <> nvl(old.sold_to_org_id,-1)
           or nvl(new.customer_id,-1) <> nvl(old.customer_id,-1)
           or nvl(new.time_activation_date_id,l_date) <> nvl(old.time_activation_date_id,l_date)
           or nvl(new.time_expiration_date_id,l_date) <> nvl(old.time_expiration_date_id,l_date)
           or nvl(new.time_termination_date_id,l_date) <> nvl(old.time_termination_date_id,l_date)
           or nvl(new.time_fulfilled_date_id,l_date) <> nvl(old.time_fulfilled_date_id,l_date)
           or nvl(new.time_effective_end_date_id,l_date) <> nvl(old.time_effective_end_date_id,l_date)
           or nvl(new.h_start_date_active,l_date) <> nvl(old.h_start_date_active,l_date)
           or nvl(new.l_start_date_active,l_date) <> nvl(old.l_start_date_active,l_date)
           or nvl(new.h_end_date_active,l_date) <> nvl(old.h_end_date_active,l_date)
           or nvl(new.l_end_date_active,l_date) <> nvl(old.l_end_date_active,l_date)
           or nvl(new.termination_date,l_date) <> nvl(old.termination_date,l_date)
           or nvl(new.blanket_min_amt,0) <> nvl(old.blanket_min_amt,0)
           or nvl(new.blanket_line_min_amt,0) <> nvl(old.blanket_line_min_amt,0)
           or nvl(new.fulfilled_amt_g,0) <> nvl(old.fulfilled_amt_g,0)
           or nvl(new.fulfilled_amt_g1,0) <> nvl(old.fulfilled_amt_g1,0)
           or nvl(new.h_cnt,0) <> nvl(old.h_cnt,0)
           or nvl(new.l_cnt,0) <> nvl(old.l_cnt,0)
           or nvl(new.commit_prorated_amt_g,0) <> nvl(old.commit_prorated_amt_g,0)
           or nvl(new.commit_prorated_amt_g1,0) <> nvl(old.commit_prorated_amt_g1,0)
           or nvl(new.fulfilled_outstand_amt_g,0) <> nvl(old.fulfilled_outstand_amt_g,0)
           or nvl(new.fulfilled_outstand_amt_g1,0) <> nvl(old.fulfilled_outstand_amt_g1,0)
           or nvl(new.transaction_phase_code,'na') <> nvl(old.transaction_phase_code,'na'))) v
     ON (   nvl(f.order_line_id,-1) = nvl(v.order_line_id,-1)
      and   f.blanket_line_id = v.blanket_line_id)
     WHEN MATCHED THEN UPDATE SET
        f.order_line_header_id = v.order_line_header_id,
        f.order_number = v.order_number,
        f.line_number = v.line_number,
        f.inventory_item_id = v.inventory_item_id,
        f.item_inv_org_id = v.item_inv_org_id,
        f.org_id = v.org_id,
        f.salesrep_id = v.salesrep_id,
        f.sales_grp_id = v.sales_grp_id,
        f.agreement_type_id = v.agreement_type_id,
        f.sold_to_org_id = v.sold_to_org_id,
        f.customer_id = v.customer_id,
        f.time_activation_date_id = v.time_activation_date_id,
        f.time_expiration_date_id = v.time_expiration_date_id,
        f.time_termination_date_id = v.time_termination_date_id,
        f.time_fulfilled_date_id = v.time_fulfilled_date_id,
        f.time_effective_end_date_id = v.time_effective_end_date_id,
        f.h_start_date_active = v.h_start_date_active,
        f.l_start_date_active = v.l_start_date_active,
        f.h_end_date_active = v.h_end_date_active,
        f.l_end_date_active = v.l_end_date_active,
        f.termination_date = v.termination_date,
        f.blanket_min_amt = v.blanket_min_amt,
        f.blanket_line_min_amt = v.blanket_line_min_amt,
        f.fulfilled_amt_g = v.fulfilled_amt_g,
        f.fulfilled_amt_g1 = v.fulfilled_amt_g1,
        f.h_cnt = v.h_cnt,
        f.l_cnt = v.l_cnt,
        f.commit_prorated_amt_g = v.commit_prorated_amt_g,
        f.commit_prorated_amt_g1 = v.commit_prorated_amt_g1,
        f.fulfilled_outstand_amt_g = v.fulfilled_outstand_amt_g,
        f.fulfilled_outstand_amt_g1 = v.fulfilled_outstand_amt_g1,
        f.transaction_phase_code = v.transaction_phase_code
     WHEN NOT MATCHED THEN INSERT(
        f.order_line_id,
        f.order_line_header_id,
        f.order_number,
        f.line_number,
        f.inventory_item_id,
        f.item_inv_org_id,
        f.blanket_line_id,
        f.blanket_header_id,
        f.blanket_number,
        f.blanket_line_number,
        f.org_id,
        f.salesrep_id,
        f.sales_grp_id,
        f.agreement_type_id,
        f.sold_to_org_id,
        f.customer_id,
        f.time_activation_date_id,
        f.time_expiration_date_id,
        f.time_termination_date_id,
        f.time_fulfilled_date_id,
        f.time_effective_end_date_id,
        f.h_start_date_active,
        f.l_start_date_active,
        f.h_end_date_active,
        f.l_end_date_active,
        f.termination_date,
        f.blanket_min_amt,
        f.blanket_line_min_amt,
        f.fulfilled_amt_g,
        f.fulfilled_amt_g1,
        f.h_cnt,
        f.l_cnt,
        f.commit_prorated_amt_g,
        f.commit_prorated_amt_g1,
        f.fulfilled_outstand_amt_g,
        f.fulfilled_outstand_amt_g1,
        f.transaction_phase_code,
        f.created_by,
        f.creation_date,
        f.last_updated_by,
        f.last_update_date,
        f.last_update_login,
        f.program_id,
        f.program_login_id,
        f.program_application_id,
        f.request_id
     )
     VALUES (
        v.order_line_id,
        v.order_line_header_id,
        v.order_number,
        v.line_number,
        v.inventory_item_id,
        v.item_inv_org_id,
        v.blanket_line_id,
        v.blanket_header_id,
        v.blanket_number,
        v.blanket_line_number,
        v.org_id,
        v.salesrep_id,
        v.sales_grp_id,
        v.agreement_type_id,
        v.sold_to_org_id,
        v.customer_id,
        v.time_activation_date_id,
        v.time_expiration_date_id,
        v.time_termination_date_id,
        v.time_fulfilled_date_id,
        v.time_effective_end_date_id,
        v.h_start_date_active,
        v.l_start_date_active,
        v.h_end_date_active,
        v.l_end_date_active,
        v.termination_date,
        v.blanket_min_amt,
        v.blanket_line_min_amt,
        v.fulfilled_amt_g,
        v.fulfilled_amt_g1,
        v.h_cnt,
        v.l_cnt,
        v.commit_prorated_amt_g,
        v.commit_prorated_amt_g1,
        v.fulfilled_outstand_amt_g,
        v.fulfilled_outstand_amt_g1,
        v.transaction_phase_code,
        -1,
        g_incre_start_date,
        -1,
        g_incre_start_date,
        -1,
        -1,
        -1,
        -1,
        -1);

    l_count := sql%rowcount;
    l_total := l_total + l_count;
    commit;

    fii_util.stop_timer;
    fii_util.print_timer('Merged '||l_count|| ' rows in ');

  end loop;

  return(l_total);

exception
  when others then
    g_errbuf  := 'Error in Function MERGE_FACT : '||sqlerrm;
    g_retcode	:= sqlcode;
    return(-1);

end merge_fact;

procedure update_fact(errbuf		in out nocopy varchar2,
                      retcode		in out nocopy varchar2) is

  l_failure		exception;
  l_start		date;
  l_end			date;
  l_period_from		date;
  l_period_to		date;
  l_row_count		number;

begin

  errbuf  := null;
  retcode := '0';
  g_load_mode := 'INCREMENTAL';
  l_row_count := 0;

  bis_collection_utilities.put_line(' ');
  bis_collection_utilities.put_line('Begin the ' || g_load_mode || ' load');

  if (not bis_collection_utilities.setup('ISC_DBI_BSA_ORDER_LINES_INCR')) then
    raise_application_error(-20000,'Error in SETUP: ' || errbuf);
    return;
  end if;

  isc_dbi_bsa_objects_c.g_push_from_date := null;
  isc_dbi_bsa_objects_c.g_push_to_date := sysdate;

  if (CHECK_SETUP = -1)
    then raise l_failure;
  end if;

  bis_collection_utilities.put_line('Identifying changed records');

  g_incre_start_date := sysdate;
  bis_collection_utilities.put_line('Last updated date is '|| to_char(g_incre_start_date,'MM/DD/YYYY HH24:MI:SS'));
  l_row_count := IDENTIFY_CHANGE_ICRL;

  if (l_row_count = -1) then
    raise l_failure;
  elsif (l_row_count = 0) then
    g_row_count := 0;
  else

    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Analyzing temp tables');
    fii_util.start_timer;

    fnd_stats.gather_table_stats(ownname => g_isc_schema,
				 tabname => 'ISC_DBI_TMP_BSA_ORDER_LINES');
    fnd_stats.gather_table_stats(ownname => g_isc_schema,
				 tabname => 'ISC_CURR_BSA_ORDER_LINES');

    fii_util.stop_timer;
    fii_util.print_timer('Analyzed the temp tables in ');

    if (DANGLING_CHECK_ICRL = -1) then
      raise l_failure;
    end if;

    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Merging data to fact tables');

    g_row_count := MERGE_FACT(ceil(l_row_count/g_batch_size));

    bis_collection_utilities.put_line('Merged '||nvl(g_row_count,0)||' rows into the fact tables');

    if (g_row_count = -1) then
      raise l_failure;
    end if;

  end if;

  -- delete rows from log table

  if (WRAPUP = -1) then
    raise l_failure;
  end if;

  retcode := g_retcode;
  errbuf := g_errbuf;

exception

  when l_failure then
    rollback;
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    bis_collection_utilities.wrapup(
    false,
    g_row_count,
    g_errbuf,
    isc_dbi_bsa_objects_c.g_push_from_date,
    isc_dbi_bsa_objects_c.g_push_to_date
    );

  when others then
    rollback;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    bis_collection_utilities.put_line(' ');
    bis_collection_utilities.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    bis_collection_utilities.wrapup(
    false,
    g_row_count,
    g_errbuf,
    isc_dbi_bsa_objects_c.g_push_from_date,
    isc_dbi_bsa_objects_c.g_push_to_date
    );

end update_fact;

end isc_dbi_bsa_objects_c;

/
