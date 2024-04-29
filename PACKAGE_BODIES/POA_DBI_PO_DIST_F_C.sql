--------------------------------------------------------
--  DDL for Package Body POA_DBI_PO_DIST_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_PO_DIST_F_C" AS
/* $Header: poadbipodfrefb.pls 120.23.12000000.2 2007/08/13 10:01:47 kalakshm ship $ */
g_init boolean := false;

/* PUBLIC PROCEDURE */
PROCEDURE initial_load (errbuf    OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY NUMBER)
  IS
     l_poa_schema          VARCHAR2(30);
     l_status              VARCHAR2(30);
     l_industry            VARCHAR2(30);

     l_stmt VARCHAR2(4000);
BEGIN
   IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_POD_F';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_POD_INC';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_POD_RATES';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_NEG_PO_RATES';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_NEG_DETAILS';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_POD_MATCH_TEMP';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_POD_LOWEST_ALL_TEMP';
      EXECUTE IMMEDIATE l_stmt;

      l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_POD_LOWEST_PRICE_TEMP';
      EXECUTE IMMEDIATE l_stmt;

      g_init := true;
      populate_po_dist_facts (errbuf, retcode);
   END IF;

EXCEPTION
WHEN OTHERS THEN
   Errbuf:= Sqlerrm;
   Retcode:=sqlcode;

   ROLLBACK;
   POA_LOG.debug_line('initial_load' || Sqlerrm || sqlcode || sysdate);
   RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);

END initial_load;



/* PUBLIC PROCEDURE */
PROCEDURE populate_po_dist_facts (errbuf    OUT NOCOPY VARCHAR2,
                            retcode         OUT NOCOPY NUMBER)
IS
   l_no_batch NUMBER;
   l_go_ahead BOOLEAN := false;
   l_count NUMBER := 0;

   l_poa_schema          VARCHAR2(30);
   l_status              VARCHAR2(30);
   l_industry            VARCHAR2(30);
   l_sec_cur_yn number;
   l_stmt varchar2(4000);
   l_start_date VARCHAR2(22);
   l_end_date varchar2(22);
   l_glob_date VARCHAR2(22);
/*
  fnd_date.initialize('YYYY/MM/DD', 'YYYY/MM/DD HH24:MI:SS');
  l_from_date := fnd_date.displayDT_to_date(p_from_date);
  l_to_date := fnd_date.displayDT_to_date(p_to_date);
*/
   l_ret number;
   l_batch_size NUMBER;
   l_start_time DATE;
   l_login number;
   l_user number;
   l_dop NUMBER := 1;
   d_start_date DATE;
   d_end_date DATE;
   d_glob_date DATE;
   l_rate_type VARCHAR2(30);
   l_srate_type varchar2(30);
   l_global_cur_code gl_sets_of_books.currency_code%type;
   l_sglobal_cur_code gl_sets_of_books.currency_code%type;
BEGIN
   Errbuf :=NULL;
   Retcode:=0;
   l_global_cur_code := bis_common_parameters.get_currency_code;
   l_sglobal_cur_code := bis_common_parameters.get_secondary_currency_code;
   l_srate_type := bis_common_parameters.get_secondary_rate_type;
   l_batch_size := bis_common_parameters.get_batch_size(10);
   l_rate_type := bis_common_parameters.get_rate_type;
   if(poa_currency_pkg.display_secondary_currency_yn)
   then
     l_sec_cur_yn := 1;
   else
     l_sec_cur_yn := 0;
   end if;

   DBMS_APPLICATION_INFO.SET_MODULE(module_name => 'DBI POD COLLECT', action_name => 'start');
   l_dop := bis_common_parameters.get_degree_of_parallelism;
   -- default DOP to profile in EDW_PARALLEL_SRC if 2nd param is not passed
   l_go_ahead := bis_collection_utilities.setup('POAPODIST');
   if (g_init) then
	   execute immediate 'alter session set hash_area_size=104857600';
	   execute immediate 'alter session set sort_area_size=104857600';
