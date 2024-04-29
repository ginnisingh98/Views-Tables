--------------------------------------------------------
--  DDL for Package Body OZF_REFRESH_SALES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_REFRESH_SALES_PVT" AS
/*$Header: ozfvrfsb.pls 120.2 2006/08/04 08:57:35 mgudivak noship $*/

Function get_primary_uom(p_id in number)
return varchar2
is
l_uom varchar2(30);
begin
   select primary_uom_code into l_uom
   from mtl_system_items
   where inventory_item_id = p_id
   and rownum =1;
   return l_uom;
EXCEPTION
    when others then
       return ('LLLPP');
END get_primary_uom;

Function get_party_id(p_id in number)
return number
is
l_party_id number;
begin
   SELECT max(a.party_id) into l_party_id
   FROM hz_cust_accounts a
   WHERE a.cust_account_id = p_id;
   return l_party_id;
EXCEPTION
    when others then
       return (-99999);
END get_party_id;


Function get_party_site_id(p_id in number)
return number
is
l_party_site_id number;
begin
   SELECT max(a.party_site_id) into l_party_site_id
        FROM hz_cust_acct_sites_all a,
             hz_cust_site_uses_all b
        WHERE b.site_use_id = p_id
        AND   b.cust_acct_site_id = a.cust_acct_site_id;
   return l_party_site_id;
EXCEPTION
    when others then
       return (-99999);
END get_party_site_id;

PROCEDURE full_load( x_return_status OUT NOCOPY VARCHAR2 ) AS

   l_api_name      CONSTANT VARCHAR2(30) := 'full_load';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_global_start_date    DATE         := TO_DATE(FND_PROFILE.VALUE('OZF_TP_GLOBAL_START_DATE'), 'MM/DD/YYYY');
   l_common_uom           VARCHAR2(30) := FND_PROFILE.VALUE('OZF_TP_COMMON_UOM');
   l_common_currency_code VARCHAR2(30) := FND_PROFILE.VALUE('OZF_TP_COMMON_CURRENCY');
   l_curr_conv_type       VARCHAR2(30) := FND_PROFILE.VALUE('OZF_CURR_CONVERSION_TYPE');

   l_profile_option_name VARCHAR2(80);
   l_user_profile_option_name VARCHAR2(240);

   CURSOR prf_name_csr IS
      SELECT user_profile_option_name
      FROM   fnd_profile_options_vl
      WHERE profile_option_name = l_profile_option_name;

   CURSOR error_csr IS
      SELECT distinct
             transaction_date,
             uom_code,
             currency_code,
             common_uom_code,
             common_currency_code,
             common_quantity,
             common_amount
      FROM ozf_sales_transactions_all
      WHERE error_flag = 'Y'
      AND   SOURCE_CODE = 'OM';

   l_mesg VARCHAR2(2000);
   l_prof_check VARCHAR2(1) := 'T';

BEGIN

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (-)') ;

   SAVEPOINT full_load;

   x_return_status := FND_API.g_ret_sts_success;

     -- Check for Profile Values

    ozf_utility_pvt.write_conc_log('-- l_global_start_date is    : ' || l_global_start_date ) ;
    ozf_utility_pvt.write_conc_log('-- l_common_uom is           : ' || l_common_uom ) ;
    ozf_utility_pvt.write_conc_log('-- l_common_currency_code is : ' || l_common_currency_code ) ;
    ozf_utility_pvt.write_conc_log('-- l_curr_conv_type is       : ' || l_curr_conv_type ) ;

    IF l_global_start_date IS NULL
     THEN
         l_prof_check := 'N';
         l_profile_option_name := 'OZF_TP_GLOBAL_START_DATE';

         OPEN prf_name_csr;
         FETCH prf_name_csr INTO l_user_profile_option_name;
         CLOSE prf_name_csr;

         FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_MISSING_PROFILE_VALUE');
         FND_MESSAGE.Set_Token('PROFILE_NAME', l_user_profile_option_name);
         l_mesg := FND_MESSAGE.get;

         ozf_utility_pvt.write_conc_log(l_mesg);
     END IF;


     IF l_common_uom IS NULL
     THEN
         l_prof_check := 'N';
         l_profile_option_name := 'OZF_TP_COMMON_UOM';

         OPEN prf_name_csr;
         FETCH prf_name_csr INTO l_user_profile_option_name;
         CLOSE prf_name_csr;

         FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_MISSING_PROFILE_VALUE');
         FND_MESSAGE.Set_Token('PROFILE_NAME', l_user_profile_option_name);
         l_mesg := FND_MESSAGE.get;

         ozf_utility_pvt.write_conc_log(l_mesg);
     END IF;

     IF l_common_currency_code IS NULL
     THEN
         l_prof_check := 'N';
         l_profile_option_name := 'OZF_TP_COMMON_CURRENCY';

         OPEN prf_name_csr;
         FETCH prf_name_csr INTO l_user_profile_option_name;
         CLOSE prf_name_csr;

         FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_MISSING_PROFILE_VALUE');
         FND_MESSAGE.Set_Token('PROFILE_NAME', l_user_profile_option_name);
         l_mesg := FND_MESSAGE.Get;

         ozf_utility_pvt.write_conc_log(l_mesg);
     END IF;

     IF l_curr_conv_type IS NULL
     THEN
         l_prof_check := 'N';
         l_profile_option_name := 'OZF_CURR_CONVERSION_TYPE';

         OPEN prf_name_csr;
         FETCH prf_name_csr INTO l_user_profile_option_name;
         CLOSE prf_name_csr;

         FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_MISSING_PROFILE_VALUE');
         FND_MESSAGE.Set_Token('PROFILE_NAME', l_user_profile_option_name);
         l_mesg := FND_MESSAGE.Get;

         ozf_utility_pvt.write_conc_log(l_mesg);
     END IF;

     IF l_prof_check = 'N'
     THEN
         RAISE FND_API.g_exc_error;
     END IF;

     -- Process any error from the previous run

      ozf_utility_pvt.write_conc_log(' -- Updating errors from previous run., if any ');

