--------------------------------------------------------
--  DDL for Package Body POA_DBI_REQ_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_REQ_F_C" AS
/* $Header: poadbireqfrefb.pls 120.10 2006/07/24 11:34:11 sdiwakar noship $ */
g_init boolean := false;

/* PUBLIC PROCEDURE */
PROCEDURE initial_load (
            errbuf    OUT NOCOPY VARCHAR2,
            retcode   OUT NOCOPY NUMBER
          )
IS
  l_poa_schema   VARCHAR2(30);
  l_status       VARCHAR2(30);
  l_industry     VARCHAR2(30);
  l_stmt         VARCHAR2(4000);
BEGIN
  IF (fnd_installation.get_app_info('POA', l_status, l_industry, l_poa_schema))  THEN
    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_REQ_F';
    EXECUTE immediate l_stmt;

    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_REQ_INC';
    EXECUTE immediate l_stmt;

    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_REQ_RATES';
    EXECUTE immediate l_stmt;

    g_init := TRUE;
    populate_req_facts (errbuf, retcode);
  END IF;

EXCEPTION
WHEN others THEN
   errbuf:= sqlerrm;
   retcode:=sqlcode;
   ROLLBACK;
   poa_log.debug_line('Initial_load' || sqlerrm || sqlcode || sysdate);
   raise_application_error(-20000,'Stack Dump Follows =>', true);
END initial_load;

/* PUBLIC PROCEDURE */
PROCEDURE populate_req_facts(
            errbuf    OUT NOCOPY VARCHAR2,
            retcode   OUT NOCOPY NUMBER
          )
IS
  l_no_batch NUMBER;
  l_go_ahead boolean := FALSE;
  l_count NUMBER := 0;
  l_poa_schema          VARCHAR2(30);
  l_status              VARCHAR2(30);
  l_industry            VARCHAR2(30);
  l_stmt VARCHAR2(4000);
  l_start_date VARCHAR2(22);
  l_end_date VARCHAR2(22);
  l_glob_date VARCHAR2(22);
  l_ret NUMBER;
  l_batch_size NUMBER;
  l_start_time DATE;
  l_login NUMBER;
  l_user NUMBER;
  l_dop NUMBER := 1;
  d_start_date DATE;
  d_end_date DATE;
  d_glob_date DATE;
  l_rate_type VARCHAR2(30);
  l_srate_type VARCHAR2(30);
  l_sec_cur_yn NUMBER;
  l_global_cur_code gl_sets_of_books.currency_code%type;
  l_sglobal_cur_code gl_sets_of_books.currency_code%type;
  l_num_corrupt_rows number;
  l_ret_variable boolean;
  cursor corrupt_rows is
    select
    rpad(hr.name,30) name,
    rpad(rhr.segment1,11) segment1,
    rpad(rln.line_num,5) line_num,
    pod.req_distribution_id,
    rln.requisition_line_id
    from
    poa_dbi_req_inc inc,
    po_requisition_headers_all rhr,
    po_requisition_lines_all rln,
    po_req_distributions_all rdn,
    po_distributions_all pod,
    po_headers_all poh,
    po_doc_style_headers style,
    hr_all_organization_units_tl hr
    where inc.primary_key = rln.requisition_line_id
    and rln.requisition_line_id = rdn.requisition_line_id
    and rdn.distribution_id = pod.req_distribution_id
    and pod.po_header_id = poh.po_header_id
    and poh.style_id = style.style_id
    and nvl(style.progress_payment_flag,'N') = 'N'
    and rhr.requisition_header_id = rln.requisition_header_id
    and rhr.org_id = hr.organization_id
    and hr.language = userenv('LANG')
    group by
    pod.req_distribution_id,
    rln.requisition_line_id,
    hr.name,
    rhr.segment1,
    rln.line_num,
    pod.req_distribution_id
    having count(*) > 1
    order by 1,2,3;
  l_corrupt_record corrupt_rows%rowtype;
  type corrupt_rec_table_type is table of l_corrupt_record%type;
  corrupt_rec_table corrupt_rec_table_type;