--	   execute immediate 'alter session disable parallel dml' ;
   end if;
   IF (NOT l_go_ahead) THEN
      errbuf := fnd_message.get;
      RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
   END IF;
   bis_collection_utilities.g_debug := FALSE;


   IF(g_init) THEN
	l_start_date := To_char(bis_common_parameters.get_global_start_date
				, 'YYYY/MM/DD HH24:MI:SS');
        d_start_date := bis_common_parameters.get_global_start_date;
   ELSE
      l_start_date := To_char(fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('POAPODIST')) - 0.004,'YYYY/MM/DD HH24:MI:SS');
      /* note that if there is not a success record in the log, we should get global start date as l_start_date */
      d_start_date := fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('POAPODIST')) - 0.004;
   END IF;


      l_end_date := To_char(Sysdate, 'YYYY/MM/DD HH24:MI:SS');
      d_end_date := Sysdate;

   bis_collection_utilities.log( 'The collection range is from '||
				 l_start_date ||' to '|| l_end_date, 0);


   IF (l_batch_size IS NULL) THEN
      l_batch_size := 10000;
   END if;

   bis_collection_utilities.log('Truncate INC table: '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
   IF (NOT(FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema))) THEN
        bis_collection_utilities.log('Error getting app info '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
        RAISE_APPLICATION_ERROR (-20000, 'Error in GET_APP_INFO: ' || errbuf);
   END IF;
   l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_POD_INC';
   EXECUTE IMMEDIATE l_stmt;
   l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_POD_RATES';
   EXECUTE IMMEDIATE l_stmt;
   l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_NEG_PO_RATES';
   EXECUTE IMMEDIATE l_stmt;
   l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_NEG_DETAILS';
   EXECUTE IMMEDIATE l_stmt;

   DBMS_APPLICATION_INFO.SET_ACTION('inc');
   bis_collection_utilities.log('Populate INC table '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
   l_glob_date := To_char(bis_common_parameters.get_global_start_date, 'YYYY/MM/DD HH24:MI:SS');
   d_glob_date := bis_common_parameters.get_global_start_date;

   if(g_init) then
     insert /*+ append parallel(poa_dbi_pod_inc) */ into poa_dbi_pod_inc
     ( primary_key,
       global_cur_conv_rate,
       batch_id,
       func_cur_code,
       txn_cur_code,
       rate_date
     )
     ( select
       po_distribution_id primary_key,
       null global_cur_conv_rate,
       1 batch_id,
       func_cur_code,
       txn_cur_code,
       rate_date
       from
       (
         (
           select /*+ parallel(pol) parallel(pll) parallel(poh) parallel(pod) parallel(poa_gl)
           NO_MERGE  USE_HASH(pol) use_hash(pll) use_hash(poh) use_hash(pod) use_hash(poa_gl)*/
           pod.po_distribution_id,
           poa_gl.currency_code func_cur_code,
           poh.currency_code txn_cur_code,
           trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
           from
           po_lines_all                    pol,
           po_line_locations_all           pll,
           po_headers_all                  poh,
           po_distributions_all            pod,
           gl_sets_of_books                poa_gl
           where pod.line_location_id            = pll.line_location_id
           and   pod.po_line_id                  = pol.po_line_id
           and   pod.po_header_id                = poh.po_header_id
           and   pll.shipment_type               in ('STANDARD','PREPAYMENT')
           and   pll.approved_flag               = 'Y'
           and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
           and   poa_gl.set_of_books_id      = pod.set_of_books_id
           and   pod.creation_date >= d_glob_date
           and ( pol.last_update_date between d_start_date and d_end_date or
                 pll.last_update_date between d_start_date and d_end_date or
                 poh.last_update_date between d_start_date and d_end_date or
                 pod.last_update_date between d_start_date and d_end_date )
         )
         union all
         (
           select /*+ parallel(pol) parallel(pll) parallel(poh) parallel(por) parallel(pod) parallel(poa_gl)
                 NO_MERGE  USE_HASH(pol) use_hash(pll) use_hash(poh) use_hash(por) use_hash(pod) use_hash(poa_gl) */
           pod.po_distribution_id,
           poa_gl.currency_code func_cur_code,
           poh.currency_code txn_cur_code,
           trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
           from
           po_lines_all                    pol,
           po_line_locations_all           pll,
           po_headers_all                  poh,
           po_releases_all                 por,
           po_distributions_all            pod,
           gl_sets_of_books                poa_gl
           where pod.line_location_id            = pll.line_location_id
           and   pod.po_release_id               = por.po_release_id
           and   pod.po_line_id                  = pol.po_line_id
           and   pod.po_header_id                = poh.po_header_id
           and   pll.shipment_type               in ('BLANKET', 'SCHEDULED')
           and   pll.approved_flag               = 'Y'
           and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
           and   poa_gl.set_of_books_id      = pod.set_of_books_id
           and   pod.creation_date >= d_glob_date
           and ( pol.last_update_date between d_start_date and d_end_date or
                 pll.last_update_date between d_start_date and d_end_date or
                 poh.last_update_date between d_start_date and d_end_date or
                 pod.last_update_date between d_start_date and d_end_date or
                 por.last_update_date between d_start_date and d_end_date)
         )
       )
     );

   else -- not initial load

   insert /*+ append */ into
   poa_dbi_pod_inc
   (
     primary_key,
     global_cur_conv_rate,
     batch_id,
     func_cur_code,
     txn_cur_code,
     rate_date
   )
   ( select
     primary_key,
     null global_cur_conv_rate,
     ceil(rownum/l_batch_size) batch_id,
     func_cur_code,
     txn_cur_code,
     rate_date
     from
     (
       (
         select /*+ cardinality(pol, 1)*/
         pod.po_distribution_id primary_key,
         poa_gl.currency_code func_cur_code,
         poh.currency_code txn_cur_code,
         trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
         from
         po_lines_all                    pol,
         po_line_locations_all           pll,
         po_headers_all                  poh,
         po_distributions_all            pod,
         gl_sets_of_books                poa_gl
         where pod.line_location_id            = pll.line_location_id
         and   pod.po_line_id                  = pol.po_line_id
         and   pod.po_header_id                = poh.po_header_id
         and   pll.shipment_type               in ('STANDARD','PREPAYMENT')
         and   pll.approved_flag               = 'Y'
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   poa_gl.set_of_books_id      = pod.set_of_books_id
         and   pod.creation_date >= d_glob_date
         and   pol.last_update_date between d_start_date and d_end_date
        UNION
         select /*+ cardinality(pll, 1)*/
         pod.po_distribution_id primary_key,
         poa_gl.currency_code func_cur_code,
         poh.currency_code txn_cur_code,
         trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
         from
         po_line_locations_all           pll,
         po_headers_all                  poh,
         po_distributions_all            pod,
         gl_sets_of_books                poa_gl
         where pod.line_location_id            = pll.line_location_id
         and   pod.po_header_id                = poh.po_header_id
         and   pll.shipment_type               in ('STANDARD','PREPAYMENT')
         and   pll.approved_flag               = 'Y'
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   poa_gl.set_of_books_id      = pod.set_of_books_id
         and   pod.creation_date >= d_glob_date
         and   pll.last_update_date between d_start_date and d_end_date
        UNION
         select /*+ cardinality(poh, 1)*/
         pod.po_distribution_id primary_key,
         poa_gl.currency_code func_cur_code,
         poh.currency_code txn_cur_code,
         trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
         from
         po_line_locations_all           pll,
         po_headers_all                  poh,
         po_distributions_all            pod,
         gl_sets_of_books                poa_gl
         where pod.line_location_id            = pll.line_location_id
         and   pod.po_header_id                = poh.po_header_id
         and   pll.shipment_type               in ('STANDARD','PREPAYMENT')
         and   pll.approved_flag               = 'Y'
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   poa_gl.set_of_books_id      = pod.set_of_books_id
         and   pod.creation_date >= d_glob_date
         and   poh.last_update_date between d_start_date and d_end_date
        UNION
         select /*+ cardinality(pod, 1)*/
         pod.po_distribution_id primary_key,
         poa_gl.currency_code func_cur_code,
         poh.currency_code txn_cur_code,
         trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
         from
         po_line_locations_all           pll,
         po_headers_all                  poh,
         po_distributions_all            pod,
         gl_sets_of_books                poa_gl
         where pod.line_location_id            = pll.line_location_id
         and   pod.po_header_id                = poh.po_header_id
         and   pll.shipment_type               in ('STANDARD','PREPAYMENT')
         and   pll.approved_flag               = 'Y'
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   poa_gl.set_of_books_id      = pod.set_of_books_id
         and   pod.creation_date >= d_glob_date
         and   pod.last_update_date between d_start_date and d_end_date
       )
       union all
       (
         select /*+ cardinality(pol, 1)*/
         pod.po_distribution_id primary_key,
         poa_gl.currency_code func_cur_code,
         poh.currency_code txn_cur_code,
         trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
         from
         po_lines_all                    pol,
         po_line_locations_all           pll,
         po_headers_all                  poh,
         po_distributions_all            pod,
         gl_sets_of_books                poa_gl
         where pod.line_location_id            = pll.line_location_id
         and   pod.po_line_id                  = pol.po_line_id
         and   pod.po_header_id                = poh.po_header_id
         and   pll.shipment_type               in ('BLANKET', 'SCHEDULED')
         and   pll.approved_flag               = 'Y'
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   poa_gl.set_of_books_id      = pod.set_of_books_id
         and   pod.creation_date >= d_glob_date
         and   pol.last_update_date between d_start_date and d_end_date
        UNION
         select /*+ cardinality(pll, 1)*/
         pod.po_distribution_id primary_key,
         poa_gl.currency_code func_cur_code,
         poh.currency_code txn_cur_code,
         trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
         from
         po_line_locations_all           pll,
         po_headers_all                  poh,
         po_distributions_all            pod,
         gl_sets_of_books                poa_gl
         where pod.line_location_id            = pll.line_location_id
         and   pod.po_header_id                = poh.po_header_id
         and   pll.shipment_type               in ('BLANKET', 'SCHEDULED')
         and   pll.approved_flag               = 'Y'
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   poa_gl.set_of_books_id      = pod.set_of_books_id
         and   pod.creation_date >= d_glob_date
         and  pll.last_update_date between d_start_date and d_end_date
        UNION
         select /*+ cardinality(poh, 1)*/
         pod.po_distribution_id primary_key,
         poa_gl.currency_code func_cur_code,
         poh.currency_code txn_cur_code,
         trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
         from
         po_line_locations_all           pll,
         po_headers_all                  poh,
         po_distributions_all            pod,
         gl_sets_of_books                poa_gl
         where pod.line_location_id            = pll.line_location_id
         and   pod.po_header_id                = poh.po_header_id
         and   pll.shipment_type               in ('BLANKET', 'SCHEDULED')
         and   pll.approved_flag               = 'Y'
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   poa_gl.set_of_books_id      = pod.set_of_books_id
         and   pod.creation_date >= d_glob_date
         and   poh.last_update_date between d_start_date and d_end_date
        UNION
         select /*+ cardinality(pod, 1)*/
         pod.po_distribution_id primary_key,
         poa_gl.currency_code func_cur_code,
         poh.currency_code txn_cur_code,
         trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
         from
         po_line_locations_all           pll,
         po_headers_all                  poh,
         po_distributions_all            pod,
         gl_sets_of_books                poa_gl
         where pod.line_location_id            = pll.line_location_id
         and   pod.po_header_id                = poh.po_header_id
         and   pll.shipment_type               in ('BLANKET', 'SCHEDULED')
         and   pll.approved_flag               = 'Y'
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   poa_gl.set_of_books_id      = pod.set_of_books_id
         and   pod.creation_date >= d_glob_date
         and   pod.last_update_date between d_start_date and d_end_date
        UNION
         select /*+ cardinality(por, 1)*/
         pod.po_distribution_id primary_key,
         poa_gl.currency_code func_cur_code,
         poh.currency_code txn_cur_code,
         trunc(nvl(pod.rate_date, pod.creation_date)) rate_date
         from
         po_line_locations_all           pll,
         po_headers_all                  poh,
         po_releases_all                 por,
         po_distributions_all            pod,
         gl_sets_of_books                poa_gl
         where pod.line_location_id            = pll.line_location_id
         and   pod.po_release_id               = por.po_release_id
         and   pod.po_header_id                = poh.po_header_id
         and   pll.shipment_type               in ('BLANKET', 'SCHEDULED')
         and   pll.approved_flag               = 'Y'
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   poa_gl.set_of_books_id      = pod.set_of_books_id
         and   pod.creation_date >= d_glob_date
         and   por.last_update_date between d_start_date and d_end_date
       )
     )
   );

   end if;

   COMMIT;

   DBMS_APPLICATION_INFO.SET_ACTION('stats incremental');

     fnd_stats.gather_table_stats(OWNNAME => l_poa_schema, TABNAME => 'POA_DBI_POD_INC');

   insert /*+ APPEND */ into poa_dbi_pod_rates
   (
     txn_cur_code,
     func_cur_code,
     rate_date,
     global_cur_conv_rate,
     sglobal_cur_conv_rate
   )
   select
   txn_cur_code,
   func_cur_code,
   rate_date,
   poa_currency_pkg.get_dbi_global_rate(
     l_rate_type,
     func_cur_code,
     rate_date,
     txn_cur_code
   ) global_cur_conv_rate,
   ( case when l_sec_cur_yn = 0
     then null
     else poa_currency_pkg.get_dbi_sglobal_rate(
            l_srate_type,
            func_cur_code,
            rate_date,
            txn_cur_code
          )
     end
   ) sglobal_cur_conv_rate
   from
   (
     select distinct
     txn_cur_code,
     func_cur_code,
     rate_date
     from poa_dbi_pod_inc
     order by func_cur_code, rate_date
   );

   COMMIT;

 if(g_init) then
   insert /*+ APPEND PARALLEL*/ into poa_dbi_neg_po_rates
   (
     txn_cur_code,
     func_cur_code,
     rate_date,
     global_cur_conv_rate,
     sglobal_cur_conv_rate
   )
   select
   txn_cur_code,
   func_cur_code,
   rate_date,
   poa_currency_pkg.get_dbi_global_rate(
     l_rate_type,
     func_cur_code,
     rate_date,
     txn_cur_code
   ) global_cur_conv_rate,
   ( case when l_sec_cur_yn = 0
     then null
     else poa_currency_pkg.get_dbi_sglobal_rate(
            l_srate_type,
            func_cur_code,
            rate_date,
            txn_cur_code
          )
     end
   ) sglobal_cur_conv_rate
   from
   (
select  /*+  parallel(pod) parallel(pol) parallel(ponh) parallel(ponbh) */
                distinct ponh.currency_code txn_cur_code,
                pgl.currency_code func_cur_code,
                nvl(trunc(ponh.rate_date), trunc(ponh.creation_date)) rate_date
        from    poa_dbi_pod_inc inc,
                po_distributions_all pod,
                po_lines_all pol,
                pon_bid_headers ponbh,
                pon_auction_headers_all ponh,
                financials_system_params_all pfsp,
                gl_sets_of_books pgl
        where   pod.po_distribution_id      = inc.primary_key
                and pod.po_line_id          = pol.po_line_id
                and pol.auction_header_id = ponbh.auction_header_id
                and ponbh.auction_header_id = ponh.auction_header_id
                and ponh.contract_type      = 'STANDARD'
                and ponh.org_id             = pfsp.org_id
                and pfsp.set_of_books_id    = pgl.set_of_books_id
                and ponh.creation_date     >= d_glob_date
union
select  /*+  parallel(pod) parallel(pol) parallel(ponh) parallel(ponbh) */
                distinct ponh.currency_code txn_cur_code,
                pgl.currency_code func_cur_code,
                nvl(trunc(ponh.rate_date), trunc(ponh.creation_date)) rate_date
        from    poa_dbi_pod_inc inc,
                po_distributions_all pod,
                po_lines_all pol,
                pon_bid_headers ponbh,
                pon_auction_headers_all ponh,
                financials_system_params_all pfsp,
                gl_sets_of_books pgl
        where   pod.po_distribution_id      = inc.primary_key
                and pod.po_line_id          = pol.po_line_id
                and pol.contract_id         = ponbh.po_header_id
                and ponbh.auction_header_id = ponh.auction_header_id
                and ponh.contract_type      = 'CONTRACT'
                and ponh.org_id             = pfsp.org_id
                and pfsp.set_of_books_id    = pgl.set_of_books_id
                and ponh.creation_date     >= d_glob_date
union
select /*+  parallel(pod) parallel(pol) parallel(ponh) parallel(ponbh) */
                distinct ponh.currency_code txn_cur_code,
                pgl.currency_code func_cur_code,
                nvl(trunc(ponh.rate_date), trunc(ponh.creation_date)) rate_date
        from
                poa_dbi_pod_inc inc,
                po_distributions_all pod,
                po_lines_all pol,
                pon_bid_headers ponbh,
                pon_auction_headers_all ponh,
                financials_system_params_all pfsp,
                gl_sets_of_books pgl
        where   pod.po_distribution_id      = inc.primary_key
                and pod.po_line_id          = pol.po_line_id
                and pol.from_header_id      = ponbh.po_header_id
                and ponbh.auction_header_id = ponh.auction_header_id
                and ponh.org_id             = pfsp.org_id
                and pfsp.set_of_books_id    = pgl.set_of_books_id
                and ponh.creation_date     >= d_glob_date
order by func_cur_code,
         rate_date    );

else --not initial load
   insert /*+ APPEND */ into poa_dbi_neg_po_rates
   (
     txn_cur_code,
     func_cur_code,
     rate_date,
     global_cur_conv_rate,
     sglobal_cur_conv_rate
   )
   select
   txn_cur_code,
   func_cur_code,
   rate_date,
   poa_currency_pkg.get_dbi_global_rate(
     l_rate_type,
     func_cur_code,
     rate_date,
     txn_cur_code
   ) global_cur_conv_rate,
   ( case when l_sec_cur_yn = 0
     then null
     else poa_currency_pkg.get_dbi_sglobal_rate(
            l_srate_type,
            func_cur_code,
            rate_date,
            txn_cur_code
          )
     end
   ) sglobal_cur_conv_rate
   from
   (
	select  /*+ leading(inc,pod) cardinality(inc,1) */
                distinct ponh.currency_code txn_cur_code,
                pgl.currency_code func_cur_code,
                nvl(trunc(ponh.rate_date), trunc(ponh.creation_date)) rate_date
        from    poa_dbi_pod_inc inc,
                po_distributions_all pod,
                po_lines_all pol,
                pon_bid_headers ponbh,
                pon_auction_headers_all ponh,
                financials_system_params_all pfsp,
                gl_sets_of_books pgl
        where   pod.po_distribution_id      = inc.primary_key
                and pod.po_line_id          = pol.po_line_id
                and pol.auction_header_id = ponbh.auction_header_id
                and ponbh.auction_header_id = ponh.auction_header_id
                and ponh.contract_type      = 'STANDARD'
                and ponh.org_id             = pfsp.org_id
                and pfsp.set_of_books_id    = pgl.set_of_books_id
                and ponh.creation_date     >= d_glob_date
union
select  /*+ leading(inc,pod) cardinality(inc,100) */
                distinct ponh.currency_code txn_cur_code,
                pgl.currency_code func_cur_code,
                nvl(trunc(ponh.rate_date), trunc(ponh.creation_date)) rate_date
        from    poa_dbi_pod_inc inc,
                po_distributions_all pod,
                po_lines_all pol,
                pon_bid_headers ponbh,
                pon_auction_headers_all ponh,
                financials_system_params_all pfsp,
                gl_sets_of_books pgl
        where   pod.po_distribution_id      = inc.primary_key
                and pod.po_line_id          = pol.po_line_id
                and pol.contract_id         = ponbh.po_header_id
                and ponbh.auction_header_id = ponh.auction_header_id
                and ponh.contract_type      = 'CONTRACT'
                and ponh.org_id             = pfsp.org_id
                and pfsp.set_of_books_id    = pgl.set_of_books_id
                and ponh.creation_date     >= d_glob_date
union
select  /*+ leading(inc,pod) cardinality(inc,1) */
                distinct ponh.currency_code txn_cur_code,
                pgl.currency_code func_cur_code,
                nvl(trunc(ponh.rate_date), trunc(ponh.creation_date)) rate_date
        from
                poa_dbi_pod_inc inc,
                po_distributions_all pod,
                po_lines_all pol,
                pon_bid_headers ponbh,
                pon_auction_headers_all ponh,
                financials_system_params_all pfsp,
                gl_sets_of_books pgl
        where   pod.po_distribution_id      = inc.primary_key
                and pod.po_line_id          = pol.po_line_id
                and pol.from_header_id      = ponbh.po_header_id
                and ponbh.auction_header_id = ponh.auction_header_id
                and ponh.org_id             = pfsp.org_id
                and pfsp.set_of_books_id    = pgl.set_of_books_id
                and ponh.creation_date     >= d_glob_date
order by func_cur_code,
         rate_date    );

end if;
   COMMIT;
   -- Gather statistics for poa_dbi_neg_po_rates
   FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_poa_schema, TABNAME => 'POA_DBI_NEG_PO_RATES') ;

  --- Create a Negotiations Table that stores all relevant data pertaining to negotiations ---
if(g_init) then
insert /*+ APPEND */ into poa_dbi_neg_details
    (
       po_distribution_id,
       auction_header_id,
       auction_line_number,
       bid_number,
       bid_line_number,
       negotiation_creator_id,
       doctype_id,
       neg_current_price,
       neg_func_cur_code,
       neg_func_cur_conv_rate,
       neg_global_cur_conv_rate,
       neg_sglobal_cur_conv_rate,
       neg_transaction_uom,
       neg_base_uom,
       neg_base_uom_conv_rate
    )
  (  select /*+ USE_HASH(inc) */
  pod.po_distribution_id,
  pol.auction_header_id,
  pol.auction_line_number,
  pol.bid_number,
  pol.bid_line_number,
  hz.person_identifier negotiation_creator_id,
  ponh.doctype_id,
  ponip.current_price neg_current_price,
  neg_rates.func_cur_code neg_func_cur_code,
  nvl(ponh.rate,1) neg_func_cur_conv_rate,
  neg_rates.global_cur_conv_rate neg_global_cur_conv_rate,
  neg_rates.sglobal_cur_conv_rate neg_sglobal_cur_conv_rate,
  uom.unit_of_measure neg_transaction_uom,
  decode(ponip.item_id, null, decode(pll.value_basis, 'AMOUNT',uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)), pitem.primary_unit_of_measure) neg_base_uom,
       decode(
                  ponip.item_id,
                  null,
		  decode(pll.value_basis,'AMOUNT',1,
		  decode(uom.unit_of_measure,nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code), 1,
		    poa_dbi_uom_pkg.convert_neg_to_po_uom(uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code))))
		  ,
                  decode(uom.unit_of_measure,
                    pitem.primary_unit_of_measure, 1,
                    poa_dbi_uom_pkg.convert_to_item_base_uom(
                      ponip.item_id,
                      ppar.master_organization_id,
                      uom.unit_of_measure,
                      pitem.primary_uom_code
                    )
                  )
               ) neg_base_uom_conv_rate
from
      poa_dbi_pod_inc inc,
      po_distributions_all pod,
      po_line_locations_all pll,
      po_lines_all pol,
      pon_bid_item_prices ponbip,
      pon_bid_headers ponbh,
      pon_auction_item_prices_all ponip,
      pon_auction_headers_all ponh,
      poa_dbi_neg_po_rates neg_rates,
      financials_system_params_all pfsp,
      gl_sets_of_books pgl,
      mtl_system_items pitem,
      mtl_units_of_measure uom,
      mtl_parameters ppar,
      hz_parties hz
where
    pod.po_distribution_id = inc.primary_key
