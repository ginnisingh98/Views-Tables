--------------------------------------------------------
--  DDL for Package Body ISC_FS_INV_USG_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_INV_USG_ETL_PKG" AS
/*$Header: iscfsinvetlb.pls 120.2 2006/05/04 17:07:10 kreardon noship $ */

g_pkg_name constant varchar2(30) := 'ISC_FS_INV_USG_ETL_PKG';
g_sysdate DATE := SYSDATE;
g_user_id NUMBER := nvl(fnd_global.user_id, -1);
g_login_id NUMBER := nvl(fnd_global.login_id, -1);
g_last_collection_date DATE;
g_ok NUMBER(1) := 0;
g_warning NUMBER(1) := 1;
g_error NUMBER(1) := -1;
g_program_id             NUMBER := fnd_global.CONC_PROGRAM_ID;
g_program_login_id       NUMBER := fnd_global.CONC_LOGIN_ID;
g_program_application_id NUMBER := fnd_global.PROG_APPL_ID;
g_request_id             NUMBER := fnd_global.CONC_REQUEST_ID;
g_bis_setup_exception exception;
g_object_name constant varchar2(30) := 'ISC_FS_INV_USG_FACT';


PROCEDURE LOGGER
( p_proc_name varchar2
, p_stmt_id number
, p_message varchar2
)
AS
BEGIN
  bis_collection_utilities.log( g_pkg_name || '.' || p_proc_name ||
                                ' #' || p_stmt_id || ' ' ||
                                p_message
                              , 3 );
END LOGGER;


FUNCTION GET_SCHEMA_NAME
( x_schema_name   out nocopy varchar2
, x_error_message out nocopy varchar2 )
RETURN number
AS
  l_isc_schema   varchar2(30);
  l_status       varchar2(30);
  l_industry     varchar2(30);

BEGIN

  if fnd_installation.get_app_info('ISC', l_status, l_industry, l_isc_schema) then
    x_schema_name := l_isc_schema;
  else
    x_error_message := 'FND_INSTALLATION.GET_APP_INFO returned false';
    return -1;
  end if;

  RETURN 0;

EXCEPTION
  WHEN others THEN
    x_error_message := 'Error in function get_schema_name : ' || sqlerrm;
    RETURN -1;

END GET_SCHEMA_NAME;


FUNCTION TRUNCATE_TABLE
( p_isc_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2 )
RETURN number
AS
BEGIN

  execute immediate 'truncate table ' || p_isc_schema || '.' || p_table_name;

  RETURN 0;

EXCEPTION
  WHEN others THEN
    x_error_message  := 'Error in function truncate_table : ' || sqlerrm;
    RETURN -1;

END TRUNCATE_TABLE;


FUNCTION GATHER_STATISTICS
( p_isc_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2 )
RETURN number
AS
BEGIN

  fnd_stats.gather_table_stats( ownname => p_isc_schema
                              , tabname => p_table_name
                              );

  RETURN 0;

EXCEPTION
  WHEN others THEN
    x_error_message  := 'Error in function gather_statistics : ' || sqlerrm;
    RETURN -1;

END GATHER_STATISTICS;


FUNCTION COMPUTE_INV_CONV_RATES
( p_isc_schema in varchar2
, x_error_message out nocopy varchar2 )
RETURN NUMBER AS

  l_proc_name constant varchar2(30):= 'COMPUTE_INV_CONV_RATES';
  l_stmt_num number;

  l_global_currency_code1 varchar2(15);
  l_global_rate_type1 varchar2(15);
  l_global_currency_code2 varchar2(15);
  l_global_rate_type2 varchar2(15);

  /* EURO currency became official on 01-JAN-1999 */
  l_euro_start_date constant date := to_date ('01/01/1999', 'mm/dd/yyyy');

  /* GL API returns -3 if EURO rate missing on 01-JAN-1999 */
  l_euro_missing_at_start constant number := -3;

  l_all_rates_found boolean;

  -- Set up a cursor to get all the invalid rates.
  -- By the logic of the fii_currency.get_global_rate_primary
  -- API, the returned value is -ve if no rate exists:
  -- -1 for dates with no rate.
  -- -2 for unrecognized conversion rates.
  -- Also, cross check with the org-date pairs in the staging table,
  -- in case some orgs never had a functional currency code defined.
  CURSOR c_invalid_rates IS
    SELECT DISTINCT
      mp.organization_code
    , decode( least( r.conversion_rate1, r.conversion_rate2 )
            , l_euro_missing_at_start, l_euro_start_date
            , r.transaction_date) transaction_date
    , r.base_currency_code
    , nvl(r.conversion_rate1, -999) primary_rate
    , nvl(r.conversion_rate2, -999) secondary_rate
    FROM
      isc_fs_inv_usg_conv_rates r
    , mtl_parameters mp
    , ( SELECT /*+ index_ffs(isc_fs_inv_usg_value_stg) */ DISTINCT
          organization_id
        , transaction_date
        FROM isc_fs_inv_usg_value_stg
      ) s
    WHERE ( nvl(r.conversion_rate1, -999) < 0 OR
            nvl(r.conversion_rate2, -999) < 0 )
    AND mp.organization_id = s.organization_id
    AND r.transaction_date (+) = s.transaction_date
    AND r.organization_id (+) = s.organization_id;

  l_exception EXCEPTION;
  l_err_msg varchar2(4000);
  l_row_count number;

