--------------------------------------------------------
--  DDL for Package Body POA_DBI_NEG_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_NEG_F_C" AS
/* $Header: poadbinegfrefb.pls 120.11.12000000.2 2007/02/27 14:41:15 sriswami ship $ */
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
    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_NEG_F';
    EXECUTE immediate l_stmt;

    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_NEG_INC';
    EXECUTE immediate l_stmt;

    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_NEG_RATES';
    EXECUTE immediate l_stmt;

    g_init := TRUE;
    populate_neg_facts (errbuf, retcode);
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
PROCEDURE populate_neg_facts(
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
BEGIN
  errbuf :=NULL;
  retcode:=0;
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

  dbms_application_info.set_module(module_name => 'DBI NEGOTIATION COLLECT', action_name => 'start');
  l_dop := bis_common_parameters.get_degree_of_parallelism;
   -- default DOP to profile in EDW_PARALLEL_SRC if 2nd param is not passed
  l_go_ahead := bis_collection_utilities.setup('POADBINEGF');

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
    l_start_date := '''' || to_char(fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('POADBINEGF'))-0.004,'YYYY/MM/DD HH24:MI:SS') || '''';
    /* if there is not a success record in the bis refresh log, then we have to get the global start date as l_start_date*/
    d_start_date := fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('POADBINEGF'))-0.004;
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
    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_NEG_INC';
    EXECUTE IMMEDIATE l_stmt;
    l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_DBI_NEG_RATES';
    EXECUTE IMMEDIATE l_stmt;
  END IF;

  dbms_application_info.set_action('inc');
  bis_collection_utilities.log('Populate Currency Conversion table '|| 'Sysdate=' ||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
  l_glob_date := '''' || To_char(bis_common_parameters.get_global_start_date, 'YYYY/MM/DD HH24:MI:SS') || '''';
  d_glob_date := bis_common_parameters.get_global_start_date;

  IF (g_init) THEN
      INSERT /*+ append parallel(poa_dbi_neg_inc) */ INTO poa_dbi_neg_inc
    (
      primary_key,
      batch_id,
      txn_cur_code,
      func_cur_code,
      rate_date
    )
    (
      SELECT /*+ PARALLEL(ponh) PARALLEL(pfsp) PARALLEL(pgl)
                 USE_HASH(ponh) USE_HASH(pfsp) */
	 ponh.auction_header_id,
         1 batch_id,
         ponh.currency_code txn_cur_code,
         pgl.currency_code func_cur_code,
         nvl(trunc(ponh.rate_date),trunc(ponh.creation_date)) rate_date
      FROM
         pon_auction_headers_all ponh,
  	 financials_system_params_all pfsp,
	 gl_sets_of_books pgl,
         pon_auc_doctypes doctype
      WHERE
          ponh.auction_status = 'AUCTION_CLOSED'
      and ponh.auction_type = 'REVERSE'                         /* Only Reverse (Buyer) auctions considered */
      and (ponh.award_complete_date is not null                 /* Only Award Complete Negotiations are considered */
            OR (doctype.internal_name = 'REQUEST_FOR_INFORMATION' AND ponh.award_status='QUALIFIED')) /* Only Completed RFIs will be included */
      and ponh.org_id = pfsp.org_id
      and pfsp.set_of_books_id = pgl.set_of_books_id
      and ponh.doctype_id = doctype.doctype_id
      and doctype.transaction_type = 'REVERSE'                  /* Redundant Filter condition as PONH is taken care */
      and ponh.creation_date > d_glob_date
      and ponh.last_update_date between d_start_date and d_end_date
      );
  ELSE
      INSERT /*+ append */ INTO poa_dbi_neg_inc
    (
      primary_key,
      batch_id,
      txn_cur_code,
      func_cur_code,
      rate_date
    )
       (
     (
      SELECT
	 ponh.auction_header_id,
         1 batch_id,
         ponh.currency_code txn_cur_code,
         pgl.currency_code func_cur_code,
         nvl(trunc(ponh.rate_date),trunc(ponh.creation_date)) rate_date
      FROM
         pon_auction_headers_all ponh,
  	 financials_system_params_all pfsp,
	 gl_sets_of_books pgl,
         pon_auc_doctypes doctype
      WHERE
          nvl(ponh.auction_status,'DRAFT') <> 'DRAFT'
      and ponh.auction_type = 'REVERSE'                         /* Forward Auctions not considered */
      and (ponh.award_complete_date is not null                 /* Only Award Complete Negotiations are considered */
            OR (doctype.internal_name = 'REQUEST_FOR_INFORMATION' AND ponh.award_status='QUALIFIED')) /* Only Completed RFIs will be included */
      and ponh.org_id = pfsp.org_id
      and pfsp.set_of_books_id = pgl.set_of_books_id
      and ponh.doctype_id = doctype.doctype_id
      and doctype.transaction_type = 'REVERSE'
      and ponh.creation_date > d_glob_date
      and ponh.last_update_date between d_start_date and d_end_date
      )
UNION
    (
      SELECT /*+ cardinality(ponbh,1) */
         distinct
         ponh.auction_header_id,
         1 batch_id,
         ponh.currency_code txn_cur_code,
         pgl.currency_code func_cur_code,
         nvl(trunc(ponh.rate_date),trunc(ponh.creation_date)) rate_date
      FROM
         pon_auction_headers_all ponh,
         pon_bid_headers ponbh,
         financials_system_params_all pfsp,
         gl_sets_of_books pgl,
         pon_auc_doctypes doctype
      WHERE
          nvl(ponh.auction_status,'DRAFT') <> 'DRAFT'
      and ponh.auction_type = 'REVERSE'                         /* Forward Auctions not considered */
      and ponh.award_complete_date is not null                  /* Only Award Complete Negotiations are considered */
      and ponh.auction_header_id = ponbh.auction_header_id
      and ponh.org_id = pfsp.org_id
      and pfsp.set_of_books_id = pgl.set_of_books_id
      and ponh.doctype_id = doctype.doctype_id
      and doctype.transaction_type = 'REVERSE'
      and ponh.creation_date > d_glob_date
      and ponbh.last_update_date between d_start_date and d_end_date
      )
      );
  END IF;
  COMMIT;
  dbms_application_info.set_action('stats incremental');

  IF (fnd_installation.get_app_info('POA', l_status, l_industry, l_poa_schema))  THEN
    fnd_stats.gather_table_stats(ownname => l_poa_schema, tabname => 'POA_DBI_NEG_INC') ;
  END IF;

  INSERT /*+ APPEND */ INTO poa_dbi_neg_rates
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
    poa_dbi_neg_inc
    order by func_cur_code, rate_date
  );

  COMMIT;

  dbms_application_info.set_action('stats rates');

  IF (fnd_installation.get_app_info('POA', l_status, l_industry, l_poa_schema)) THEN
     fnd_stats.gather_table_stats(ownname => l_poa_schema,
              tabname => 'POA_DBI_NEG_RATES') ;
  END IF;

  bis_collection_utilities.log('Populate base table: '|| 'Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
  select max(batch_id), COUNT(1) into l_no_batch, l_count from poa_dbi_neg_inc;
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
  IF (l_no_batch is NOT NULL) then
  IF (g_init) THEN
    bis_collection_utilities.log('Initial Load - using one batch approach, populate base fact. '|| 'Sysdate=' ||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
   INSERT /*+ append parallel(t) */ INTO poa_dbi_neg_f t (
      t.auction_header_id ,              /* Auction Header ID */
      t.auction_line_number,             /* Auction Line Number */
      t.bid_number,                      /* Awarded Bid Number */
      t.bid_line_number,                 /* Awarded Bid Line Number */
      t.doctype_id,                      /* Is it an Auction/RFQ/Offer */
      t.auction_round_number,            /* Auction Round Number */
      t.prev_round_auction_header_id,    /* Previous Round Auction Header ID */
      t.auction_creation_date,           /* Auction Creation Date */
      t.publish_date,                    /* Published Date */
      t.open_bidding_date,               /* Opened for Bidding Date */
      t.close_bidding_date,              /* Closed for Bidding Date */
      t.prev_round_close_date,           /* Previous Round Close Bidding Date */
      t.next_round_creation_date,        /* Next Round Creation Date */
      t.award_date,                      /* Award Date */
      t.award_complete_date,             /* Award Complete Date */
      t.rfi_complete_date,               /* RFI Complete Date */
      t.org_id,                          /* OU ID */
      t.negotiation_creator_id,          /* Negotiation Creator ID */
      t.category_id,                     /* Category ID */
      t.po_item_id,                      /* PO Item ID */
      t.supplier_id,                     /* Winning Supplier ID */
      t.supplier_site_id,                /* Winning Supplier Site ID */
      t.quantity,                        /* Requested Quantity */
      t.award_qty,                       /* Awarded Quantity */
      t.award_price,                     /* Awarded Price */
      t.current_price,                   /* Current Price of that Vendor */
      t.award_amount_t,                  /* Award Amount in transactional currency */
      t.award_amount_b,                  /* Award Amount in functional currency */
      t.award_amount_g,                  /* Award Amount in global currency */
      t.award_amount_sg,                 /* Award Amount in secondary global currency */
      t.current_amount_t,                /* Current Amount in transactional currency */
      t.current_amount_b,                /* Current Amount in functional currency */
      t.current_amount_g,                /* Current Amount in global currency */
      t.current_amount_sg,               /* Current Amount in secondary global currency */
      t.line_type_id,                    /* Line Type of the Sourcing Line */
      t.order_type_lookup_code,          /* Value basis of the Sourcing Line */
      t.auction_status,                  /* Auction Status */
      t.award_status,                    /* Award Status */
      t.allocation_status,               /* Allocation Status */
      t.received_bid_count,              /* No. of Bids Received for this Sourcing Line */
      t.supplier_invite_date,            /* Date on which the Supplier was invited */
      t.contract_type,                   /* Outcome Document STANDARD/BLANKET */
      t.po_header_id,                    /* PO Header ID of the Outcome Document */
--    t.requisition_header_id,           /* Backing Requisition Header ID */
--    t.requisition_line_id,             /* Backing Requisition Line ID */
      t.func_cur_code,                   /* Functional Currency Code */
      t.func_cur_conv_rate,              /* Functional Currency Conversion Rate */
      t.global_cur_conv_rate,            /* Global Currency Conversion Rate */
      t.sglobal_cur_conv_rate,           /* Secondary Global Currency Conversion Rate */
      t.base_uom,                        /* Base UOM */
      t.transaction_uom,                 /* Transaction UOM */
      t.base_uom_conv_rate,              /* Base UOM conversion rate */
      t.created_by,                      /* WHO Column */
      t.last_update_login,               /* WHO Column */
      t.creation_date,                   /* WHO Column */
      t.last_updated_by,                 /* WHO Column */
      t.last_update_date                 /* WHO Column */
   )
    SELECT
      s.auction_header_id,
      s.auction_line_number,
      s.bid_number,
      s.bid_line_number,
      s.doctype_id,
      s.auction_round_number,
      s.prev_round_auction_header_id,
      s.current_round_creation_date creation_date,
      s.publish_date,
      s.open_bidding_date,
      s.close_bidding_date,
      s.prev_round_close_date,
      s.next_round_creation_date,
      s.award_date,
      s.award_complete_date,
      s.rfi_complete_date,
      s.org_id,
      s.negotiation_creator_id,
      s.category_id,
      s.po_item_id,
      s.supplier_id,
      s.supplier_site_id,
      decode(s.order_type_lookup_code,'QUANTITY',s.quantity * s.base_uom_conv_rate, to_number(null)),
      decode(s.order_type_lookup_code,'QUANTITY',s.award_qty * s.base_uom_conv_rate, to_number(null)),
      (s.award_price / s.base_uom_conv_rate),
      (s.current_price / s.base_uom_conv_rate),
      decode(s.award_status, 'COMPLETED', decode(s.order_type_lookup_code, 'QUANTITY',s.award_price * s.award_qty, s.award_price), null),
      decode(s.award_status,'COMPLETED' , decode(s.order_type_lookup_code, 'QUANTITY',s.award_price * s.award_qty * s.func_cur_conv_rate, s.award_price * s.func_cur_conv_rate)
                           ,null),
      decode(s.award_status,'COMPLETED',  decode(s.order_type_lookup_code, 'QUANTITY',
            decode(s.global_cur_conv_rate, 0, s.award_price * s.award_qty, s.award_price * s.award_qty * s.func_cur_conv_rate * s.global_cur_conv_rate),
            decode(s.global_cur_conv_rate, 0, s.award_price, s.award_price * s.func_cur_conv_rate * s.global_cur_conv_rate)), null),
      decode(s.award_status,'COMPLETED',  decode(s.order_type_lookup_code, 'QUANTITY',
            decode(s.sglobal_cur_conv_rate, 0, s.award_price * s.award_qty, s.award_price * s.award_qty * s.func_cur_conv_rate * s.sglobal_cur_conv_rate),
	    decode(s.sglobal_cur_conv_rate, 0, s.award_price, s.award_price * s.func_cur_conv_rate * s.sglobal_cur_conv_rate)), null),
      decode(s.order_type_lookup_code, 'QUANTITY', s.current_price *  s.award_qty, s.current_price),
      decode(s.order_type_lookup_code, 'QUANTITY', s.current_price *  s.award_qty * s.func_cur_conv_rate, s.current_price * s.func_cur_conv_rate),
      decode(s.order_type_lookup_code, 'QUANTITY',
         decode(s.global_cur_conv_rate, 0, s.current_price *  s.award_qty, s.current_price * s.award_qty * s.func_cur_conv_rate * s.global_cur_conv_rate),
         decode(s.global_cur_conv_rate, 0, s.current_price, s.current_price * s.func_cur_conv_rate * s.global_cur_conv_rate)),
      decode(s.order_type_lookup_code, 'QUANTITY',
         decode(s.sglobal_cur_conv_rate, 0, s.current_price *  s.award_qty, s.current_price * s.award_qty * s.func_cur_conv_rate * s.sglobal_cur_conv_rate),
         decode(s.sglobal_cur_conv_rate, 0, s.current_price, s.current_price * s.func_cur_conv_rate * s.sglobal_cur_conv_rate)),
      s.line_type_id,
      s.order_type_lookup_code,
      s.auction_status,
      s.award_status,
      s.allocation_status,
      s.received_bid_count,
      s.supplier_invite_date,
      s.contract_type,
      s.po_header_id,
--    s.requisition_header_id,
--    s.requisition_line_id,
      s.func_cur_code,
      s.func_cur_conv_rate,
      s.global_cur_conv_rate,
      s.sglobal_cur_conv_rate,
      decode(s.order_type_lookup_code,'QUANTITY', s.base_uom, null),
      s.transaction_uom,
      s.base_uom_conv_rate,
      l_user,
      l_login,
      l_start_time,
      l_user,
      l_start_time
      FROM
      (
       SELECT /*+ PARALLEL(inc) PARALLEL(ponh) USE_HASH(inc)  USE_HASH(ponh) */
          ponh_multi.auction_header_id,
 	  ponip.line_number auction_line_number,
	  ponbh.bid_number bid_number,
	  ponbip.line_number bid_line_number,
	  ponh_multi.doctype_id,
	  ponh_multi_orig.creation_date current_round_creation_date,
	  ponh_prev.close_bidding_date prev_round_close_date,
	  ponh_next.creation_date next_round_creation_date,
	  nvl(ponh_multi.auction_round_number,1) auction_round_number,
          ponh_prev.auction_header_id prev_round_auction_header_id,
	  ponh_multi_orig.publish_date,
      	  ponh_multi_orig.open_bidding_date,
	  ponh_multi.close_bidding_date,
	  ponh_multi.award_date,
	  decode(doctype.internal_name, 'REQUEST_FOR_INFORMATION', to_date(null), ponh.award_complete_date) award_complete_date,
	  ponh.org_id,
          hz.person_identifier negotiation_creator_id,
	  ponip.category_id,
          poa_dbi_items_pkg.getitemkey(ponip.item_id, ppar.master_organization_id, ponip.category_id, NULL, NULL, ponip.item_description) po_item_id,
          decode(ponh_multi.award_status,'QUALIFIED', -99, 'NO', -99, ponbh.vendor_id) supplier_id,
	  decode(ponh_multi.award_status,'QUALIFIED', -99, 'NO', -99, ponbh.vendor_site_id) supplier_site_id,
          ponip.order_type_lookup_code,
	  decode(ponh_multi.award_status,'NO',null,  'QUALIFIED', null, decode(ponh.contract_type,'CONTRACT', to_number(null), ponip.quantity)) quantity,
          decode(ponh_multi.award_status,'NO',null,  'QUALIFIED', null, decode(ponh.contract_type, 'CONTRACT', to_number(null), ponbip.award_quantity)) award_qty,
          decode(ponh_multi.award_status,'NO',null,  'QUALIFIED', null, decode(ponh.contract_type, 'CONTRACT', to_number(null), ponip.current_price)) current_price,
	  decode(ponh_multi.award_status,'NO',null,  'QUALIFIED', null, decode(ponbip.award_status,'AWARDED',ponbip.award_price,null)) award_price,
	  ponip.line_type_id,
          ponh.auction_status,
          nvl(ponh_multi.award_status,ponbip.award_status) award_status,
	  decode(ponh_multi.award_status,'NO',NULL,ponip.allocation_status) allocation_status,
	  decode(ponh_multi.award_status,'NO',NULL,ponip.number_of_bids) received_bid_count,
	  decode(ponh_multi.award_status,'NO', to_date(null), nvl(ponbp.creation_date,ponh_multi_orig.publish_date)) supplier_invite_date,
          ponh.contract_type,
          ponbh.po_header_id,
--	  ponreq.requisition_header_id, /* Placeholder */
--	  ponreq.requisition_line_id,   /* Placeholder */
          decode(ponip.item_id, null, uom.unit_of_measure, pitem.primary_unit_of_measure) base_uom,
          uom.unit_of_measure transaction_uom,
	  decode(
                  ponip.item_id,
                  null, 1,
                  decode(uom.unit_of_measure,
                    pitem.primary_unit_of_measure, 1,
                    poa_dbi_uom_pkg.convert_to_item_base_uom(
                      ponip.item_id,
                      ppar.master_organization_id,
                      uom.unit_of_measure,
                      pitem.primary_uom_code
                    )
                  )
               ) base_uom_conv_rate,
          rat.func_cur_code func_cur_code,
          nvl(ponh.rate,1) func_cur_conv_rate,
          rat.global_cur_conv_rate,
          rat.sglobal_cur_conv_rate,
	  decode(doctype.internal_name, 'REQUEST_FOR_INFORMATION', nvl(ponh.award_complete_date, ponh.last_update_date), null) rfi_complete_date
       FROM
	 poa_dbi_neg_inc inc,
	 poa_dbi_neg_rates rat,
         pon_auction_headers_all ponh,
	 pon_auction_item_prices_all ponip,
	 pon_bid_headers ponbh,
	 pon_bid_item_prices ponbip,
	 pon_bidding_parties ponbp,
--	 pon_backing_requisitions ponreq,
  	 financials_system_params_all pfsp,
         mtl_parameters ppar,
         mtl_system_items pitem,
	 gl_sets_of_books pgl,
         hz_parties hz,
         mtl_units_of_measure uom,
	 pon_auc_doctypes doctype,
	 pon_auction_headers_all ponh_multi,
	 pon_auction_headers_all ponh_multi_orig,
	 pon_auction_headers_all ponh_prev,
	 pon_auction_headers_all ponh_next
      WHERE
      inc.primary_key = ponh.auction_header_id
      and (ponh.award_complete_date is not null                 /* Only Published Negotiations are considered */
           OR (doctype.internal_name = 'REQUEST_FOR_INFORMATION' AND ponh.award_status='QUALIFIED')) /* Only Completed RFIs will be included */
      and ponh.auction_header_id = ponip.auction_header_id
      and decode(ponh.award_status, 'QUALIFIED', null, ponh.auction_header_id) = ponbh.auction_header_id(+) /* Include only the Auction Record of RFI and not the Responses */
      and ponbh.auction_header_id = ponbip.auction_header_id(+) /* For Bidded Transactions Only */
      and ponbh.bid_number = ponbip.bid_number(+)
      and nvl(ponbip.line_number,ponip.line_number) = ponip.line_number /* Filter to give unique record */
      and ponbh.auction_header_id = ponbp.auction_header_id(+)
      and ponbh.trading_partner_id = ponbp.trading_partner_id(+)
      and ponbh.vendor_site_id = ponbp.vendor_site_id(+)
      and nvl(ponbh.bid_status,'ACTIVE') = 'ACTIVE'             /* If a Supplier changes bids, they store ARCHIVED. Ignore them. */
      and nvl(ponbip.award_status,'-999') <> 'REJECTED'         /* Cannot be NULL or REJECTED */
--    and ponip.auction_header_id = ponreq.auction_header_id(+) /* If Backing Requisition is available */
--    and ponip.line_number = ponreq.line_number(+)             /* If Backing Requisition is available */
      and ponh_multi.doctype_id = doctype.doctype_id                  /* Join to get document type, particulary for RFI */
      and doctype.transaction_type = 'REVERSE'                  /* Redundant Filter condition as PONH is taken care */
      and ponh.org_id = pfsp.org_id
      and pfsp.set_of_books_id = pgl.set_of_books_id
      and pfsp.inventory_organization_id = ppar.organization_id
      and ponip.uom_code = uom.uom_code(+)
      and ponip.item_id = pitem.inventory_item_id(+)
      and ppar.master_organization_id = nvl(pitem.organization_id, ppar.master_organization_id)
      and inc.txn_cur_code = rat.txn_cur_code
      and inc.func_cur_code = rat.func_cur_code
      and inc.rate_date = rat.rate_date
      and ponh.trading_partner_contact_id = hz.party_id
      and ponh_multi.auction_header_id_orig_round = ponh.auction_header_id_orig_round
      and ponh_multi_orig.auction_header_id = ponh_multi.auction_header_id_orig_amend
      and nvl(ponh_multi.auction_header_id_prev_round, ponh_multi.auction_header_id) = ponh_prev.auction_header_id
      and ponh_multi.auction_header_id = ponh_next.auction_header_id_prev_round(+)
      and nvl(ponh_next.auction_status,'AUCTION_CLOSED')='AUCTION_CLOSED'
      and ponh_multi.auction_status = 'AUCTION_CLOSED' /* Check that it cannot be ACTIVE */
      and ponip.group_type IN ('LINE', 'LOT', 'GROUP_LINE') /* Do not involve Lot Lines and Group */
      and ponh.creation_date > d_glob_date
     )s;
      COMMIT;
    ELSE
      -- Incremental load (process in batches)
      bis_collection_utilities.log('incremental collection');
      FOR v_batch_no IN 1..l_no_batch LOOP
      bis_collection_utilities.log('batch no='||v_batch_no || ' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), 1);

      MERGE INTO poa_dbi_neg_f t using
      ( SELECT  /*+ cardinality(inc,1) */
          ponh_multi.auction_header_id,
 	  ponip.line_number auction_line_number,
	  ponbh.bid_number bid_number,
	  ponbip.line_number bid_line_number,
	  ponh_multi.doctype_id,
	  ponh_multi_orig.creation_date current_round_creation_date,
	  ponh_prev.close_bidding_date prev_round_close_date,
	  ponh_next.creation_date next_round_creation_date,
	  nvl(ponh_multi.auction_round_number,1) auction_round_number,
          ponh_prev.auction_header_id prev_round_auction_header_id,
	  ponh_multi_orig.publish_date,
      	  ponh_multi_orig.open_bidding_date,
	  ponh_multi.close_bidding_date,
	  ponh_multi.award_date,
	  decode(doctype.internal_name, 'REQUEST_FOR_INFORMATION', to_date(null), ponh.award_complete_date) award_complete_date,
	  ponh.org_id,
          hz.person_identifier negotiation_creator_id,
	  ponip.category_id,
          poa_dbi_items_pkg.getitemkey(ponip.item_id, ppar.master_organization_id, ponip.category_id, NULL, NULL, ponip.item_description) po_item_id,
          decode(ponh_multi.award_status,'QUALIFIED', -99, 'NO', -99, ponbh.vendor_id) supplier_id,
	  decode(ponh_multi.award_status,'QUALIFIED', -99, 'NO', -99, ponbh.vendor_site_id) supplier_site_id,
          ponip.order_type_lookup_code,
	  decode(ponh_multi.award_status,'NO',null,  'QUALIFIED', null, decode(ponh.contract_type,'CONTRACT', to_number(null), ponip.quantity)) quantity,
          decode(ponh_multi.award_status,'NO',null,  'QUALIFIED', null, decode(ponh.contract_type, 'CONTRACT', to_number(null), ponbip.award_quantity)) award_qty,
          decode(ponh_multi.award_status,'NO',null,  'QUALIFIED', null, decode(ponh.contract_type, 'CONTRACT', to_number(null), ponip.current_price)) current_price,
	  decode(ponh_multi.award_status,'NO',null,  'QUALIFIED', null, decode(ponbip.award_status,'AWARDED',ponbip.award_price,null)) award_price,
	  ponip.line_type_id,
          ponh.auction_status,
          --decode(ponbh.bid_status,'ARCHIVED','DELETE',nvl(ponbip.award_status,ponh.award_status)) award_status,
          nvl(ponh_multi.award_status,ponbip.award_status) award_status,
	  decode(ponh_multi.award_status,'NO',null,ponip.allocation_status) allocation_status,
	  decode(ponh_multi.award_status,'NO',null,ponip.number_of_bids) received_bid_count,
	  decode(ponh_multi.award_status,'NO', to_date(null), nvl(ponbp.creation_date, ponh_multi_orig.publish_date)) supplier_invite_date,
          ponh.contract_type,
          ponbh.po_header_id,
--	  ponreq.requisition_header_id,
--	  ponreq.requisition_line_id,
          decode(ponip.item_id, null, uom.unit_of_measure, pitem.primary_unit_of_measure) base_uom,
          uom.unit_of_measure transaction_uom,
	  decode(
                  ponip.item_id,
                  null, 1,
                  decode(uom.unit_of_measure,
                    pitem.primary_unit_of_measure, 1,
                    poa_dbi_uom_pkg.convert_to_item_base_uom(
                      ponip.item_id,
                      ppar.master_organization_id,
                      uom.unit_of_measure,
                      pitem.primary_uom_code
                    )
                  )
               ) base_uom_conv_rate,
          rat.func_cur_code func_cur_code,
          nvl(ponh.rate,1) func_cur_conv_rate,
          rat.global_cur_conv_rate,
          rat.sglobal_cur_conv_rate,
	  nvl(ponbip.award_status, ponh.award_status) bid_award_status, /* RFI has only ponh information */
          ponbh.bid_status bid_status,
	  decode(doctype.internal_name, 'REQUEST_FOR_INFORMATION', nvl(ponh.award_complete_date, ponh.last_update_date), null) rfi_complete_date
       FROM
	 poa_dbi_neg_inc inc,
	 poa_dbi_neg_rates rat,
         pon_auction_headers_all ponh,
	 pon_auction_item_prices_all ponip,
	 pon_bid_headers ponbh,
	 pon_bid_item_prices ponbip,
	 pon_bidding_parties ponbp,
--	 pon_backing_requisitions ponreq,
  	 financials_system_params_all pfsp,
         mtl_parameters ppar,
         mtl_system_items pitem,
	 gl_sets_of_books pgl,
         hz_parties hz,
         mtl_units_of_measure uom,
	 pon_auc_doctypes doctype,
	 pon_auction_headers_all ponh_multi,
	 pon_auction_headers_all ponh_multi_orig,
	 pon_auction_headers_all ponh_prev,
	 pon_auction_headers_all ponh_next
      WHERE
          inc.primary_key = ponh.auction_header_id
      and (ponh.award_complete_date is not null                  /* Only Published Negotiations are considered */
           OR (doctype.internal_name = 'REQUEST_FOR_INFORMATION' AND ponh.award_status='QUALIFIED')) /* Only Completed RFIs will be included */
      and ponh.auction_header_id = ponip.auction_header_id
      and decode(ponh.award_status, 'QUALIFIED', null, ponh.auction_header_id) = ponbh.auction_header_id(+) /* Include only the Auction Record of RFI and not the Responses */
      and ponbh.auction_header_id = ponbip.auction_header_id(+) /* For Bidded Transactions Only */
      and ponbh.bid_number = ponbip.bid_number(+)
      and nvl(ponbip.line_number,ponip.line_number) = ponip.line_number /* Filter to give unique record */
      and ponbh.auction_header_id = ponbp.auction_header_id(+) /* Join to Bidding Parties to get Supplier Invite Date */
      and ponbh.trading_partner_id = ponbp.trading_partner_id(+)
      and ponbh.vendor_site_id = ponbp.vendor_site_id(+)
      and nvl(ponbh.bid_status,'ACTIVE') = 'ACTIVE'             /* If a Supplier changes bids, they store ARCHIVED. Ignore them. */
      and nvl(ponbip.award_status,'-999') <> 'REJECTED'         /* Cannot be NULL or REJECTED */
--    and ponip.auction_header_id = ponreq.auction_header_id(+) /* If Backing Requisition is available */
--    and ponip.line_number = ponreq.line_number(+)             /* If Backing Requisition is available */
      and ponh_multi.doctype_id = doctype.doctype_id                  /* Join to get document type, particulary for RFI */
      and doctype.transaction_type = 'REVERSE'
      and ponh.org_id = pfsp.org_id
      and pfsp.set_of_books_id = pgl.set_of_books_id
      and pfsp.inventory_organization_id = ppar.organization_id
      and ponip.uom_code = uom.uom_code(+)
      and ponip.item_id = pitem.inventory_item_id(+)
      and inc.txn_cur_code = rat.txn_cur_code
      and inc.func_cur_code = rat.func_cur_code
      and inc.rate_date = rat.rate_date
      and ppar.master_organization_id = nvl(pitem.organization_id, ppar.master_organization_id)
      and ponh.trading_partner_contact_id = hz.party_id
      and ponh_multi.auction_header_id_orig_round = ponh.auction_header_id_orig_round
      and ponh_multi_orig.auction_header_id = ponh_multi.auction_header_id_orig_amend
      and nvl(ponh_multi.auction_header_id_prev_round, ponh_multi.auction_header_id) = ponh_prev.auction_header_id
      and ponh_multi.auction_header_id = ponh_next.auction_header_id_prev_round(+)
      and nvl(ponh_next.auction_status,'AUCTION_CLOSED')='AUCTION_CLOSED'
      and ponh_multi.auction_status = 'AUCTION_CLOSED'
      and ponip.group_type IN ('LINE', 'LOT', 'GROUP_LINE') /* Do not involve Lot Lines and Group */
      and ponh.creation_date > d_glob_date
     ) s
     ON (    t.auction_header_id=s.auction_header_id
         and t.auction_line_number=s.auction_line_number
         and nvl(t.bid_number,-99) = nvl(s.bid_number,-99) /* RFI has NULL in this column */
	 and nvl(t.bid_line_number,-99) = nvl(s.bid_line_number,-99) /* RFI has NULL in this column */
         ) /* These 4 would give unique records */
     WHEN MATCHED THEN UPDATE SET
      t.doctype_id = s.doctype_id,
      t.auction_round_number = s.auction_round_number,
      t.prev_round_auction_header_id = s.prev_round_auction_header_id,
      t.auction_creation_date = s.current_round_creation_date,
      t.publish_date = s.publish_date,
      t.open_bidding_date = s.open_bidding_date,
      t.close_bidding_date = s.close_bidding_date,
      t.prev_round_close_date = s.prev_round_close_date,
      t.next_round_creation_date = s.next_round_creation_date,
      t.award_date = s.award_date,
      t.award_complete_date = s.award_complete_date,
      t.rfi_complete_date = s.rfi_complete_date,
      t.org_id = s.org_id,
      t.negotiation_creator_id = s.negotiation_creator_id,
      t.category_id = s.category_id,
      t.po_item_id = s.po_item_id,
      t.supplier_id = s.supplier_id,
      t.supplier_site_id = s.supplier_site_id,
      t.quantity =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
               decode(s.order_type_lookup_code,'QUANTITY',s.quantity * s.base_uom_conv_rate, to_number(null))
           else
           null
           end
      ),
      t.award_qty =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
               decode(s.order_type_lookup_code,'QUANTITY',s.award_qty * s.base_uom_conv_rate, to_number(null))
           else
           null
           end
      ),
      t.award_price =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
               s.award_price / s.base_uom_conv_rate
           else
           null
           end
      ),
      t.current_price =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
               s.current_price / s.base_uom_conv_rate
           else
	   null
	   end
       ),
      t.award_amount_t =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
               decode(s.award_status,
	                  'COMPLETED',decode(s.order_type_lookup_code, 'QUANTITY', s.award_price * s.award_qty, s.award_price),
			   null
		     )
           else
	   null
	   end
      ),
     t.award_amount_b =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
                 decode(s.award_status,
			  'COMPLETED', decode(s.order_type_lookup_code, 'QUANTITY',s.award_price * s.award_qty * s.func_cur_conv_rate, s.award_price * s.func_cur_conv_rate),
			   null
		        )
           else
	   null
	   end
      ),
      t.award_amount_g =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
               decode(s.award_status,
                          'COMPLETED',
                 	  decode(s.order_type_lookup_code, 'QUANTITY',
		              decode(s.global_cur_conv_rate, 0, s.award_price * s.award_qty, s.award_price * s.award_qty * s.func_cur_conv_rate * s.global_cur_conv_rate),
                              decode(s.global_cur_conv_rate, 0, s.award_price, s.award_price * s.func_cur_conv_rate * s.global_cur_conv_rate)),
     			  null
		     )
           else
	   null
	   end
      ),
      t.award_amount_sg =
       (case
            when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	        and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	        and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
                decode(s.award_status,
		          'COMPLETED',
                           decode(s.order_type_lookup_code, 'QUANTITY',
                              decode(s.sglobal_cur_conv_rate, 0,s.award_price * s.award_qty, s.award_price * s.award_qty * s.func_cur_conv_rate * s.sglobal_cur_conv_rate)),
			  null
		      )
            else
    	    null
	    end
      ),
      t.current_amount_t =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
                      decode(s.order_type_lookup_code,'QUANTITY',s.current_price * s.award_qty, s.current_price)
           else
	   null
	   end
      ),
      t.current_amount_b =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
		   decode(s.order_type_lookup_code, 'QUANTITY',s.current_price * s.award_qty * s.func_cur_conv_rate, s.current_price * s.func_cur_conv_rate)
           else
	   null
	   end
      ),
      t.current_amount_g =
      (case
           when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	       and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	       and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
	          decode(s.order_type_lookup_code, 'QUANTITY',
		     decode(s.global_cur_conv_rate, 0, s.current_price * s.award_qty, s.current_price * s.award_qty * s.func_cur_conv_rate * s.global_cur_conv_rate),
                     decode(s.global_cur_conv_rate,0, s.current_price, s.current_price * s.func_cur_conv_rate * s.global_cur_conv_rate))
           else
	   null
	   end
      ),
      t.current_amount_sg =
       (case
            when    nvl(s.auction_status,'-999') IN ('ACTIVE','AUCTION_CLOSED')  /* Check if COMMIT_ACTIVE needs to be included here */
	        and nvl(s.bid_status,'ACTIVE') = 'ACTIVE'
	        and nvl(s.bid_award_status,'-999') <> 'REJECTED' THEN
		   decode(s.order_type_lookup_code, 'QUANTITY',
		      decode(s.sglobal_cur_conv_rate, 0, s.current_price * s.award_qty, s.current_price * s.award_qty * s.func_cur_conv_rate * s.sglobal_cur_conv_rate),
		      decode(s.sglobal_cur_conv_rate, 0, s.current_price , s.current_price * s.func_cur_conv_rate * s.sglobal_cur_conv_rate))
            else
    	    null
	    end
      ),
      t.line_type_id = s.line_type_id,
      t.order_type_lookup_code = s.order_type_lookup_code,
      t.auction_status = s.auction_status,
      t.award_status = s.award_status,
      t.allocation_status = s.allocation_status,
      t.supplier_invite_date = s.supplier_invite_date,
      t.contract_type = s.contract_type,
      t.po_header_id = s.po_header_id,