and pod.line_location_id = pll.line_location_id
and pll.po_line_id = pol.po_line_id
and pol.from_header_id is null
and pol.auction_header_id = ponbip.auction_header_id
and pol.bid_number = ponbip.bid_number
and pol.auction_line_number = ponbip.auction_line_number
and pol.bid_line_number = ponbip.line_number
and ponbip.auction_header_id = ponbh.auction_header_id
and ponbh.auction_header_id = ponip.auction_header_id
and ponip.auction_header_id = ponh.auction_header_id
and ponbh.bid_number = ponbip.bid_number
and ponbip.auction_line_number = ponip.line_number
and ponh.org_id = pfsp.org_id
and ponbh.contract_type in ('STANDARD','BLANKET')
and pfsp.set_of_books_id = pgl.set_of_books_id
and pfsp.inventory_organization_id = ppar.organization_id
and ponip.item_id = pitem.inventory_item_id(+)
and ppar.master_organization_id = nvl(pitem.organization_id, ppar.master_organization_id)
and ponip.uom_code = uom.uom_code(+)
and ponh.trading_partner_contact_id = hz.party_id
and neg_rates.rate_date = nvl(trunc(ponh.rate_date), trunc(ponh.creation_date))
and neg_rates.txn_cur_code = ponh.currency_code
and neg_rates.func_cur_code = pgl.currency_code
and ponh.creation_date >= d_glob_date
UNION
select /*+ USE_HASH(inc) */
  pod.po_distribution_id,
  pol_orig.auction_header_id,
  pol_orig.auction_line_number,
  pol_orig.bid_number,
  pol_orig.bid_line_number,
  hz.person_identifier negotiation_creator_id,
  ponh.doctype_id,
  ponip.current_price neg_current_price,
  neg_rates.func_cur_code neg_func_cur_code,
  nvl(ponh.rate,1) neg_func_cur_conv_rate,
  neg_rates.global_cur_conv_rate neg_global_cur_conv_rate,
  neg_rates.sglobal_cur_conv_rate neg_sglobal_cur_conv_rate,
  uom.unit_of_measure neg_transaction_uom,
  decode(ponip.item_id, null, decode(pll.value_basis, 'AMOUNT',uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)), pitem.primary_unit_of_measure) neg_base_uom,
       decode(
                  ponip.item_id,
                  null,
		  decode(pll.value_basis,'AMOUNT',1,
		  decode(uom.unit_of_measure,nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code), 1,
		    poa_dbi_uom_pkg.convert_neg_to_po_uom(uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code))))
		  ,
                  decode(uom.unit_of_measure,
                    pitem.primary_unit_of_measure, 1,
                    poa_dbi_uom_pkg.convert_to_item_base_uom(
                      ponip.item_id,
                      ppar.master_organization_id,
                      uom.unit_of_measure,
                      pitem.primary_uom_code
                    )
                  )
               ) neg_base_uom_conv_rate
from
      poa_dbi_pod_inc inc,
      po_distributions_all pod,
      po_line_locations_all pll,
      po_lines_all pol,
      po_headers_all poh_orig,
      po_lines_all pol_orig,
      pon_bid_item_prices ponbip,
      pon_bid_headers ponbh,
      pon_auction_item_prices_all ponip,
      pon_auction_headers_all ponh,
      poa_dbi_neg_po_rates neg_rates,
      financials_system_params_all pfsp,
      gl_sets_of_books pgl,
      mtl_system_items pitem,
      mtl_units_of_measure uom,
      mtl_parameters ppar,
      hz_parties hz
where
    pod.po_distribution_id = inc.primary_key
and pod.line_location_id = pll.line_location_id
and pll.po_line_id = pol.po_line_id
and pol.from_header_id = poh_orig.po_header_id
and pol.from_line_id = pol_orig.po_line_id
and pol_orig.po_header_id = poh_orig.po_header_id
and pol_orig.po_header_id = poh_orig.po_header_id
and pol_orig.bid_number = ponbh.bid_number
and pol_orig.bid_line_number = ponbip.line_number
and pol_orig.auction_header_id = ponh.auction_header_id
and pol_orig.auction_line_number = ponip.line_number
and ponbip.auction_header_id = ponbh.auction_header_id
and ponbh.auction_header_id = ponip.auction_header_id
and ponip.auction_header_id = ponh.auction_header_id
and ponbh.bid_number = ponbip.bid_number
and ponbip.auction_line_number = ponip.line_number
and ponh.org_id = pfsp.org_id
and ponbh.contract_type = 'BLANKET'
and pfsp.set_of_books_id = pgl.set_of_books_id
and pfsp.inventory_organization_id = ppar.organization_id
and ponip.item_id = pitem.inventory_item_id(+)
and ppar.master_organization_id = nvl(pitem.organization_id, ppar.master_organization_id)
and ponip.uom_code = uom.uom_code(+)
and ponh.trading_partner_contact_id = hz.party_id
and neg_rates.rate_date = nvl(trunc(ponh.rate_date), trunc(ponh.creation_date))
and neg_rates.txn_cur_code = ponh.currency_code
and neg_rates.func_cur_code = pgl.currency_code
and ponh.creation_date >= d_glob_date
UNION
select /*+ USE_HASH(inc) */
  pod.po_distribution_id,
  ponbip.auction_header_id,
  ponbip.auction_line_number,
  ponbip.bid_number,
  ponbip.line_number bid_line_number,
  hz.person_identifier negotiation_creator_id,
  ponh.doctype_id,
  null neg_current_price,
  neg_rates.func_cur_code neg_func_cur_code,
  nvl(ponh.rate,1) neg_func_cur_conv_rate,
  neg_rates.global_cur_conv_rate neg_global_cur_conv_rate,
  neg_rates.sglobal_cur_conv_rate neg_sglobal_cur_conv_rate,
  uom.unit_of_measure neg_transaction_uom,
  decode(ponip.item_id, null, decode(pll.value_basis, 'AMOUNT',uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)), pitem.primary_unit_of_measure) neg_base_uom,
       decode(
                  ponip.item_id,
                  null,
		  decode(pll.value_basis,'AMOUNT',1,
		  decode(uom.unit_of_measure,nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code), 1,
		    poa_dbi_uom_pkg.convert_neg_to_po_uom(uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code))))
		  ,
                  decode(uom.unit_of_measure,
                    pitem.primary_unit_of_measure, 1,
                    poa_dbi_uom_pkg.convert_to_item_base_uom(
                      ponip.item_id,
                      ppar.master_organization_id,
                      uom.unit_of_measure,
                      pitem.primary_uom_code
                    )
                  )
               ) neg_base_uom_conv_rate
from
      poa_dbi_pod_inc inc,
      po_distributions_all pod,
      po_line_locations_all pll,
      po_lines_all pol,
      po_headers_all poh_orig,
      pon_bid_item_prices ponbip,
      pon_bid_headers ponbh,
      pon_auction_item_prices_all ponip,
      pon_auction_headers_all ponh,
      poa_dbi_neg_po_rates neg_rates,
      financials_system_params_all pfsp,
      gl_sets_of_books pgl,
      mtl_system_items pitem,
      mtl_units_of_measure uom,
      mtl_parameters ppar,
      hz_parties hz
where
    pod.po_distribution_id = inc.primary_key
and pod.line_location_id = pll.line_location_id
and pll.po_line_id = pol.po_line_id
and pol.contract_id = poh_orig.po_header_id
and ponbh.po_header_id = poh_orig.po_header_id
and ponbh.contract_type = 'CONTRACT'
and ponbip.auction_header_id = ponbh.auction_header_id
and ponbh.auction_header_id = ponip.auction_header_id
and ponip.auction_header_id = ponh.auction_header_id
and ponbh.bid_number = ponbip.bid_number
and ponbip.auction_line_number = ponip.line_number
and ponh.org_id = pfsp.org_id
and pfsp.set_of_books_id = pgl.set_of_books_id
and pfsp.inventory_organization_id = ppar.organization_id
and ponip.item_id = pitem.inventory_item_id(+)
and ppar.master_organization_id = nvl(pitem.organization_id, ppar.master_organization_id)
and ponip.uom_code = uom.uom_code(+)
and ponh.trading_partner_contact_id = hz.party_id
and neg_rates.rate_date = nvl(trunc(ponh.rate_date), trunc(ponh.creation_date))
and neg_rates.txn_cur_code = ponh.currency_code
and neg_rates.func_cur_code = pgl.currency_code
and ponh.creation_date >= d_glob_date );
else --not initial load, change the hints for faster performance
insert /*+ APPEND */ into poa_dbi_neg_details
    (
       po_distribution_id,
       auction_header_id,
       auction_line_number,
       bid_number,
       bid_line_number,
       negotiation_creator_id,
       doctype_id,
       neg_current_price,
       neg_func_cur_code,
       neg_func_cur_conv_rate,
       neg_global_cur_conv_rate,
       neg_sglobal_cur_conv_rate,
       neg_transaction_uom,
       neg_base_uom,
       neg_base_uom_conv_rate
    )
  (  select /*+ leading(inc,pod) cardinality(inc,1) */
  pod.po_distribution_id,
  pol.auction_header_id,
  pol.auction_line_number,
  pol.bid_number,
  pol.bid_line_number,
  hz.person_identifier negotiation_creator_id,
  ponh.doctype_id,
  ponip.current_price neg_current_price,
  neg_rates.func_cur_code neg_func_cur_code,
  nvl(ponh.rate,1) neg_func_cur_conv_rate,
  neg_rates.global_cur_conv_rate neg_global_cur_conv_rate,
  neg_rates.sglobal_cur_conv_rate neg_sglobal_cur_conv_rate,
  uom.unit_of_measure neg_transaction_uom,
  decode(ponip.item_id, null, decode(pll.value_basis, 'AMOUNT',uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)), pitem.primary_unit_of_measure) neg_base_uom,
       decode(
                  ponip.item_id,
                  null,
		  decode(pll.value_basis,'AMOUNT',1,
		  decode(uom.unit_of_measure,nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code), 1,
		    poa_dbi_uom_pkg.convert_neg_to_po_uom(uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code))))
		  ,
                  decode(uom.unit_of_measure,
                    pitem.primary_unit_of_measure, 1,
                    poa_dbi_uom_pkg.convert_to_item_base_uom(
                      ponip.item_id,
                      ppar.master_organization_id,
                      uom.unit_of_measure,
                      pitem.primary_uom_code
                    )
                  )
               ) neg_base_uom_conv_rate
from
      poa_dbi_pod_inc inc,
      po_distributions_all pod,
      po_line_locations_all pll,
      po_lines_all pol,
      pon_bid_item_prices ponbip,
      pon_bid_headers ponbh,
      pon_auction_item_prices_all ponip,
      pon_auction_headers_all ponh,
      poa_dbi_neg_po_rates neg_rates,
      financials_system_params_all pfsp,
      gl_sets_of_books pgl,
      mtl_system_items pitem,
      mtl_units_of_measure uom,
      mtl_parameters ppar,
      hz_parties hz
where
    pod.po_distribution_id = inc.primary_key
and pod.line_location_id = pll.line_location_id
and pll.po_line_id = pol.po_line_id
and pol.from_header_id is null
and pol.auction_header_id = ponbip.auction_header_id
and pol.bid_number = ponbip.bid_number
and pol.auction_line_number = ponbip.auction_line_number
and pol.bid_line_number = ponbip.line_number
and ponbip.auction_header_id = ponbh.auction_header_id
and ponbh.auction_header_id = ponip.auction_header_id
and ponip.auction_header_id = ponh.auction_header_id
and ponbh.bid_number = ponbip.bid_number
and ponbip.auction_line_number = ponip.line_number
and ponh.org_id = pfsp.org_id
and ponbh.contract_type in ('STANDARD','BLANKET')
and pfsp.set_of_books_id = pgl.set_of_books_id
and pfsp.inventory_organization_id = ppar.organization_id
and ponip.item_id = pitem.inventory_item_id(+)
and ppar.master_organization_id = nvl(pitem.organization_id, ppar.master_organization_id)
and ponip.uom_code = uom.uom_code(+)
and ponh.trading_partner_contact_id = hz.party_id
and neg_rates.rate_date = nvl(trunc(ponh.rate_date), trunc(ponh.creation_date))
and neg_rates.txn_cur_code = ponh.currency_code
and neg_rates.func_cur_code = pgl.currency_code
and ponh.creation_date >= d_glob_date
UNION
select /*+ leading(inc,pod) cardinality(inc,1) */
  pod.po_distribution_id,
  pol_orig.auction_header_id,
  pol_orig.auction_line_number,
  pol_orig.bid_number,
  pol_orig.bid_line_number,
  hz.person_identifier negotiation_creator_id,
  ponh.doctype_id,
  ponip.current_price neg_current_price,
  neg_rates.func_cur_code neg_func_cur_code,
  nvl(ponh.rate,1) neg_func_cur_conv_rate,
  neg_rates.global_cur_conv_rate neg_global_cur_conv_rate,
  neg_rates.sglobal_cur_conv_rate neg_sglobal_cur_conv_rate,
  uom.unit_of_measure neg_transaction_uom,
  decode(ponip.item_id, null, decode(pll.value_basis, 'AMOUNT',uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)), pitem.primary_unit_of_measure) neg_base_uom,
       decode(
                  ponip.item_id,
                  null,
		  decode(pll.value_basis,'AMOUNT',1,
		  decode(uom.unit_of_measure,nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code), 1,
		    poa_dbi_uom_pkg.convert_neg_to_po_uom(uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code))))
		  ,
                  decode(uom.unit_of_measure,
                    pitem.primary_unit_of_measure, 1,
                    poa_dbi_uom_pkg.convert_to_item_base_uom(
                      ponip.item_id,
                      ppar.master_organization_id,
                      uom.unit_of_measure,
                      pitem.primary_uom_code
                    )
                  )
               ) neg_base_uom_conv_rate