UPDATE ozf_sales_transactions_all
SET   common_amount = gl_currency_api.convert_amount_sql(currency_code,
                                                         common_currency_code,
                                                         transaction_date,
                                                         l_curr_conv_type,
                                                         amount) ,
      common_quantity = inv_convert.inv_um_convert(inventory_item_id,
                                                  NULL,
                                                  quantity,
                                                  uom_code,
                                                  common_uom_code,
                                                  NULL,
                                                  NULL) ,
      error_flag = DECODE(sign(inv_convert.inv_um_convert( inventory_item_id,
                                                           NULL,
                                                           quantity,
                                                           uom_code,
                                                           common_uom_code,
                                                           NULL,
                                                           NULL)
                               ), -1, 'Y',
                              DECODE(
                                     sign(gl_currency_api.convert_amount_sql(currency_code,
                                                                             common_currency_code,
                                                                             transaction_date,
                                                                             l_curr_conv_type,
                                                                             amount)
                                         ),-1,'Y','N'
                                     )
                           )
WHERE source_code = 'OM'
AND   error_flag = 'Y';


       ozf_utility_pvt.write_conc_log(' -- Inserting New transaction ');

     -- Insert
INSERT INTO ozf_sales_transactions_all(
                 SALES_TRANSACTION_ID ,
                 OBJECT_VERSION_NUMBER ,
                 LAST_UPDATE_DATE ,
                 LAST_UPDATED_BY ,
                 CREATION_DATE ,
                 REQUEST_ID ,
                 CREATED_BY ,
                 CREATED_FROM ,
                 LAST_UPDATE_LOGIN ,
                 PROGRAM_APPLICATION_ID ,
                 PROGRAM_UPDATE_DATE ,
                 PROGRAM_ID ,
                 SOLD_TO_CUST_ACCOUNT_ID ,
                 BILL_TO_SITE_USE_ID ,
                 SHIP_TO_SITE_USE_ID ,
                 TRANSACTION_DATE,
                 QUANTITY ,
                 UOM_CODE ,
                 AMOUNT ,
                 CURRENCY_CODE ,
                 INVENTORY_ITEM_ID ,
                 PRIMARY_QUANTITY ,
                 PRIMARY_UOM_CODE ,
                 AVAILABLE_PRIMARY_QUANTITY ,
                 COMMON_QUANTITY ,
                 COMMON_UOM_CODE ,
                 COMMON_CURRENCY_CODE ,
                 COMMON_AMOUNT ,
                 ERROR_FLAG,
                 HEADER_ID ,
                 LINE_ID ,
                 ORG_ID,
                 SOURCE_CODE,
                 TRANSFER_TYPE,
                 SOLD_TO_PARTY_ID,
                 SOLD_TO_PARTY_SITE_ID
                 )