BEGIN
  errbuf :=NULL;
  retcode:=0;
  l_num_corrupt_rows := 0;
  l_batch_size := bis_common_parameters.get_batch_size(10);
  l_rate_type :=  bis_common_parameters.get_rate_type;
  l_global_cur_code := bis_common_parameters.get_currency_code;
  l_sglobal_cur_code := bis_common_parameters.get_secondary_currency_code;
  l_srate_type := bis_common_parameters.get_secondary_rate_type;
  if(poa_currency_pkg.display_secondary_currency_yn)
  then
    l_sec_cur_yn := 1;
  else
    l_sec_cur_yn := 0;
  end if;

  dbms_application_info.set_module(module_name => 'DBI REQ COLLECT', action_name => 'start');
  l_dop := bis_common_parameters.get_degree_of_parallelism;
   -- default DOP to profile in EDW_PARALLEL_SRC if 2nd param is not passed
  l_go_ahead := bis_collection_utilities.setup('POAREQLN');

  IF (g_init)
  then
    execute immediate 'alter session set hash_area_size=104857600';
    execute immediate 'alter session set sort_area_size=104857600';
  END IF;

  IF (NOT l_go_ahead) THEN
    errbuf := fnd_message.get;
    raise_application_error (-20000, 'Error in SETUP: ' || errbuf);
  END IF;
  bis_collection_utilities.g_debug := false;

  -- --------------------------------------------
  -- Taking care of cases where the input from/to
  -- date is NULL.
  -- --------------------------------------------

  IF (g_init) THEN
    l_start_date := To_char(bis_common_parameters.get_global_start_date,'YYYY/MM/DD HH24:MI:SS');
    d_start_date := bis_common_parameters.get_global_start_date;
  ELSE
    l_start_date := '''' || to_char(fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('POAREQLN'))-0.004,'YYYY/MM/DD HH24:MI:SS') || '''';
    /* if there is not a success record in the bis refresh log, then we have to get the global start date as l_start_date*/
    d_start_date := fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('POAREQLN'))-0.004;
  END IF;


  l_end_date := '''' || To_char(SYSDATE, 'YYYY/MM/DD HH24:MI:SS') || '''';
  d_end_date := SYSDATE;


  bis_collection_utilities.log( 'The collection range is from '||
                 l_start_date ||' to '|| l_end_date, 0);


  IF (l_batch_size is null) THEN
    l_batch_size := 10000;
  END IF;

  bis_collection_utilities.log('Truncate Currency Conversion table: '|| 'Sysdate=' ||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
  IF (fnd_installation.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_REQ_INC';
    EXECUTE IMMEDIATE l_stmt;

    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_REQ_RATES';
    EXECUTE IMMEDIATE l_stmt;
  END IF;

  dbms_application_info.set_action('inc');
  bis_collection_utilities.log('Populate Currency Conversion table '|| 'Sysdate=' ||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
  l_glob_date := '''' || To_char(bis_common_parameters.get_global_start_date, 'YYYY/MM/DD HH24:MI:SS') || '''';
  d_glob_date := bis_common_parameters.get_global_start_date;


  IF (g_init) THEN
    INSERT /*+ append parallel(poa_dbi_req_inc) */ INTO poa_dbi_req_inc
    (
      primary_key,
      line_location_id,
      batch_id,
      txn_cur_code,
      func_cur_code,
      rate_date
    )
    ( SELECT  /*+ PARALLEL(rhr) PARALLEL(rln) PARALLEL(poh) PARALLEL(pol)
PARALLEL(pll) PARALLEL(por) PARALLEL(pfsp) PARALLEL(rfsp) PARALLEL(pgl)
PARALLEL(rgl) USE_HASH(rhr) USE_HASH(rln) USE_HASH(poh) USE_HASH(pol)
USE_HASH(pll) USE_HASH(por) USE_HASH(pfsp) USE_HASH(rfsp) USE_HASH(pgl)
USE_HASH(rgl) */
      rln.requisition_line_id primary_key,
      pll.line_location_id,
      1 batch_id,
      decode(pll.line_location_id, null, nvl(rln.currency_code, rgl.currency_code),poh.currency_code) txn_cur_code,
      decode(pll.line_location_id, null, rgl.currency_code, pgl.currency_code) func_cur_code,
      decode(pll.line_location_id, null, nvl(trunc(rln.rate_date),trunc(rln.creation_date)), nvl(trunc(poh.rate_date), trunc(pll.creation_date))) rate_date
      FROM
      po_requisition_headers_all rhr,
      po_requisition_lines_all rln,
      po_req_distributions_all rdn,
      po_headers_all poh,
      po_lines_all pol,
      po_line_locations_all pll,
      po_distributions_all pod,
      po_releases_all por,
      financials_system_params_all pfsp,
      financials_system_params_all rfsp,
      gl_sets_of_books pgl,
      gl_sets_of_books rgl
      WHERE
             rhr.authorization_status = 'APPROVED'
      and    rln.source_type_code = 'VENDOR'
      and    rln.requisition_header_id = rhr.requisition_header_id
      and    rln.creation_date >= d_glob_date
      and    nvl(rln.modified_by_agent_flag,'N') <> 'Y'
      and    nvl(rln.cancel_flag,'N')='N'
      and    nvl(rhr.contractor_status,'NOT_APPLICABLE') <> 'PENDING'
      and    nvl(rln.closed_code,'-999') <> 'FINALLY CLOSED'
      and    rln.org_id = rfsp.org_id
      and    rfsp.set_of_books_id = rgl.set_of_books_id
      and    rdn.requisition_line_id = rln.requisition_line_id
      and    rdn.distribution_id = pod.req_distribution_id (+)
      and    pod.line_location_id = pll.line_location_id (+)
      and    nvl(pll.shipment_type,'-99') <> 'PREPAYMENT'
      and    pll.po_release_id = por.po_release_id (+)
      and    pll.po_line_id = pol.po_line_id (+)
      and    pol.po_header_id = poh.po_header_id (+)
      and    pll.org_id = pfsp.org_id (+)
      and    pfsp.set_of_books_id = pgl.set_of_books_id (+)
      and    (rhr.last_update_date between d_start_date and d_end_date or
              rln.last_update_date between d_start_date and d_end_date or
              pll.last_update_date between d_start_date and d_end_date or
              poh.last_update_date between d_start_date and d_end_date or
              pol.last_update_date between d_start_date and d_end_date or
              por.last_update_date between d_start_date and d_end_date )
      group by
      rln.requisition_line_id,
      pll.line_location_id,
      rln.currency_code,
      rgl.currency_code,
      poh.currency_code,
      pgl.currency_code,
      trunc(rln.rate_date),
      trunc(rln.creation_date),
      trunc(poh.rate_date),
      trunc(pll.creation_date)
    );

    /* Have to do a commit here as check for corrupt rows need to be done.
    */

    commit;

    /* After collection of poa_dbi_req_inc, run a check for corrupt data.
    ** If corrupt data is found, print details in request output and
    ** set the request to complete with warning.
    */


    open corrupt_rows;
    fetch corrupt_rows bulk collect into corrupt_rec_table;
    close corrupt_rows;
    for i in 1..corrupt_rec_table.count loop
      l_num_corrupt_rows := l_num_corrupt_rows + 1;
      if (l_num_corrupt_rows = 1) then
        fnd_file.put_line(fnd_file.output,'Corrupt Data Report');
        fnd_file.put_line(fnd_file.output,'===================');
        fnd_file.put_line(fnd_file.output,'Operating Unit                 Requisition Line');
        fnd_file.put_line(fnd_file.output,'------------------------------ ----------- -----');
      end if;
      fnd_file.put_line(fnd_file.output,corrupt_rec_table(i).name||' '||corrupt_rec_table(i).segment1||' '||corrupt_rec_table(i).line_num);
    end loop;
    if (l_num_corrupt_rows > 0) then
      bis_collection_utilities.log('-------------------------------------------------------------------------------------', 0);
      bis_collection_utilities.log('This request has encountered corrupt data in PO tables.', 0);
      bis_collection_utilities.log('There are one or more requisition distributions which are referred to by', 0);
      bis_collection_utilities.log('multiple non-complex-work purchase order distributions. Please see the output of', 0);
      bis_collection_utilities.log('this request for the list of such requisition lines.', 0);
      bis_collection_utilities.log('   ', 0);
      bis_collection_utilities.log('These requisition lines have not been collected into the fact and consequently', 0);
      bis_collection_utilities.log('are not displayed in DBI reports', 0);
      bis_collection_utilities.log('   ', 0);
      bis_collection_utilities.log('If you need to collect and report on these records in DBI please fix this bad data',0);
      bis_collection_utilities.log('and re-run the DBI initial load request set. If you do not need this data collected',0);
      bis_collection_utilities.log('and reported in DBI you can ignore this warning. If you need help fixing this data',0);
      bis_collection_utilities.log('please contact Oracle Support.',0);
      bis_collection_utilities.log('-------------------------------------------------------------------------------------', 0);

      for i in 1..corrupt_rec_table.count loop
        delete from poa_dbi_req_inc where primary_key = corrupt_rec_table(i).requisition_line_id;
      end loop;
      commit;
      l_ret_variable := fnd_concurrent.set_interim_status(
        status => 'WARNING',
        message => 'Bad data found in PO tables.'
      );
    end if;
  ELSE -- not initial load
    INSERT /*+ APPEND */ INTO poa_dbi_req_inc
    (
      primary_key,
      line_location_id,
      batch_id,
      txn_cur_code,
      func_cur_code,
      rate_date
    )
    select primary_key,
    line_location_id,
    batch_id,
    txn_cur_code,
    func_cur_code,
    rate_date
    from
    (
      (
        (
          SELECT  /*+ cardinality(rhr, 1)*/
          rln.requisition_line_id primary_key,
          pll.line_location_id,
          ceil(rownum/l_batch_size) batch_id,
          decode(pll.line_location_id, null, nvl(rln.currency_code, rgl.currency_code),poh.currency_code) txn_cur_code,
          decode(pll.line_location_id, null, rgl.currency_code, pgl.currency_code) func_cur_code,
          decode(pll.line_location_id, null, nvl(trunc(rln.rate_date),trunc(rln.creation_date)), nvl(trunc(poh.rate_date), trunc(pll.creation_date))) rate_date
          FROM
          po_requisition_headers_all rhr,
          po_requisition_lines_all rln,
          po_headers_all poh,
          po_line_locations_all pll,
          financials_system_params_all pfsp,
          financials_system_params_all rfsp,
          gl_sets_of_books pgl,
          gl_sets_of_books rgl,
          po_req_distributions_all rdn,
          po_distributions_all pod
          WHERE  rhr.authorization_status in ('APPROVED','CANCELLED','REJECTED','RETURNED')
          and    rln.source_type_code = 'VENDOR'
          and    rln.requisition_header_id = rhr.requisition_header_id
          and    nvl(rhr.contractor_status,'NOT_APPLICABLE') <> 'PENDING'
          and    pll.po_header_id = poh.po_header_id (+)
          and    rln.org_id = rfsp.org_id
          and    rfsp.set_of_books_id = rgl.set_of_books_id
          and    pll.org_id = pfsp.org_id (+)
          and    pfsp.set_of_books_id = pgl.set_of_books_id (+)
          and    rln.creation_date >= d_glob_date
          and    rdn.requisition_line_id = rln.requisition_line_id
          and    rdn.distribution_id = pod.req_distribution_id(+)
          and    pod.line_location_id = pll.line_location_id(+)
          and    nvl(pll.shipment_type,'-99') <> 'PREPAYMENT'
          and    rhr.last_update_date between d_start_date and d_end_date
        )
        UNION
        (
          SELECT  /*+ cardinality(rln, 1)*/
          rln.requisition_line_id primary_key,
          pll.line_location_id,
          ceil(rownum/l_batch_size) batch_id,
          decode(pll.line_location_id, null, nvl(rln.currency_code, rgl.currency_code),poh.currency_code) txn_cur_code,
          decode(pll.line_location_id, null, rgl.currency_code, pgl.currency_code) func_cur_code,
          decode(pll.line_location_id, null, nvl(trunc(rln.rate_date),trunc(rln.creation_date)), nvl(trunc(poh.rate_date), trunc(pll.creation_date))) rate_date
          FROM
          po_requisition_headers_all rhr,
          po_requisition_lines_all rln,
          po_headers_all poh,
          po_line_locations_all pll,
          financials_system_params_all pfsp,
          financials_system_params_all rfsp,
          gl_sets_of_books pgl,
          gl_sets_of_books rgl,
          po_req_distributions_all rdn,
          po_distributions_all pod
          WHERE  rhr.authorization_status in ('APPROVED','CANCELLED','REJECTED','RETURNED')
          and    rln.source_type_code = 'VENDOR'
          and    rln.requisition_header_id = rhr.requisition_header_id
          and    nvl(rhr.contractor_status,'NOT_APPLICABLE') <> 'PENDING'
          and    pll.po_header_id = poh.po_header_id (+)
          and    rln.org_id = rfsp.org_id
          and    rfsp.set_of_books_id = rgl.set_of_books_id
          and    pll.org_id = pfsp.org_id (+)
          and    pfsp.set_of_books_id = pgl.set_of_books_id (+)
          and    rln.creation_date >= d_glob_date
          and    rdn.requisition_line_id = rln.requisition_line_id
          and    rdn.distribution_id = pod.req_distribution_id(+)
          and    pod.line_location_id = pll.line_location_id(+)
          and    nvl(pll.shipment_type,'-99') <> 'PREPAYMENT'
          and    rln.last_update_date between d_start_date and d_end_date
        )
        UNION
        (
          SELECT  /*+ cardinality(pll, 1)*/
          rln.requisition_line_id primary_key,
          pll.line_location_id,
          ceil(rownum/l_batch_size) batch_id,
          decode(pll.line_location_id, null, nvl(rln.currency_code, rgl.currency_code),poh.currency_code) txn_cur_code,
          decode(pll.line_location_id, null, rgl.currency_code, pgl.currency_code) func_cur_code,
          decode(pll.line_location_id, null, nvl(trunc(rln.rate_date),trunc(rln.creation_date)), nvl(trunc(poh.rate_date), trunc(pll.creation_date))) rate_date
          FROM
          po_requisition_headers_all rhr,
          po_requisition_lines_all rln,
          po_headers_all poh,
          po_line_locations_all pll,
          financials_system_params_all pfsp,
          financials_system_params_all rfsp,
          gl_sets_of_books pgl,
          gl_sets_of_books rgl,
          po_req_distributions_all rdn,
          po_distributions_all pod
          WHERE  rhr.authorization_status in ('APPROVED','CANCELLED','REJECTED','RETURNED')
          and    rln.source_type_code = 'VENDOR'
          and    rln.requisition_header_id = rhr.requisition_header_id
          and    nvl(rhr.contractor_status,'NOT_APPLICABLE') <> 'PENDING'
          and    pll.po_header_id = poh.po_header_id
          and    rln.org_id = rfsp.org_id
          and    rfsp.set_of_books_id = rgl.set_of_books_id
          and    pll.org_id = pfsp.org_id
          and    pfsp.set_of_books_id = pgl.set_of_books_id
          and    rln.creation_date >= d_glob_date
          and    rdn.requisition_line_id = rln.requisition_line_id
          and    rdn.distribution_id = pod.req_distribution_id
          and    pod.line_location_id = pll.line_location_id
          and    nvl(pll.shipment_type,'-99') <> 'PREPAYMENT'
          and    pll.last_update_date between d_start_date and d_end_date
        )
        UNION
        (
          SELECT  /*+ cardinality(poh, 1)*/
          rln.requisition_line_id primary_key,
          pll.line_location_id,
          ceil(rownum/l_batch_size) batch_id,
          decode(pll.line_location_id, null, nvl(rln.currency_code, rgl.currency_code),poh.currency_code) txn_cur_code,
          decode(pll.line_location_id, null, rgl.currency_code, pgl.currency_code) func_cur_code,
          decode(pll.line_location_id, null, nvl(trunc(rln.rate_date),trunc(rln.creation_date)), nvl(trunc(poh.rate_date), trunc(pll.creation_date))) rate_date
          FROM
          po_requisition_headers_all rhr,
          po_requisition_lines_all rln,
          po_headers_all poh,
          po_line_locations_all pll,
          financials_system_params_all pfsp,
          financials_system_params_all rfsp,
          gl_sets_of_books pgl,
          gl_sets_of_books rgl,
          po_req_distributions_all rdn,
          po_distributions_all pod
          WHERE  rhr.authorization_status in ('APPROVED','CANCELLED','REJECTED','RETURNED')
          and    rln.source_type_code = 'VENDOR'
          and    rln.requisition_header_id = rhr.requisition_header_id
          and    nvl(rhr.contractor_status,'NOT_APPLICABLE') <> 'PENDING'
          and    pll.po_header_id = poh.po_header_id
          and    rln.org_id = rfsp.org_id
          and    rfsp.set_of_books_id = rgl.set_of_books_id
          and    pll.org_id = pfsp.org_id
          and    pfsp.set_of_books_id = pgl.set_of_books_id
          and    rln.creation_date >= d_glob_date
          and    rdn.requisition_line_id = rln.requisition_line_id
          and    rdn.distribution_id = pod.req_distribution_id
          and    pod.line_location_id = pll.line_location_id
          and    nvl(pll.shipment_type,'-99') <> 'PREPAYMENT'
          and    poh.last_update_date between d_start_date and d_end_date
        )
        UNION
        (
          SELECT  /*+ cardinality(pol, 1)*/
          rln.requisition_line_id primary_key,
          pll.line_location_id,
          ceil(rownum/l_batch_size) batch_id,
          decode(pll.line_location_id, null, nvl(rln.currency_code, rgl.currency_code),poh.currency_code) txn_cur_code,
          decode(pll.line_location_id, null, rgl.currency_code, pgl.currency_code) func_cur_code,
          decode(pll.line_location_id, null, nvl(trunc(rln.rate_date),trunc(rln.creation_date)), nvl(trunc(poh.rate_date), trunc(pll.creation_date))) rate_date
          FROM
          po_requisition_headers_all rhr,
          po_requisition_lines_all rln,
          po_headers_all poh,
          po_lines_all pol,
          po_line_locations_all pll,
          financials_system_params_all pfsp,
          financials_system_params_all rfsp,
          gl_sets_of_books pgl,
          gl_sets_of_books rgl,
          po_req_distributions_all rdn,
          po_distributions_all pod
          WHERE  rhr.authorization_status in ('APPROVED','CANCELLED','REJECTED','RETURNED')
          and    rln.source_type_code = 'VENDOR'
          and    rln.requisition_header_id = rhr.requisition_header_id
          and    nvl(rhr.contractor_status,'NOT_APPLICABLE') <> 'PENDING'
          and    pll.po_line_id = pol.po_line_id
          and    pll.po_header_id = poh.po_header_id
          and    rln.org_id = rfsp.org_id
          and    rfsp.set_of_books_id = rgl.set_of_books_id
          and    pll.org_id = pfsp.org_id
          and    pfsp.set_of_books_id = pgl.set_of_books_id
          and    rln.creation_date >= d_glob_date
          and    rdn.requisition_line_id = rln.requisition_line_id
          and    rdn.distribution_id = pod.req_distribution_id
          and    pod.line_location_id = pll.line_location_id
          and    nvl(pll.shipment_type,'-99') <> 'PREPAYMENT'
          and    pol.last_update_date between d_start_date and d_end_date
        )
        UNION
        (
          SELECT  /*+ cardinality(por, 1)*/
          rln.requisition_line_id primary_key,
          pll.line_location_id,
          ceil(rownum/l_batch_size) batch_id,
          decode(pll.line_location_id, null, nvl(rln.currency_code, rgl.currency_code),poh.currency_code) txn_cur_code,
          decode(pll.line_location_id, null, rgl.currency_code, pgl.currency_code) func_cur_code,
          decode(pll.line_location_id, null, nvl(trunc(rln.rate_date),trunc(rln.creation_date)), nvl(trunc(poh.rate_date), trunc(pll.creation_date))) rate_date
          FROM
          po_requisition_headers_all rhr,
          po_requisition_lines_all rln,
          po_headers_all poh,
          po_line_locations_all pll,
          po_releases_all por,
          financials_system_params_all pfsp,
          financials_system_params_all rfsp,
          gl_sets_of_books pgl,
          gl_sets_of_books rgl,
          po_req_distributions_all rdn,
          po_distributions_all pod
          WHERE  rhr.authorization_status in ('APPROVED','CANCELLED','REJECTED','RETURNED')
          and    rln.source_type_code = 'VENDOR'
          and    rln.requisition_header_id = rhr.requisition_header_id
          and    nvl(rhr.contractor_status,'NOT_APPLICABLE') <> 'PENDING'
          and    pll.po_release_id = por.po_release_id
          and    pll.po_header_id = poh.po_header_id
          and    rln.org_id = rfsp.org_id
          and    rfsp.set_of_books_id = rgl.set_of_books_id
          and    pll.org_id = pfsp.org_id
          and    pfsp.set_of_books_id = pgl.set_of_books_id
          and    rln.creation_date >= d_glob_date
          and    rdn.requisition_line_id = rln.requisition_line_id
          and    rdn.distribution_id = pod.req_distribution_id
          and    pod.line_location_id = pll.line_location_id
          and    nvl(pll.shipment_type,'-99') <> 'PREPAYMENT'
          and    por.last_update_date between d_start_date and d_end_date
        )
      )
      UNION ALL
      (
        (
          SELECT  /*+ cardinality(rhr, 1)*/
          rln.requisition_line_id primary_key,
          null line_location_id,
          ceil(rownum/l_batch_size) batch_id,
          nvl(rln.currency_code,rgl.currency_code) txn_cur_code,
          rgl.currency_code func_cur_code ,
          nvl(trunc(rln.rate_date),trunc(rln.creation_date)) rate_date
          FROM po_requisition_headers_all rhr,
          po_requisition_lines_all rln,
          financials_system_params_all rfsp,
          gl_sets_of_books rgl
          WHERE rhr.authorization_status='INCOMPLETE'
          and    rln.source_type_code = 'VENDOR'
          and rln.requisition_header_id = rhr.requisition_header_id
          and rhr.approved_date is not null
          and nvl(rhr.contractor_status,'NOT_APPLICABLE')<>'PENDING'
          and rln.org_id = rfsp.org_id
          and rfsp.set_of_books_id = rgl.set_of_books_id
          and rln.creation_date >= d_glob_date
          and rhr.last_update_date between d_start_date and d_end_date
        )
        UNION
        (
          SELECT  /*+ cardinality(rln, 1)*/
          rln.requisition_line_id primary_key,
          null line_location_id,
          ceil(rownum/l_batch_size) batch_id,
          nvl(rln.currency_code,rgl.currency_code) txn_cur_code,
          rgl.currency_code func_cur_code,
          nvl(trunc(rln.rate_date),trunc(rln.creation_date)) rate_date
          FROM po_requisition_headers_all rhr,
          po_requisition_lines_all rln,
          financials_system_params_all rfsp,
          gl_sets_of_books rgl
          WHERE rhr.authorization_status='INCOMPLETE'
          and    rln.source_type_code = 'VENDOR'
          and rln.requisition_header_id = rhr.requisition_header_id
          and rhr.approved_date is not null
          and nvl(rhr.contractor_status,'NOT_APPLICABLE')<>'PENDING'
          and rln.org_id = rfsp.org_id
          and rfsp.set_of_books_id = rgl.set_of_books_id
          and rln.creation_date >= d_glob_date
          and rln.last_update_date between d_start_date and d_end_date
        )
      )
    )
    group by
    primary_key,
    line_location_id,
    batch_id,
    txn_cur_code,
    func_cur_code,
    rate_date;
  END IF;

  COMMIT;
  dbms_application_info.set_action('stats incremental');

  IF (fnd_installation.get_app_info('POA', l_status, l_industry, l_poa_schema))  THEN
    fnd_stats.gather_table_stats(ownname => l_poa_schema, tabname => 'POA_DBI_REQ_INC') ;
  END IF;

  INSERT /*+ APPEND */ INTO poa_dbi_req_rates
  (
    txn_cur_code,
    func_cur_code,
    rate_date,
    global_cur_conv_rate,
    sglobal_cur_conv_rate
  )
  SELECT
  txn_cur_code,
  func_cur_code,
  rate_date,
  poa_currency_pkg.get_dbi_global_rate(
    l_rate_type,
    func_cur_code,
    rate_date,
    txn_cur_code
  ) global_cur_conv_rate,
  ( case when l_sec_cur_yn = 0 then null
    else
      poa_currency_pkg.get_dbi_sglobal_rate (
        l_srate_type,
        func_cur_code,
        rate_date,
        txn_cur_code
      )
    end
  ) sglobal_cur_conv_rate
  FROM
  (
    select distinct
    txn_cur_code,
    func_cur_code,
    rate_date
    from
    poa_dbi_req_inc
    order by func_cur_code, rate_date
  );


  COMMIT;
  dbms_application_info.set_action('stats rates');

  IF (fnd_installation.get_app_info('POA', l_status, l_industry, l_poa_schema)) THEN
     fnd_stats.gather_table_stats(ownname => l_poa_schema,
              tabname => 'POA_DBI_REQ_RATES') ;
  END IF;

  bis_collection_utilities.log('Populate base table: '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
  select max(batch_id), COUNT(1) into l_no_batch, l_count from poa_dbi_req_inc;
  bis_collection_utilities.log('Identified '|| l_count ||' changed records. Batch size='|| l_batch_size || '. # of Batches=' || l_no_batch
				|| '. Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);


  /* missing currency handling */

  IF (poa_currency_pkg.g_missing_cur) THEN
    poa_currency_pkg.g_missing_cur := false;
    errbuf := 'There are missing currencies\n';
    raise_application_error (-20000, 'Error in INC table collection: ' || errbuf);
  END IF;

  l_start_time := sysdate; -- should be the end date of the collection??
  l_login := fnd_global.login_id;
  l_user := fnd_global.user_id;
  dbms_application_info.set_action('collect');
 if (l_no_batch is NOT NULL) then
  IF (g_init) THEN
    bis_collection_utilities.log('Initial Load - using one batch approach, populate base fact. '|| 'Sysdate=' ||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
    INSERT /*+ append parallel(t) */ INTO poa_dbi_req_f t (
      t.req_line_id ,
      t.req_header_id ,
      t.po_line_location_id ,
      t.req_creation_ou_id,
      t.req_creation_date ,
      t.req_approved_date ,
      t.po_creation_ou_id,
      t.po_creation_date ,
      t.po_submit_date ,
      t.po_approved_date,
      t.req_fulfilled_date,
      t.expected_date,
      t.supplier_id ,
      t.supplier_site_id,
      t.category_id,
      t.po_item_id,
      t.buyer_id,
      t.org_id,
      t.ship_to_org_id,
      t.requester_id,
      t.line_type_id,
      t.preparer_id,
      t.unit_price,
      t.line_quantity,
      t.line_amount_t,
      t.line_amount_b,
      t.line_amount_g,
      t.line_amount_sg,
      t.emergency_flag,
      t.urgent_flag,
      t.sourcing_flag,
      t.include_in_ufr,
      t.unproc_ped_flag,
      t.po_revisions,
      t.po_creation_method,
      t.func_cur_code,
      t.func_cur_conv_rate,
      t.global_cur_conv_rate,
      t.sglobal_cur_conv_rate,
      t.base_uom,
      t.transaction_uom,
      t.base_uom_conv_rate,
      t.created_by,
      t.last_update_login,
      t.creation_date,
      t.last_updated_by,
      t.last_update_date
    )
    SELECT
    req_line_id,
    req_header_id,
    min(po_line_location_id) po_line_location_id,
    req_creation_ou_id,
    req_creation_date,
    req_approved_date,
    po_creation_ou_id,
    min(po_creation_date),
    max(po_submit_date),
    decode(min(po_approved_flag),'Y',max(po_approved_date),to_date(null)) po_approved_date,
    max(req_fulfilled_date),
    min(expected_date),
    supplier_id,
    supplier_site_id,
    category_id,
    po_item_id,
    buyer_id,
    org_id,
    ship_to_org_id,
    requester_id,
    line_type_id,
    preparer_id,
    sum(unit_price),
    sum(line_quantity),
    sum(line_amount_t),
    sum(line_amount_b),
    sum(line_amount_g),
    sum(line_amount_sg),
    emergency_flag,
    urgent_flag,
    sourcing_flag,
    include_in_ufr,
    max(unproc_ped_flag),
    po_revisions,
    po_creation_method,
    func_cur_code,
    func_cur_conv_rate,
    global_cur_conv_rate,
    sglobal_cur_conv_rate,
    base_uom,
    transaction_uom,
    base_uom_conv_rate,
    l_user,
    l_login,
    l_start_time,
    l_user,
    l_start_time
    FROM
    ( SELECT
      s.req_line_id ,
      s.req_header_id ,
      s.po_line_location_id,
      s.req_creation_ou_id,
      s.req_creation_date,
      s.req_approved_date,
      s.po_creation_ou_id,
      s.po_creation_date,
      s.po_submit_date,
      s.po_approved_date,
      s.po_approved_flag,
      decode(s.matching_basis, 'AMOUNT', to_date(null), s.req_fulfilled_date) req_fulfilled_date,
      decode(s.matching_basis, 'AMOUNT', to_date(null), nvl(s.po_promised_date, nvl(s.po_need_by_date, s.req_need_by_date))) expected_date,
      nvl(s.supplier_id,-1) supplier_id,
      nvl(s.supplier_site_id,-1) supplier_site_id,
      s.category_id,
      s.po_item_id,
      nvl(s.buyer_id,-1) buyer_id,
      nvl(s.po_creation_ou_id,req_creation_ou_id) org_id,
      s.ship_to_org_id,
      s.requester_id,
      s.line_type_id,
      s.preparer_id,
      (s.unit_price / s.base_uom_conv_rate) unit_price,
      decode(s.order_type_lookup_code,'QUANTITY', s.line_quantity * s.base_uom_conv_rate, to_number(null)) line_quantity,
      decode(s.matching_basis, 'AMOUNT', s.line_amount_t, s.unit_price * s.line_quantity) line_amount_t,
      decode(s.matching_basis, 'AMOUNT', s.line_amount_t * s.func_cur_conv_rate, s.unit_price * s.line_quantity * s.func_cur_conv_rate) line_amount_b,
      decode(
        s.matching_basis, 'AMOUNT',
        decode(s.global_cur_conv_rate, 0, s.line_amount_t, s.line_amount_t * s.func_cur_conv_rate * s.global_cur_conv_rate),
        decode(s.global_cur_conv_rate, 0, s.unit_price * s.line_quantity, s.unit_price * s.line_quantity * s.func_cur_conv_rate * s.global_cur_conv_rate)
      ) line_amount_g,
      decode(
        s.matching_basis, 'AMOUNT',
        decode(s.sglobal_cur_conv_rate, 0, s.line_amount_t, s.line_amount_t * s.func_cur_conv_rate * s.sglobal_cur_conv_rate),
        decode(s.sglobal_cur_conv_rate, 0, s.unit_price * s.line_quantity, s.unit_price * s.line_quantity * s.func_cur_conv_rate * s.sglobal_cur_conv_rate)
      ) line_amount_sg,
      s.emergency_flag,
      s.urgent_flag,
      s.sourcing_flag,
      s.include_in_ufr,
      s.po_revisions,
      s.po_creation_method,
      s.func_cur_code,
      s.func_cur_conv_rate,
      s.global_cur_conv_rate,
      s.sglobal_cur_conv_rate,
      decode(s.order_type_lookup_code,'QUANTITY', s.base_uom, null) base_uom,
      s.transaction_uom,
      s.base_uom_conv_rate,
      ( case when (s.po_approved_date is null and
              decode(s.matching_basis, 'AMOUNT', to_date(null),
              nvl(s.po_promised_date, nvl(s.po_need_by_date,
             s.req_need_by_date))) < l_start_time) then 'Y'
        else 'N' end
      ) unproc_ped_flag
      FROM
      ( SELECT  /*+ PARALLEL(inc) PARALLEL(rln) PARALLEL(rhr) PARALLEL(poh)
PARALLEL(pol) PARALLEL(pll) PARALLEL(por) PARALLEL(pitem) PARALLEL(ritem)
PARALLEL(pod) PARALLEL(rdn) PARALLEL(rat) PARALLEL(pfsp) PARALLEL(rfsp)
PARALLEL(pgl) PARALLEL(rgl)  USE_HASH(inc) USE_HASH(rln) USE_HASH(rhr)
USE_HASH(poh) USE_HASH(pol) USE_HASH(pll) USE_HASH(por) USE_HASH(pitem)
USE_HASH(ritem) USE_HASH(pod) USE_HASH(rdn) USE_HASH(rat) USE_HASH(pfsp)
USE_HASH(fsp) USE_HASH(pgl) USE_HASH(rgl)*/
        rln.requisition_line_id req_line_id,
        rhr.requisition_header_id req_header_id,
        pll.line_location_id po_line_location_id,
        rhr.org_id req_creation_ou_id,
        rln.creation_date req_creation_date,
        nvl(rhr.approved_date,rhr.creation_date) req_approved_date,
        rln.need_by_date req_need_by_date,
        decode(pll.po_release_id,null,poh.org_id,por.org_id) po_creation_ou_id,
        pll.creation_date po_creation_date,
        decode(pll.po_release_id,null,poh.submit_date,por.submit_date) po_submit_date,
        decode(pll.approved_flag, 'Y', pll.approved_date, null) po_approved_date,
	nvl(pll.approved_flag,'N') po_approved_flag,
        ( case
             when nvl(pll.consigned_flag,'N')='Y' or nvl(pll.vmi_flag,'N')='Y' then null
             when nvl(style.progress_payment_flag,'N') = 'Y' then null
             when nvl(pll.approved_flag,'N')='Y' then
                 case when nvl(pll.receipt_required_flag, 'N') = 'N'
                    and nvl(pll.inspection_required_flag, 'N') = 'N'
                then least(nvl(pll.shipment_closed_date,pll.closed_for_invoice_date), pll.closed_for_invoice_date)
                else least(nvl(pll.shipment_closed_date,pll.closed_for_receiving_date),pll.closed_for_receiving_date)
                end
             else
             null
          end
        ) req_fulfilled_date,
        pll.need_by_date po_need_by_date,
        pll.promised_date po_promised_date,
        nvl(poh.vendor_id, rln.vendor_id) supplier_id,
        nvl(poh.vendor_site_id, rln.vendor_site_id) supplier_site_id,
        nvl(pol.category_id, rln.category_id) category_id,
        decode(
          pll.line_location_id, null,
          poa_dbi_items_pkg.getitemkey(rln.item_id, rpar.master_organization_id, rln.category_id, rln.suggested_vendor_product_code, rln.vendor_id, rln.item_description),
          poa_dbi_items_pkg.getitemkey(pol.item_id, ppar.master_organization_id, pol.category_id, pol.vendor_product_num, poh.vendor_id, pol.item_description)
        ) po_item_id,
        nvl(decode(pll.po_release_id,null,poh.agent_id,por.agent_id),rln.suggested_buyer_id) buyer_id,
        nvl(pll.ship_to_organization_id, rln.destination_organization_id) ship_to_org_id,
        rln.to_person_id requester_id, --get the requester from the requisition itself since it can be changed on the PO distn
        rln.line_type_id,
        rhr.preparer_id,
        nvl(pll.price_override, nvl(rln.currency_unit_price,rln.unit_price)) unit_price, -- in transactional currency
        sum( case when pll.line_location_id is null then rdn.req_line_quantity
               when pll.line_location_id is not null then
                 decode(pll.matching_basis,'QUANTITY',pod.quantity_ordered - nvl(pod.quantity_cancelled,0),0)
               else null
             end
        ) line_quantity,
        sum( case when pll.line_location_id is null then nvl(rdn.req_line_currency_amount,rdn.req_line_amount)
               when pll.line_location_id is not null
               then decode(pll.matching_basis,'AMOUNT',pod.amount_ordered - nvl(pod.amount_cancelled,0),0) -- Confirm if this amount is in transactional currency
               else null
           end
        ) line_amount_t,
        decode(rhr.emergency_po_num, null, 'N', 'Y') emergency_flag,
        rln.urgent_flag,
        ( case when nvl(rln.line_location_id,-999)=-999
                    and nvl(rln.cancel_flag,'N')='N'
                    and nvl(rhr.authorization_status,'-999')='APPROVED'
                    and (rln.at_sourcing_flag='Y' or
                         (rln.reqs_in_pool_flag='Y'
                          and nvl(rln.on_rfq_flag,'N')='Y'
                          and nvl(rln.auction_header_id,-999)=-999))
               then 'Y'
               when nvl(rln.line_location_id,-999)=-999
                    and nvl(rln.cancel_flag,'N')='N'
                    and nvl(rhr.authorization_status,'-999')='APPROVED'
                    and rln.reqs_in_pool_flag='Y'
               then 'N'
               else ''
          end
        ) sourcing_flag,
        ( case when decode(pll.line_location_id,null,rln.matching_basis,pll.matching_basis)='AMOUNT' then 'N'
               when (nvl(style.progress_payment_flag,'N') = 'Y') then 'N'
               when nvl(pll.consigned_flag,'N')='Y' or nvl(pll.vmi_flag,'N')='Y' then 'N'
               else 'Y'
           end
        ) include_in_ufr,
        decode(pll.line_location_id,null,rln.matching_basis,pll.matching_basis) matching_basis,
        decode(pll.line_location_id,null,rln.order_type_lookup_code,pll.value_basis) order_type_lookup_code,
        decode(pll.po_release_id,null,poh.revision_num,por.revision_num) po_revisions,
        ( case when decode(pll.po_release_id,null,poh.document_creation_method,por.document_creation_method) in ('ENTER_PO', 'ENTER_RELEASE', 'COPY_DOCUMENT', 'AUTOCREATE')
        then 'M' else 'A' end) po_creation_method,
        rat.func_cur_code func_cur_code,
        decode(pll.line_location_id,null,nvl(rln.rate,1),nvl(poh.rate,1)) func_cur_conv_rate,
        rat.global_cur_conv_rate,
        rat.sglobal_cur_conv_rate,
        decode(
          pll.line_location_id, null,
          decode(rln.item_id, null, rln.unit_meas_lookup_code, ritem.primary_unit_of_measure),
          decode(pol.item_id, null, pol.unit_meas_lookup_code, pitem.primary_unit_of_measure)
        ) base_uom,
        decode(
          pll.line_location_id, null,
          rln.unit_meas_lookup_code,
          pol.unit_meas_lookup_code
        ) transaction_uom,
        decode(
          pll.line_location_id,
          null, decode(
                  rln.item_id,
                  null, 1,
                  decode(rln.unit_meas_lookup_code,
                    ritem.primary_unit_of_measure, 1,
                    poa_dbi_uom_pkg.convert_to_item_base_uom(
                      rln.item_id,
                      rpar.master_organization_id,
                      rln.unit_meas_lookup_code,
                      ritem.primary_uom_code
                    )
                  )
                ),
          decode(
            pol.item_id,
            null, 1,
            decode(
              pol.unit_meas_lookup_code,
              pitem.primary_unit_of_measure, 1,
              poa_dbi_uom_pkg.convert_to_item_base_uom(
                pol.item_id,
                ppar.master_organization_id,
                pol.unit_meas_lookup_code,
                pitem.primary_uom_code
              )
            )
          )
        ) base_uom_conv_rate
        FROM
        poa_dbi_req_inc              inc,
        poa_dbi_req_rates            rat,
        po_requisition_lines_all     rln,
        po_req_distributions_all     rdn,
        po_headers_all               poh,
        po_lines_all                 pol,
        po_releases_all              por,
        financials_system_params_all pfsp,
        mtl_parameters               ppar,
        mtl_system_items             pitem,
        financials_system_params_all rfsp,
        mtl_parameters               rpar,
        mtl_system_items             ritem,
        gl_sets_of_books             pgl,
        gl_sets_of_books             rgl,
        po_requisition_headers_all   rhr,
        po_line_locations_all        pll,
        po_distributions_all         pod,
        po_doc_style_headers         style
        WHERE
              inc.primary_key = rln.requisition_line_id
        and   (inc.line_location_id is null or inc.line_location_id = pll.line_location_id)
        and   rln.requisition_header_id = rhr.requisition_header_id
        and   rln.requisition_line_id = rdn.requisition_line_id
        and   nvl(rln.cancel_flag,'N')='N'
        and   rdn.distribution_id = pod.req_distribution_id (+)
        and   pll.po_line_id = pol.po_line_id (+)
        and   pll.po_release_id = por.po_release_id (+)
        and   pol.po_header_id = poh.po_header_id (+)
        and   pod.line_location_id = pll.line_location_id(+)
        and   poh.style_id = style.style_id(+)
        and   poh.org_id = pfsp.org_id (+)
        and   pfsp.set_of_books_id = pgl.set_of_books_id (+)
        and   pfsp.inventory_organization_id = ppar.organization_id (+)
        and   rhr.org_id = rfsp.org_id
        and   rfsp.inventory_organization_id = rpar.organization_id
        and   rfsp.set_of_books_id = rgl.set_of_books_id
        and   rln.item_id = ritem.inventory_item_id (+)
        and   rpar.master_organization_id = nvl(ritem.organization_id, rpar.master_organization_id)
        and   pol.item_id = pitem.inventory_item_id (+)
        and   inc.txn_cur_code = rat.txn_cur_code
        and   inc.func_cur_code = rat.func_cur_code
        and   inc.rate_date = rat.rate_date
        and   nvl(ppar.master_organization_id, -999) = nvl(pitem.organization_id, nvl(ppar.master_organization_id, -999))
        and   rhr.authorization_status = 'APPROVED'
        and   rln.source_type_code = 'VENDOR'
        and   nvl(rln.modified_by_agent_flag,'N') <> 'Y'
        and   nvl(rhr.contractor_status,'NOT_APPLICABLE') <> 'PENDING'
        and   rln.creation_date > d_glob_date
        group by
        pitem.primary_unit_of_measure,
        pitem.primary_uom_code,
        pll.amount,
        pll.amount_cancelled,
        pll.approved_date,
        pll.approved_flag,
        pll.closed_for_invoice_date,
        pll.closed_for_receiving_date,
        pll.consigned_flag,
        pll.creation_date,
        pll.inspection_required_flag,
        pll.line_location_id,
        pll.matching_basis,
        pll.need_by_date,
        pll.payment_type,
        pll.po_release_id,
        pll.price_override,
        pll.promised_date,
        pll.receipt_required_flag,
        pll.ship_to_organization_id,
        pll.shipment_closed_date,
        pll.value_basis,
        pll.vmi_flag,
        poh.agent_id,
        poh.document_creation_method,
        poh.org_id,
        poh.rate,
        poh.revision_num,
        poh.submit_date,
        poh.vendor_id,
        poh.vendor_site_id,
        pol.category_id,
        pol.item_description,
        pol.item_id,
        pol.matching_basis,
        pol.order_type_lookup_code,
        pol.unit_meas_lookup_code,
        pol.vendor_product_num,
        por.agent_id,
        por.document_creation_method,
        por.org_id,
        por.revision_num,
        por.submit_date,
        ppar.master_organization_id,
        rat.func_cur_code,
        rat.global_cur_conv_rate,
        rat.sglobal_cur_conv_rate,
        rhr.approved_date,
        rhr.authorization_status,
        rhr.creation_date,
        rhr.emergency_po_num,
        rhr.org_id,
        rhr.preparer_id,
        rhr.requisition_header_id,
        ritem.primary_unit_of_measure,
        ritem.primary_uom_code,
        rln.at_sourcing_flag,
        rln.auction_header_id,
        rln.cancel_flag,
        rln.category_id,
        rln.creation_date,
        rln.currency_unit_price,
        rln.destination_organization_id,
        rln.item_description,
        rln.item_id,
        rln.line_location_id,
        rln.line_type_id,
        rln.matching_basis,
        rln.need_by_date,
        rln.on_rfq_flag,
        rln.order_type_lookup_code,
        rln.rate,
        rln.reqs_in_pool_flag,
        rln.requisition_line_id,
        rln.suggested_buyer_id,
        rln.suggested_vendor_product_code,
        rln.to_person_id,
        rln.unit_meas_lookup_code,
        rln.unit_price,
        rln.urgent_flag,
        rln.vendor_id,
        rln.vendor_site_id,
        rpar.master_organization_id,
        style.progress_payment_flag
      ) s
    )
    group by
    req_line_id,
    req_header_id,
    req_creation_ou_id,
    req_creation_date,
    req_approved_date,
    po_creation_ou_id,
    supplier_id,
    supplier_site_id,
    category_id,
    po_item_id,
    buyer_id,
    org_id,
    ship_to_org_id,
    requester_id,
    line_type_id,
    preparer_id,
    emergency_flag,
    urgent_flag,
    sourcing_flag,
    include_in_ufr,
    po_revisions,
    po_creation_method,
    func_cur_code,
    func_cur_conv_rate,
    global_cur_conv_rate,
    sglobal_cur_conv_rate,
    base_uom,
    transaction_uom,
    base_uom_conv_rate;

      COMMIT;

    ELSE
      -- Incremental load (process in batches)
      bis_collection_utilities.log('incremental collection');
     FOR v_batch_no IN 1..l_no_batch LOOP
      bis_collection_utilities.log('batch no='||v_batch_no || ' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 1);
      MERGE INTO poa_dbi_req_f t using
      (
        SELECT
        req_line_id,
        req_header_id,
        min(po_line_location_id) po_line_location_id,
        req_creation_ou_id,
        req_creation_date,
        req_approved_date,
        po_creation_ou_id,
        min(po_creation_date) po_creation_date,
        max(po_submit_date) po_submit_date,
        decode(min(po_approved_flag),'Y',max(po_approved_date),to_date(null)) po_approved_date,
        max(req_fulfilled_date) req_fulfilled_date,
        min(expected_date) expected_date,
        supplier_id,
        supplier_site_id,
        category_id,
        po_item_id,
        buyer_id,
        org_id,
        ship_to_org_id,
        requester_id,
        line_type_id,
        preparer_id,
        sum(unit_price) unit_price,
        sum(line_quantity) line_quantity,
        sum(line_amount_t) line_amount_t,
        sum(line_amount_b) line_amount_b,
        sum(line_amount_g) line_amount_g,
        sum(line_amount_sg) line_amount_sg,
        emergency_flag,
        urgent_flag,
        sourcing_flag,
        include_in_ufr,
        max(unproc_ped_flag) unproc_ped_flag,
        po_revisions,
        po_creation_method,
        func_cur_code,
        func_cur_conv_rate,
        global_cur_conv_rate,
        sglobal_cur_conv_rate,
        base_uom,
        transaction_uom,
        base_uom_conv_rate
        from
        ( select
          req_line_id,
          req_header_id,
          po_line_location_id,
          req_creation_ou_id,
          req_creation_date,
          req_approved_date,
          po_creation_ou_id,
          po_creation_date,
          po_submit_date,
          po_approved_date,
	  po_approved_flag,
          decode(matching_basis, 'AMOUNT', to_date(null), req_fulfilled_date) req_fulfilled_date,
          decode(matching_basis, 'AMOUNT', to_date(null), nvl(po_promised_date, nvl(po_need_by_date, req_need_by_date))) expected_date,
          nvl(supplier_id,-1) supplier_id,
          nvl(supplier_site_id,-1) supplier_site_id,
          category_id,
          po_item_id,
          nvl(buyer_id,-1) buyer_id,
          nvl(po_creation_ou_id,req_creation_ou_id) org_id,
          ship_to_org_id,
          requester_id,
          line_type_id,
          preparer_id,
          (unit_price / base_uom_conv_rate) unit_price,
          decode(order_type_lookup_code,'QUANTITY', line_quantity * base_uom_conv_rate, to_number(null)) line_quantity,
          decode(matching_basis, 'AMOUNT', line_amount_t, unit_price * line_quantity) line_amount_t,
          decode(matching_basis, 'AMOUNT', line_amount_t * func_cur_conv_rate, unit_price * line_quantity * func_cur_conv_rate) line_amount_b,
          decode(
            matching_basis, 'AMOUNT',
            decode(global_cur_conv_rate, 0, line_amount_t, line_amount_t * func_cur_conv_rate * global_cur_conv_rate),
            decode(global_cur_conv_rate, 0, unit_price * line_quantity, unit_price * line_quantity * func_cur_conv_rate * global_cur_conv_rate)
          ) line_amount_g,
          decode(
            matching_basis, 'AMOUNT',
            decode(sglobal_cur_conv_rate, 0, line_amount_t, line_amount_t * func_cur_conv_rate * sglobal_cur_conv_rate),
            decode(sglobal_cur_conv_rate, 0, unit_price * line_quantity, unit_price * line_quantity * func_cur_conv_rate * sglobal_cur_conv_rate)
          ) line_amount_sg,
          emergency_flag,
          urgent_flag,
          sourcing_flag,
          include_in_ufr,
          po_revisions,
          po_creation_method,
          func_cur_code,
          func_cur_conv_rate,
          global_cur_conv_rate,
          sglobal_cur_conv_rate,
          decode(order_type_lookup_code,'QUANTITY', base_uom, null) base_uom,
          transaction_uom,
          base_uom_conv_rate,
          ( case when (po_approved_date is null and
                  decode(matching_basis, 'AMOUNT', to_date(null),
                  nvl(po_promised_date, nvl(po_need_by_date,
                 req_need_by_date))) < l_start_time) then 'Y'
            else 'N' end
          ) unproc_ped_flag
          from
          ( SELECT /*+ cardinality(inc,1) */
            rln.requisition_line_id req_line_id,
            rhr.requisition_header_id req_header_id,
            pll.line_location_id po_line_location_id,
            rhr.org_id req_creation_ou_id,
            rln.creation_date req_creation_date,
            (case when nvl(rhr.authorization_status,'-999')='APPROVED' and nvl(rln.cancel_flag,'N')='N'
                   and nvl(rln.modified_by_agent_flag,'N')='N' and nvl(rln.closed_code,'-999') <> 'FINALLY CLOSED'
                  then nvl(rhr.approved_date,rhr.creation_date)
                 else
                  null
            end) req_approved_date,
            rln.need_by_date req_need_by_date,
            decode(pll.po_release_id,null,poh.org_id,por.org_id) po_creation_ou_id,
            pll.creation_date po_creation_date,
            decode(pll.po_release_id,null,poh.submit_date,por.submit_date) po_submit_date,
            (case when nvl(rhr.authorization_status,'-999')='APPROVED' and nvl(rln.cancel_flag,'N')='N'
                       and nvl(rln.modified_by_agent_flag,'N')='N' and nvl(rln.closed_code,'-999') <> 'FINALLY CLOSED'
                       and nvl(pll.approved_flag,'N')='Y' then pll.approved_date
                  else
                  null
            end) po_approved_date,
	    nvl(pll.approved_flag,'N') po_approved_flag,
            ( case
                    when  nvl(rhr.authorization_status,'-999')='APPROVED' and nvl(rln.cancel_flag,'N')='N'
                          and nvl(rln.modified_by_agent_flag,'N')='N'  and nvl(rln.closed_code,'-999') <> 'FINALLY CLOSED'
                    then
                       case
                             when nvl(pll.consigned_flag,'N')='Y' or nvl(pll.vmi_flag,'N')='Y' then null
                             when nvl(style.progress_payment_flag,'N') = 'Y' then null
                         when nvl(pll.approved_flag,'N')='Y'
                             then
                               case when nvl(pll.receipt_required_flag,'N') = 'N' and nvl(pll.inspection_required_flag, 'N') = 'N'
                               then least(nvl(pll.shipment_closed_date,pll.closed_for_invoice_date),pll.closed_for_invoice_date)
                               else least(nvl(pll.shipment_closed_date,pll.closed_for_receiving_date),pll.closed_for_receiving_date)
                               end
                          else
                           null
                       end
                   else
                   null
              end
            ) req_fulfilled_date,
            pll.need_by_date po_need_by_date,
            pll.promised_date po_promised_date,
            nvl(poh.vendor_id, rln.vendor_id) supplier_id,
            nvl(poh.vendor_site_id, rln.vendor_site_id) supplier_site_id,
            nvl(pol.category_id, rln.category_id) category_id,
            decode(
              pll.line_location_id,
              null, poa_dbi_items_pkg.getitemkey(
                      rln.item_id,
                      rpar.master_organization_id,
                      rln.category_id,
                      rln.suggested_vendor_product_code,
                      rln.vendor_id,
                      rln.item_description
                    ),
              poa_dbi_items_pkg.getitemkey(
                pol.item_id,
                ppar.master_organization_id,
                pol.category_id,
                pol.vendor_product_num,
                poh.vendor_id,
                pol.item_description
              )
            ) po_item_id,
            nvl(decode(pll.po_release_id,null,poh.agent_id,por.agent_id),rln.suggested_buyer_id) buyer_id,
            nvl(pll.ship_to_organization_id, rln.destination_organization_id) ship_to_org_id,
            rln.to_person_id requester_id, --get the requester from the requisition itself
            rln.line_type_id,
            rhr.preparer_id,
            nvl(pll.price_override, nvl(rln.currency_unit_price,rln.unit_price)) unit_price, -- in transactional currency
            sum( case
                 when  nvl(rhr.authorization_status,'-999')='APPROVED'
                         and nvl(rln.cancel_flag,'N')='N'  and nvl(rln.closed_code,'-999') <> 'FINALLY CLOSED'
                       and nvl(rln.modified_by_agent_flag,'N')='N' then
                        case when pll.line_location_id is null then rdn.req_line_quantity
                             when pll.line_location_id is not null then (pod.quantity_ordered-nvl(pod.quantity_cancelled,0))
                        else
                        null
                        end
                 else
                 null
               end
              ) line_quantity,
            sum( case
                 when  nvl(rhr.authorization_status,'-999')='APPROVED'
                         and nvl(rln.cancel_flag,'N')='N' and nvl(rln.closed_code,'-999') <> 'FINALLY CLOSED'
                       and nvl(rln.modified_by_agent_flag,'N')='N' then
                        case when pll.line_location_id is null then nvl(rdn.req_line_currency_amount, rdn.req_line_amount)
                             when pll.line_location_id is not null then (pod.amount_ordered-nvl(pod.amount_cancelled,0))
                        else
                        null
                        end
                 else
                 null
               end
              ) line_amount_t,
            decode(rhr.emergency_po_num, null, 'N', 'Y') emergency_flag,
            rln.urgent_flag,
            ( case when nvl(rln.line_location_id,-999)=-999
                        and nvl(rln.cancel_flag,'N')='N'
                        and nvl(rhr.authorization_status,'-999')='APPROVED'
                        and (rln.at_sourcing_flag='Y' or
                             (rln.reqs_in_pool_flag='Y'
                              and nvl(rln.on_rfq_flag,'N')='Y'
                              and nvl(rln.auction_header_id,-999)=-999))
                   then 'Y'
                   when nvl(rln.line_location_id,-999)=-999
                        and nvl(rln.cancel_flag,'N')='N'
                        and nvl(rhr.authorization_status,'-999')='APPROVED'
                        and rln.reqs_in_pool_flag='Y'
                   then 'N'
                   else ''
              end
            ) sourcing_flag,
            ( case when nvl(rhr.authorization_status,'-999') = 'APPROVED'  and nvl(rln.closed_code,'-999') <> 'FINALLY CLOSED'
                   then
                     case when nvl(rln.cancel_flag,'N')='Y' then 'N'
                          when decode(pll.line_location_id,null,rln.matching_basis,pll.matching_basis)='AMOUNT' then 'N'
                          when nvl(pll.consigned_flag,'N')='Y' or nvl(pll.vmi_flag,'N')='Y' then 'N'
                          when (nvl(style.progress_payment_flag,'N') = 'Y') then 'N'
                          else 'Y'
                     end
                   when nvl(rhr.authorization_status,'-999') = 'CANCELLED'
                   then 'A'
                   else 'N'
              end
            ) include_in_ufr,
            decode(pll.line_location_id,null,rln.matching_basis,pll.matching_basis) matching_basis,
            decode(pll.line_location_id,null,rln.order_type_lookup_code,pll.value_basis) order_type_lookup_code,
            decode(pll.po_release_id,null,poh.revision_num,por.revision_num) po_revisions,
            ( case when decode(pll.po_release_id,null,poh.document_creation_method,por.document_creation_method) in ('ENTER_PO', 'ENTER_RELEASE', 'COPY_DOCUMENT', 'AUTOCREATE')
            then 'M' else 'A' end) po_creation_method,
            rat.func_cur_code func_cur_code,
            decode(pll.line_location_id,null,nvl(rln.rate,1),nvl(poh.rate,1)) func_cur_conv_rate,
            rat.global_cur_conv_rate,
            rat.sglobal_cur_conv_rate,
            decode(
              pll.line_location_id,
              null, decode(rln.item_id, null, rln.unit_meas_lookup_code,ritem.primary_unit_of_measure),
              decode(pol.item_id, null, pol.unit_meas_lookup_code,pitem.primary_unit_of_measure)
            ) base_uom,
            decode( pll.line_location_id, null, rln.unit_meas_lookup_code, pol.unit_meas_lookup_code) transaction_uom,
            decode(
              pll.line_location_id,
              null, decode(
                      rln.item_id,
                      null, 1,
                      decode(
                        rln.unit_meas_lookup_code,
                        ritem.primary_unit_of_measure, 1,
                        poa_dbi_uom_pkg.convert_to_item_base_uom(
                          rln.item_id,
                          rpar.master_organization_id,
                          rln.unit_meas_lookup_code,
                          ritem.primary_uom_code
                        )
                      )
                    ),
              decode(
                pol.item_id,
                null, 1,
                decode(
                  pol.unit_meas_lookup_code,
                  pitem.primary_unit_of_measure, 1,
                  poa_dbi_uom_pkg.convert_to_item_base_uom(
                    pol.item_id,
                    ppar.master_organization_id,
                    pol.unit_meas_lookup_code,
                    pitem.primary_uom_code
                  )
                )
              )
            ) base_uom_conv_rate
            FROM
            poa_dbi_req_inc inc,
            poa_dbi_req_rates rat,
            po_requisition_lines_all rln,
            po_req_distributions_all rdn,
            po_headers_all poh,
            po_lines_all pol,
            po_releases_all por,
            financials_system_params_all pfsp,
            mtl_parameters ppar,
            mtl_system_items pitem,
            financials_system_params_all rfsp,
            mtl_parameters rpar,
            mtl_system_items ritem,
            gl_sets_of_books pgl,
            gl_sets_of_books rgl,
            po_requisition_headers_all rhr,
            po_line_locations_all pll,
            po_distributions_all pod,
            po_doc_style_headers style
            WHERE
                  inc.primary_key = rln.requisition_line_id
            and   (inc.line_location_id is null or inc.line_location_id = pll.line_location_id)
            and   inc.batch_id = v_batch_no
            and   rln.requisition_header_id = rhr.requisition_header_id
            and   rln.requisition_line_id = rdn.requisition_line_id
            and   rdn.distribution_id = pod.req_distribution_id (+)
            and   pll.po_line_id = pol.po_line_id (+)
            and   pod.line_location_id = pll.line_location_id(+)
            and   pll.po_release_id = por.po_release_id (+)
            and   pol.po_header_id = poh.po_header_id (+)
            and   poh.org_id = pfsp.org_id (+)
            and   pfsp.inventory_organization_id = ppar.organization_id (+)
            and   pfsp.set_of_books_id = pgl.set_of_books_id(+)
            and   rhr.org_id = rfsp.org_id
            and   rfsp.inventory_organization_id = rpar.organization_id
            and   rfsp.set_of_books_id = rgl.set_of_books_id
            and   rln.item_id = ritem.inventory_item_id (+)
            and   rpar.master_organization_id = nvl(ritem.organization_id, rpar.master_organization_id)
            and   pol.item_id = pitem.inventory_item_id (+)
            and   nvl(ppar.master_organization_id, -999) = nvl(pitem.organization_id, nvl(ppar.master_organization_id, -999))
            and   inc.txn_cur_code = rat.txn_cur_code
            and   inc.func_cur_code = rat.func_cur_code
            and   inc.rate_date = rat.rate_date
            and   rhr.authorization_status in ('APPROVED','CANCELLED','REJECTED','RETURNED','INCOMPLETE')
            and   rln.source_type_code = 'VENDOR'
            and   nvl(rhr.contractor_status,'NOT_APPLICABLE') <> 'PENDING'
            and   rln.creation_date > d_glob_date
            and   poh.style_id = style.style_id(+)
            group by
            pitem.primary_unit_of_measure,
            pitem.primary_uom_code,
            pll.amount,
            pll.amount_cancelled,
            pll.approved_date,
            pll.approved_flag,
            pll.closed_for_invoice_date,
            pll.closed_for_receiving_date,
            pll.consigned_flag,
            pll.creation_date,
            pll.inspection_required_flag,
            pll.line_location_id,
            pll.matching_basis,
            pll.need_by_date,
            pll.payment_type,
            pll.po_release_id,
            pll.price_override,
            pll.promised_date,
            pll.receipt_required_flag,
            pll.ship_to_organization_id,
            pll.shipment_closed_date,
            pll.value_basis,
            pll.vmi_flag,
            poh.agent_id,
            poh.document_creation_method,
            poh.org_id,
            poh.rate,
            poh.revision_num,
            poh.submit_date,
            poh.vendor_id,
            poh.vendor_site_id,
            pol.category_id,
            pol.item_description,
            pol.item_id,
            pol.matching_basis,
            pol.order_type_lookup_code,
            pol.unit_meas_lookup_code,
            pol.vendor_product_num,
            por.agent_id,
            por.document_creation_method,
            por.org_id,
            por.revision_num,
            por.submit_date,
            ppar.master_organization_id,
            rat.func_cur_code,
            rat.global_cur_conv_rate,
            rat.sglobal_cur_conv_rate,
            rhr.approved_date,
            rhr.authorization_status,
            rhr.creation_date,
            rhr.emergency_po_num,
            rhr.org_id,
            rhr.preparer_id,
            rhr.requisition_header_id,
            ritem.primary_unit_of_measure,
            ritem.primary_uom_code,
            rln.at_sourcing_flag,
            rln.auction_header_id,
            rln.cancel_flag,
            rln.category_id,
            rln.closed_code,
            rln.creation_date,
            rln.currency_unit_price,
            rln.destination_organization_id,
            rln.item_description,
            rln.item_id,
            rln.line_location_id,
            rln.line_type_id,
            rln.matching_basis,
            rln.modified_by_agent_flag,
            rln.need_by_date,
            rln.on_rfq_flag,
            rln.order_type_lookup_code,
            rln.rate,
            rln.reqs_in_pool_flag,
            rln.requisition_line_id,
            rln.suggested_buyer_id,
            rln.suggested_vendor_product_code,
            rln.to_person_id,
            rln.unit_meas_lookup_code,
            rln.unit_price,
            rln.urgent_flag,
            rln.vendor_id,
            rln.vendor_site_id,
            rpar.master_organization_id,
            style.progress_payment_flag
          )
        )
        group by
        req_line_id,
        req_header_id,
        req_creation_ou_id,
        req_creation_date,
        req_approved_date,
        po_creation_ou_id,
        supplier_id,
        supplier_site_id,
        category_id,
        po_item_id,
        buyer_id,
        org_id,
        ship_to_org_id,
        requester_id,
        line_type_id,
        preparer_id,
        emergency_flag,
        urgent_flag,
        sourcing_flag,
        include_in_ufr,
        po_revisions,
        po_creation_method,
        func_cur_code,
        func_cur_conv_rate,
        global_cur_conv_rate,
        sglobal_cur_conv_rate,
        base_uom,
        transaction_uom,
        base_uom_conv_rate
      ) s
      ON (t.req_line_id = s.req_line_id)
      WHEN MATCHED THEN UPDATE SET
        t.po_line_location_id = s.po_line_location_id,
        t.req_approved_date = s.req_approved_date,
        t.po_creation_ou_id = s.po_creation_ou_id,
        t.po_creation_date = s.po_creation_date,
        t.po_submit_date = s.po_submit_date,
        t.po_approved_date = s.po_approved_date,
        t.req_fulfilled_date = s.req_fulfilled_date,
        t.expected_date = s.expected_date,
        t.supplier_id = s.supplier_id,
        t.supplier_site_id = s.supplier_site_id,
        t.category_id = s.category_id,
	t.po_item_id = s.po_item_id,
        t.buyer_id = s.buyer_id,
        t.org_id = s.org_id,
        t.ship_to_org_id = s.ship_to_org_id,
        t.requester_id = s.requester_id,
        t.line_type_id = s.line_type_id,
        t.preparer_id = s.preparer_id,
        t.unit_price = s.unit_price,
        t.line_quantity = s.line_quantity,
        t.line_amount_t = s.line_amount_t,
        t.line_amount_b = s.line_amount_b,
        t.line_amount_g = s.line_amount_g,
        t.line_amount_sg = s.line_amount_sg,
        t.emergency_flag = s.emergency_flag,
        t.urgent_flag = s.urgent_flag,
        t.sourcing_flag = s.sourcing_flag,
        t.include_in_ufr = s.include_in_ufr,
        t.po_revisions = s.po_revisions,
	t.po_creation_method = s.po_creation_method,
        t.func_cur_code = s.func_cur_code,
        t.func_cur_conv_rate = s.func_cur_conv_rate,
        t.global_cur_conv_rate = s.global_cur_conv_rate,
        t.sglobal_cur_conv_rate = s.sglobal_cur_conv_rate,
        t.base_uom = s.base_uom,
        t.transaction_uom = s.transaction_uom,
        t.base_uom_conv_rate = s.base_uom_conv_rate,
        t.last_update_login = l_login,
        t.last_updated_by = l_user,
        t.last_update_date = l_start_time,
        t.unproc_ped_flag = s.unproc_ped_flag
      WHEN NOT MATCHED THEN INSERT
      (
        t.req_line_id ,
        t.req_header_id ,
        t.po_line_location_id ,
        t.req_creation_ou_id,
        t.req_creation_date ,
        t.req_approved_date ,
        t.po_creation_ou_id,
        t.po_creation_date ,
        t.po_submit_date ,
        t.po_approved_date,
        t.req_fulfilled_date,
        t.expected_date,
        t.supplier_id ,
        t.supplier_site_id,
        t.category_id,
        t.po_item_id,
        t.buyer_id,
        t.org_id,
        t.ship_to_org_id,
        t.requester_id,
        t.line_type_id,
        t.preparer_id,
        t.unit_price,
        t.line_quantity,
        t.line_amount_t,
        t.line_amount_b,
        t.line_amount_g,
        t.line_amount_sg,
        t.emergency_flag,
        t.urgent_flag,
        t.sourcing_flag,
        t.include_in_ufr,
        t.po_revisions,
        t.po_creation_method,
        t.func_cur_code,
        t.func_cur_conv_rate,
        t.global_cur_conv_rate,
        t.sglobal_cur_conv_rate,
        t.base_uom,
        t.transaction_uom,
        t.base_uom_conv_rate,
        t.created_by,
        t.last_update_login,
        t.creation_date,
        t.last_updated_by,
        t.last_update_date,
        t.unproc_ped_flag
      ) VALUES
      (
        s.req_line_id ,
        s.req_header_id ,
        s.po_line_location_id ,
        s.req_creation_ou_id,
        s.req_creation_date ,
        s.req_approved_date ,
        s.po_creation_ou_id,
        s.po_creation_date ,
        s.po_submit_date ,
        s.po_approved_date,
        s.req_fulfilled_date,
        s.expected_date,
        s.supplier_id ,
        s.supplier_site_id,
        s.category_id,
        s.po_item_id,
        s.buyer_id,
        s.org_id,
        s.ship_to_org_id,
        s.requester_id,
        s.line_type_id,
        s.preparer_id,
        s.unit_price,
        s.line_quantity,
        s.line_amount_t,
        s.line_amount_b,
        s.line_amount_g,
        s.line_amount_sg,
        s.emergency_flag,
        s.urgent_flag,
        s.sourcing_flag,
        s.include_in_ufr,
        s.po_revisions,
        s.po_creation_method,
        s.func_cur_code,
        s.func_cur_conv_rate,
        s.global_cur_conv_rate,
        s.sglobal_cur_conv_rate,
        s.base_uom,
        s.transaction_uom,
        s.base_uom_conv_rate,
        l_user,
        l_login,
        l_start_time,
        l_user,
        l_start_time,
        s.unproc_ped_flag
      );
     COMMIT;

     DBMS_APPLICATION_INFO.SET_ACTION('batch ' || v_batch_no || ' done');
    END LOOP;
   END IF;
  END IF;
    bis_collection_utilities.log('Collection complete '|| 'Sysdate=' ||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
    bis_collection_utilities.wrapup(TRUE, l_count, 'POA DBI REQ COLLECTION SUCEEDED', to_date(l_start_date, '''YYYY/MM/DD HH24:MI:SS'''), To_date(l_end_date, '''YYYY/MM/DD HH24:MI:SS'''));
    g_init := false;
    dbms_application_info.set_module(null, null);
    if ( l_num_corrupt_rows > 0 ) then
      fnd_concurrent.af_commit;
      l_ret_variable := fnd_concurrent.set_completion_status(
        status => 'WARNING',
        message => 'Bad data found in PO tables.'
      );
    end if;
  EXCEPTION
   WHEN others THEN
      dbms_application_info.set_action('error');
      errbuf:=sqlerrm;
      retcode:=sqlcode;
      bis_collection_utilities.log('Collection failed with '||errbuf||':'||retcode||' Sysdate=' ||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
      bis_collection_utilities.wrapup(FALSE, l_count, errbuf||':'||retcode, to_date(l_start_date, '''YYYY/MM/DD HH24:MI:SS'''), to_date(l_end_date, '''YYYY/MM/DD HH24:MI:SS'''));
      RAISE;
  END populate_req_facts;

END POA_DBI_REQ_F_C;

/