from
      poa_dbi_pod_inc inc,
      po_distributions_all pod,
      po_line_locations_all pll,
      po_lines_all pol,
      po_headers_all poh_orig,
      po_lines_all pol_orig,
      pon_bid_item_prices ponbip,
      pon_bid_headers ponbh,
      pon_auction_item_prices_all ponip,
      pon_auction_headers_all ponh,
      poa_dbi_neg_po_rates neg_rates,
      financials_system_params_all pfsp,
      gl_sets_of_books pgl,
      mtl_system_items pitem,
      mtl_units_of_measure uom,
      mtl_parameters ppar,
      hz_parties hz
where
    pod.po_distribution_id = inc.primary_key
and pod.line_location_id = pll.line_location_id
and pll.po_line_id = pol.po_line_id
and pol.from_header_id = poh_orig.po_header_id
and pol.from_line_id = pol_orig.po_line_id
and pol_orig.po_header_id = poh_orig.po_header_id
and pol_orig.po_header_id = poh_orig.po_header_id
and pol_orig.bid_number = ponbh.bid_number
and pol_orig.bid_line_number = ponbip.line_number
and pol_orig.auction_header_id = ponh.auction_header_id
and pol_orig.auction_line_number = ponip.line_number
and ponbip.auction_header_id = ponbh.auction_header_id
and ponbh.auction_header_id = ponip.auction_header_id
and ponip.auction_header_id = ponh.auction_header_id
and ponbh.bid_number = ponbip.bid_number
and ponbip.auction_line_number = ponip.line_number
and ponh.org_id = pfsp.org_id
and ponbh.contract_type = 'BLANKET'
and pfsp.set_of_books_id = pgl.set_of_books_id
and pfsp.inventory_organization_id = ppar.organization_id
and ponip.item_id = pitem.inventory_item_id(+)
and ppar.master_organization_id = nvl(pitem.organization_id, ppar.master_organization_id)
and ponip.uom_code = uom.uom_code(+)
and ponh.trading_partner_contact_id = hz.party_id
and neg_rates.rate_date = nvl(trunc(ponh.rate_date), trunc(ponh.creation_date))
and neg_rates.txn_cur_code = ponh.currency_code
and neg_rates.func_cur_code = pgl.currency_code
and ponh.creation_date >= d_glob_date
UNION
select /*+ leading(inc,pod) cardinality(inc,1) */
  pod.po_distribution_id,
  ponbip.auction_header_id,
  ponbip.auction_line_number,
  ponbip.bid_number,
  ponbip.line_number bid_line_number,
  hz.person_identifier negotiation_creator_id,
  ponh.doctype_id,
  null neg_current_price,
  neg_rates.func_cur_code neg_func_cur_code,
  nvl(ponh.rate,1) neg_func_cur_conv_rate,
  neg_rates.global_cur_conv_rate neg_global_cur_conv_rate,
  neg_rates.sglobal_cur_conv_rate neg_sglobal_cur_conv_rate,
  uom.unit_of_measure neg_transaction_uom,
  decode(ponip.item_id, null, decode(pll.value_basis, 'AMOUNT',uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)), pitem.primary_unit_of_measure) neg_base_uom,
       decode(
                  ponip.item_id,
                  null,
		  decode(pll.value_basis,'AMOUNT',1,
		  decode(uom.unit_of_measure,nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code), 1,
		    poa_dbi_uom_pkg.convert_neg_to_po_uom(uom.unit_of_measure, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code))))
		  ,
                  decode(uom.unit_of_measure,
                    pitem.primary_unit_of_measure, 1,
                    poa_dbi_uom_pkg.convert_to_item_base_uom(
                      ponip.item_id,
                      ppar.master_organization_id,
                      uom.unit_of_measure,
                      pitem.primary_uom_code
                    )
                  )
               ) neg_base_uom_conv_rate
from
      poa_dbi_pod_inc inc,
      po_distributions_all pod,
      po_line_locations_all pll,
      po_lines_all pol,
      po_headers_all poh_orig,
      pon_bid_item_prices ponbip,
      pon_bid_headers ponbh,
      pon_auction_item_prices_all ponip,
      pon_auction_headers_all ponh,
      poa_dbi_neg_po_rates neg_rates,
      financials_system_params_all pfsp,
      gl_sets_of_books pgl,
      mtl_system_items pitem,
      mtl_units_of_measure uom,
      mtl_parameters ppar,
      hz_parties hz
where
    pod.po_distribution_id = inc.primary_key
and pod.line_location_id = pll.line_location_id
and pll.po_line_id = pol.po_line_id
and pol.contract_id = poh_orig.po_header_id
and ponbh.po_header_id = poh_orig.po_header_id
and ponbh.contract_type = 'CONTRACT'
and ponbip.auction_header_id = ponbh.auction_header_id
and ponbh.auction_header_id = ponip.auction_header_id
and ponip.auction_header_id = ponh.auction_header_id
and ponbh.bid_number = ponbip.bid_number
and ponbip.auction_line_number = ponip.line_number
and ponh.org_id = pfsp.org_id
and pfsp.set_of_books_id = pgl.set_of_books_id
and pfsp.inventory_organization_id = ppar.organization_id
and ponip.item_id = pitem.inventory_item_id(+)
and ppar.master_organization_id = nvl(pitem.organization_id, ppar.master_organization_id)
and ponip.uom_code = uom.uom_code(+)
and ponh.trading_partner_contact_id = hz.party_id
and neg_rates.rate_date = nvl(trunc(ponh.rate_date), trunc(ponh.creation_date))
and neg_rates.txn_cur_code = ponh.currency_code
and neg_rates.func_cur_code = pgl.currency_code
and ponh.creation_date >= d_glob_date );

end if;