SELECT ozf_sales_transactions_all_s.nextval,
       1,
       SYSDATE,
       FND_GLOBAL.user_id,
       SYSDATE,
       -1,
       FND_GLOBAL.user_id,
       'OZFVRFSB',
       -1,
       NULL, --PROGRAM_APPLICATION_ID
       NULL, --PROGRAM_UPDATE_DATE
       NULL, --PROGRAM_ID
       ln.sold_to_org_id,          --SOLD_TO_CUST_ACCOUNT_ID ,
       ln.invoice_to_org_id,       --BILL_TO_SITE_USE_ID ,
       ln.ship_to_org_id,          --SHIP_TO_SITE_USE_ID ,
       NVL(TRUNC(ln.actual_shipment_date),TRUNC(ln.request_date)),
       /*  4590570
       DECODE(ln.line_category_code,
                   'ORDER',  TRUNC(ln.actual_shipment_date),
                   'RETURN', TRUNC(rln.actual_shipment_date)
             ),                     -- TRANSACTION_DATE
       */
       NVL(ln.shipped_quantity,ln.ordered_quantity),  --QUANTITY ,
       ln.order_quantity_uom,    --UOM ,
       ln.unit_selling_price* NVL(ln.shipped_quantity,ln.ordered_quantity),  --AMOUNT ,
       hdr.transactional_curr_code,  --CURRENCY_CODE ,
       ln.inventory_item_id,         --INVENTORY_ITEM_ID ,
       inv_convert.inv_um_convert(ln.inventory_item_id,
                                  NULL,
                                  NVL(ln.shipped_quantity,ln.ordered_quantity),
                                  ln.order_quantity_uom,
                                  get_primary_uom(to_number(ln.inventory_item_id)),
                                  NULL,
                                  NULL),--PRIMARY_QUANTITY ,
       get_primary_uom(to_number(ln.inventory_item_id)), --PRIMARY_UOM ,
       inv_convert.inv_um_convert(ln.inventory_item_id,
                                  NULL,
                                  NVL(ln.shipped_quantity,ln.ordered_quantity),
                                  ln.order_quantity_uom,
                                  get_primary_uom(to_number(ln.inventory_item_id)),
                                  NULL,
                                  NULL), --AVAILABLE_PRIMARY_QUANTITY ,
       inv_convert.inv_um_convert(ln.inventory_item_id,
                                  NULL,
                                  NVL(ln.shipped_quantity,ln.ordered_quantity),
                                  ln.order_quantity_uom,
                                  l_common_uom,
                                  NULL,
                                  NULL),  --COMMON_QUANTITY ,
       l_common_uom,                      --COMMON_UOM ,
       l_common_currency_code,            --COMMON_CURRENCY_CODE ,
       gl_currency_api.convert_amount_sql(hdr.transactional_curr_code,
                                          l_common_currency_code,
                                          NVL(ln.actual_shipment_date,ln.request_date),
                                          l_curr_conv_type,
                                          ln.unit_selling_price*( NVL(ln.shipped_quantity,ln.ordered_quantity))
                                          ) , --COMMON_AMOUNT ,
       DECODE(sign(inv_convert.inv_um_convert(ln.inventory_item_id,
                                              NULL,
                                              NVL(ln.shipped_quantity,ln.ordered_quantity),
                                              ln.order_quantity_uom,
                                              l_common_uom,
                                              NULL,
                                              NULL)
                  ), -1, 'Y',
                     DECODE(
                            sign(gl_currency_api.convert_amount_sql(hdr.transactional_curr_code,
                                          l_common_currency_code,
                                          NVL(ln.actual_shipment_date,ln.request_date),
                                          l_curr_conv_type,
                                          (ln.unit_selling_price*NVL(ln.shipped_quantity,ln.ordered_quantity)))
                                 ),-1,'Y','N'
                           )
             ), -- ERROR_FLAG
       ln.header_id,              --HEADER_ID ,
       ln.line_id,                --LINE_ID ,
       ln.org_id,                 --ORG_ID,
       'OM',                      --SOURCE_CODE
       DECODE(ln.line_category_code,
                          'ORDER', 'IN',
                          'RETURN', 'OUT')
      , get_party_id(ln.sold_to_org_id) party_id
      , get_party_site_id(ln.invoice_to_org_id) SOLD_TO_PARTY_SITE_ID
FROM oe_order_headers_all hdr,
     oe_order_lines_all ln
WHERE ln.open_flag = 'N'
AND   ln.cancelled_flag = 'N'
AND   ln.header_id = hdr.header_id
AND   NVL(ln.actual_shipment_date,ln.request_date) > l_global_start_date  ;