--    t.requisition_header_id = s.requisition_header_id,
--    t.requisition_line_id = s.requisition_line_id,
      t.func_cur_code = s.func_cur_code,
      t.func_cur_conv_rate = s.func_cur_conv_rate,
      t.global_cur_conv_rate = s.global_cur_conv_rate,
      t.sglobal_cur_conv_rate = s.sglobal_cur_conv_rate,
      t.base_uom = s.base_uom,
      t.transaction_uom = s.transaction_uom,
      t.base_uom_conv_rate = s.base_uom_conv_rate,
      t.last_update_login = l_login,
      t.last_updated_by = l_user,
      t.last_update_date = l_start_time
    WHEN NOT MATCHED THEN INSERT
    (
      t.auction_header_id ,              /* Auction Header ID */
      t.auction_line_number,             /* Auction Line Number */
      t.bid_number,                      /* Awarded Bid Number */
      t.bid_line_number,                 /* Awarded Bid Line Number */
      t.doctype_id,                      /* Is it an Auction/RFQ/Offer */
      t.auction_round_number,            /* Auction Round Number */
      t.prev_round_auction_header_id,    /* Previous Round Auction Header ID */
      t.auction_creation_date,           /* Auction Creation Date */
      t.publish_date,                    /* Published Date */
      t.open_bidding_date,               /* Opened for Bidding Date */
      t.close_bidding_date,              /* Closed for Bidding Date */
      t.prev_round_close_date,           /* Previous Round Close Bidding Date */
      t.next_round_creation_date,        /* Next Round Creation Date */
      t.award_date,                      /* Award Date */
      t.award_complete_date,             /* Award Complete Date */
      t.rfi_complete_date,               /* RFI Complete Date */
      t.org_id,                          /* OU ID */
      t.negotiation_creator_id,          /* Negotiation Creator ID */
      t.category_id,                     /* Category ID */
      t.po_item_id,                      /* PO Item ID */
      t.supplier_id,                     /* Winning Supplier ID */
      t.supplier_site_id,                /* Winning Supplier Site ID */
      t.quantity,                        /* Requested Quantity */
      t.award_qty,                       /* Awarded Quantity */
      t.award_price,                     /* Awarded Price */
      t.current_price,                   /* Current Price */
      t.award_amount_t,                  /* Awarded Amount in transactional currency */
      t.award_amount_b,                  /* Awarded Amount in functional currency */
      t.award_amount_g,                  /* Awarded Amount in global currency */
      t.award_amount_sg,                 /* Awarded Amount in secondary global currency */
      t.current_amount_t,                /* Current Amount in transactional currency */
      t.current_amount_b,                /* Current Amount in functional currency */
      t.current_amount_g,                /* Current Amount in global currency */
      t.current_amount_sg,               /* Current Amount in secondary global currency */
      t.line_type_id,                    /* Line Type of the Sourcing Line */
      t.order_type_lookup_code,          /* Value basis of the Sourcing Line */
      t.auction_status,                  /* Auction Status */
      t.award_status,                    /* Award Status */
      t.allocation_status,               /* Allocation Status */
      t.received_bid_count,              /* No. of Bids Received for this Sourcing Line */
      t.supplier_invite_date,            /* Date on which Supplier was Invited */
      t.contract_type,                   /* Outcome Document STANDARD/BLANKET */
      t.po_header_id,                    /* PO Header ID of the Outcome Document */
--    t.requisition_header_id,           /* Backing Requisition Header ID */
--    t.requisition_line_id,             /* Backing Requisition Line ID */
      t.func_cur_code,                   /* Functional Currency Code */
      t.func_cur_conv_rate,              /* Functional Currency Conversion Rate */
      t.global_cur_conv_rate,            /* Global Currency Conversion Rate */
      t.sglobal_cur_conv_rate,           /* Secondary Global Currency Conversion Rate */
      t.base_uom,                        /* Base UOM */
      t.transaction_uom,                 /* Transaction UOM */
      t.base_uom_conv_rate,              /* Base UOM conversion rate */
      t.created_by,                      /* WHO Column */
      t.last_update_login,               /* WHO Column */
      t.creation_date,                   /* WHO Column */
      t.last_updated_by,                 /* WHO Column */
      t.last_update_date                 /* WHO Column */
   ) VALUES
   (
      s.auction_header_id,
      s.auction_line_number,
      s.bid_number,
      s.bid_line_number,
      s.doctype_id,
      s.auction_round_number,
      s.prev_round_auction_header_id,
      s.current_round_creation_date,
      s.publish_date,
      s.open_bidding_date,
      s.close_bidding_date,
      s.prev_round_close_date,
      s.next_round_creation_date,
      s.award_date,
      s.award_complete_date,
      s.rfi_complete_date,
      s.org_id,
      s.negotiation_creator_id,
      s.category_id,
      s.po_item_id,
      s.supplier_id,
      s.supplier_site_id,
      decode(s.order_type_lookup_code,'QUANTITY',s.quantity * s.base_uom_conv_rate, to_number(null)),
      decode(s.order_type_lookup_code,'QUANTITY',s.award_qty * s.base_uom_conv_rate, to_number(null)),
      s.award_price / s.base_uom_conv_rate,
      s.current_price / s.base_uom_conv_rate,
      decode(s.award_status,
          'COMPLETED', decode(s.order_type_lookup_code, 'QUANTITY',s.award_price * s.award_qty, s.award_price),
	  'QUALIFIED',0,
	  null
	),
      decode(s.award_status,
          'COMPLETED', decode(s.order_type_lookup_code, 'QUANTITY',s.award_price * s.award_qty * s.func_cur_conv_rate, s.award_price * s.func_cur_conv_rate),
	  'QUALIFIED',0,
  	   null
	 ),
      decode(s.award_status,
          'COMPLETED',
           decode(s.order_type_lookup_code, 'QUANTITY',
             decode(s.global_cur_conv_rate, 0, s.award_price * s.award_qty, s.award_price * s.award_qty * s.func_cur_conv_rate * s.global_cur_conv_rate),
             decode(s.global_cur_conv_rate, 0, s.award_price, s.award_price * s.func_cur_conv_rate * s.global_cur_conv_rate)),
	   'QUALIFIED',0,
	    null
	   ),
      decode(s.award_status,
           'COMPLETED' ,
             decode(s.order_type_lookup_code, 'QUANTITY',
               decode(s.sglobal_cur_conv_rate, 0, s.award_price * s.award_qty, s.award_price * s.award_qty * s.func_cur_conv_rate * s.sglobal_cur_conv_rate),
	       decode(s.sglobal_cur_conv_rate, 0, s.award_price, s.award_price * s.func_cur_conv_rate * s.sglobal_cur_conv_rate)),
	   'QUALIFIED',0,
	    null
            ),
      decode(s.order_type_lookup_code, 'QUANTITY', s.current_price * s.award_qty, s.current_price),
      decode(s.order_type_lookup_code, 'QUANTITY', s.current_price * s.award_qty * s.func_cur_conv_rate, s.current_price * s.func_cur_conv_rate),
      decode(s.order_type_lookup_code, 'QUANTITY',
         decode(s.global_cur_conv_rate, 0, s.current_price * s.award_qty, s.current_price * s.award_qty * s.func_cur_conv_rate * s.global_cur_conv_rate),
         decode(s.global_cur_conv_rate, 0, s.current_price, s.current_price * s.func_cur_conv_rate * s.global_cur_conv_rate)),
      decode(s.order_type_lookup_code, 'QUANTITY',
         decode(s.sglobal_cur_conv_rate, 0, s.current_price * s.award_qty, s.current_price * s.award_qty * s.func_cur_conv_rate * s.sglobal_cur_conv_rate),
         decode(s.sglobal_cur_conv_rate, 0, s.current_price, s.current_price * s.func_cur_conv_rate * s.sglobal_cur_conv_rate)),
      s.line_type_id,
      s.order_type_lookup_code,
      s.auction_status,
      s.award_status,
      s.allocation_status,
      s.received_bid_count,
      s.supplier_invite_date,
      s.contract_type,
      s.po_header_id,
--    s.requisition_header_id,
--    s.requisition_line_id,
      s.func_cur_code,
      s.func_cur_conv_rate,
      s.global_cur_conv_rate,
      s.sglobal_cur_conv_rate,
      decode(s.order_type_lookup_code,'QUANTITY', s.base_uom, null),
      s.transaction_uom,
      s.base_uom_conv_rate,
      l_user,
      l_login,
      l_start_time,
      l_user,
      l_start_time
     );
     COMMIT;
    DBMS_APPLICATION_INFO.SET_ACTION('batch ' || v_batch_no || ' done');
    END LOOP;
    END IF;
 END IF;
    bis_collection_utilities.log('Collection complete '|| 'Sysdate=' ||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
    bis_collection_utilities.wrapup(TRUE, l_count, 'POA_DBI_NEG_F COLLECTION SUCEEDED', to_date(l_start_date, '''YYYY/MM/DD HH24:MI:SS'''), To_date(l_end_date, '''YYYY/MM/DD HH24:MI:SS'''));
    g_init := false;
    dbms_application_info.set_module(null, null);
  EXCEPTION
   WHEN others THEN
      dbms_application_info.set_action('error');
      errbuf:=sqlerrm;
      retcode:=sqlcode;
      bis_collection_utilities.log('Collection failed with '||errbuf||':'||retcode||' Sysdate=' ||to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'), 0);
      bis_collection_utilities.wrapup(FALSE, l_count, errbuf||':'||retcode, to_date(l_start_date, '''YYYY/MM/DD HH24:MI:SS'''), to_date(l_end_date, '''YYYY/MM/DD HH24:MI:SS'''));
      RAISE;
  END populate_neg_facts;

END POA_DBI_NEG_F_C;

/