COMMIT;


   DBMS_APPLICATION_INFO.SET_ACTION('stats rates');

     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_poa_schema,
              TABNAME => 'POA_DBI_POD_RATES') ;
   FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_poa_schema,
             TABNAME => 'POA_DBI_NEG_DETAILS') ;

   bis_collection_utilities.log('Populate base table: '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);

   select max(batch_id), COUNT(1) into l_no_batch, l_count from poa_dbi_pod_inc;
   bis_collection_utilities.log('Identified '|| l_count ||' changed records. Batch size='|| l_batch_size || '. # of Batches=' || l_no_batch
				|| '. Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);

   /* missing currency handling */

   IF (poa_currency_pkg.g_missing_cur) THEN
      poa_currency_pkg.g_missing_cur := false;
      errbuf := 'There are missing currencies\n';
      RAISE_APPLICATION_ERROR (-20000, 'Error in INC table collection: ' || errbuf);
   END IF;

   /*
   IF (l_rate = -1) THEN
      bis_collection_utilities.log('There are missing currencies '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
      RAISE_APPLICATION_ERROR (-20000, 'Error in INC table collection: ' || errbuf);
    ELSIF (l_rate = -2) THEN
      bis_collection_utilities.log('There are invalid  currencies '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
      RAISE_APPLICATION_ERROR (-20000, 'Error in INC table collection: ' || errbuf);
   END IF;
     */

   l_start_time := sysdate;
   l_login := fnd_global.login_id;
   l_user := fnd_global.user_id;
   DBMS_APPLICATION_INFO.SET_ACTION('collect');

   if (l_no_batch is NOT NULL) then
     IF (g_init) THEN
       bis_collection_utilities.log('Initial Load - populate match table. '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);

       INSERT /*+ APPEND PARALLEL(poa_dbi_pod_match_temp) */ INTO
       poa_dbi_pod_match_temp
       ( po_distribution_id,
         creation_date,
         quantity,
         unit_meas_lookup_code,
         currency_code,
         item_id,
         ship_to_location_id,
         org_id,
         need_by_date,
         func_cur_code,
         rate_date,
         ship_to_ou_id,
         category_id,
         ship_to_organization_id
       )
       SELECT /*+ PARALLEL(inc) PARALLEL(pod) PARALLEL(pll) PARALLEL(pol)
                  PARALLEL(poh) use_hash(pod) use_hash(pll) use_hash(pol)
                  use_hash(poh) use_hash(match) */
       pod.po_distribution_id,
       pod.creation_date,
       pll.quantity,
       nvl(pll.unit_meas_lookup_code,pol.unit_meas_lookup_code),
       poh.currency_code,
       pol.item_id,
       pll.ship_to_location_id,
       poh.org_id,
       pll.need_by_date,
       inc.func_cur_code,
       nvl(pod.rate_date, pod.creation_date),
       match.ship_to_ou_id,
       pol.category_id,
       pll.ship_to_organization_id
       FROM
       poa_dbi_pod_inc       inc,
       po_distributions_all  pod,
       po_line_locations_all pll,
       po_lines_all          pol,
       po_headers_all        poh,
       po_doc_style_headers  style,
       ( SELECT /*+ PARALLEL(pod) PARALLEL(psc) PARALLEL(plc) PARALLEL(inc)
                    PARALLEL(ga) no_merge use_hash(pod) use_hash(psc)
                    use_hash(plc) use_hash(v1) use_hash(ga) use_hash(pgoa)
                    use_hash(hro) */
         distinct
         pod.po_distribution_id,
         hro.ship_to_ou_id
         FROM
         po_distributions_all        pod,
         po_line_locations_all       psc,
         po_lines_all                plc,
         poa_dbi_pod_inc             inc,
         po_headers_all              ga,
        (select /*+ no_merge */ to_number(hro.org_information3) ship_to_ou_id,organization_id
        from hr_organization_information hro where
           hro.org_information_context='Accounting Information') hro,
         ( SELECT /*+ PARALLEL(pl) PARALLEL(ph) no_merge use_hash(ph, pl) */
           pl.item_id,
           ph.start_date,
           ph.end_date,
           pl.expiration_date,
           ph.org_id,
           ph.global_agreement_flag,
           ph.po_header_id,
           pl.creation_date
           FROM
           po_lines_all pl,
           po_headers_all ph
           WHERE ph.type_lookup_code = 'BLANKET'
           and   pl.price_break_lookup_code is not null
           AND   ph.approved_flag IN ('Y', 'R')
           and   ph.po_header_id = pl.po_header_id
           and   nvl(ph.cancel_flag, 'N') = 'N'
           and   nvl(pl.cancel_flag, 'N') = 'N'
         ) v1,
         ( select /*+ no_merge parallel(pgoa) */
           distinct po_header_id, purchasing_org_id
           from po_ga_org_assignments pgoa
           where enabled_flag = 'Y'
         ) pgoa
         WHERE plc.po_line_id          = psc.po_line_id
         and   psc.line_location_id    = pod.line_location_id
         and   psc.shipment_type       = 'STANDARD'
         and   plc.from_header_id      = ga.po_header_id(+)
         and   nvl(ga.global_agreement_flag, 'N') = 'N'
         and   psc.approved_flag       = 'Y'
         and   plc.item_id             is not null
         and   pod.creation_date       is not null
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   v1.item_id              = plc.item_id
         AND   inc.primary_key         = pod.po_distribution_id
         and   v1.po_header_id         = pgoa.po_header_id (+)
         and   to_number(hro.organization_id) = psc.ship_to_organization_id
         and   (
                 ( pgoa.purchasing_org_id in
                   ( select /*+ ordered no_merge parallel(tfh) parallel(fsp1) parallel(fsp2) use_hash(tfh) use_hash(fsp1) use_hash(fsp2) */ tfh.start_org_id
                     from
                     mtl_procuring_txn_flow_hdrs_v tfh,
                     financials_system_params_all fsp1,
                     financials_system_params_all fsp2
                     where pod.creation_date between nvl(tfh.start_date, pod.creation_date) and nvl(tfh.end_date, pod.creation_date)
                     and fsp1.org_id = tfh.start_org_id
                     and fsp1.purch_encumbrance_flag = 'N'
                     and fsp2.org_id = tfh.end_org_id
                     and fsp2.purch_encumbrance_flag = 'N'
                     and tfh.end_org_id = hro.ship_to_ou_id
                     and ((tfh.qualifier_code is null) or (tfh.qualifier_code = 1 and tfh.qualifier_value_id = plc.category_id))
                     and ((tfh.organization_id is null) or (tfh.organization_id = psc.ship_to_organization_id))
                   )
                 )
                 or (nvl(pgoa.purchasing_org_id,hro.ship_to_ou_id) = hro.ship_to_ou_id )
               )
         and   (
                 ( v1.org_id = hro.ship_to_ou_id
                   and nvl(v1.global_agreement_flag, 'N') = 'N'
                 )
                 or
                 ( v1.global_agreement_flag = 'Y'
                   and pgoa.purchasing_org_id is not null
                 )
               )
         and   Trunc(pod.creation_date) between nvl(v1.start_date, Trunc(pod.creation_date))
         and   nvl(v1.end_date, pod.creation_date)
         and   pod.creation_date >= v1.creation_date
         and   Trunc(pod.creation_date) <= nvl(v1.expiration_date, pod.creation_date)
       ) match
       WHERE inc.primary_key  = pod.po_distribution_id
       AND   poh.po_header_id        = pol.po_header_id
       and   pol.po_line_id          = pll.po_line_id
       and   pll.line_location_id    = pod.line_location_id
       and   poh.style_id            = style.style_id
       and   nvl(style.progress_payment_flag,'N') = 'N'
       and   pll.approved_flag       = 'Y'
       and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
       and   pod.creation_date       is not NULL
       and   inc.primary_key         = match.po_distribution_id;

      COMMIT;

      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_poa_schema,
              			   TABNAME => 'POA_DBI_POD_MATCH_TEMP') ;

      bis_collection_utilities.log('Initial Load - populate lowest price table. '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);

      INSERT /*+ APPEND PARALLEL(t) */ INTO poa_dbi_pod_lowest_all_temp t(po_distribution_id, po_header_id, shipto_price, generic_price, unit_price)
      WITH bb AS (
				select /*+ PARALLEL(b) PARALLEL(ptmp) PARALLEL(std) PARALLEL(poa_gl) PARALLEL(fsp) no_merge leading(ptmp) use_hash(l, b, pgoa, std) */
				distinct ptmp.po_distribution_id,ptmp.creation_date,ptmp.ship_to_location_id, ptmp.item_id, ptmp.unit_meas_lookup_code,
                                b.po_header_id,b.amount_limit,b.min_release_amount b_min_release_amount, b.global_agreement_flag, b.vendor_id,
                                l.po_line_id, l.item_id b_item_id, l.unit_meas_lookup_code b_unit_meas_lookup_code,  l.cancel_flag, l.expiration_date, l.price_break_lookup_code, l.unit_price, l.min_release_amount bl_min_release_amount,
                                l.creation_date bl_creation_date,
				nvl(std.po_line_id, l.po_line_id) std_id,
                                poa_gl.currency_code bl_func_cur_code, b.rate bl_rate
				from 	po_headers_all b,
				poa_dbi_pod_match_temp ptmp,
                                po_lines_all std,
				(select  /*+ PARALLEL(bl) no_merge */ bl.po_header_id, bl.item_id, bl.unit_meas_lookup_code,bl.expiration_date, bl.po_line_id, bl.min_release_amount, bl.unit_price, bl.cancel_flag, bl.price_break_lookup_code, bl.creation_date
				 from	po_lines_all bl
				 where 	bl.price_break_lookup_code is not null
				 and 	nvl(bl.cancel_flag, 'N') = 'N'
				 ) l,
                                (select /*+ PARALLEL(pgoa) no_merge */ distinct po_header_id, purchasing_org_id
                                 from po_ga_org_assignments pgoa
                                 where enabled_flag = 'Y') pgoa,
                                financials_system_params_all fsp, -- to get the functional currency of the blanket agreement
                                gl_sets_of_books poa_gl
				where l.po_header_id = b.po_header_id
				and l.item_id = ptmp.item_id
				and l.unit_meas_lookup_code = ptmp.unit_meas_lookup_code
				and Trunc(ptmp.creation_date) <= nvl(l.expiration_date, ptmp.creation_date)
                                and ptmp.creation_date >= l.creation_date
				and b.type_lookup_code = 'BLANKET'
				and b.approved_flag in ('Y','R')
				and nvl(b.cancel_flag, 'N') = 'N'
                                and b.po_header_id = pgoa.po_header_id (+)
                                and b.org_id = fsp.org_id
                                and fsp.set_of_books_id = poa_gl.set_of_books_id
                                and ((pgoa.purchasing_org_id in
                                    (select /*+ ordered PARALLEL(tfh) PARALLEL(fsp1) PARALLEL(fsp2) no_merge use_hash(tfh) use_hash(fsp1) use_hash(fsp2) */ tfh.start_org_id
                                       from mtl_procuring_txn_flow_hdrs_v tfh,
                                            financials_system_params_all fsp1,
                                            financials_system_params_all fsp2
                                       where ptmp.creation_date between nvl(tfh.start_date, ptmp.creation_date) and nvl(tfh.end_date, ptmp.creation_date)
                                       and fsp1.org_id = tfh.start_org_id
                                       and fsp1.purch_encumbrance_flag = 'N'
                                       and fsp2.org_id = tfh.end_org_id
                                       and fsp2.purch_encumbrance_flag = 'N'
                                       and tfh.end_org_id = ptmp.ship_to_ou_id
                                       and ((tfh.qualifier_code is null) or (tfh.qualifier_code = 1 and tfh.qualifier_value_id = ptmp.category_id))
                                       and ((tfh.organization_id is null) or (tfh.organization_id = ptmp.ship_to_organization_id))
                                    )
                                  )
                                  or (nvl(pgoa.purchasing_org_id, ptmp.ship_to_ou_id) = ptmp.ship_to_ou_id))
                                and ((ptmp.ship_to_ou_id = b.org_id and nvl(b.global_agreement_flag, 'N') = 'N')
                                    or
                                    (b.global_agreement_flag = 'Y' and pgoa.purchasing_org_id is not null))
				and Trunc(ptmp.creation_date) between nvl(b.start_date, Trunc(ptmp.creation_date)) AND nvl(b.end_date, ptmp.creation_date)
                                and l.po_line_id = std.from_line_id (+)
       )
         select po_distribution_id,
                 po_header_id,
              min(price1 * cur_conversion_rate) keep (dense_rank first order by nvl2(price1, nvl(quantity, 0), null) desc nulls last, trunc(creation_date) desc) price1,
              min(price2 * cur_conversion_rate) keep (dense_rank first order by nvl2(price1, nvl(quantity, 0), null) desc nulls last, trunc(creation_date) desc) price2,
              min(unit_price * cur_conversion_rate) unit_price
           from (
              select /*+ PARALLEL(blanket) PARALLEL(bblanket) PARALLEL(ptmp3) PARALLEL(pb) ORDERED use_hash(blanket bblanket ptmp3 pb) */
              ptmp3.po_distribution_id,
              ptmp3.quantity dist_quantity,
	      blanket.po_line_id,
              blanket.line_all_qty,
	      pb.line_location_id,
	      blanket.line_qty,
	      pb.price_override,
	      unit_price,
	      pb.ship_to_location_id,
	      price_break_lookup_code,
	      blanket.amount_limit,
	      blanket.b_min,
	      bl_min,
	      pb.quantity,
	      blanket.b_item_id,
              pb.creation_date,
              blanket.po_header_id,
              blanket.vendor_id
              , nvl(blanket.bl_rate, 1) * decode(blanket.bl_func_cur_code, ptmp3.func_cur_code, 1, poa_ga_util_pkg.get_ga_conversion_rate(blanket.bl_func_cur_code, ptmp3.func_cur_code, ptmp3.rate_date)) cur_conversion_rate
                   -- convert to blanket functional currency and then to standard PO functional currency
	      ,(case when pb.ship_to_location_id = ptmp3.ship_to_location_id
		and ( pb.quantity is null or ( price_break_lookup_code = 'NON CUMULATIVE' and ptmp3.quantity >= pb.quantity)
		      or (price_break_lookup_code = 'CUMULATIVE' and ptmp3.quantity + blanket.line_qty >= pb.quantity))
		then pb.price_override else null end) price1
	      ,(case when pb.line_location_id is not null and pb.ship_to_location_id is null
		and (pb.quantity is null or (price_break_lookup_code = 'NON CUMULATIVE' and ptmp3.quantity >= pb.quantity)
		     or (price_break_lookup_code = 'CUMULATIVE' and ptmp3.quantity + blanket.line_all_qty >= pb.quantity))
	   	then pb.price_override else null end) price2
	      from
		(
		   select /*+ PARALLEL(rll) PARALLEL(rd) no_merge leading(b) use_hash(rll, rd) */
		   b.po_distribution_id, b.creation_date, b.po_header_id, b.vendor_id, b.amount_limit, b.b_min_release_amount b_min, b.global_agreement_flag,
                   b.po_line_id, b.b_item_id, b.b_unit_meas_lookup_code,
		   b.cancel_flag, b.expiration_date, b.price_break_lookup_code, b.unit_price, b.bl_min_release_amount bl_min, b.bl_creation_date, b.bl_func_cur_code, b.bl_rate
		   ,sum(case when rll.approved_flag='Y' and rll.ship_to_location_id = b.ship_to_location_id
			    and rd.creation_date < b.creation_date
                            then
			    nvl(rd.quantity_ordered,0)-nvl(rd.quantity_cancelled,0) else 0 END) line_qty
		   ,sum(case when rll.approved_flag='Y' and rd.creation_date < b.creation_date then
			    nvl(rd.quantity_ordered,0)-nvl(rd.quantity_cancelled,0) else 0 end)	line_all_qty
		   from bb b
		       ,po_line_locations_all rll
	               ,po_distributions_all rd
		   where        b.std_id = rll.po_line_id(+)
		     and 	rll.line_location_id = rd.line_location_id(+)
                     and        nvl(rd.distribution_type,'-99') <> 'AGREEMENT'
		     and 	(rll.shipment_type is null or rll.shipment_type in ('BLANKET', 'STANDARD', 'PRICE BREAK'))
		   GROUP by b.po_distribution_id, b.po_line_id, b.po_header_id, b.creation_date, b.vendor_id, b.global_agreement_flag,
		   b.b_item_id, b.bl_min_release_amount, b.b_unit_meas_lookup_code, b.cancel_flag,
		   b.expiration_date, b.price_break_lookup_code, b.unit_price,b.amount_limit, b.b_min_release_amount, b.bl_creation_date, b.bl_func_cur_code, b.bl_rate
                  ) blanket,
		  (
		   select /*+ PARALLEL(rll) PARALLEL(rd) no_merge leading(b) use_hash(rll, rd) */
		   b.po_distribution_id, b.po_header_id,
                   sum(case when rd.creation_date < b.creation_date then
                     nvl(rll.price_override,0) * (nvl(rd.quantity_ordered,0)-nvl(rd.quantity_cancelled,0)) else 0 END) blanket_amt
		   from bb b
		       ,po_line_locations_all rll
	               ,po_distributions_all rd
		   where        b.std_id = rll.po_line_id(+)
		     and 	rll.line_location_id = rd.line_location_id(+)
                     and        nvl(rd.distribution_type,'-99') <> 'AGREEMENT'
		     and 	(rll.shipment_type is null or rll.shipment_type in ('BLANKET', 'STANDARD', 'PRICE BREAK'))
		   GROUP by b.po_distribution_id, b.po_header_id
		   ) bblanket,
		poa_dbi_pod_match_temp ptmp3,
		po_line_locations_all pb
  	     where blanket.po_distribution_id = ptmp3.po_distribution_id
                and blanket.po_distribution_id = bblanket.po_distribution_id
                and blanket.po_header_id = bblanket.po_header_id
		and blanket.b_item_id = ptmp3.item_id
		and blanket.b_unit_meas_lookup_code = ptmp3.unit_meas_lookup_code
		and nvl(blanket.cancel_flag, 'N') = 'N'
		and Trunc(blanket.creation_date) <= nvl(blanket.expiration_date, blanket.creation_date)
                and blanket.creation_date >= blanket.bl_creation_date
		and pb.po_line_id(+) = blanket.po_line_id
		and pb.shipment_type(+) = 'PRICE BREAK'
		and nvl(pb.cancel_flag, 'N') = 'N'
                and trunc(nvl(ptmp3.need_by_date, ptmp3.creation_date)) between
                     trunc(nvl(pb.start_date, nvl(pb.creation_date, nvl(ptmp3.need_by_date, ptmp3.creation_date)))) and
                     nvl(pb.end_date, nvl(ptmp3.need_by_date, ptmp3.creation_date))
		and ptmp3.quantity * nvl(pb.price_override,unit_price) >= nvl(blanket.bl_min,0)
		and ptmp3.quantity * nvl(pb.price_override,unit_price) >= nvl(blanket.b_min,0)
		and (blanket.amount_limit is null or ptmp3.quantity * nvl(pb.price_override,unit_price) + bblanket.blanket_amt
				   <= blanket.amount_limit)
	)
	group by po_distribution_id  ,po_line_id, po_header_id;

        COMMIT;

      	FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_poa_schema,
              			     TABNAME => 'POA_DBI_POD_LOWEST_ALL_TEMP') ;

        insert /*+ APPEND PARALLEL(t) */ into poa_dbi_pod_lowest_price_temp t(po_distribution_id,
                                                    lowest_price,
                                                    potential_contract_id)
        select po_distribution_id,
               coalesce(min(shipto_price), min(generic_price), min(unit_price)) lowest_price,
               coalesce(min(nvl2(shipto_price, po_header_id, null)) keep (dense_rank first order by shipto_price nulls last) ,
                        min(nvl2(generic_price, po_header_id, null)) keep (dense_rank first order by generic_price nulls last) ,
                        min(po_header_id) keep (dense_rank first order by unit_price nulls last) ) potential_contract_id from
        poa_dbi_pod_lowest_all_temp
        group by po_distribution_id;

        COMMIT;

      	FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_poa_schema,
              			     TABNAME => 'POA_DBI_POD_LOWEST_PRICE_TEMP') ;

 	bis_collection_utilities.log('Initial Load - using one batch approach, populate base fact. '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
      INSERT /*+ APPEND PARALLEL(t) */ INTO
      poa_dbi_pod_f t
      (
        t.po_distribution_id,
        t.po_header_id,
        t.po_line_id,
        t.po_release_id,
        t.creation_operating_unit_id,
        t.ship_to_org_id,
        t.approved_date,
        t.distribution_creation_date,
        t.supplier_id,
        t.supplier_site_id,
        t.po_item_id,
        t.category_id,
        t.buyer_id,
        t.code_combination_id,
        t.func_cur_code,
        t.global_cur_conv_rate,
        t.base_uom_conv_rate,
        t.purchase_amount_b,
        t.contract_amount_b,
        t.non_contract_amount_b,
        t.pot_contract_amount_b,
        t.pot_savings_amount_b,
        t.unit_price,
        t.quantity,
        t.creation_mode,
        t.order_type,
        t.catalog_type,
        t.destination_type_code,
        t.amt_billed,
        t.amt_financed,
        t.amt_recouped,
        t.qty_billed,
        t.qty_financed,
        t.qty_recouped,
        t.qty_cancelled,
        t.potential_contract_id,
        t.shipment_type,
        t.apps_source_code,
        t.from_document_type,
        t.from_document_id,
        t.consigned_code,
        t.base_uom,
        t.transaction_uom,
        t.requestor_id,
        t.start_date_active,
        t.last_update_login,
        t.creation_date,
        t.last_updated_by,
        t.last_update_date,
        t.func_cur_conv_rate,
        t.sglobal_cur_conv_rate,
        t.expected_date,
        t.days_late_receipt_allowed,
        t.days_early_receipt_allowed,
        t.price_override,
        t.line_location_id,
        t.item_id,
        t.matching_basis,
        t.receiving_routing_id,
        t.company_id,
        t.cost_center_id,
        t.payment_type,
        t.complex_work_flag,
---Begin Changes for Item Avg Price
        t.non_zero_quantity,
---End Changes for Item Avg Price
       t.auction_header_id,
       t.auction_line_number,
       t.bid_number,
       t.bid_line_number,
       t.negotiation_creator_id,
       t.doctype_id,
        t.neg_current_price,
        t.neg_func_cur_code,
        t.neg_func_cur_conv_rate,
        t.neg_global_cur_conv_rate,
        t.neg_sglobal_cur_conv_rate,
        t.neg_transaction_uom,
        t.neg_base_uom,
        t.neg_base_uom_conv_rate,
       t.negotiated_by_preparer_flag
      )
      SELECT
      s.po_distribution_id,
      s.po_header_id,
      s.po_line_id,
      s.po_release_id,
      s.org_id,
      s.ship_to_organization_id,
      s.approved_date,
      s.creation_date,
      s.vendor_id,
      s.vendor_site_id,
      s.po_item_id,
      s.category_id,
      s.agent_id,
      s.code_combination_id,
      s.currency_code,
      s.global_cur_conv_rate,
      s.base_uom_conv_rate,
      s.purchase_amount,
      decode(s.prepayment_flag,'Y',0,s.contract_amount) contract_amount,
      decode(s.prepayment_flag,'Y',0,s.non_contract_amount) non_contract_amount,
      decode(s.prepayment_flag,'Y',0,s.pot_contract_amount) pot_contract_amount,
      decode(s.prepayment_flag,'Y',0,s.pot_savings_amount) pot_savings_amount,
      s.price_override / s.base_uom_conv_rate,
      s.quantity * s.base_uom_conv_rate,
      s.creation_mode,
      s.order_type,
      s.catalog_type,
      s.destination_type_code,
      s.amount_billed,
      s.amount_financed,
      s.amount_recouped,
      s.quantity_billed * s.base_uom_conv_rate,
      s.quantity_financed * s.base_uom_conv_rate,
      s.quantity_recouped * s.base_uom_conv_rate,
      s.quantity_cancelled * s.base_uom_conv_rate,
      s.potential_contract_id,
      s.shipment_type,
      s.apps_source_code,
      s.from_document_type,
      s.from_document_id,
      s.consigned_code,
      s.base_uom,
      s.transaction_uom,
      s.requestor_id,
      s.current_time, -- not sure if this is what it means
      s.login_id,
      s.current_time,
      s.user_id,
      s.current_time,
      s.func_cur_conv_rate,
      s.sglobal_cur_conv_rate,
      s.expected_date,
      s.days_late_receipt_allowed,
      s.days_early_receipt_allowed,
      s.price_override,
      s.line_location_id,
      s.item_id,
      s.matching_basis,
      s.receiving_routing_id,
      s.company_id,
      s.cost_center_id,
      s.payment_type,
      s.complex_work_flag,
---Begin Changes for Item Avg Price
      s.non_zero_quantity * s.base_uom_conv_rate,
---End Changes for Item Avg Price
      s.auction_header_id,
      s.auction_line_number,
      s.bid_number,
      s.bid_line_number,
      s.negotiation_creator_id,
      s.doctype_id,
      s.neg_current_price / s.neg_base_uom_conv_rate,
      s.neg_func_cur_code,
      s.neg_func_cur_conv_rate,
      s.neg_global_cur_conv_rate,
      s.neg_sglobal_cur_conv_rate,
      s.neg_transaction_uom,
      s.neg_base_uom,
      s.neg_base_uom_conv_rate,
      s.negotiated_by_preparer_flag
      FROM
      ( SELECT /*+ PARALLEL(inc) PARALLEL(pll) PARALLEL(pol) PARALLEL(poh)
                   PARALLEL(prl) PARALLEL(prd) PARALLEL(low) PARALLEL(match)
                   PARALLEL(item) PARALLEL(por) PARALLEL(ref) PARALLEL(prh)
                   PARALLEL(par) PARALLEL(poa_gl) PARALLEL(fsp)
                   NO_MERGE  USE_HASH(poh) use_hash(pol) use_hash(item)
                   use_hash(prl) use_hash(prd) */
        pod.po_distribution_id,
        poh.po_header_id,
        pol.po_line_id,
        pod.po_release_id,
        pll.org_id,
        pll.ship_to_organization_id,
        -- Trunc(NVL(POA_OLTP_GENERIC_PKG.get_approved_date_pll(pod.creation_date, pll.line_location_id), pll.approved_date)) approved_date,
        Trunc(nvl(pod.approved_date,pll.approved_date)) approved_date,
        Trunc(pod.creation_date) creation_date,
        poh.vendor_id,
        poh.vendor_site_id,
        poa_dbi_items_pkg.getitemkey(pol.item_id, par.master_organization_id, pol.category_id,
                     pol.vendor_product_num, poh.vendor_id, pol.item_description) po_item_id,
        pol.category_id,
        decode(por.po_release_id, null, poh.agent_id, por.agent_id) agent_id,
        pod.code_combination_id, -- not used for now
        Nvl(poa_gl.currency_code, 'DBI_ERR') CURRENCY_CODE,
        rat.GLOBAL_CUR_CONV_RATE,
        decode(pol.item_id, null, 1, decode(nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code), item.primary_unit_of_measure, 1,
          poa_dbi_uom_pkg.convert_to_item_base_uom(pol.item_id, par.master_organization_id, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code) ,item.primary_uom_code ))) base_uom_conv_rate,
        decode(pll.matching_basis,
               'AMOUNT',
               Nvl(pod.amount_ordered,0) - Nvl(pod.amount_cancelled,0),
               (Nvl(pod.quantity_ordered,0) - Nvl(pod.quantity_cancelled,0)) * Nvl(pll.price_override,0)
              ) purchase_amount,
        ( case
          when (nvl(pol.negotiated_by_preparer_flag,'N')='Y') then
            decode(
              pll.matching_basis,
              'AMOUNT',
              nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0),
              (nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0)) * nvl(pll.price_override,0)
            )
          else 0 end
        ) contract_amount,
        ( case
          when (nvl(pol.negotiated_by_preparer_flag,'N')='N') then
            decode(
              pll.matching_basis,
              'AMOUNT',
              nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0),
              (nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0)) * nvl(pll.price_override,0)
            )
          else 0 end
        ) non_contract_amount,
        (CASE WHEN (pol.item_id IS NOT NULL
                    AND pll.shipment_type = 'STANDARD'
                    AND (nvl(ref.global_agreement_flag, 'N') = 'N')
                    AND match.po_distribution_id IS NOT null
                    and nvl(pol.negotiated_by_preparer_flag,'N')='N')
         THEN  ((Nvl(pod.quantity_ordered,0) - Nvl(pod.quantity_cancelled,0)) * Nvl(pll.price_override,0))
         ELSE 0 END) pot_contract_amount,
        (CASE WHEN (pol.item_id IS NOT NULL
                    AND pll.shipment_type = 'STANDARD'
                    AND (nvl(ref.global_agreement_flag, 'N') = 'N')
                    AND match.po_distribution_id IS NOT null
                    AND nvl(pol.negotiated_by_preparer_flag,'N') = 'N')
         THEN  ((Nvl(pod.quantity_ordered,0) - Nvl(pod.quantity_cancelled,0))
            * (Nvl(pll.price_override,0) - Nvl(low.lowest_price/nvl(pod.rate,1), Nvl(pll.price_override,0))
               ))  ELSE 0 END ) pot_savings_amount, -- lowest price is already in the transactional currency of the PO
        pll.price_override,
        ( case
          when pll.value_basis = 'QUANTITY' then
            nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0)
          else null end
        ) quantity,
        null creation_mode, -- Automatic/Manual Manishas API not used for now
        pll.value_basis order_type,
        prl.catalog_type, -- not used for now
        pod.destination_type_code,
        pod.amount_billed,
        decode(
          pll.matching_basis,
          'AMOUNT',
          nvl(pod.amount_financed,0),
          (nvl(pod.quantity_financed,0) * nvl(pll.price_override,0))
        ) amount_financed,
        decode(
          pll.matching_basis,
          'AMOUNT',
          nvl(pod.amount_recouped,0),
          (nvl(pod.quantity_recouped,0) * nvl(pll.price_override,0))
        ) amount_recouped,
        ( case
          when pll.value_basis = 'QUANTITY' then
            pod.quantity_billed
          else null end
        ) quantity_billed,
        ( case
          when pll.value_basis = 'QUANTITY' then
            pod.quantity_financed
          else null end
        ) quantity_financed,
        ( case
          when pll.value_basis = 'QUANTITY' then
            pod.quantity_recouped
          else null end
        ) quantity_recouped,
        ( case
          when pll.matching_basis = 'QUANTITY' then
            pod.quantity_cancelled
          else null end
        ) quantity_cancelled,
        low.potential_contract_id,
        pll.shipment_type,
        nvl(prh.apps_source_code, 'PO') apps_source_code,
        ref.type_lookup_code from_document_type,
        pol.from_header_id from_document_id,
        (case when (pll.consigned_flag = 'Y') then 1
              when ((por.consigned_consumption_flag = 'Y') or (poh.consigned_consumption_flag = 'Y')) then 2 else 0 end) consigned_code,
        (case when pll.value_basis = 'QUANTITY'
               then decode(pol.item_id, null, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code), item.primary_unit_of_measure)
               else null
         end) base_uom,
        (case when pll.value_basis = 'QUANTITY'
               then nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)
               else null
        end) transaction_uom,
        prl.to_person_id requestor_id,
        l_start_time current_time,
        l_login login_id,
        l_user user_id,
        nvl(pod.rate,1) func_cur_conv_rate,
        rat.sglobal_cur_conv_rate,
        Nvl(pll.promised_date, pll.need_by_date) expected_date,
        Nvl(pll.days_late_receipt_allowed, 0)  days_late_receipt_allowed,
        Nvl(pll.days_early_receipt_allowed, 0) days_early_receipt_allowed,
        pll.line_location_id,
        pol.item_id,
        pll.matching_basis,
        pll.receiving_routing_id,
        ccid.company_id,
        ccid.cost_center_id,
        pll.payment_type,
        ( case
          when nvl(style.progress_payment_flag,'N') = 'N' then 'N'
          else  'Y' end
        ) complex_work_flag,
        decode(pll.shipment_type, 'PREPAYMENT','Y','N') prepayment_flag,