/* Bug 5371613
  Incremental load is not done by Funds Accrual Engine
  This program will now be run only in full refresh mode for the first time
AND NOT EXISTS ( SELECT 1
                 FROM ozf_sales_transactions_all trx
                 WHERE trx.line_id = ln.line_id
                 AND source_code = 'OM' );
*/

   -- Log error messages here
   /*
   Get all records from ozf_sales_transactions_all with error_flag = 'Y'
   converted_quantity = -9999 or converted_amount = -1
   */

   ozf_utility_pvt.write_conc_log(' -- Currency and UOM conversion Errors --  ');

   FOR err IN error_csr
   LOOP
       IF err.common_quantity < 0
       THEN
           -- UOM and COMMON_UOM conversion
         FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_MISSING_CONVERSIONS');
         FND_MESSAGE.Set_Token('TYPE', 'UOM');
         FND_MESSAGE.Set_Token('FROM_VALUE', err.uom_code);
         FND_MESSAGE.Set_Token('TO_VALUE', err.common_uom_code);
         FND_MESSAGE.Set_Token('DATE', err.transaction_date);
         l_mesg := FND_MESSAGE.Get;

         ozf_utility_pvt.write_conc_log(l_mesg);

       END IF;

       IF err.common_amount < 0
       THEN
           -- CURRENCY_CODE and COMMON_CURRENCY_CODE conversion
           FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_MISSING_CONVERSIONS');
           FND_MESSAGE.Set_Token('TYPE', 'CURRENCY');
           FND_MESSAGE.Set_Token('FROM_VALUE', err.currency_code);
           FND_MESSAGE.Set_Token('TO_VALUE', err.common_currency_code);
           FND_MESSAGE.Set_Token('DATE', err.transaction_date);
           l_mesg := FND_MESSAGE.Get;

           ozf_utility_pvt.write_conc_log(l_mesg);

       END IF;

   END LOOP;

   --
   -- End full load logic
   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' (+)');

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' Unexpected Error ' );
          ozf_utility_pvt.write_conc_log(sqlerrm(sqlcode) );

END full_load;


/*
PROCEDURE order_sales_sumry_mv_refresh
    (ERRBUF   OUT NOCOPY VARCHAR2
    ,RETCODE  OUT NOCOPY NUMBER)
IS
BEGIN

    ozf_utility_pvt.write_conc_log(' -- Begin Materialized view refresh -- ');

    DBMS_MVIEW.REFRESH(
                list => 'ORDER' ,
                method => '?'
        );

    ozf_utility_pvt.write_conc_log(' -- End Materialized view refresh -- ');
  --------------------------------------------------------
  -- Gather statistics for the use of cost-based optimizer
  --------------------------------------------------------

   ozf_utility_pvt.write_conc_log(' -- Begin FND_STATS API to gather table statstics -- ');

   fnd_stats.gather_table_stats (ownname=>'APPS', tabname=>'OZF_ORDER_SALES_SUMRY_MV');

   ozf_utility_pvt.write_conc_log(' -- End FND_STATS API to gather table statstics -- ');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
                Retcode  := -2;

   WHEN OTHERS THEN
                Errbuf:= sqlerrm;
                Retcode:=sqlcode;
                ozf_utility_pvt.write_conc_log(Retcode||':'||Errbuf);

END order_sales_sumry_mv_refresh;
*/

PROCEDURE load (
                ERRBUF                  OUT  NOCOPY VARCHAR2,
                RETCODE                 OUT  NOCOPY NUMBER,
                p_increment_mode         IN         VARCHAR2 DEFAULT NULL)
IS
    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version             CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'ozf_refresh_order_sales_pkg';
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(240);
    x_return_status           VARCHAR2(1) ;
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;

BEGIN
      ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' (-)');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (NVL(p_increment_mode,'N') = 'N')
      THEN
          DELETE FROM ozf_sales_transactions_all
          WHERE source_code = 'OM';
      END IF;

      COMMIT;

      full_load( x_return_status );

      IF    x_return_status = FND_API.g_ret_sts_error
      THEN
            RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

      ozf_utility_pvt.write_conc_log(' -- Commiting Transactions before MV Refresh ');

      COMMIT;

      ozf_utility_pvt.write_conc_log(' -- Committed !! ');
      --
      -- Refresh the MVS here
      --

      ozf_utility_pvt.write_conc_log(' -- Begin MV Refresh -- ');

      ozf_refresh_view_pvt.load(ERRBUF, RETCODE, 'ORDER');
      ozf_refresh_view_pvt.load(ERRBUF, RETCODE, 'INVENTORY');

      ozf_utility_pvt.write_conc_log(' -- End MV Refresh -- ');

      ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' (+)');

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          ERRBUF := x_msg_data;
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' Expected Error');

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          ERRBUF := sqlerrm(sqlcode);
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' Unexpected Error');

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' Others');

END load;


END ozf_refresh_sales_pvt;

/