BEGIN

  BIS_COLLECTION_UTILITIES.LOG( 'Begin Currency Conversion', 1 );

  -- get the primary global currency code
  l_stmt_num := 10;
  l_global_currency_code1 := BIS_COMMON_PARAMETERS.GET_CURRENCY_CODE;
  IF l_global_currency_code1 IS NULL THEN
    l_err_msg := 'Unable to get primary global currency code.';
    logger( l_proc_name, l_stmt_num, l_err_msg );
    RAISE l_exception;
  END IF;

  BIS_COLLECTION_UTILITIES.LOG( 'Primary global currency code: ' || l_global_currency_code1, 2
);

  -- get the primary global rate type
  l_stmt_num := 20;
  l_global_rate_type1 := bis_common_parameters.get_rate_type;
  IF l_global_rate_type1 IS NULL THEN
    l_err_msg := 'Unable to get primary global rate type.';
    logger( l_proc_name, l_stmt_num, l_err_msg );
    RAISE l_exception;
  END IF;

  BIS_COLLECTION_UTILITIES.LOG( 'Primary global rate type: ' || l_global_rate_type1, 2 );

  -- get the secondary global currency code
  l_stmt_num := 30;
  l_global_currency_code2 := bis_common_parameters.get_secondary_currency_code;

  IF l_global_currency_code2 IS NOT NULL THEN
    BIS_COLLECTION_UTILITIES.LOG( 'Secondary global currency code: ' ||
l_global_currency_code2, 2 );
  ELSE
    BIS_COLLECTION_UTILITIES.LOG( 'Secondary global currency code is not defined', 2 );
  END IF;

  -- get the secondary global rate type
  l_stmt_num := 40;
  l_global_rate_type2 := bis_common_parameters.get_secondary_rate_type;
  IF l_global_rate_type2 IS NULL AND l_global_currency_code2 IS NOT NULL THEN
    l_err_msg := 'Unable to get secondary global rate type.';
    LOGGER( l_proc_name, l_stmt_num, l_err_msg );
    RAISE l_exception;
  END IF;

  IF l_global_currency_code2 IS NOT NULL THEN
    BIS_COLLECTION_UTILITIES.LOG( 'Secondary global rate type: ' || l_global_rate_type2, 2 );
  END IF;

  -- truncate the conversion rates work table
  l_stmt_num := 50;
  IF truncate_table
     ( p_isc_schema
     , 'ISC_FS_INV_USG_CONV_RATES'
     , l_err_msg ) <> 0 THEN
    LOGGER( l_proc_name, l_stmt_num, l_err_msg );
    RAISE l_exception;
  END IF;

  BIS_COLLECTION_UTILITIES.LOG( 'Currency conversion table truncated', 2 );

  -- Get all the distinct organization and date pairs and the
  -- base currency codes for the orgs into the conversion rates
  -- work table.

  -- Use the fii_currency.get_global_rate_primary function to get the
  -- conversion rate given a currency code and a date.
  -- only attempt to get conversion rate for rows that are complete
  -- (have complete_flag = 'Y')
  --
  -- The function returns:
  -- 1 for currency code when is the global currency
  -- -1 for dates for which there is no currency conversion rate
  -- -2 for unrecognized currency conversion rates

  -- By selecting distinct org and currency code from the gl_set_of_books
  -- and hr_organization_information, take care of duplicate codes.

  l_stmt_num := 60;
  INSERT /*+ append */
  INTO ISC_FS_INV_USG_CONV_RATES
  ( organization_id
  , transaction_date
  , base_currency_code
  , conversion_rate1
  , conversion_rate2
  , creation_date
  , last_update_date
  , created_by
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  SELECT
    s.organization_id
  , s.transaction_date
  , c.currency_code
  , fii_currency.get_global_rate_primary
                              ( c.currency_code
                              , s.transaction_date )  conversion_rate1
  , decode( l_global_currency_code2
          , null, 0 -- only attempt conversion if secondary currency defined
          , fii_currency.get_global_rate_secondary
                              ( c.currency_code
                              , s.transaction_date )
          ) conversion_rate2
  , g_sysdate
  , g_sysdate
  , g_user_id
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  FROM
    ( SELECT /*+ index_ffs(isc_fs_inv_usg_value_stg)
                 parallel_index(isc_fs_inv_usg_value_stg) */ DISTINCT
        organization_id
      , transaction_date
      FROM
        ISC_FS_INV_USG_VALUE_STG
    ) s
  , ( SELECT DISTINCT
        hoi.organization_id
      , gsob.currency_code
      FROM
        hr_organization_information hoi
      , gl_sets_of_books gsob
      WHERE hoi.org_information_context  = 'Accounting Information'
      AND hoi.org_information1  = to_char(gsob.set_of_books_id)
    ) c
  WHERE c.organization_id  = s.organization_id;

  l_row_count := sql%rowcount;
  COMMIT;

  BIS_COLLECTION_UTILITIES.LOG( l_row_count || ' rows inserted into currency conversion
table', 2 );

  l_all_rates_found := true;

  -- gather statistics on conversion rates table before returning
  l_stmt_num := 70;
  IF GATHER_STATISTICS
     ( p_isc_schema
     , 'ISC_FS_INV_USG_CONV_RATES'
     , l_err_msg ) <> 0 then
    LOGGER( l_proc_name, l_stmt_num, l_err_msg );
    RAISE l_exception;
  END IF;

  BIS_COLLECTION_UTILITIES.LOG( 'Currency conversion table analyzed', 2 );

  -- Check that all rates have been found and are non-negative.
  -- If there is a problem, notify user.
  l_stmt_num := 80;
  FOR invalid_rate_rec IN c_invalid_rates LOOP

    -- print the header out
    IF c_invalid_rates%rowcount = 1 THEN
      bis_collection_utilities.writeMissingRateHeader;
    END IF;

    l_all_rates_found := false;

    IF invalid_rate_rec.primary_rate < 0 THEN
      bis_collection_utilities.writeMissingRate
      ( l_global_rate_type1
      , invalid_rate_rec.base_currency_code
      , l_global_currency_code1
      , invalid_rate_rec.transaction_date );
    END IF;

    IF invalid_rate_rec.secondary_rate < 0 THEN
      bis_collection_utilities.writeMissingRate
      ( l_global_rate_type2
      , invalid_rate_rec.base_currency_code
      , l_global_currency_code2
      , invalid_rate_rec.transaction_date );
    END IF;

  END LOOP;

  -- If all rates not found raise an exception
  IF NOT l_all_rates_found THEN
    l_err_msg := 'Missing currency rates exist.';
    LOGGER( l_proc_name, l_stmt_num, l_err_msg );
    RAISE l_exception;
  END IF;

  BIS_COLLECTION_UTILITIES.LOG( 'End Currency Conversion', 1 );

  RETURN g_ok;

EXCEPTION

  WHEN l_exception THEN
    x_error_message := l_err_msg;
    RETURN g_error;

  WHEN others THEN
    ROLLBACK;
    l_err_msg := substr( sqlerrm, 1, 4000 );
    LOGGER( l_proc_name, l_stmt_num, l_err_msg );
    x_error_message := 'Load conversion rate computation failed';
    RETURN g_error;

END COMPUTE_INV_CONV_RATES;


-- -------------------------------------------------------------------
-- PUBLIC PROCEDURES
-- -------------------------------------------------------------------

PROCEDURE GET_INV_USG_INITIAL_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY
varchar2)
IS
 l_proc_name constant varchar2(30) := 'GET_INV_USG_INITIAL_LOAD';
 l_stmt_num        NUMBER;
 l_row_count   	   NUMBER;
 l_err_num 	   NUMBER;
 l_err_msg 	   VARCHAR2(255);
 l_exception exception;
 l_isc_schema      VARCHAR2(30);
 l_status          VARCHAR2(30);
 l_industry        VARCHAR2(30);
 l_list dbms_sql.varchar2_table;
BEGIN

 l_list(1) := 'BIS_GLOBAL_START_DATE';

 BIS_COLLECTION_UTILITIES.LOG( 'Begin Initial Load' );

 IF (bis_common_parameters.check_global_parameters(l_list)) THEN

	 l_stmt_num := 0;
	 IF NOT BIS_COLLECTION_UTILITIES.SETUP( g_object_name ) THEN
	   l_err_msg := 'Error in BIS_COLLECTION_UTILITIES.Setup';
	   LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	   RAISE g_bis_setup_exception;
	 END IF;

	  -- get the isc schema name
	 l_stmt_num := 5;
	 IF get_schema_name
	    ( l_isc_schema
	    , l_err_msg ) <> 0 THEN
	   LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	   RAISE l_exception;
	 END IF;

	 -- truncate the Log table
	 l_stmt_num := 10;
	 IF truncate_table
	    ( l_isc_schema
	    , 'ISC_FS_INV_USG_LOG'
	    , l_err_msg ) <> 0 THEN
	   LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	   RAISE l_exception;
	 END IF;

	 BIS_COLLECTION_UTILITIES.LOG( 'Log table truncated', 1 );

	 /* Insert into our log table the upper transaction boundaries for every organization to
	  be extracted. We will access OPI_DBI_CONC_PROG_RUN_LOG to obtain these upper boundaries. The
	 incremental load will use these boundaries as starting points. */

	 l_stmt_num := 20;
	 INSERT INTO ISC_FS_INV_USG_LOG
	 (
		 ORGANIZATION_ID
		,FROM_TRANSACTION_ID
		,TO_TRANSACTION_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,PROGRAM_ID
		,PROGRAM_LOGIN_ID
		,PROGRAM_APPLICATION_ID
		,REQUEST_ID
	 )
	 SELECT
	 	 from_to_txn.BOUND_LEVEL_ENTITY_ID organization_id
		,min(from_to_txn.FROM_BOUND_ID) FROM_TRANSACTION_ID
		,case
		     when nvl(max(from_to_txn_incr.TO_BOUND_ID),-99) > max(from_to_txn.TO_BOUND_ID) then max(from_to_txn_incr.TO_BOUND_ID)
	             else max(from_to_txn.TO_BOUND_ID)
		 end TO_TRANSACTION_ID  /* The to_transaction_id must come from the INCR row if there is one */
		 /* the nvl is in case the inventory page incremental has not been run yet */
		,g_user_id
		,g_sysdate
		,g_sysdate
		,g_user_id
		,g_login_id
		,g_program_id
		,g_program_login_id
		,g_program_application_id
		,g_request_id
	 FROM
		  OPI_DBI_CONC_PROG_RUN_LOG from_to_txn
		 ,OPI_DBI_CONC_PROG_RUN_LOG from_to_txn_incr
		  /* Change in Boundaries Log table in OPI caused a change in how our code handles MMT boundaries */
	 WHERE
	   	  from_to_txn.etl_type = 'INVENTORY'
	  AND from_to_txn.BOUND_TYPE = 'ID'
  	  AND from_to_txn.DRIVING_TABLE_CODE = 'MMT'
	  AND from_to_txn.LOAD_TYPE = 'INIT'
	  AND from_to_txn.BOUND_LEVEL_ENTITY_CODE = 'ORGANIZATION'
      AND from_to_txn_incr.etl_type (+) = 'INVENTORY'
      AND from_to_txn_incr.BOUND_TYPE (+) = 'ID'
      AND from_to_txn_incr.DRIVING_TABLE_CODE (+) = 'MMT'
      AND from_to_txn_incr.LOAD_TYPE (+) = 'INCR'
      AND from_to_txn_incr.BOUND_LEVEL_ENTITY_CODE (+) = 'ORGANIZATION'
	  AND from_to_txn.BOUND_LEVEL_ENTITY_ID = from_to_txn_incr.BOUND_LEVEL_ENTITY_ID (+)
	 GROUP BY
	  from_to_txn.BOUND_LEVEL_ENTITY_ID
	 UNION /* This union is for Organizations that were created after initial load of inventory page */
 	 SELECT
	 	 from_to_txn.BOUND_LEVEL_ENTITY_ID organization_id
		,-1 FROM_TRANSACTION_ID
		/* Organizations that were created after initial load of inventory page,
		hence after GSD, do not have INIT rows */
		,from_to_txn.TO_BOUND_ID TO_TRANSACTION_ID
		,g_user_id
		,g_sysdate
		,g_sysdate
		,g_user_id
		,g_login_id
		,g_program_id
		,g_program_login_id
		,g_program_application_id
		,g_request_id
	 FROM
		 OPI_DBI_CONC_PROG_RUN_LOG from_to_txn
		  /* Change in Boundaries Log table in OPI caused a change in how our code handles MMT boundaries */
	 WHERE
	   	  from_to_txn.etl_type = 'INVENTORY'
	  AND from_to_txn.BOUND_TYPE = 'ID'
  	  AND from_to_txn.DRIVING_TABLE_CODE = 'MMT'
	  AND from_to_txn.LOAD_TYPE = 'INCR'
	  AND from_to_txn.BOUND_LEVEL_ENTITY_CODE = 'ORGANIZATION'
	  AND not exists (SELECT 'X' FROM OPI_DBI_CONC_PROG_RUN_LOG olog
                   	  WHERE
					    olog.etl_type = 'INVENTORY'
					  AND olog.BOUND_TYPE = 'ID'
				  	  AND olog.DRIVING_TABLE_CODE = 'MMT'
					  AND olog.LOAD_TYPE = 'INIT'
					  AND from_to_txn.BOUND_LEVEL_ENTITY_ID = olog.BOUND_LEVEL_ENTITY_ID);

	 -- truncate the staging table
	 l_stmt_num := 30;
	 IF TRUNCATE_TABLE
	    ( l_isc_schema
	    , 'ISC_FS_INV_USG_VALUE_STG'
	    , l_err_msg ) <> 0 THEN
	   LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	   RAISE l_exception;
	 END IF;

	 BIS_COLLECTION_UTILITIES.LOG( 'Staging table truncated', 1 );

	 l_stmt_num := 40;
	 /* Insert field service material issue transaction values into staging table */
	 INSERT /*+ append parallel(ISC_FS_INV_USG_VALUE_STG) */ INTO ISC_FS_INV_USG_VALUE_STG
	 (
		 ORGANIZATION_ID
		,SUBINVENTORY_CODE
		,TRANSACTION_DATE
		,INVENTORY_ITEM_ID
		,ONHAND_VALUE_B
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,PROGRAM_ID
		,PROGRAM_LOGIN_ID
		,PROGRAM_APPLICATION_ID
		,REQUEST_ID
	 )
	 SELECT	 /*+ ordered use_hash(mmt,mta,bound) swap_join_inputs(bound)
           parallel(mmt) parallel(mta) pq_distribute(mta,hash,hash) pq_distribute(bound,none,broadcast) */
	 	 mta.ORGANIZATION_ID
		,mmt.SUBINVENTORY_CODE
		,trunc(mta.TRANSACTION_DATE) TRANSACTION_DATE
		,mta.INVENTORY_ITEM_ID
		,SUM(mta.BASE_TRANSACTION_VALUE)*(-1) ONHAND_VALUE_B /* Issue transactions are
expressed in negative numbers	*/
		,g_user_id
		,g_sysdate
		,g_sysdate
		,g_user_id
		,g_login_id
		,g_program_id
		,g_program_login_id
		,g_program_application_id
		,g_request_id
	 FROM
		(SELECT
			 csi1.organization_id
			,csi1.SECONDARY_INVENTORY_NAME
			,cutt.TRANSACTION_TYPE_ID
			,mtt.TRANSACTION_ACTION_ID
			,mtt.TRANSACTION_SOURCE_TYPE_ID
		FROM
			 CSP_PLANNING_PARAMETERS cpp
			,CSP_USG_TRANSACTION_TYPES cutt
			,CSP_SEC_INVENTORIES csi1
			,MTL_TRANSACTION_TYPES mtt
		WHERE
			cpp.FORECAST_RULE_ID = cutt.FORECAST_RULE_ID
		and csi1.organization_id = cpp.organization_id
		and csi1.SECONDARY_INVENTORY_NAME = cpp.SECONDARY_INVENTORY
		and csi1.CONDITION_TYPE = 'G' /* Usable Subinventory */
		and mtt.TRANSACTION_TYPE_ID = cutt.TRANSACTION_TYPE_ID
		and mtt.TRANSACTION_ACTION_ID = 1 	/* Issue */
		UNION
		SELECT /* For subinventories without forecast rule defined: Use this default
transaction type */
			 csi2.organization_id
			,csi2.SECONDARY_INVENTORY_NAME
			,93 transaction_type_id  /* Field Service Usage transaction type */
			,1  TRANSACTION_ACTION_ID
			,13 TRANSACTION_SOURCE_TYPE_ID
		FROM
			 CSP_SEC_INVENTORIES csi2
		WHERE
			csi2.CONDITION_TYPE = 'G' /* Usable Subinventory */
			and not exists
			(select 'x' from CSP_PLANNING_PARAMETERS cpp
			 where cpp.organization_id = csi2.organization_id
			   and cpp.SECONDARY_INVENTORY = csi2.secondary_inventory_name
			   and cpp.forecast_rule_id is not null) /* Do not include subinventories that
have forecast rules defined */
			) sec
		,mtl_material_transactions mmt
		,ISC_FS_INV_USG_LOG bound /* Obtain the transaction boundaries from our log table */
		,mtl_transaction_accounts mta
	 WHERE
	 	mmt.organization_id = sec.organization_id
	  and mmt.SUBINVENTORY_CODE = sec.SECONDARY_INVENTORY_NAME
	  and mmt.TRANSACTION_ACTION_ID = sec.TRANSACTION_ACTION_ID
	  and mmt.TRANSACTION_TYPE_ID  = sec.TRANSACTION_TYPE_ID
	  and mmt.TRANSACTION_SOURCE_TYPE_ID = sec.TRANSACTION_SOURCE_TYPE_ID
	  and mmt.organization_id = bound.organization_id
	  /* Note that the boundary conditions have changed from > to >= and from <= to < due to changes in OPI's log table logic */
	  and mmt.transaction_id >= bound.from_transaction_id
	  and mmt.transaction_id < bound.to_transaction_id
  	  and mta.accounting_line_type = 1 /* Inventory Valuation */
	  and mta.transaction_id = mmt.transaction_id
	 GROUP BY
	 	 mta.ORGANIZATION_ID
		,mmt.SUBINVENTORY_CODE
		,mta.INVENTORY_ITEM_ID
		,trunc(mta.TRANSACTION_DATE);

	 l_row_count := sql%rowcount;
	 COMMIT;

	 BIS_COLLECTION_UTILITIES.LOG( l_row_count || ' rows inserted into staging table', 1 );

	 -- gather statistics on staging table before computing
	 -- conversion rates
	 l_stmt_num := 50;
	 IF GATHER_STATISTICS
	    ( l_isc_schema
	    , 'ISC_FS_INV_USG_VALUE_STG'
	    , l_err_msg ) <> 0 THEN
	   LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	   RAISE l_exception;
	 END IF;

	 BIS_COLLECTION_UTILITIES.LOG( 'Staging table analyzed', 1 );

	 -- check currency conversion rates
	 l_stmt_num := 60;
	 IF COMPUTE_INV_CONV_RATES
	    ( l_isc_schema
	    , l_err_msg ) <> 0 THEN
	   LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	   RAISE l_exception;
	 END IF;

	 -- truncate the fact table
	 l_stmt_num := 70;
	 IF TRUNCATE_TABLE
	    ( l_isc_schema
	    , 'ISC_FS_INV_USG_VALUE_F PURGE MATERIALIZED VIEW LOG'
	    , l_err_msg ) <> 0 THEN
	   LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	   RAISE l_exception;
	 END IF;

	 BIS_COLLECTION_UTILITIES.LOG( 'Base summary table truncated', 1 );

	 /* Insert field service inventory usage value data into the DBI Field Service Inventory
	  Usage Value Base Summary table based on Staging table and Current Conversion table */
	 l_stmt_num := 80;
	 INSERT /* append parallel(f) */ INTO ISC_FS_INV_USG_VALUE_F f
	 (
		 ORGANIZATION_ID
		,SUBINVENTORY_CODE
		,TRANSACTION_DATE
		,INVENTORY_ITEM_ID
		,ONHAND_VALUE_B
		,PRIM_CONVERSION_RATE
		,SEC_CONVERSION_RATE
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,PROGRAM_ID
		,PROGRAM_LOGIN_ID
		,PROGRAM_APPLICATION_ID
		,REQUEST_ID
		)
	 SELECT /* parallel(s) parallel(c) */
		 s.ORGANIZATION_ID
		,s.SUBINVENTORY_CODE
		,s.TRANSACTION_DATE
		,s.INVENTORY_ITEM_ID
		,s.ONHAND_VALUE_B
		,c.conversion_rate1
		,c.conversion_rate2
		,g_user_id
		,g_sysdate
		,g_sysdate
		,g_user_id
		,g_login_id
		,g_program_id
		,g_program_login_id
		,g_program_application_id
		,g_request_id
	 FROM
		 ISC_FS_INV_USG_VALUE_STG s
		,ISC_FS_INV_USG_CONV_RATES c
	 WHERE
			  c.organization_id = s.organization_id
	 AND c.transaction_date = s.transaction_date;

	 l_row_count := sql%rowcount;
	 COMMIT;

	 BIS_COLLECTION_UTILITIES.LOG( l_row_count || ' rows inserted into base summary', 1 );

	 -- cleanup staging/currency conversion tables
	 l_stmt_num := 90;
	 IF TRUNCATE_TABLE
	     ( l_isc_schema
	     , 'ISC_FS_INV_USG_VALUE_STG'
	     , l_err_msg ) <> 0 THEN
	    LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	    RAISE l_exception;
	 END IF;

	 BIS_COLLECTION_UTILITIES.LOG( 'Staging table truncated', 1 );

	 l_stmt_num := 100;
	 IF TRUNCATE_TABLE
	     ( l_isc_schema
	     , 'ISC_FS_INV_USG_CONV_RATES'
	     , l_err_msg ) <> 0 THEN
	    LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	    RAISE l_exception;
	 END IF;

	 BIS_COLLECTION_UTILITIES.LOG( 'Currency conversion table truncated', 1 );

	 l_stmt_num := 110;
	 BIS_COLLECTION_UTILITIES.WRAPUP(
	    p_status => TRUE,
	    p_count => l_row_count,
	    p_message => 'Successfully loaded Field Service Inventory Usage Base Table at ' ||
TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
	 );

	 BIS_COLLECTION_UTILITIES.LOG('End Initial Load');

	 errbuf := null;
	 retcode := g_ok;

 ELSE
     retcode := g_error;
     BIS_COLLECTION_UTILITIES.LOG('Global Parameters are not setup.');
     BIS_COLLECTION_UTILITIES.LOG('Please check that the profile option BIS_GLOBAL_START_DATE
is setup.');

 END IF;

EXCEPTION
  WHEN OTHERS THEN
    rollback;
    IF l_err_msg is null THEN
      l_err_msg := substr(sqlerrm,1,4000);
    END IF;
    BIS_COLLECTION_UTILITIES.WRAPUP( p_status => FALSE
                                   , p_message => l_err_msg
                                   );
    errbuf := l_err_msg;
    retcode := g_error;

END GET_INV_USG_INITIAL_LOAD;



PROCEDURE GET_INV_USG_INCREMENTAL_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY
varchar2)
IS
 l_proc_name constant varchar2(30) := 'GET_INV_USG_INCREMENTAL_LOAD';
 l_stmt_num        NUMBER;
 l_row_count   	   NUMBER;
 l_err_num 	   NUMBER;
 l_err_msg 	   VARCHAR2(255);
 l_exception exception;
 l_isc_schema      VARCHAR2(30);
 l_status          VARCHAR2(30);
 l_industry        VARCHAR2(30);
 l_list dbms_sql.varchar2_table;
BEGIN

 l_list(1) := 'BIS_GLOBAL_START_DATE';

 BIS_COLLECTION_UTILITIES.LOG( 'Begin Incremental Load' );

 IF (bis_common_parameters.check_global_parameters(l_list)) THEN

	l_stmt_num := 0;
	IF NOT BIS_COLLECTION_UTILITIES.SETUP( g_object_name ) THEN
	 l_err_msg := 'Error in BIS_COLLECTION_UTILITIES.Setup';
	 LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	 RAISE g_bis_setup_exception;
	END IF;

	/* Update or insert into our log table the new upper transaction boundaries for every
	organization to be extracted. We will access OPI_DBI_INV_VALUE_LOG to obtain these upper
	boundaries. The next incremental load will use these boundaries as starting points.
	(Note: We will be using the from transaction id column to store the upper transaction
	boundary momentarily during the collection since the to transaction id column already
	stores the lower transaction id. At the end of the collection we will swith the from and
	to boundaries.) */

	l_stmt_num := 5;
	MERGE INTO ISC_FS_INV_USG_LOG bivlog USING
	(
	 /* This select statement has changed due to OPI changes in its Boundaries log table */
	 SELECT
	  	 from_to_txn.BOUND_LEVEL_ENTITY_ID organization_id
		,from_to_txn.TO_BOUND_ID FROM_TRANSACTION_ID
		/* This will become the To transaction at the end of the collection. We are temporarily storing the To boundary
		   in the from transaction column */
	 FROM
		  OPI_DBI_CONC_PROG_RUN_LOG from_to_txn
	 WHERE
	   	  from_to_txn.etl_type = 'INVENTORY'
	  AND from_to_txn.BOUND_TYPE = 'ID'
  	  AND from_to_txn.DRIVING_TABLE_CODE = 'MMT'
	  AND from_to_txn.LOAD_TYPE = 'INCR'
	  AND from_to_txn.BOUND_LEVEL_ENTITY_CODE = 'ORGANIZATION'
	) opilog
	ON (bivlog.organization_id = opilog.organization_id)
	WHEN matched THEN
	UPDATE SET
		 bivlog.FROM_TRANSACTION_ID = opilog.FROM_TRANSACTION_ID
		,bivlog.LAST_UPDATE_DATE = g_sysdate
		,bivlog.LAST_UPDATED_BY = g_user_id
		,bivlog.LAST_UPDATE_LOGIN = g_login_id
		,bivlog.PROGRAM_ID = g_program_id
		,bivlog.PROGRAM_LOGIN_ID = g_program_login_id
		,bivlog.PROGRAM_APPLICATION_ID = g_program_application_id
		,bivlog.REQUEST_ID = g_request_id
	WHEN NOT matched THEN
	INSERT /* If new organization has been created after field service collection */
	(
	 ORGANIZATION_ID
	,FROM_TRANSACTION_ID
	,TO_TRANSACTION_ID
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,PROGRAM_ID
	,PROGRAM_LOGIN_ID
	,PROGRAM_APPLICATION_ID
	,REQUEST_ID
	)
	VALUES
	(
	 opilog.ORGANIZATION_ID
	,opilog.FROM_TRANSACTION_ID /* This temporarily contains the To transaction boundary */
	,-1 /* It will become the from transaction id at the end of the collection */
	/* We use -1 because the OPI Incremental could have run more than once since
	   the last time the Field Service Incremental was run */
	,g_user_id
	,g_sysdate
	,g_sysdate
	,g_user_id
	,g_login_id
	,g_program_id
	,g_program_login_id
	,g_program_application_id
	,g_request_id
	);

	BIS_COLLECTION_UTILITIES.LOG( 'Log Table updated', 1);

	-- get the isc schema name
	l_stmt_num := 10;
	IF get_schema_name
	  ( l_isc_schema
	  , l_err_msg ) <> 0 THEN
	 LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	 RAISE l_exception;
	END IF;

	-- truncate the staging table
	l_stmt_num := 20;
	IF truncate_table
	  ( l_isc_schema
	  , 'ISC_FS_INV_USG_VALUE_STG'
	  , l_err_msg ) <> 0 THEN
	 LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	 RAISE l_exception;
	END IF;

	BIS_COLLECTION_UTILITIES.LOG( 'Staging table truncated', 1);

	/* Insert field service material issue transaction values into staging table */
	l_stmt_num := 30;
	INSERT /*+ append parallel(ISC_FS_INV_USG_VALUE_STG) */ INTO ISC_FS_INV_USG_VALUE_STG
	(
	 ORGANIZATION_ID
	,SUBINVENTORY_CODE
	,TRANSACTION_DATE
	,INVENTORY_ITEM_ID
	,ONHAND_VALUE_B
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,PROGRAM_ID
	,PROGRAM_LOGIN_ID
	,PROGRAM_APPLICATION_ID
	,REQUEST_ID
	)
	SELECT
	 mta.ORGANIZATION_ID
	,mmt.SUBINVENTORY_CODE
	,trunc(mta.TRANSACTION_DATE) TRANSACTION_DATE
	,mta.INVENTORY_ITEM_ID
	,SUM(mta.BASE_TRANSACTION_VALUE)*(-1) ONHAND_VALUE_B /* Issue transactions are expressed
in negative numbers */
	,g_user_id
	,g_sysdate
	,g_sysdate
	,g_user_id
	,g_login_id
	,g_program_id
	,g_program_login_id
	,g_program_application_id
	,g_request_id
	FROM
	mtl_transaction_accounts mta,
	(SELECT
		 csi1.organization_id
		,csi1.SECONDARY_INVENTORY_NAME
		,cutt.TRANSACTION_TYPE_ID
		,mtt.TRANSACTION_ACTION_ID
		,mtt.TRANSACTION_SOURCE_TYPE_ID
	FROM
		CSP_PLANNING_PARAMETERS cpp,
		CSP_USG_TRANSACTION_TYPES cutt,
		CSP_SEC_INVENTORIES csi1,
		MTL_TRANSACTION_TYPES mtt
	WHERE
		cpp.FORECAST_RULE_ID = cutt.FORECAST_RULE_ID
		AND csi1.organization_id = cpp.organization_id
		AND csi1.SECONDARY_INVENTORY_NAME = cpp.SECONDARY_INVENTORY
		AND csi1.CONDITION_TYPE = 'G' 	/* Usable Subinventory */
		AND mtt.TRANSACTION_TYPE_ID = cutt.TRANSACTION_TYPE_ID
		AND mtt.TRANSACTION_ACTION_ID = 1 	/* Issue */
	UNION
	SELECT /* For subinventories without forecast rule defined: Use this default transaction
type */
		 csi2.organization_id
		,csi2.SECONDARY_INVENTORY_NAME
		,93 transaction_type_id	   /* Field Service Usage transaction type */
		,1  TRANSACTION_ACTION_ID
		,13 TRANSACTION_SOURCE_TYPE_ID
	FROM CSP_SEC_INVENTORIES csi2
	WHERE
		csi2.CONDITION_TYPE = 'G'	/* Usable Subinventory */
		and not exists
			(select 'x' from CSP_PLANNING_PARAMETERS cpp
			 where cpp.organization_id = csi2.organization_id
			   and cpp.SECONDARY_INVENTORY = csi2.secondary_inventory_name
			   and cpp.forecast_rule_id is not null) /* Do not include subinventories that
have forecast rules defined */
	) sec,
	mtl_material_transactions mmt
	,ISC_FS_INV_USG_LOG bound /* Obtain the transaction boundaries from our log table */
	WHERE
		mmt.organization_id = sec.organization_id
	AND mmt.SUBINVENTORY_CODE = sec.SECONDARY_INVENTORY_NAME
	AND mmt.TRANSACTION_ACTION_ID = sec.TRANSACTION_ACTION_ID
	AND mmt.TRANSACTION_TYPE_ID  = sec.TRANSACTION_TYPE_ID
	AND mmt.TRANSACTION_SOURCE_TYPE_ID = sec.TRANSACTION_SOURCE_TYPE_ID
	AND mta.accounting_line_type = 1
	AND mta.transaction_id = mmt.transaction_id
	AND mta.organization_id = bound.organization_id
    /* Note that the boundary conditions have changed from > to >= and from <= to < due to changes in OPI's log table logic */
	AND mta.transaction_id >= bound.to_transaction_id  /* The from and to boundaries are
switched in the log table at this point */
	AND mta.transaction_id < bound.from_transaction_id
	GROUP BY
	 mta.ORGANIZATION_ID
	,mmt.SUBINVENTORY_CODE
	,mta.INVENTORY_ITEM_ID
	,trunc(mta.TRANSACTION_DATE);

	l_row_count := sql%rowcount;
	COMMIT;
	BIS_COLLECTION_UTILITIES.LOG( l_row_count || ' rows inserted into staging table', 1 );

	-- gather statistics on staging table before computing
	-- conversion rates
	l_stmt_num := 40;
	IF GATHER_STATISTICS
	 ( l_isc_schema
	 , 'ISC_FS_INV_USG_VALUE_STG'
	 , l_err_msg ) <> 0 THEN
	LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	RAISE l_exception;
	END IF;

	BIS_COLLECTION_UTILITIES.LOG( 'Staging table analyzed', 1 );

	-- check currency conversion rates
	l_stmt_num := 50;
	IF COMPUTE_INV_CONV_RATES
	 ( l_isc_schema
	 , l_err_msg ) <> 0 THEN
	LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	RAISE l_exception;
	END IF;


	/* Merge field service inventory usage value data into the DBI Field Service Inventory
	Usage Value Base Summary table based on Staging table and Current Conversion table */

	l_stmt_num := 60;
	MERGE INTO ISC_FS_INV_USG_VALUE_F f	USING
	(
	 SELECT /* parallel(s) parallel(c) */
		 s.ORGANIZATION_ID
		,s.SUBINVENTORY_CODE
		,s.TRANSACTION_DATE
		,s.INVENTORY_ITEM_ID
		,s.ONHAND_VALUE_B
		,c.conversion_rate1
		,c.conversion_rate2
	 FROM
	 	 ISC_FS_INV_USG_VALUE_STG s
		,ISC_FS_INV_USG_CONV_RATES c
	 WHERE
		 	c.organization_id = s.organization_id
		AND c.transaction_date = s.transaction_date
	) t
	ON
		(t.organization_id = f.organization_id
	AND t.subinventory_code = f.subinventory_code
	AND	t.inventory_item_id = f.inventory_item_id
	AND t.transaction_date = f.transaction_date
	)
	WHEN MATCHED THEN
	UPDATE SET
		 f.ONHAND_VALUE_B = f.ONHAND_VALUE_B + t.ONHAND_VALUE_B
		,f.LAST_UPDATE_DATE = g_sysdate
		,f.LAST_UPDATED_BY = g_user_id
		,f.LAST_UPDATE_LOGIN = g_login_id
		,f.PROGRAM_ID = g_program_id
		,f.PROGRAM_LOGIN_ID = g_program_login_id
		,f.PROGRAM_APPLICATION_ID = g_program_application_id
		,f.REQUEST_ID = g_request_id
	WHEN NOT MATCHED THEN
	INSERT
	(
	 ORGANIZATION_ID
	,SUBINVENTORY_CODE
	,TRANSACTION_DATE
	,INVENTORY_ITEM_ID
	,ONHAND_VALUE_B
	,PRIM_CONVERSION_RATE
	,SEC_CONVERSION_RATE
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,PROGRAM_ID
	,PROGRAM_LOGIN_ID
	,PROGRAM_APPLICATION_ID
	,REQUEST_ID
	)
	VALUES
	(
	 t.ORGANIZATION_ID
	,t.SUBINVENTORY_CODE
	,t.TRANSACTION_DATE
	,t.INVENTORY_ITEM_ID
	,t.ONHAND_VALUE_B
	,t.conversion_rate1
	,t.conversion_rate2
	,g_user_id
	,g_sysdate
	,g_sysdate
	,g_user_id
	,g_login_id
	,g_program_id
	,g_program_login_id
	,g_program_application_id
	,g_request_id
	);

	l_row_count := sql%rowcount;
	COMMIT;

	BIS_COLLECTION_UTILITIES.LOG( l_row_count || ' rows inserted into base summary', 1 );

	-- cleanup staging
	l_stmt_num := 70;
	IF TRUNCATE_TABLE
	    ( l_isc_schema
	    , 'ISC_FS_INV_USG_VALUE_STG'
	    , l_err_msg ) <> 0 THEN
	   LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	   RAISE l_exception;
	END IF;

	BIS_COLLECTION_UTILITIES.LOG( 'Staging table truncated', 1 );

	l_stmt_num := 80;
	IF TRUNCATE_TABLE
	    ( l_isc_schema
	    , 'ISC_FS_INV_USG_CONV_RATES'
	    , l_err_msg ) <> 0 THEN
	   LOGGER( l_proc_name, l_stmt_num, l_err_msg );
	   RAISE l_exception;
	END IF;

	BIS_COLLECTION_UTILITIES.LOG( 'Currency conversion table truncated', 1 );

	l_stmt_num := 90;
	UPDATE ISC_FS_INV_USG_LOG
	SET	 from_transaction_id = to_transaction_id,to_transaction_id = from_transaction_id;

	COMMIT;

	BIS_COLLECTION_UTILITIES.LOG( 'Log table updated', 1 );

	l_stmt_num := 100;
	BIS_COLLECTION_UTILITIES.WRAPUP(
	  p_status => TRUE,
	  p_count => l_row_count,
	  p_message => 'Successfully loaded Field Service Inventory Usage Base Table at ' ||
TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
	);

	BIS_COLLECTION_UTILITIES.LOG('End Incremental Load');

	errbuf := null;
	retcode := g_ok;

 ELSE
    retcode := g_error;
    BIS_COLLECTION_UTILITIES.LOG('Global Parameters are not setup.');
    BIS_COLLECTION_UTILITIES.LOG('Please check that the profile option BIS_GLOBAL_START_DATE
is setup.');

 END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_err_msg is null THEN
      l_err_msg := substr(sqlerrm,1,4000);
    END IF;
    BIS_COLLECTION_UTILITIES.WRAPUP( p_status => FALSE
                                   , p_message => l_err_msg
                                   );
    errbuf := l_err_msg;
    retcode := g_error;

END GET_INV_USG_INCREMENTAL_LOAD;


End ISC_FS_INV_USG_ETL_PKG;

/