---Begin Changes for Item Avg Price for computing non-zero price quantity
        decode(nvl(pll.price_override,0),0, 0, case when pll.value_basis =
                   'QUANTITY' then nvl(pod.quantity_ordered,0) -
                    nvl(pod.quantity_cancelled,0) else null end ) non_zero_quantity,
---End Changes for Item Avg Price
        negd.auction_header_id,
        negd.auction_line_number,
	negd.bid_number,
	negd.bid_line_number,
	nvl(negd.negotiation_creator_id,-1) negotiation_creator_id,
	nvl(negd.doctype_id,-1) doctype_id,
	negd.neg_current_price,
	negd.neg_func_cur_code,
	negd.neg_func_cur_conv_rate,
	negd.neg_global_cur_conv_rate,
	negd.neg_sglobal_cur_conv_rate,
	negd.neg_transaction_uom,
	negd.neg_base_uom,
	negd.neg_base_uom_conv_rate,
        nvl(pol.negotiated_by_preparer_flag,'N') negotiated_by_preparer_flag
        FROM
        poa_dbi_pod_inc   inc,
        poa_dbi_neg_details negd,
	poa_dbi_pod_rates rat,
        po_doc_style_headers style,
        gl_sets_of_books  poa_gl,
        ( select /*+ PARALLEL(a) PARALLEL(pod) NO_MERGE */
          pod.po_distribution_id,
          pod.creation_date,
          pod.req_distribution_id,
          pod.line_location_id,
          pod.org_id,
          pod.po_release_id,
          pod.code_combination_id,
          pod.set_of_books_id,
          pod.quantity_ordered,
          pod.quantity_cancelled,
          pod.amount_billed,
          pod.amount_financed,
          pod.amount_recouped,
          pod.quantity_billed,
          pod.quantity_financed,
          pod.quantity_recouped,
          pod.destination_type_code,
          pod.rate,
          min(approved_date) approved_date,
          pod.amount_ordered,
          pod.amount_cancelled
          from
          po_line_locations_archive_all a,
          po_distributions_all pod
          where pod.line_location_id = a.line_location_id(+)
          and   a.approved_date(+) >= pod.creation_date
          and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
          group by
          pod.po_distribution_id,
          pod.creation_date,
          pod.req_distribution_id,
          pod.line_location_id,
          pod.org_id,
          pod.po_release_id,
          pod.code_combination_id,
          pod.set_of_books_id,
          pod.quantity_ordered,
          pod.quantity_cancelled,
          pod.amount_billed,
          pod.amount_financed,
          pod.amount_recouped,
          pod.quantity_billed,
          pod.quantity_financed,
          pod.quantity_recouped,
          pod.destination_type_code,
          pod.rate,
          pod.amount_ordered,
          pod.amount_cancelled
        ) pod,
        po_line_locations_all         pll,
        po_lines_all                  pol,
        po_headers_all                poh,
        po_requisition_lines_all      prl,
        po_req_distributions_all      prd,
        financials_system_params_all  fsp,
        poa_dbi_pod_lowest_price_temp low,
        poa_dbi_pod_match_temp        match,
        mtl_system_items              item,
        po_releases_all               por,
        po_headers_all                ref,
        po_requisition_headers_all    prh,
        mtl_parameters                par,
        fii_gl_ccid_dimensions        ccid,
        pon_auction_headers_all       ponh
        WHERE inc.primary_key         = pod.PO_DISTRIBUTION_ID
        and   inc.func_cur_code       = rat.func_cur_code
        and   inc.rate_date           = rat.rate_date
        and   inc.txn_cur_code        = rat.txn_cur_code
        and   poh.po_header_id        = pol.po_header_id
        and   poh.style_id            = style.style_id
        and   pol.po_line_id          = pll.po_line_id
        and   por.po_release_id (+)   = pll.po_release_id
        and   ref.po_header_id (+)    = pol.from_header_id
        and   pll.line_location_id    = pod.line_location_id
        and   poa_gl.set_of_books_id  = pod.set_of_books_id
        and   pod.org_id              = fsp.org_id
        AND   pod.req_distribution_id = prd.distribution_id(+)
        and   prd.requisition_line_id = prl.requisition_line_id(+)
        and   prl.requisition_header_id = prh.requisition_header_id(+)
        and   pll.approved_flag       = 'Y'
        and   pod.creation_date       is not null
        AND   inc.primary_key         = match.po_distribution_id(+)
        AND   inc.primary_key         = low.po_distribution_id(+)
        and   inc.primary_key         = negd.po_distribution_id(+) /* Check for presence of Auction Details */
        and   fsp.inventory_organization_id = par.organization_id
        and   pol.auction_header_id   = ponh.auction_header_id(+)
        and   item.inventory_item_id(+) = pol.item_id
        and   par.master_organization_id = nvl(item.organization_id, par.master_organization_id)
        and   pod.code_combination_id = ccid.code_combination_id(+)
      ) s;
    COMMIT;
    else

      FOR v_batch_no IN 1..l_no_batch LOOP
	 bis_collection_utilities.log('batch no='||v_batch_no || ' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 1);

     merge INTO poa_dbi_pod_f T
     using
     (
       SELECT /*+  cardinality(inc,1) */
       pod.po_distribution_id,
       poh.po_header_id,
       pol.po_line_id,
       pll.line_location_id,
       pod.po_release_id,
       pll.org_id ,
       pll.ship_to_organization_id ,
       pll.approved_date approved_date,
       /* important that we are using pll.approved_date.  In case of archiving on print, poh/por level approved_date
          may not be present.  This is the true earliest approval date at distribution level */
       pod.creation_date creation_date,
       poh.vendor_id,
       poh.vendor_site_id,
       poa_dbi_items_pkg.getitemkey(pol.item_id, par.master_organization_id, pol.category_id,
                             pol.vendor_product_num, poh.vendor_id, pol.item_description) po_item_id,
       pol.category_id,
       decode(por.po_release_id, null, poh.agent_id, por.agent_id) agent_id,
       pod.code_combination_id, -- not used for now
       Nvl(poa_gl.currency_code, 'DBI_ERR') CURRENCY_CODE,
       --Nvl(pod.rate, 1) FUNC_CUR_CONV_RATE,
       /* poa_dbi_currency_pkg.get_global_currency_rate(poh.rate_type, poh.currency_code, NVL(pod.rate_date,
            pod.creation_date), pod.rate) GLOBAL_CUR_CONV_RATE, */
       rat.GLOBAL_CUR_CONV_RATE,
       decode(pol.item_id, null, 1,  poa_dbi_uom_pkg.convert_to_item_base_uom(pol.item_id, par.master_organization_id, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code))) base_uom_conv_rate,
       (case when pll.matching_basis = 'AMOUNT'
             then (Nvl(pod.amount_ordered,0) - Nvl(pod.amount_cancelled,0))
             else (Nvl(pod.quantity_ordered,0) - Nvl(pod.quantity_cancelled,0)) * Nvl(pll.price_override,0)
        end) purchase_amount,
       ( case when nvl(pol.negotiated_by_preparer_flag,'N') = 'Y'
              then decode(pll.matching_basis,'AMOUNT',
                          nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0),
                          (nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0)) * nvl(pll.price_override,0))
              else 0
         end
       ) contract_amount,
       ( case when nvl(pol.negotiated_by_preparer_flag,'N') = 'N'
              then decode(pll.matching_basis, 'AMOUNT',
                          nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0),
                          (nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0)) * nvl(pll.price_override,0))
              else 0
         end
       ) non_contract_amount,
       (CASE WHEN (pol.item_id IS NOT NULL
                   AND pll.shipment_type = 'STANDARD'
                   AND (nvl(ref.global_agreement_flag, 'N') = 'N')
                   AND match.po_distribution_id IS NOT null
                   and nvl(pol.negotiated_by_preparer_flag,'N') = 'N')
        THEN  ((Nvl(pod.quantity_ordered,0) - Nvl(pod.quantity_cancelled,0)) * Nvl(pll.price_override,0))
        ELSE 0 END) pot_contract_amount,
       (CASE WHEN (pol.item_id IS NOT NULL
                   AND pll.shipment_type = 'STANDARD'
                   AND (nvl(ref.global_agreement_flag, 'N') = 'N')
                   AND match.po_distribution_id IS NOT null
                   and nvl(pol.negotiated_by_preparer_flag,'N') = 'N')
            THEN  ((Nvl(pod.quantity_ordered,0) - Nvl(pod.quantity_cancelled,0))
                   * (Nvl(pll.price_override,0) - Nvl(poa_dbi_savings_pkg.get_lowest_possible_price(pod.creation_date,
                                                                            poh.org_id,
                                                                            pll.need_by_date,
                                                                            pll.quantity, --shipment quantity
                                                                            nvl(pll.unit_meas_lookup_code,pol.unit_meas_lookup_code),
                                                                            poh.currency_code,
                                                                            pol.item_id,
                                                                            pol.item_revision,
                                                                            pol.category_id,
                                                                            pll.ship_to_location_id,
                                                                            poa_gl.currency_code, -- standard PO functional currency
                                                                            nvl(pod.rate_date, pod.creation_date), -- rate date
                                                                            match.ship_to_ou_id, -- ship to OU
                                                                            pll.ship_to_organization_id,
                                                                            pod.po_distribution_id,
                                                                            'PRICE')/nvl(pod.rate,1),
                                                                            Nvl(pll.price_override,0) )
              ))  ELSE 0 END ) pot_savings_amount,
       pll.price_override,
       (case when pll.value_basis = 'QUANTITY'
              then Nvl(pod.quantity_ordered,0) - Nvl(pod.quantity_cancelled,0)
              else null
         end) quantity,
       null creation_mode, -- Automatic/Manual Manishas API not used for now
       pll.value_basis order_type,
       prl.catalog_type, -- not used for now
       pod.destination_type_code,
       --  Decode(pod.destination_type_code, 'EXPENSE', 'I', 'D') spend_type, -- Indirect/Direct  not used for now
       pod.amount_billed,
       pod.amount_financed,
       pod.amount_recouped,
       (case when pll.value_basis = 'QUANTITY'
             then pod.quantity_billed
             else null
        end) quantity_billed,
       (case when pll.value_basis = 'QUANTITY'
             then pod.quantity_financed
             else null
        end) quantity_financed,
       (case when pll.value_basis = 'QUANTITY'
             then pod.quantity_recouped
             else null
        end) quantity_recouped,
        (case when pll.value_basis = 'QUANTITY'
              then pod.quantity_cancelled
              else null
         end) quantity_cancelled,
       (case when (pol.item_id is not null and pll.shipment_type = 'STANDARD' and match.po_distribution_id is not null)
        then poa_dbi_savings_pkg.get_lowest_possible_price(pod.creation_date,
                                                poh.org_id,
                                                pll.need_by_date,
                                                pll.quantity, --shipment quantity
                                                nvl(pll.unit_meas_lookup_code,pol.unit_meas_lookup_code),
                                                poh.currency_code,
                                                pol.item_id,
                                                pol.item_revision,
                                                pol.category_id,
                                                pll.ship_to_location_id,
                                                poa_gl.currency_code, -- standard PO functional currency
                                                nvl(pod.rate_date, pod.creation_date), -- rate date
                                                match.ship_to_ou_id, -- ship to OU
                                                pll.ship_to_organization_id,
                                                pod.po_distribution_id,
                                                'BLANKET')
        else null end) potential_contract_id,
       pll.shipment_type,
       nvl(prh.apps_source_code, 'PO') apps_source_code,
       ref.type_lookup_code from_document_type,
       pol.from_header_id from_document_id,
       (case when (pll.consigned_flag = 'Y') then 1
             when ((por.consigned_consumption_flag = 'Y') or (poh.consigned_consumption_flag = 'Y')) then 2 else 0 end) consigned_code,
       (case when pll.value_basis = 'QUANTITY'
              then decode(pol.item_id, null, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code), poa_dbi_uom_pkg.get_item_base_uom(pol.item_id, par.master_organization_id, nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)))
              else null
        end) base_uom,
       (case when pll.value_basis = 'QUANTITY'
             then nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)
             else null
        end) transaction_uom,
       prl.to_person_id requestor_id,
       --  null invoice_price_variance, -- IPV not used for now
       --  0 po_approval_cycle_time, -- cycle time delayed calc
       l_start_time current_time,
       l_login login_id,
       l_user user_id,
       nvl(pod.rate,1) func_cur_conv_rate,
       rat.sglobal_cur_conv_rate,
       Nvl(pll.promised_date, pll.need_by_date) expected_date,
       Nvl(pll.days_late_receipt_allowed, 0)  days_late_receipt_allowed,
       Nvl(pll.days_early_receipt_allowed, 0) days_early_receipt_allowed,
       pol.item_id,
       pll.matching_basis,
       pll.receiving_routing_id,
       ccid.company_id,
       ccid.cost_center_id,
       pll.payment_type,
       ( case
         when nvl(doc_style.progress_payment_flag,'N') = 'N' then 'N'
         else  'Y' end
       ) complex_work_flag,
        decode(pll.shipment_type, 'PREPAYMENT','Y','N') prepayment_flag,
---Begin Changes for Item Avg Price
        decode(nvl(pll.price_override,0),0,0,case when pll.value_basis =
                   'QUANTITY' then nvl(pod.quantity_ordered,0) -
                    nvl(pod.quantity_cancelled,0) else null end ) non_zero_quantity,
---End Changes for Item Avg Price
       negd.auction_header_id,
       negd.auction_line_number,
       negd.bid_number,
       negd.bid_line_number,
       nvl(negd.negotiation_creator_id,-1) negotiation_creator_id,
       nvl(negd.doctype_id,-1) doctype_id,
       negd.neg_current_price,
       negd.neg_func_cur_code,
       negd.neg_func_cur_conv_rate,
       negd.neg_global_cur_conv_rate,
       negd.neg_sglobal_cur_conv_rate,
       negd.neg_transaction_uom,
       negd.neg_base_uom,
       negd.neg_base_uom_conv_rate,
       nvl(pol.negotiated_by_preparer_flag,'N') negotiated_by_preparer_flag
       FROM
       poa_dbi_pod_inc              inc,
       poa_dbi_neg_details          negd,
       poa_dbi_pod_rates            rat,
       gl_sets_of_books             poa_gl,
       po_distributions_all         pod,
       po_line_locations_all        pll,
       po_lines_all                 pol,
       po_headers_all               poh,
       po_requisition_lines_all     prl,
       po_req_distributions_all     prd,
       financials_system_params_all fsp,
       po_releases_all              por,
       po_headers_all               ref,
       po_requisition_headers_all   prh,
       mtl_parameters               par,
       fii_gl_ccid_dimensions       ccid,
       po_doc_style_headers         doc_style,
       pon_auction_headers_all      ponh,
       ( SELECT /*+  cardinality(inc,1) */
         distinct pod.po_distribution_id, hro.ship_to_ou_id
         FROM
         po_distributions_all        pod,
         po_line_locations_all       psc,
         po_lines_all                plc,
         poa_dbi_pod_inc             inc,
         po_headers_all              ga,
       (select /*+ no_merge */ to_number(hro.org_information3) ship_to_ou_id,organization_id
        from hr_organization_information hro where
             hro.org_information_context='Accounting Information') hro,
         po_doc_style_headers        style,
         po_headers_all              phc,
         ( SELECT
           pl.item_id,
           ph.start_date,
           ph.end_date,
           pl.expiration_date,
           ph.org_id,
           ph.global_agreement_flag,
           ph.po_header_id,
           pl.creation_date
           FROM
           po_lines_all pl,
           po_headers_all ph
           WHERE ph.type_lookup_code = 'BLANKET'
           AND   pl.price_break_lookup_code IS NOT null
           AND   ph.approved_flag IN ('Y', 'R')
           and   ph.po_header_id = pl.po_header_id
           and   nvl(ph.cancel_flag, 'N') = 'N'
           and   nvl(pl.cancel_flag, 'N') = 'N'
         ) v1,
         ( select distinct po_header_id, purchasing_org_id
           from po_ga_org_assignments pgoa
           where enabled_flag = 'Y'
         ) pgoa
         WHERE plc.po_line_id          = psc.po_line_id
         and   psc.line_location_id    = pod.line_location_id
         and   phc.po_header_id        = plc.po_header_id
         and   phc.style_id            = style.style_id
         and   nvl(style.progress_payment_flag,'N') = 'N'
         and   psc.shipment_type       = 'STANDARD'
         and   plc.from_header_id      = ga.po_header_id (+)
         and   nvl(ga.global_agreement_flag, 'N') = 'N'
         and   psc.approved_flag       = 'Y'
         and   plc.item_id             is not null
         and   pod.creation_date       is not null
         and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
         and   v1.item_id         = plc.item_id
         AND   inc.primary_key = pod.po_distribution_id
         and   v1.po_header_id = pgoa.po_header_id (+)
         and   to_number(hro.organization_id) = psc.ship_to_organization_id
         and   (
                 ( pgoa.purchasing_org_id in
                   ( select tfh.start_org_id
                     from
                     mtl_procuring_txn_flow_hdrs_v tfh,
                     financials_system_params_all fsp1,
                     financials_system_params_all fsp2
                     where pod.creation_date between nvl(tfh.start_date, pod.creation_date) and nvl(tfh.end_date, pod.creation_date)
                     and   fsp1.org_id = tfh.start_org_id
                     and   fsp1.purch_encumbrance_flag = 'N'
                     and   fsp2.org_id = tfh.end_org_id
                     and   fsp2.purch_encumbrance_flag = 'N'
                     and   tfh.end_org_id = hro.ship_to_ou_id
                     and   ((tfh.qualifier_code is null) or (tfh.qualifier_code = 1 and tfh.qualifier_value_id = plc.category_id))
                     and   ((tfh.organization_id is null) or (tfh.organization_id = psc.ship_to_organization_id))
                   )
                 )
                 or
                 (
                   nvl(pgoa.purchasing_org_id, hro.ship_to_ou_id) = hro.ship_to_ou_id
                 )
               )
         and   (
                 ( v1.org_id = hro.ship_to_ou_id
                   and nvl(v1.global_agreement_flag, 'N') = 'N'
                 )
                 or
                 ( v1.global_agreement_flag = 'Y'
                   and pgoa.purchasing_org_id is not null
                 )
               )
         and   Trunc(pod.creation_date) between nvl(v1.start_date, Trunc(pod.creation_date))
         and   nvl(v1.end_date, pod.creation_date)
         and   pod.creation_date >= v1.creation_date
         and   Trunc(pod.creation_date) <= nvl(v1.expiration_date, pod.creation_date)
       ) match
       WHERE inc.primary_key         = pod.PO_DISTRIBUTION_ID
       and   inc.func_cur_code       = rat.func_cur_code
       and   inc.txn_cur_code        = rat.txn_cur_code
       and   inc.rate_date           = rat.rate_date
        and   inc.primary_key         = negd.po_distribution_id(+) /* Check for presence of Auction Details */
       --and   (inc.primary_key = negd.po_distribution_id or negd.po_distribution_id is null)
       and   poh.po_header_id        = pol.po_header_id
       and   pol.po_line_id          = pll.po_line_id
       and   por.po_release_id (+)   = pll.po_release_id
       and   ref.po_header_id (+)    = pol.from_header_id
       and   pll.line_location_id    = pod.line_location_id
       and   poa_gl.set_of_books_id  = pod.set_of_books_id
       and   pod.org_id              = fsp.org_id
       and   poh.style_id            = doc_style.style_id
       and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
       AND   pod.req_distribution_id = prd.distribution_id(+)
       and   prd.requisition_line_id = prl.requisition_line_id(+)
       and   prl.requisition_header_id = prh.requisition_header_id(+)
       and   fsp.inventory_organization_id = par.organization_id
       and   pll.approved_flag       = 'Y'
       and   pod.creation_date       is not NULL
       and   pol.auction_header_id   = ponh.auction_header_id(+)
       AND   inc.batch_id            = v_batch_no
       AND   inc.primary_key         = match.po_distribution_id(+)
       and   pod.code_combination_id = ccid.code_combination_id(+)
     ) S
     ON (T.po_distribution_id = S.po_distribution_id)
     WHEN matched THEN UPDATE SET
     /* there are a few columns that we DONT update, such as earliest approval date and currency */
     t.ship_to_org_id = s.ship_to_organization_id,
     t.supplier_id = s.vendor_id,
     t.supplier_site_id = s.vendor_site_id,
     t.po_item_id = s.po_item_id,
     t.category_id = s.category_id,
     t.buyer_id = s.agent_id,
     t.global_cur_conv_rate = s.global_cur_conv_rate,
     t.base_uom_conv_rate = s.base_uom_conv_rate,
     t.purchase_amount_b = s.purchase_amount,
     t.contract_amount_b = decode(s.prepayment_flag,'Y',0,s.contract_amount),
     t.non_contract_amount_b = decode(s.prepayment_flag,'Y',0,s.non_contract_amount),
     t.pot_contract_amount_b = decode(s.prepayment_flag,'Y',0,s.pot_contract_amount),
     t.pot_savings_amount_b = decode(s.prepayment_flag,'Y',0,s.pot_savings_amount),
     t.unit_price = s.price_override / s.base_uom_conv_rate,
     t.quantity = s.quantity * s.base_uom_conv_rate,
     t.creation_mode = s.creation_mode,
     t.catalog_type = s.catalog_type,
     t.destination_type_code = s.destination_type_code,
     t.amt_billed = s.amount_billed,
     t.amt_financed = s.amount_financed,
     t.amt_recouped = s.amount_recouped,
     t.qty_billed = s.quantity_billed * s.base_uom_conv_rate,
     t.qty_financed = s.quantity_financed * s.base_uom_conv_rate,
     t.qty_recouped = s.quantity_recouped * s.base_uom_conv_rate,
     t.qty_cancelled = s.quantity_cancelled * s.base_uom_conv_rate,
     t.potential_contract_id = s.potential_contract_id,
     t.shipment_type = s.shipment_type,
     t.apps_source_code = s.apps_source_code,
     t.from_document_type = s.from_document_type,
     t.from_document_id = s.from_document_id,
     t.consigned_code = s.consigned_code,
     t.base_uom = s.base_uom,
     t.transaction_uom = s.transaction_uom,
     t.requestor_id = s.requestor_id,
     t.last_update_login = s.login_id,
     t.last_updated_by = s.user_id,
     t.last_update_date = s.current_time,
     t.func_cur_conv_rate = s.func_cur_conv_rate,
     t.sglobal_cur_conv_rate = s.sglobal_cur_conv_rate,
     t.expected_date = s.expected_date,
     t.days_late_receipt_allowed = s.days_late_receipt_allowed,
     t.days_early_receipt_allowed = s.days_early_receipt_allowed,
     t.price_override = s.price_override,
     t.line_location_id = s.line_location_id,
     t.item_id = s.item_id,
     t.matching_basis = s.matching_basis,
     t.receiving_routing_id = s.receiving_routing_id,
     t.company_id = s.company_id,
     t.cost_center_id = s.cost_center_id,
     t.payment_type = s.payment_type,
     t.complex_work_flag = s.complex_work_flag ,
---Begin Changes for Item Avg Price
     t.non_zero_quantity = s.non_zero_quantity * s.base_uom_conv_rate,
---End Changes for Item Avg Price
     t.neg_current_price = s.neg_current_price / s.neg_base_uom_conv_rate,
     t.neg_func_cur_code = s.neg_func_cur_code,
     t.neg_func_cur_conv_rate = s.neg_func_cur_conv_rate,
     t.neg_global_cur_conv_rate = s.neg_global_cur_conv_rate,
     t.neg_sglobal_cur_conv_rate = s.neg_sglobal_cur_conv_rate,
     t.neg_transaction_uom = s.neg_transaction_uom,
     t.neg_base_uom = s.neg_base_uom,
     t.neg_base_uom_conv_rate = s.neg_base_uom_conv_rate,
     t.negotiated_by_preparer_flag = s.negotiated_by_preparer_flag
     WHEN NOT matched THEN INSERT
     (
       t.po_distribution_id ,
       t.po_header_id ,
       t.po_line_id ,
       t.po_release_id,
       t.creation_operating_unit_id,
       t.ship_to_org_id,
       t.approved_date ,
       t.distribution_creation_date ,
       t.supplier_id ,
       t.supplier_site_id,
       t.po_item_id,
       t.category_id,
       t.buyer_id,
       t.code_combination_id,
       t.func_cur_code ,
       t.global_cur_conv_rate,
       t.base_uom_conv_rate,
       t.purchase_amount_b,
       t.contract_amount_b,
       t.non_contract_amount_b,
       t.pot_contract_amount_b,
       t.pot_savings_amount_b,
       t.unit_price,
       t.quantity,
       t.creation_mode,
       t.order_type ,
       t.catalog_type,
       t.destination_type_code ,
       t.amt_billed,
       t.amt_financed,
       t.amt_recouped,
       t.qty_billed,
       t.qty_financed,
       t.qty_recouped,
       t.qty_cancelled,
       t.potential_contract_id,
       t.shipment_type,
       t.apps_source_code,
       t.from_document_type,
       t.from_document_id,
       t.consigned_code,
       t.base_uom,
       t.transaction_uom,
       t.requestor_id,
--     t.invoice_price_variance,
--     t.po_approval_cycle_time,
       t.start_date_active ,
       t.last_update_login ,
       t.creation_date,
       t.last_updated_by,
       t.last_update_date,
       t.func_cur_conv_rate,
       t.sglobal_cur_conv_rate,
       t.expected_date,
       t.days_late_receipt_allowed,
       t.days_early_receipt_allowed,
       t.price_override,
       t.line_location_id,
       t.item_id,
       t.matching_basis,
       t.receiving_routing_id,
       t.company_id,
       t.cost_center_id,
       t.payment_type,
       t.complex_work_flag ,
---Begin Changes for Item Avg Price
       t.non_zero_quantity,
---End Changes for Item Avg Price
       t.auction_header_id,
       t.auction_line_number,
       t.bid_number,
       t.bid_line_number,
       t.negotiation_creator_id,
       t.doctype_id,
       t.neg_current_price,
       t.neg_func_cur_code,
       t.neg_func_cur_conv_rate,
       t.neg_global_cur_conv_rate,
       t.neg_sglobal_cur_conv_rate,
       t.neg_transaction_uom,
       t.neg_base_uom,
       t.neg_base_uom_conv_rate,
       t.negotiated_by_preparer_flag
     ) VALUES
     ( s.po_distribution_id,
       s.po_header_id,
       s.po_line_id,
       s.po_release_id,
       s.org_id ,
       s.ship_to_organization_id ,
       --s.approved_date,
       Trunc(NVL(POA_OLTP_GENERIC_PKG.get_approved_date_pll(s.creation_date, s.line_location_id), s.approved_date)),
       Trunc(s.creation_date) ,
       s.vendor_id,
       s.vendor_site_id,
       s.po_item_id,
       s.category_id,
       s.agent_id,
       s.code_combination_id,
       s.currency_code,
       s.global_cur_conv_rate,
       s.base_uom_conv_rate,
       s.purchase_amount,
       decode(s.prepayment_flag,'Y',0,s.contract_amount),
       decode(s.prepayment_flag,'Y',0,s.non_contract_amount),
       decode(s.prepayment_flag,'Y',0,s.pot_contract_amount),
       decode(s.prepayment_flag,'Y',0,s.pot_savings_amount),
       s.price_override / s.base_uom_conv_rate,
       s.quantity * s.base_uom_conv_rate,
       s.creation_mode,
       s.order_type,
       s.catalog_type,
       s.destination_type_code,
       s.amount_billed,
       s.amount_financed,
       s.amount_recouped,
       s.quantity_billed * s.base_uom_conv_rate,
       s.quantity_financed * s.base_uom_conv_rate,
       s.quantity_recouped * s.base_uom_conv_rate,
       s.quantity_cancelled * s.base_uom_conv_rate,
       s.potential_contract_id,
       s.shipment_type,
       s.apps_source_code,
       s.from_document_type,
       s.from_document_id,
       s.consigned_code,
       s.base_uom,
       s.transaction_uom,
       s.requestor_id,
--     s.invoice_price_variance,
--     s.approved_date - s.creation_date ,
       s.current_time, -- not sure if this is what it means
       s.login_id ,
       s.current_time,
       s.user_id,
       s.current_time,
       s.func_cur_conv_rate,
       s.sglobal_cur_conv_rate,
       s.expected_date,
       s.days_late_receipt_allowed,
       s.days_early_receipt_allowed,
       s.price_override,
       s.line_location_id,
       s.item_id,
       s.matching_basis,
       s.receiving_routing_id,
       s.company_id,
       s.cost_center_id,
       s.payment_type,
       s.complex_work_flag,
---Begin Changes for Item Avg Price
       s.non_zero_quantity * s.base_uom_conv_rate,
---End Changes for Item Avg Price
       s.auction_header_id,
       s.auction_line_number,
       s.bid_number,
       s.bid_line_number,
       s.negotiation_creator_id,
       s.doctype_id,
       s.neg_current_price / s.neg_base_uom_conv_rate,
       s.neg_func_cur_code,
       s.neg_func_cur_conv_rate,
       s.neg_global_cur_conv_rate,
       s.neg_sglobal_cur_conv_rate,
       s.neg_transaction_uom,
       s.neg_base_uom,
       s.neg_base_uom_conv_rate,
       s.negotiated_by_preparer_flag
     );

     COMMIT;
     bis_collection_utilities.log('best price calculation hit='|| poa_dbi_savings_pkg.g_hit_count, 2);
     poa_dbi_savings_pkg.g_hit_count := 0;

     DBMS_APPLICATION_INFO.SET_ACTION('batch ' || v_batch_no || ' done');
    END LOOP;
   END IF;
  END IF;
/*
   if (l_no_batch is NOT NULL) then
      FOR v_batch_no IN 1..l_no_batch LOOP
	 bis_collection_utilities.log('EAD batch no='||v_batch_no || ' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 1);
	 update poa_dbi_pod_f f
	   set (approved_date, po_approval_cycle_time) = (SELECT min(approved_date), MIN(approved_date - pod.creation_date)
							  from po_line_locations_archive_all pll
							  ,po_distributions_all pod
							  where pod.po_distribution_id = f.po_distribution_id
							  and pll.line_location_id = pod.line_location_id
							  and pll.approved_date >= pod.creation_date)
	   where f.po_distribution_id in (select primary_key from poa_dbi_pod_inc
					  where batch_id = v_batch_no);
	 COMMIT;
	 DBMS_APPLICATION_INFO.SET_ACTION('EAD batch ' || v_batch_no || ' done');
      END LOOP;
   END IF;
*/

   bis_collection_utilities.log('Collection complete '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
   bis_collection_utilities.wrapup(TRUE, l_count, 'POA DBI PO DIST COLLECTION SUCEEDED', To_date(l_start_date, '''YYYY/MM/DD HH24:MI:SS'''), To_date(l_end_date, '''YYYY/MM/DD HH24:MI:SS'''));
   g_init := false;
   DBMS_APPLICATION_INFO.set_module(NULL, NULL);
EXCEPTION
   WHEN OTHERS THEN
      DBMS_APPLICATION_INFO.SET_ACTION('error');
      errbuf:=sqlerrm;
      retcode:=sqlcode;
      bis_collection_utilities.log('Collection failed with '||errbuf||':'||retcode||' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
--      dbms_output.put_line(l_start_date || l_end_date);
      bis_collection_utilities.wrapup(FALSE, l_count, errbuf||':'||retcode,
				      To_date(l_start_date, '''YYYY/MM/DD HH24:MI:SS'''), To_date(l_end_date, '''YYYY/MM/DD HH24:MI:SS'''));


      RAISE;
END populate_po_dist_facts;

END POA_DBI_PO_DIST_F_C;

/
