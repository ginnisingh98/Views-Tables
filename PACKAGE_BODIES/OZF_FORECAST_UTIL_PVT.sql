--------------------------------------------------------
--  DDL for Package Body OZF_FORECAST_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FORECAST_UTIL_PVT" AS
/* $Header: ozfvfoub.pls 120.7 2006/10/04 20:56:27 mkothari noship $*/
/**
Fri Sep 29 2006:11/16 AM RSSHARMA Fixed bug # 5572679.Part MOAC fixes. Replaced retrieval of org_if FROM environment variable CLIENT_INFO by calling MO_GLOBAL package function.
Comprehensive fix remaing.
*/
g_pkg_name   CONSTANT VARCHAR2(30):='OZF_FORECAST_UTIL_PVT';

-----------------------------------------------------------
-- CF
-----------------------------------------------------------

OZF_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
OZF_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
OZF_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

 PROCEDURE get_dates ( p_period_type_id IN NUMBER,
                       p_time_id        IN NUMBER,
                       x_record_type_id OUT NOCOPY NUMBER,
                       x_start_date     OUT NOCOPY DATE,
                       x_end_date     OUT NOCOPY DATE)  IS


 BEGIN
    IF  p_period_type_id = 128
    THEN
       --
       x_record_type_id := 119;

       SELECT start_date, end_date INTO x_start_date, x_end_date
       FROM ozf_time_ent_year
       WHERE ent_year_id = p_time_id;
       --
    ELSIF p_period_type_id = 64
    THEN
       --
       x_record_type_id := 55;

       SELECT start_date, end_date INTO x_start_date, x_end_date
       FROM ozf_time_ent_qtr
       WHERE ent_qtr_id = p_time_id;
       --
    ELSIF p_period_type_id = 32
    THEN
       --
       x_record_type_id := 23;

       SELECT start_date, end_date INTO x_start_date, x_end_date
       FROM ozf_time_ent_period
       WHERE ent_period_id = p_time_id;
       --
    ELSIF p_period_type_id = 16
    THEN
       --
       x_record_type_id := 11;

       SELECT start_date, end_date INTO x_start_date, x_end_date
       FROM ozf_time_week
       WHERE week_id = p_time_id;
       --
    ELSIF p_period_type_id = 1
    THEN
       --
       x_record_type_id := 1;

       SELECT start_date, end_date INTO x_start_date, x_end_date
       FROM ozf_time_day
       WHERE report_date_julian = p_time_id;
       --
    END IF;
  END get_dates;


  PROCEDURE get_sales ( p_obj_type                  IN VARCHAR2,
                        p_obj_id                    IN NUMBER,
                        p_product_attribute_context IN VARCHAR2,
                        p_product_attribute         IN VARCHAR2,
                        p_product_attr_value        IN VARCHAR2,
                        p_qualifier_grouping_no     IN NUMBER,
                        p_period_number             IN NUMBER,
                        p_forecast_id               IN NUMBER,
                        x_sales                     OUT NOCOPY NUMBER ) AS


    CURSOR periods_csr (p_object_id IN NUMBER)
    IS
    SELECT period_number,
           start_date,
           end_date,
           period_type_id
    FROM ozf_forecast_periods
    WHERE obj_type = p_obj_type
    AND   obj_id   = p_object_id
    AND   period_number = NVL(p_period_number, period_number)
    AND (forecast_id IS NULL -- inanaiah: For compatibility with older release
     OR forecast_id = p_forecast_id); -- inanaiah: making periods bound to forecast_id as is the case when creating new version ;

    CURSOR sales_csr  (p_as_of_date     IN DATE,
                     p_record_type_id IN NUMBER )
    IS
    select SUM(sales.sales_qty)
    from ozf_order_sales_sumry_mv sales,
     ozf_time_rpt_struct rpt,
     ( select cust.qualifier_grouping_no,
              cust.cust_account_id,
                  decode ( count(cust.qualifier_grouping_no),
                           1, max(cust.site_use_code), null
                                 ) site_use_code,
                  decode ( count(cust.qualifier_grouping_no),
                          1, max(cust.site_use_id), null
                                 ) site_use_id,
              prod.product_attribute_context,
              prod.product_attribute,
              prod.product_attr_value,
              prod.product_id inventory_item_id
       from ozf_forecast_customers cust,
            ozf_forecast_products prod
       where prod.obj_type = p_obj_type
       and prod.obj_id = p_obj_id
       and prod.obj_type = cust.obj_type
       and prod.obj_id =  cust.obj_id
       group by cust.qualifier_grouping_no,
                cust.cust_account_id,
                prod.product_attribute_context,
                prod.product_attribute,
                prod.product_attr_value,
                prod.product_id
      ) cust_prod,
      ozf_forecast_dimentions dim
      where dim.obj_type =  p_obj_type
        and   dim.obj_id   =  p_obj_id
        AND   dim.forecast_id = p_forecast_id
        and   dim.product_attribute_context = cust_prod.product_attribute_context
        and   dim.product_attribute  = cust_prod.product_attribute
        and   dim.product_attr_value = cust_prod.product_attr_value
        and   dim.qualifier_grouping_no = cust_prod.qualifier_grouping_no
        and   sales.sold_to_cust_account_id = cust_prod.cust_account_id
        and   decode(cust_prod.site_use_code,
                          NULL,-99,
                         'BILL_TO',sales.bill_to_site_use_id,
                                   sales.ship_to_site_use_id) = NVL(cust_prod.site_use_id, -99)
        and   sales.inventory_item_id = cust_prod.inventory_item_id
        and   rpt.report_date = p_as_of_date
        and   BITAND(rpt.record_type_id, p_record_type_id ) = rpt.record_type_id
        and   rpt.time_id = sales.time_id
        and dim.product_attribute_context = NVL(p_product_attribute_context, dim.product_attribute_context)
        and dim.product_attribute = NVL(p_product_attribute, dim.product_attribute)
        and dim.product_attr_value = NVL(p_product_attr_value, dim.product_attr_value)
        and dim.qualifier_grouping_no = NVL(p_qualifier_grouping_no, dim.qualifier_grouping_no) ;

    -- inanaiah: R12 - for offer_code
 /*   CURSOR base_quantity_type_csr IS
    SELECT base_quantity_type, offer_code
    FROM ozf_act_forecasts_all
    WHERE forecast_id = p_forecast_id;

    CURSOR offerid_csr(p_offer_code IN VARCHAR2) IS
    SELECT qp_list_header_id --offer_id
    FROM ozf_offers off
    WHERE off.offer_code = p_offer_code;
*/

    l_sales          NUMBER := 0;
    l_period_sales   NUMBER := 0;

    l_xtd_sales      NUMBER := 0;
    l_start_xtd      NUMBER := 0;
    l_end_xtd      NUMBER := 0;

    l_record_type_id NUMBER;
    l_start_date     DATE;
    l_end_date       DATE;

    -- R12
--  l_base_quantity_type VARCHAR2(30);
--  l_offer_code    VARCHAR2(30);
    l_obj_id        NUMBER := p_obj_id;

  BEGIN

----dbms_output.put_line('Obj_Type '|| p_obj_type);
----dbms_output.put_line('Obj_Id   '|| p_obj_id);

    -- inanaiah: R12 - for offer code
    -- appropriate offer_id will be passed as p_obj_id whenever basis is OFFER_CODE
/*
    OPEN base_quantity_type_csr;
    FETCH base_quantity_type_csr INTO l_base_quantity_type, l_offer_code;
    CLOSE base_quantity_type_csr;

    IF (l_base_quantity_type = 'OFFER_CODE')
    THEN
        OPEN offerid_csr(l_offer_code);
        FETCH offerid_csr INTO l_obj_id;
        CLOSE offerid_csr;
    END IF;
*/
    FOR i IN periods_csr(l_obj_id)
    LOOP
         get_dates(i.period_type_id,
                   i.period_number,
                   l_record_type_id,
                   l_start_date,
                   l_end_date );

 ----dbms_output.put_line('period_type_id '|| i.period_type_id );
 ----dbms_output.put_line('period_number   '|| i.period_number);
 ----dbms_output.put_line('l_record_type_id '|| l_record_type_id );
 ----dbms_output.put_line('l_start_date   '|| l_start_date);
 ----dbms_output.put_line('l_end_date   '|| l_end_date);

         IF i.start_date > l_start_date
         THEN
              -- Start Date is in the middle of the period
              -- Sales for the period = XTD for End_Date - XTD for Start_Date
             OPEN sales_csr(i.end_date, l_record_type_id);
             FETCH sales_csr INTO l_end_xtd;
             CLOSE sales_csr;

             OPEN sales_csr(i.start_date, l_record_type_id);
             FETCH sales_csr INTO l_start_xtd;
             CLOSE sales_csr;

             l_xtd_sales := l_end_xtd - l_start_xtd;
         ELSE
              -- Sales for the period is XTD as of End Date

             OPEN sales_csr(i.end_date, l_record_type_id);
             FETCH sales_csr INTO l_xtd_sales;
             CLOSE sales_csr;

         END IF;

 ----dbms_output.put_line('l_end_xtd '||l_end_xtd  );
 ----dbms_output.put_line('l_start_xtd   '|| l_start_xtd);
 ----dbms_output.put_line('l_xtd_sales   '|| l_xtd_sales);

         l_sales := l_sales + l_xtd_sales;

    END LOOP;

    x_sales := l_sales;
----dbms_output.put_line('x_Sales   '|| x_sales);
  END;

  -- R12 modified
PROCEDURE create_forecast(p_api_version      IN  NUMBER,
                          p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
                          p_commit           IN  VARCHAR2  := FND_API.g_false,
                          p_obj_type         IN VARCHAR2,
                          p_obj_id           IN NUMBER,
                          p_fcst_uom         IN VARCHAR2,

                          p_start_date       IN DATE,
                          p_end_date         IN DATE,
                          p_base_quantity_type IN VARCHAR2,
                          p_base_quantity_ref IN VARCHAR2,
                          p_last_scenario_id IN NUMBER,
                          p_offer_code       IN VARCHAR2,

                          x_forecast_id      IN OUT NOCOPY NUMBER,
                          x_activity_metric_id OUT NOCOPY NUMBER, -- 11510
                                      x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2
                          ) AS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'Create_Forecast';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status          VARCHAR2(1);

   l_forecast_id NUMBER;
   l_act_forecast_count NUMBER;
   l_act_forecast_rec OZF_ActForecast_PVT.act_forecast_rec_type;

   -- 11510
   l_activity_metric_id NUMBER;

      CURSOR c_act_met_id IS
      SELECT ozf_act_metrics_all_s.NEXTVAL
      FROM   dual;

BEGIN

   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_Forecast;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   IF x_forecast_id IS NULL
   THEN
    l_act_forecast_rec.arc_act_fcast_used_by := p_obj_type;
    l_act_forecast_rec.act_fcast_used_by_id  := p_obj_id;
    l_act_forecast_rec.forecast_uom_code     := p_fcst_uom;
    l_act_forecast_rec.base_quantity         := 0;

   --R12 modified
    ----dbms_output.put_line( ' -- Create_Forecast -- ');
    ----dbms_output.put_line( ' --  ***** -- '||p_last_scenario_id);
   IF p_last_scenario_id = 0
   THEN
       ----dbms_output.put_line( ' --  ***** -- ');
    l_act_forecast_rec.last_scenario_id      := 1;
   ELSIF p_last_scenario_id IS NULL
   THEN
   ----dbms_output.put_line( ' --  ***** -- ');
    l_act_forecast_rec.last_scenario_id      := 1;
   ELSE
    ----dbms_output.put_line( ' --  1 ***** -- ');
    l_act_forecast_rec.last_scenario_id      := p_last_scenario_id + 1;
   END IF;

   l_act_forecast_rec.base_quantity_type    := p_base_quantity_type;
   l_act_forecast_rec.base_quantity_ref     := p_base_quantity_ref;
   l_act_forecast_rec.base_quantity_start_date := p_start_date;
   l_act_forecast_rec.base_quantity_end_date := p_end_date;
   l_act_forecast_rec.offer_code := p_offer_code;

----dbms_output.put_line( '-- 1.1 create_forecast --');
   OZF_ActForecast_PVT.Create_ActForecast (
                        p_api_version => p_api_version,
                        x_return_status => l_return_status ,
                        x_msg_count     => x_msg_count ,
                        x_msg_data      => x_msg_data ,

                        p_act_forecast_rec => l_act_forecast_rec,
                        x_forecast_id      => x_forecast_id );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

 ----dbms_output.put_line( '-- 1.2 --' || x_forecast_id );
   -- 11510
      l_forecast_id := x_forecast_id;
   ELSE
      l_forecast_id := x_forecast_id;
   END IF;

   OPEN c_act_met_id;
   FETCH c_act_met_id INTO l_activity_metric_id;
   CLOSE c_act_met_id;
----dbms_output.put_line( '-- 1.3 --' || l_activity_metric_id );

   INSERT INTO ozf_act_metrics_all (
             ACTIVITY_METRIC_ID     , LAST_UPDATE_DATE,
             LAST_UPDATED_BY        , CREATION_DATE,
             CREATED_BY             , LAST_UPDATE_LOGIN,
             OBJECT_VERSION_NUMBER  , ACT_METRIC_USED_BY_ID,
             ARC_ACT_METRIC_USED_BY , APPLICATION_ID,
             SENSITIVE_DATA_FLAG    , METRIC_ID,
             ORG_ID,
             DIRTY_FLAG )
   VALUES (   l_activity_metric_id   , sysdate,
              fnd_global.user_id             , sysdate,
              fnd_global.user_id             , fnd_global.login_id,
              1                              , l_forecast_id,
              'FCST'                         , 530 ,
              'N'                            , 1,
              MO_GLOBAL.GET_CURRENT_ORG_ID() ,
              'Y');

   x_activity_metric_id  := l_activity_metric_id;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Create_Forecast;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Create_Forecast;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

   WHEN OTHERS THEN

      ROLLBACK TO Create_Forecast;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );


END create_forecast;


-----------------------------------------------------------
-- CD
-----------------------------------------------------------

PROCEDURE create_dimentions (
                              p_api_version      IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
                              p_commit           IN  VARCHAR2  := FND_API.g_false,
                              p_obj_type         IN VARCHAR2,
                              p_obj_id           IN NUMBER,
                              p_forecast_id      IN NUMBER,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2 )
AS

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'create_dimentions';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);


TYPE DimCurType IS REF CURSOR;
dim_cv  DimCurType;
excp_cv DimCurType;

-- RUP1: Modified qualifier_grouping_no for Camp Level
l_obj_dimentions VARCHAR2(30000) :=
'select distinct '||
'       prd.PRODUCT_ATTRIBUTE_CONTEXT, '||
'       prd.PRODUCT_ATTRIBUTE, '||
'       prd.PRODUCT_ATTR_VALUE, '||
'       (off.qp_list_header_id + mkt.QUALIFIER_GROUPING_NO) qualifier_grouping_no, '||
'       mkt.QUALIFIER_CONTEXT, '||
'       mkt.QUALIFIER_ATTRIBUTE, '||
'       mkt.QUALIFIER_ATTR_VALUE, '||
'       mkt.QUALIFIER_ATTR_VALUE_TO, '||
'       mkt.COMPARISON_OPERATOR_CODE '||
'from qp_pricing_attributes prd, '||
'     qp_qualifiers mkt, '||
'     ozf_act_offers off,  '||
'     qp_list_lines ln '||
'where off.arc_act_offer_used_by = :l_object_type  '||
'and off.act_offer_used_by_id = :l_object_id  '||
'and off.qp_list_header_id = prd.list_header_id  '||
'and prd.excluder_flag = ''N'' '||
'and prd.list_line_id = ln.list_line_id '||
'and (ln.start_date_active < SYSDATE '||
'     OR  ln.start_date_active IS NULL) '||
'and (ln.end_date_active > SYSDATE '||
'     OR ln.end_date_active IS NULL) '||
'and prd.list_header_id = mkt.list_header_id ' ||
'and (mkt.start_date_active < SYSDATE '||
'     OR  mkt.start_date_active IS NULL) '||
'and (mkt.end_date_active > SYSDATE '||
'     OR mkt.end_date_active IS NULL) '||
'and mkt.list_line_id = -1';



l_obj_exclusions VARCHAR2(30000) :=
'select exp.PRODUCT_ATTRIBUTE_CONTEXT, '||
'       exp.PRODUCT_ATTRIBUTE, '||
'       exp.PRODUCT_ATTR_VALUE, '||
'       prd.PRODUCT_ATTRIBUTE_CONTEXT, '||
'       prd.PRODUCT_ATTRIBUTE, '||
'       prd.PRODUCT_ATTR_VALUE ' ||
'from qp_pricing_attributes prd, '||
'     qp_pricing_attributes exp,'||
'     ozf_act_offers off '||
'where  off.arc_act_offer_used_by = :l_object_type '||
'and off.act_offer_used_by_id = :l_object_id  '||
'and off.qp_list_header_id = prd.list_header_id  '||
'and prd.excluder_flag = ''Y'' '||
'and prd.list_line_id = exp.list_line_id '||
'and exp.excluder_flag = ''N'' ' ;

l_offer_dimentions VARCHAR2(30000) :=
'select distinct  '||
'       prd.PRODUCT_ATTRIBUTE_CONTEXT, '||
'       prd.PRODUCT_ATTRIBUTE, '||
'       prd.PRODUCT_ATTR_VALUE, '||
'       mkt.QUALIFIER_GROUPING_NO, '||
'       mkt.QUALIFIER_CONTEXT, '||
'       mkt.QUALIFIER_ATTRIBUTE, '||
'       mkt.QUALIFIER_ATTR_VALUE, '||
'       mkt.QUALIFIER_ATTR_VALUE_TO, '||
'       mkt.COMPARISON_OPERATOR_CODE '||
'from qp_pricing_attributes prd, '||
'     qp_qualifiers mkt, '||
'     qp_list_lines ln '||
'where ''OFFR'' = :l_object_type '||
'and prd.list_header_id = :l_object_id '||
'and prd.excluder_flag = ''N'' '||
'and prd.list_line_id = ln.list_line_id '||
'and (ln.start_date_active < SYSDATE '||
'     OR  ln.start_date_active IS NULL) '||
'and (ln.end_date_active > SYSDATE '||
'     OR ln.end_date_active IS NULL) '||
'and prd.list_header_id = mkt.list_header_id ' ||
'and (mkt.start_date_active < SYSDATE '||
'     OR  mkt.start_date_active IS NULL) '||
'and (mkt.end_date_active > SYSDATE '||
'     OR mkt.end_date_active IS NULL) '||
'and mkt.list_line_id = -1';

l_offer_exclusions VARCHAR2(30000) :=
'select exp.PRODUCT_ATTRIBUTE_CONTEXT, '||
'       exp.PRODUCT_ATTRIBUTE, '||
'       exp.PRODUCT_ATTR_VALUE, '||
'       prd.PRODUCT_ATTRIBUTE_CONTEXT, '||
'       prd.PRODUCT_ATTRIBUTE, '||
'       prd.PRODUCT_ATTR_VALUE ' ||
'from qp_pricing_attributes prd, '||
'     qp_pricing_attributes exp '||
'where  ''OFFR'' = :l_object_type '||
'and prd.list_header_id  = :l_object_id  '||
'and prd.excluder_flag = ''Y'' '||
'and prd.list_line_id = exp.list_line_id '||
'and exp.excluder_flag = ''N'' ' ;

l_lumpsum_offr_dim VARCHAR2(30000) :=
'select ''ITEM'' PRODUCT_ATTRIBUTE_CONTEXT ,'||
'       DECODE(a.level_type_code,''PRODUCT'', '||
'                                ''PRICING_ATTRIBUTE1'', '||
'                                ''PRICING_ATTRIBUTE2'') PRODUCT_ATTRIBUTE , '||
'       DECODE(a.level_type_code,''PRODUCT'', '||
'                                a.inventory_item_id, '||
'                                a.category_id) PRODUCT_ATTR_VALUE, '||
'       10 QUALIFIER_GROUPING_NO , '||
'       ''CUSTOMER'' QUALIFIER_CONTEXT, '||
'       ''QUALIFIER_ATTRIBUTE2''  QUALIFIER_ATTRIBUTE, '||
'        b.qualifier_id  QUALIFIER_ATTR_VALUE, '||
'        null QUALIFIER_ATTR_VALUE_TO, '||
'        ''='' COMPARISON_OPERATOR_CODE '||
'from ams_act_products a, '||
'ozf_offers b '||
'where a.arc_act_product_used_by = :l_object_type '||
'and a.act_product_used_by_id = :l_object_id '||
'and a.act_product_used_by_id = b.qp_list_header_id '||
'and a.excluded_flag = ''N'' ' ;

l_lumpsum_offr_exc VARCHAR2(30000) :=
'select ''ITEM'' product_attribute_context, '||
'       DECODE(a.level_type_code,''PRODUCT'', '||
'                                ''PRICING_ATTRIBUTE1'', '||
'                                ''PRICING_ATTRIBUTE2'') product_attribute , '||
'       DECODE(a.level_type_code,''PRODUCT'', '||
'                                a.inventory_item_id, '||
'                                a.category_id) product_attr_value, '||
'       ''ITEM'' product_attribute_context_e , '||
'       DECODE(b.level_type_code,''PRODUCT'', '||
'                                ''PRICING_ATTRIBUTE1'', '||
'                                ''PRICING_ATTRIBUTE2'') product_attribute_e , '||
'       DECODE(b.level_type_code,''PRODUCT'', '||
'                                 b.inventory_item_id, '||
'                                 b.category_id) product_attr_value_e    '||
'from ams_act_products a, '||
'     ams_act_products b '||
'where a.arc_act_product_used_by = :l_object_type  '||
'and a.act_product_used_by_id = :l_object_id  '||
'and a.excluded_flag = ''N'' '||
'and b.arc_act_product_used_by = ''PROD'' '||
'and b.act_product_used_by_id = a.activity_product_id '||
'and b.excluded_flag = ''Y'' ';

-- 11510
l_wkst_dimentions VARCHAR2(30000) :=
'select prd.product_attribute_context, '||
'       prd.product_attribute, '||
'       prd.product_attr_value, '||
'       -1 qualifier_grouping_no, '||
'       mkt.qualifier_context, '||
'       mkt.qualifier_attribute, '||
'       mkt.qualifier_attr_value, '||
'       NULL qualifier_attr_value_to, '||
'       mkt.comparison_operator_code '||
'from ozf_worksheet_lines prd, '||
'     ozf_worksheet_qualifiers mkt '||
'where ''WKST'' = :l_object_type '||
'and mkt.worksheet_header_id =   :l_object_id '||
'and mkt.worksheet_header_id = prd.worksheet_header_id '||
'and prd.exclude_flag = ''N'' ';

-- R12
l_vol_offer_dimensions VARCHAR2(30000) :=
'SELECT   '||
'  ODP.PRODUCT_CONTEXT, '||
'  ODP.PRODUCT_ATTRIBUTE, '||
'  ODP.PRODUCT_ATTR_VALUE, '||
'  MKT.QUALIFIER_GROUPING_NO,  '||
'  MKT.QUALIFIER_CONTEXT,  '||
'  MKT.QUALIFIER_ATTRIBUTE,  '||
'  MKT.QUALIFIER_ATTR_VALUE,  '||
'  MKT.QUALIFIER_ATTR_VALUE_TO,  '||
'  MKT.COMPARISON_OPERATOR_CODE  '||
'FROM  '||
'  OZF_OFFERS OFFR, '||
'  OZF_OFFER_DISCOUNT_LINES ODL, '||
'  OZF_OFFER_DISCOUNT_PRODUCTS ODP, '||
'  QP_QUALIFIERS MKT '||
'WHERE ''OFFR'' = :l_object_type '||
'  AND OFFR.QP_LIST_HEADER_ID = :l_object_id '||
'  AND OFFR.OFFER_ID = ODL.OFFER_ID  '||
'  AND ODL.TIER_TYPE = ''PBH'' '||
'  AND ODP.OFFER_ID = OFFR.OFFER_ID '||
'  AND ODP.OFFER_DISCOUNT_LINE_ID = ODL.OFFER_DISCOUNT_LINE_ID '||
'  AND ODP.APPLY_DISCOUNT_FLAG = ''Y'' '||
'  AND OFFR.QP_LIST_HEADER_ID = MKT.LIST_HEADER_ID  '||
'  AND (MKT.START_DATE_ACTIVE < SYSDATE OR  MKT.START_DATE_ACTIVE IS NULL)  '||
'  AND (MKT.END_DATE_ACTIVE > SYSDATE   OR MKT.END_DATE_ACTIVE IS NULL)  '||
'  AND MKT.LIST_LINE_ID = -1';

-- R12
l_vol_offer_exc VARCHAR2(30000) :=
'  SELECT '||
'  EXCODP.PRODUCT_CONTEXT, '||
'  EXCODP.PRODUCT_ATTRIBUTE, '||
'  EXCODP.PRODUCT_ATTR_VALUE, '||
'  PRDODP.PRODUCT_CONTEXT, '||
'  PRDODP.PRODUCT_ATTRIBUTE, '||
'  PRDODP.PRODUCT_ATTR_VALUE '||
'FROM '||
'  OZF_OFFERS OFFR, '||
'  OZF_OFFER_DISCOUNT_LINES ODL, '||
'  OZF_OFFER_DISCOUNT_PRODUCTS PRDODP, '||
'  OZF_OFFER_DISCOUNT_PRODUCTS EXCODP '||
'WHERE ''OFFR'' = :l_object_type '||
'  AND OFFR.QP_LIST_HEADER_ID = :l_object_id '||
'  AND OFFR.OFFER_ID = ODL.OFFER_ID  '||
'  AND ODL.TIER_TYPE = ''PBH'' '||
'  AND EXCODP.OFFER_ID = OFFR.OFFER_ID '||
'  AND ODL.OFFER_DISCOUNT_LINE_ID = EXCODP.OFFER_DISCOUNT_LINE_ID '||
'  AND EXCODP.APPLY_DISCOUNT_FLAG = ''N'' '||
'  AND PRDODP.OFFER_ID = OFFR.OFFER_ID '||
'  AND ODL.OFFER_DISCOUNT_LINE_ID = PRDODP.OFFER_DISCOUNT_LINE_ID '||
'  AND PRDODP.APPLY_DISCOUNT_FLAG = ''Y'' ';




CURSOR get_offer_type(l_qp_list_header_id NUMBER) IS
SELECT offer_type
FROM ozf_offers
WHERE qp_list_header_id = l_qp_list_header_id;

l_offer_type      VARCHAR2(30);

l_fcst_dimentions VARCHAR2(30000);
l_fcst_exclusions VARCHAR2(30000);

l_product_attribute_context ozf_forecast_dimentions.product_attribute_context%TYPE;
l_product_attribute         ozf_forecast_dimentions.product_attribute%TYPE;
l_product_attr_value        ozf_forecast_dimentions.product_attr_value%TYPE;

l_product_attribute_context_e ozf_forecast_prod_exclusions.product_attribute_context_e%TYPE;
l_product_attribute_e         ozf_forecast_prod_exclusions.product_attribute_e%TYPE;
l_product_attr_value_e        ozf_forecast_prod_exclusions.product_attr_value_e%TYPE;

l_qualifier_grouping_no        ozf_forecast_dimentions.qualifier_grouping_no%TYPE;
l_qualifier_context            ozf_forecast_dimentions.qualifier_context%TYPE;
l_qualifier_context_attribute  ozf_forecast_dimentions.qualifier_attribute%TYPE;
l_qualifier_attr_value         ozf_forecast_dimentions.qualifier_attr_value%TYPE;
l_qualifier_attr_value_to      ozf_forecast_dimentions.qualifier_attr_value_to%TYPE;
l_comparison_operator_code     ozf_forecast_dimentions.comparison_operator_code%TYPE;

l_count NUMBER :=0;
l_obj_type      VARCHAR2(30);

BEGIN

    IF (OZF_DEBUG_HIGH_ON) THEN

    OZF_Utility_PVT.debug_message(l_full_name || ': Start Creating Dimentions');

    END IF;

    SAVEPOINT  Create_Dimentions;

    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name)
    THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.g_ret_sts_success;
----dbms_output.put_line( ' -- IN create_dimentions -- ');
    IF p_obj_type IN ('CAMP', 'CSCH')
    THEN

          l_fcst_dimentions := l_obj_dimentions ;
          l_fcst_exclusions := l_obj_exclusions ;

    ELSIF (( p_obj_type = 'OFFR' ) OR (p_obj_type = 'DISP' ) )
    THEN
----dbms_output.put_line( ' -- IN create_dimentions, p_obj_type **** -- '||p_obj_type);
          OPEN get_offer_type(p_obj_id);
          FETCH get_offer_type INTO l_offer_type;
          CLOSE get_offer_type ;
----dbms_output.put_line( ' -- IN create_dimentions, l_offer_type **** -- '||l_offer_type);
          IF l_offer_type = 'LUMPSUM'
          THEN
               l_fcst_dimentions := l_lumpsum_offr_dim ;
               l_fcst_exclusions := l_lumpsum_offr_exc ;
          ELSIF l_offer_type = 'VOLUME_OFFER'
          THEN
               l_fcst_dimentions := l_vol_offer_dimensions ;
               l_fcst_exclusions := l_vol_offer_exc ;
          ELSE
               l_fcst_dimentions := l_offer_dimentions ;
               l_fcst_exclusions := l_offer_exclusions ;
          END IF;
    ELSIF ( p_obj_type = 'WKST' )
    THEN
          -- 11510
          l_fcst_dimentions := l_wkst_dimentions;

    END IF;
----dbms_output.put_line( ' -- IN create_dimentions, before deleting **** -- ');
  -- inanaiah: R12 - delete records only of the forecast being refered otherwise the reference needed is lost when creating new version
    DELETE FROM ozf_forecast_dimentions
    WHERE obj_type = p_obj_type
    AND   obj_id   = p_obj_id
    AND forecast_id = p_forecast_id;

    --R12 change
    IF (p_obj_type = 'DISP')
    THEN
        l_obj_type := 'OFFR';
    ELSE
        l_obj_type := p_obj_type;
    END IF;
----dbms_output.put_line( ' -- IN create_dimentions, after deleting **** -- '||l_obj_type);
    --OPEN dim_cv FOR l_fcst_dimentions USING p_obj_type, p_obj_id;

    OPEN dim_cv FOR l_fcst_dimentions USING l_obj_type, p_obj_id;
    LOOP

----dbms_output.put_line( ' -- IN create_dimentions, B4 fetch dim_cv **** -- ');
      FETCH dim_cv INTO
                        l_product_attribute_context,
                        l_product_attribute,
                        l_product_attr_value,
                        l_qualifier_grouping_no,
                        l_qualifier_context,
                        l_qualifier_context_attribute,
                        l_qualifier_attr_value,
                        l_qualifier_attr_value_to,
                        l_comparison_operator_code ;
----dbms_output.put_line( ' -- IN create_dimentions, AFTER fetch dim_cv **** -- ');
      EXIT WHEN dim_cv%NOTFOUND;

      l_count := l_count + 1 ;
----dbms_output.put_line( ' -- IN create_dimentions, B4 INSERT INTO ozf_forecast_dimentions **** -- ');
      INSERT INTO ozf_forecast_dimentions(FORECAST_DIMENTION_ID,
                                          OBJ_TYPE,
                                          OBJ_ID,
                                          PRODUCT_ATTRIBUTE_CONTEXT,
                                          PRODUCT_ATTRIBUTE,
                                          PRODUCT_ATTR_VALUE,
                                          QUALIFIER_GROUPING_NO,
                                          QUALIFIER_CONTEXT,
                                          QUALIFIER_ATTRIBUTE,
                                          QUALIFIER_ATTR_VALUE,
                                          QUALIFIER_ATTR_VALUE_TO,
                                          COMPARISON_OPERATOR_CODE,
                                          SECURITY_GROUP_ID,
                                          CREATION_DATE,
                                          CREATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_LOGIN,
                                          FORECAST_ID)
      VALUES  (         ozf_forecast_dimentions_s.nextval,
                        p_obj_type,
                        p_obj_id,
                        l_product_attribute_context,
                        l_product_attribute,
                        l_product_attr_value,
                        l_qualifier_grouping_no,
                        l_qualifier_context,
                        l_qualifier_context_attribute,
                        l_qualifier_attr_value,
                        l_qualifier_attr_value_to,
                        l_comparison_operator_code,
                        NULL,
                        sysdate,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.user_id,
                        fnd_global.login_id,
                        p_forecast_id  );

    END LOOP;

    CLOSE dim_cv;

    IF l_count = 0
    THEN
        if p_obj_type <> 'WKST'
        then
            FND_MESSAGE.set_name('OZF', 'OZF_FCST_PROD_MKT_REQD');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        end if;
    END IF;

    -- 11510 : Worksheets will not have exclusions
    IF ( p_obj_type <> 'WKST' ) THEN
----dbms_output.put_line( ' -- IN create_dimentions, p_obj_type <> WKST **** -- ');
    /* inanaiah: R12 - not deleted as the reference is needed when creating new version
    DELETE FROM ozf_forecast_prod_exclusions
    WHERE obj_type = p_obj_type
    AND   obj_id   = p_obj_id ;
    */

    --OPEN excp_cv FOR l_fcst_exclusions USING p_obj_type, p_obj_id;
    OPEN excp_cv FOR l_fcst_exclusions USING l_obj_type, p_obj_id;

    LOOP
    ----dbms_output.put_line( ' -- IN create_dimentions, B4 fetching excp_cv **** -- ');
      FETCH excp_cv INTO
                        l_product_attribute_context,
                        l_product_attribute,
                        l_product_attr_value,
                        l_product_attribute_context_e,
                        l_product_attribute_e,
                        l_product_attr_value_e ;
    ----dbms_output.put_line( ' -- IN create_dimentions, AFTER fetching excp_cv **** -- ');
      EXIT WHEN excp_cv%NOTFOUND;
    ----dbms_output.put_line( ' -- IN create_dimentions, B4 INSERT INTO ozf_forecast_prod_exclusions **** -- ');
      INSERT INTO ozf_forecast_prod_exclusions(
                         FORECAST_PROD_EXCLUSION_ID,
                         OBJ_TYPE,
                         OBJ_ID,
                         PRODUCT_ATTRIBUTE_CONTEXT,
                         PRODUCT_ATTRIBUTE,
                         PRODUCT_ATTR_VALUE,
                         PRODUCT_ATTRIBUTE_CONTEXT_E,
                         PRODUCT_ATTRIBUTE_E,
                         PRODUCT_ATTR_VALUE_E,
                         SECURITY_GROUP_ID,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_LOGIN)
      VALUES  (         ozf_forecast_prod_exclusions_s.nextval,
                        p_obj_type,
                        p_obj_id,
                        l_product_attribute_context,
                        l_product_attribute,
                        l_product_attr_value,
                        l_product_attribute_context_e,
                        l_product_attribute_e,
                        l_product_attr_value_e,
                        NULL,
                        sysdate,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.user_id,
                        fnd_global.login_id  );


    END LOOP;

    CLOSE excp_cv;

    END IF;

    IF (OZF_DEBUG_HIGH_ON) THEN
        OZF_Utility_PVT.debug_message(l_full_name || ': End Creating Dimentions');
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Create_Dimentions;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      ROLLBACK TO Create_Dimentions;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


END create_dimentions;


-----------------------------------------------------------
-- CP
-----------------------------------------------------------

PROCEDURE populate_fcst_products(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_obj_type         IN VARCHAR2,
  p_obj_id           IN NUMBER,
  p_forecast_id      IN NUMBER,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2

)
IS

  CURSOR c_products IS
  SELECT DISTINCT
         product_attribute_context,
         product_attribute,
         product_attr_value
    FROM ozf_forecast_dimentions
   WHERE obj_type = p_obj_type
     AND obj_id = p_obj_id
     AND forecast_id = p_forecast_id;

  CURSOR c_excluded_products( p_product_attribute_context IN VARCHAR2,
                              p_product_attribute IN VARCHAR2,
                              p_product_attr_value IN VARCHAR2 ) IS
  SELECT product_attribute_context_e,
         product_attribute_e,
         product_attr_value_e
    FROM ozf_forecast_prod_exclusions
   WHERE product_attribute_context = p_product_attribute_context
   AND   product_attribute = p_product_attribute
   AND   product_attr_value = p_product_attr_value
   AND   obj_type = p_obj_type
   AND   obj_id = p_obj_id ;
/*
  CURSOR c_no_products IS
  SELECT COUNT(*)
    FROM ozf_forecast_dimentions
   WHERE obj_type = p_obj_type
     AND obj_id = p_obj_id;
*/
  CURSOR c_no_excl_products( p_product_attribute_context IN VARCHAR2,
                             p_product_attribute IN VARCHAR2,
                             p_product_attr_value IN VARCHAR2 ) IS
  SELECT COUNT(*)
    FROM ozf_forecast_prod_exclusions
   WHERE product_attribute_context = p_product_attribute_context
   AND   product_attribute = p_product_attribute
   AND   product_attr_value = p_product_attr_value
   AND   obj_type = p_obj_type
   AND   obj_id = p_obj_id ;

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'populate_fcst_products';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  l_stmt_temp     VARCHAR2(32000) := NULL;
  l_stmt_product1 VARCHAR2(32000) := NULL;
  l_stmt_product2 VARCHAR2(32000) := NULL;
  l_stmt_product  VARCHAR2(32000) := NULL;
  l_stmt_denorm   VARCHAR2(32000) := NULL;

  l_pricing_attribute_id NUMBER;
  l_list_line_id         NUMBER;

--  l_no_products          NUMBER;
  l_no_excl_products     NUMBER;
--  l_prod_index           NUMBER;
  l_excl_index           NUMBER;
  l_denorm_csr           NUMBER;
  l_ignore               NUMBER;


BEGIN

  IF (OZF_DEBUG_HIGH_ON) THEN

  OZF_Utility_PVT.debug_message(l_full_name || ': Start populate products');

  END IF;

  SAVEPOINT Populate_Products;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  delete from ozf_forecast_products
  where obj_type = p_obj_type
  and obj_id = p_obj_id ;

/*
  OPEN c_no_products;
  FETCH c_no_products INTO l_no_products;
  CLOSE c_no_products;

  l_prod_index := 1;
*/
  FOR i IN c_products LOOP
  FND_DSQL.init;
  FND_DSQL.add_text('INSERT INTO ozf_forecast_products( ');
  FND_DSQL.add_text('forecast_product_id, ');
  FND_DSQL.add_text('obj_type, ');
  FND_DSQL.add_text('obj_id, ');
  FND_DSQL.add_text('product_attribute_context, ');
  FND_DSQL.add_text('product_attribute, ');
  FND_DSQL.add_text('product_attr_value, ');
  FND_DSQL.add_text('product_id, ');
  FND_DSQL.add_text('creation_date, ');
  FND_DSQL.add_text('created_by, ');
  FND_DSQL.add_text('last_update_date, ');
  FND_DSQL.add_text('last_updated_by , ');
  FND_DSQL.add_text('last_update_login )');

  FND_DSQL.add_text(' SELECT ');
  FND_DSQL.add_text('ozf_forecast_products_s.nextval,');
  FND_DSQL.add_bind(p_obj_type);
  FND_DSQL.add_text(',');
  FND_DSQL.add_bind(p_obj_id);
  FND_DSQL.add_text(',');
  FND_DSQL.add_bind(i.product_attribute_context);
  FND_DSQL.add_text(',' );
  FND_DSQL.add_bind(i.product_attribute);
  FND_DSQL.add_text(',' );
  FND_DSQL.add_bind(i.product_attr_value);
  FND_DSQL.add_text(',' );
  FND_DSQL.add_text('a.product_id , ');
  FND_DSQL.add_text('sysdate , ');
  FND_DSQL.add_text('fnd_global.user_id ,');
  FND_DSQL.add_text('sysdate , ');
  FND_DSQL.add_text('fnd_global.user_id, ');
  FND_DSQL.add_text('fnd_global.login_id ');

  FND_DSQL.add_text(' FROM (');

      l_stmt_temp := null;
      l_stmt_product  := NULL;
      l_stmt_product1 := NULL;
      l_stmt_denorm := NULL;

      OPEN c_no_excl_products(i.product_attribute_context,
                              i.product_attribute,
                              i.product_attr_value);
      FETCH c_no_excl_products INTO l_no_excl_products;
      CLOSE c_no_excl_products;

--      FND_DSQL.add_text('(');

      l_stmt_temp := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql(
                             p_context         => i.product_attribute_context,
                             p_attribute       => i.product_attribute,
                             p_attr_value_from => i.product_attr_value,
                             p_attr_value_to   => NULL,
                             p_comparison      => NULL,
                             p_type            => 'PROD'
                            );

      IF l_stmt_temp IS NULL THEN
        GOTO NEXT_PRODUCT;
      ELSE
        IF l_no_excl_products > 0 THEN
          FND_DSQL.add_text(' MINUS (');
        END IF;
      END IF;

      IF l_stmt_product1 IS NULL THEN
        l_stmt_product1 := l_stmt_temp;
      END IF;

      l_stmt_product2 := NULL;
      l_excl_index := 1;

      FOR j IN c_excluded_products(i.product_attribute_context,
                                   i.product_attribute,
                                   i.product_attr_value )
      LOOP

        l_stmt_temp := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql(
                                  p_context         => j.product_attribute_context_e,
                                  p_attribute       => j.product_attribute_e,
                                  p_attr_value_from => j.product_attr_value_e,
                                  p_attr_value_to   => NULL,
                                  p_comparison      => NULL,
                                  p_type            => 'PROD'
                                 );

        IF l_stmt_temp IS NULL THEN
          EXIT;
        ELSE
          IF l_excl_index < l_no_excl_products THEN
            FND_DSQL.add_text(' UNION ');
            l_excl_index := l_excl_index + 1;
          ELSE
            FND_DSQL.add_text(')');
          END IF;
        END IF;
      END LOOP;

--      FND_DSQL.add_text(')');
/*
      IF l_prod_index < l_no_products THEN
        FND_DSQL.add_text(' UNION ');
        l_prod_index := l_prod_index + 1;
      END IF;
*/
      FND_DSQL.add_text(') a');

       l_denorm_csr := DBMS_SQL.open_cursor;
       FND_DSQL.set_cursor(l_denorm_csr);
       l_stmt_denorm := FND_DSQL.get_text(FALSE);
       DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
       FND_DSQL.do_binds;
       l_ignore := DBMS_SQL.execute(l_denorm_csr);
       dbms_sql.close_cursor(l_denorm_csr);

      <<NEXT_PRODUCT>>
      NULL;
  END LOOP;

  IF (OZF_DEBUG_HIGH_ON) THEN

  OZF_Utility_PVT.debug_message(l_full_name || ': End populate products');

  END IF;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      ROLLBACK TO Populate_Products;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END populate_fcst_products;



PROCEDURE get_site_type( p_context   IN VARCHAR2,
                         p_attribute IN VARCHAR2,
                         p_type OUT NOCOPY VARCHAR2)
IS

-- ?? What if the condition_id_column has a site_use_id/party_site_id with a
--    different alias ??
-- Ans: Implementation doc specifies to use these column names only

CURSOR check_for_site(l_context VARCHAR2, l_attribute VARCHAR2) IS
  SELECT DECODE(instr(upper(condition_id_column),'SITE_USE_ID'),
                  0,DECODE(instr(upper(condition_id_column),'PARTY_SITE_ID'),0,'N','P'),
                   'C')
  FROM ozf_denorm_queries
  WHERE query_for='ELIG'
  AND condition_id_column IS NOT NULL
  AND context = l_context
  AND attribute = l_attribute;

BEGIN

/* ************
  N = Not a site
  P = Party Site
  C = Customer Account Site
   ************ */

  OPEN check_for_site(p_context,p_attribute);
  FETCH check_for_site INTO p_type ;
  CLOSE check_for_site;

END get_site_type;


PROCEDURE populate_fcst_customers(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_obj_type         IN VARCHAR2,
  p_obj_id           IN NUMBER,
  p_forecast_id      IN NUMBER,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2

)
IS

  CURSOR c_groups IS
  SELECT distinct qualifier_grouping_no
    FROM ozf_forecast_dimentions
   WHERE obj_type = p_obj_type
     AND obj_id   =  p_obj_id
     AND forecast_id = p_forecast_id;

  CURSOR c_get_site_use(p_site_use_id NUMBER) IS
  SELECT site_use_code
  FROM hz_cust_site_uses
  WHERE site_use_id = p_site_use_id;

  CURSOR c_qualifiers(l_grouping_no NUMBER) IS
  SELECT DISTINCT
         qualifier_context,
         qualifier_attribute,
         qualifier_attr_value,
         qualifier_attr_value_to,
         comparison_operator_code
    FROM ozf_forecast_dimentions
   WHERE obj_type = p_obj_type
     AND obj_id   = p_obj_id
     AND forecast_id = p_forecast_id
     AND qualifier_grouping_no = l_grouping_no ;

  CURSOR c_no_qualifiers(l_grouping_no NUMBER) IS
  SELECT COUNT(*)
  FROM   (SELECT DISTINCT
                 qualifier_context,
                 qualifier_attribute,
                 qualifier_attr_value,
                 qualifier_attr_value_to,
                 comparison_operator_code
         FROM    ozf_forecast_dimentions
         WHERE   obj_type = p_obj_type
         AND     obj_id   = p_obj_id
         AND     forecast_id = p_forecast_id
         AND     qualifier_grouping_no = l_grouping_no) ;

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'populate_fcst_parties';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  l_stmt_temp     VARCHAR2(32000)        := NULL;
  l_stmt_group    VARCHAR2(32000)        := NULL;
  l_stmt_denorm    VARCHAR2(32000)        := NULL;

  l_qualifier_grouping_no NUMBER := NULL;
  l_site_use_id           VARCHAR2(40);
  l_site_type             VARCHAR2(1);
  l_site_use_code         VARCHAR2(30) := 'NULL';

  l_no_qualifiers        NUMBER;
  l_qualifier_index      NUMBER;
  l_denorm_csr           NUMBER;
  l_ignore               NUMBER;

BEGIN

  IF (OZF_DEBUG_HIGH_ON) THEN

  OZF_Utility_PVT.debug_message(l_full_name || ': Start populate customers');

  END IF;
  SAVEPOINT Populate_Customers;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  DELETE FROM ozf_forecast_customers
  WHERE obj_type = p_obj_type
  AND   obj_id = p_obj_id ;

  FOR i IN c_groups LOOP

    FND_DSQL.init;
    FND_DSQL.add_text('INSERT INTO ozf_forecast_customers( ');
    FND_DSQL.add_text('forecast_customer_id, ');
    FND_DSQL.add_text('obj_type, ');
    FND_DSQL.add_text('obj_id, ');
    FND_DSQL.add_text('qualifier_grouping_no, ');
    FND_DSQL.add_text('cust_account_id, ');
    FND_DSQL.add_text('site_use_id, ');
    FND_DSQL.add_text('site_use_code, ');
    FND_DSQL.add_text('creation_date, ');
    FND_DSQL.add_text('created_by, ');
    FND_DSQL.add_text('last_update_date, ');
    FND_DSQL.add_text('last_updated_by, ');
    FND_DSQL.add_text('last_update_login )');

/*
    FOR j IN c_qualifiers(i.qualifier_grouping_no) LOOP
      get_site_type(j.qualifier_context, j.qualifier_attribute, l_site_type);

      IF ( l_site_type = 'P' ) THEN
        l_site_use_id := -1;
      ELSIF ( l_site_type = 'N') THEN
        l_site_use_id := NULL;
      ELSIF ( l_site_type = 'C') THEN
        l_site_use_id := j.qualifier_attr_value ;

        OPEN c_get_site_use(j.qualifier_attr_value);
        FETCH c_get_site_use INTO l_site_use_code;
        CLOSE c_get_site_use;
      ELSE
        l_site_use_id := NULL;
      END IF ;
    END LOOP;
*/
    FND_DSQL.add_text(' SELECT ');
    FND_DSQL.add_text('ozf_forecast_customers_s.nextval ,');
    FND_DSQL.add_bind(p_obj_type);
    FND_DSQL.add_text(',');
    FND_DSQL.add_bind(p_obj_id);
    FND_DSQL.add_text(',');
    FND_DSQL.add_bind(i.qualifier_grouping_no);
    FND_DSQL.add_text(',');
    FND_DSQL.add_text('b.cust_account_id ,');
    FND_DSQL.add_text('b.site_use_id ,');
    FND_DSQL.add_text('b.site_use_code ,');
--   FND_DSQL.add_bind(l_site_use_id);
--    FND_DSQL.add_text(',');
--    FND_DSQL.add_bind(l_site_use_code);
--    FND_DSQL.add_text(',');
    FND_DSQL.add_text('sysdate , ');
    FND_DSQL.add_text('fnd_global.user_id ,');
    FND_DSQL.add_text('sysdate , ');
    FND_DSQL.add_text('fnd_global.user_id, ');
    FND_DSQL.add_text('fnd_global.login_id ');

    FND_DSQL.add_text(' FROM (');

    OPEN c_no_qualifiers(i.qualifier_grouping_no);
    FETCH c_no_qualifiers INTO l_no_qualifiers;
    CLOSE c_no_qualifiers;

    l_stmt_group := NULL;
    l_site_type  := NULL;
    l_qualifier_grouping_no := i.qualifier_grouping_no;
    l_qualifier_index := 1;

    FOR j IN c_qualifiers(i.qualifier_grouping_no) LOOP


      l_stmt_temp := NULL;

      l_stmt_temp := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql(
                             p_context         => j.qualifier_context,
                             p_attribute       => j.qualifier_attribute,
                             p_attr_value_from => j.qualifier_attr_value,
                             p_attr_value_to   => j.qualifier_attr_value_to,
                             p_comparison      => j.comparison_operator_code,
                             p_type            => 'ELIG'
                            );

      IF l_stmt_temp IS NULL
      THEN
          -- context-attribute pair does not return a party
          GOTO NEXT_CUSTOMER ;
      ELSE

        IF l_qualifier_index < l_no_qualifiers THEN
          FND_DSQL.add_text(' INTERSECT ');
          l_qualifier_index := l_qualifier_index + 1;
        END IF;
      END IF;

      <<NEXT_CUSTOMER>>
      null;
    END LOOP;
    FND_DSQL.add_text(') b');

--    FND_DSQL.add_text(' a,hz_cust_accounts b');
--    FND_DSQL.add_text(' WHERE a.party_id = b.party_id ');

    IF l_stmt_temp IS NULL
    THEN
       GOTO NEXT_GROUP ;
    END IF;

       l_denorm_csr := DBMS_SQL.open_cursor;
       FND_DSQL.set_cursor(l_denorm_csr);
       l_stmt_denorm := FND_DSQL.get_text(FALSE);
       ams_utility_pvt.debug_message('stmt ' || l_stmt_denorm);
       DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
       FND_DSQL.do_binds;
       l_ignore := DBMS_SQL.execute(l_denorm_csr);
       dbms_sql.close_cursor(l_denorm_csr);

    <<NEXT_GROUP>>
    NULL;

  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      ROLLBACK TO Populate_Customers;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
x_msg_data := SQLERRM;
END populate_fcst_customers;

PROCEDURE populate_fcst_periods(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_obj_type         IN VARCHAR2,
  p_obj_id           IN NUMBER,
  p_start_date       IN DATE,
  p_end_date         IN DATE,
  p_period_level     IN VARCHAR2,
  p_forecast_id      IN NUMBER,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2 )
IS

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'populate_fcst_periods';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  CURSOR periods_csr (p_period_type_id IN NUMBER)
  IS
  SELECT DISTINCT
       decode(p_period_type_id  ,
                    1, report_date_julian,
                   16, week_id,
                   32, month_id,
                   64, ent_qtr_id
                     , ent_year_id ) time_id
  FROM ozf_time_day
  WHERE report_date BETWEEN p_start_date AND p_end_date;

  CURSOR day_csr(l_time_id IN NUMBER) IS
  SELECT to_char(report_date) name, start_date, end_date
  FROM ozf_time_day
  WHERE report_date_julian = l_time_id;

  CURSOR week_csr(l_time_id IN NUMBER) IS
  SELECT name, start_date, end_date
  FROM ozf_time_week
  WHERE week_id = l_time_id;

  CURSOR month_csr(l_time_id IN NUMBER) IS
  SELECT name, start_date, end_date
  FROM ozf_time_ent_period
  WHERE ent_period_id = l_time_id;

  CURSOR qtr_csr(l_time_id IN NUMBER) IS
  SELECT name, start_date, end_date
  FROM ozf_time_ent_qtr
  WHERE ent_qtr_id = l_time_id;

  CURSOR year_csr(l_time_id IN NUMBER) IS
  SELECT name, start_date, end_date
  FROM ozf_time_ent_year
  WHERE ent_year_id = l_time_id;


  l_temp_start_date DATE;
  l_temp_end_date   DATE;
  l_days            NUMBER;
  l_period_number   NUMBER ;
  l_period_type_id  NUMBER;
  l_name            VARCHAR2(100);

BEGIN
  IF (OZF_DEBUG_HIGH_ON)
  THEN
    OZF_Utility_PVT.debug_message(l_full_name || ': Start Populate Periods');
  END IF;
  SAVEPOINT Populate_Periods;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  x_return_status := FND_API.g_ret_sts_success;

  IF ( ( p_start_date IS NULL) OR (p_end_date IS NULL) )
  THEN
    return;
  END IF;

  -- inanaiah: R12 - delete records only of the forecast being refered otherwise the reference needed is lost when creating new version
  DELETE FROM ozf_forecast_periods
  WHERE obj_id = p_obj_id
  AND obj_type = p_obj_type
  AND forecast_id = p_forecast_id;

-- Period Type (day - 1, week 16, month - 32, quarter - 64, year - 128)

----dbms_output.put_line( ' -- period  -- '|| p_period_level );
----dbms_output.put_line( ' -- period: start date  -- '|| p_start_date );
----dbms_output.put_line( ' -- period: end date  -- '|| p_end_date );
----dbms_output.put_line( ' -- period: obj type  -- '|| p_obj_type );

  l_period_type_id := p_period_level;

--  FOR i IN periods_csr(l_period_type_id)
  FOR i IN periods_csr(p_period_level)
  LOOP

----dbms_output.put_line( ' -- period  -- '|| p_period_level );

  l_period_number := i.time_id ;
  IF p_period_level = '1'
  THEN
    OPEN day_csr(i.time_id);
    FETCH day_csr INTO l_name, l_temp_start_date, l_temp_end_date;
    CLOSE day_csr;
  ELSIF p_period_level = '16'
  THEN
    OPEN week_csr(i.time_id);
    FETCH week_csr INTO l_name, l_temp_start_date, l_temp_end_date;
    CLOSE week_csr;
  ELSIF p_period_level = '32'
  THEN
    OPEN month_csr(i.time_id);
    FETCH month_csr INTO l_name, l_temp_start_date, l_temp_end_date;
    CLOSE month_csr;
  ELSIF p_period_level = '64'
  THEN
    OPEN qtr_csr(i.time_id);
    FETCH qtr_csr INTO l_name, l_temp_start_date, l_temp_end_date;
    CLOSE qtr_csr;
  ELSE
    OPEN year_csr(i.time_id);
    FETCH year_csr INTO l_name, l_temp_start_date, l_temp_end_date;
    CLOSE year_csr;
  END IF;

        IF l_temp_start_date < p_start_date
        THEN
            l_temp_start_date := p_start_date;
        END IF;

        IF l_temp_end_date > p_end_date
        THEN
            l_temp_end_date := p_end_date;
        END IF;

        INSERT INTO ozf_forecast_periods (
                     forecast_period_id,
                     obj_type,
                     obj_id,
                     period_number,
                     start_date,
                     end_date,
                     creation_date,
                     created_by,
                     last_update_date,
                     last_updated_by,
                     last_update_login,
                     period_type_id,
                     period_name,
                     forecast_id)
        VALUES ( ozf_forecast_periods_s.nextval,
                 p_obj_type,
                 p_obj_id,
                 l_period_number,
                 l_temp_start_date,
                 l_temp_end_date,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 fnd_global.login_id,
                 l_period_type_id,
                 l_name,
                 p_forecast_id );
   END LOOP;

  IF (OZF_DEBUG_HIGH_ON)
  THEN
      OZF_Utility_PVT.debug_message(l_full_name || ': End Populate Periods');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      ROLLBACK TO Populate_Periods;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


END populate_fcst_periods;

-----------------------------------------------
 PROCEDURE create_fact(p_fact_type IN VARCHAR2,
                       p_base_quantity IN NUMBER,
                       p_fact_reference IN VARCHAR2,
                       p_start_date IN DATE,
                       p_end_date IN DATE,
                       p_forecast_id IN NUMBER,
                       p_activity_metric_id IN NUMBER,
                       p_previous_fact_id IN NUMBER,
                       p_root_fact_id IN NUMBER,
                       p_node_id IN NUMBER  ) IS
 BEGIN
     ----dbms_output.put_line( ' -- $$$$$$ create_fact-- ');
       INSERT INTO ozf_act_metric_facts_all (
                   ACTIVITY_METRIC_FACT_ID , LAST_UPDATE_DATE ,
                   LAST_UPDATED_BY         , CREATION_DATE    ,
                   CREATED_BY              , OBJECT_VERSION_NUMBER    ,
                   ACT_METRIC_USED_BY_ID   , ARC_ACT_METRIC_USED_BY   ,
                   VALUE_TYPE              , ACTIVITY_METRIC_ID       ,
                   TRANS_FORECASTED_VALUE  , FUNCTIONAL_CURRENCY_CODE ,
                   FUNC_FORECASTED_VALUE   , ORG_ID       ,
                   DE_METRIC_ID            , TIME_ID1     ,
                   FROM_DATE               , TO_DATE      ,
                   FACT_VALUE              , FACT_PERCENT ,
                   BASE_QUANTITY           , ROOT_FACT_ID ,
                   PREVIOUS_FACT_ID        , FACT_TYPE    ,
                   FACT_REFERENCE          , LAST_UPDATE_LOGIN,
                   FORECAST_REMAINING_QUANTITY , NODE_ID)
       VALUES (    ozf_act_metric_facts_all_s.nextval , sysdate ,
                   fnd_global.user_id                 , sysdate ,
                   fnd_global.user_id                 , 1 ,
                   p_forecast_id                      , 'FCST' ,
                   'NUMERIC'                          , p_activity_metric_id,
                   0                                  , 'NONE',
                   0, MO_GLOBAL.GET_CURRENT_ORG_ID(),
                   0                                  , 0 ,
                   p_start_date                       , p_end_date ,
                   NULL                               , NULL ,
                   ROUND(NVL(p_base_quantity,0))      , p_root_fact_id ,
                   p_previous_fact_id                 , p_fact_type ,
                   p_fact_reference ,                 fnd_global.login_id,
                   0                                  , p_node_id);

               --  ROUND(NVL(p_base_quantity,0))      , p_root_fact_id ,

 END create_fact;

--------------------------------------------------

PROCEDURE  create_dimention_facts (
                                    p_api_version      IN  NUMBER,
                                    p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
                                    p_commit           IN  VARCHAR2  := FND_API.g_false,
                                    --R12 Baseline
                                    p_base_quantity_type IN VARCHAR2,
                                    p_obj_type IN VARCHAR2,
                                    p_obj_id   IN NUMBER,
                                    p_forecast_id IN NUMBER,
                                    p_activity_metric_id IN NUMBER,
                                    p_dimention IN VARCHAR2,
                                    p_fcst_uom  IN VARCHAR2,
                                    p_product_attribute_context IN VARCHAR2,
                                    p_product_attribute IN VARCHAR2,
                                    p_product_attr_value IN VARCHAR2,
                                    p_qualifier_grouping_no IN NUMBER,
                                    p_period_number IN NUMBER,
                                    p_previous_fact_id IN NUMBER,
                                    p_root_fact_id  IN NUMBER,
                                    x_return_status    OUT NOCOPY VARCHAR2,
                                    x_msg_count        OUT NOCOPY NUMBER,
                                    x_msg_data         OUT NOCOPY VARCHAR2)
IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'create_dimention_facts';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);
/*
   CURSOR get_base_sales (l_product_attribute_context IN VARCHAR2,
                          l_product_attribute     IN VARCHAR2,
                          l_product_attr_value    IN VARCHAR2,
                          l_qualifier_grouping_no IN NUMBER,
                          l_period_number         IN NUMBER )
   IS
          select SUM(inv_convert.inv_um_convert( bs.product_id,
                                                 null,
                                                 bs.qty,
                                                 bs.order_uom,
                                                 p_fcst_uom,
                                                 null, null)
                    )
          from ozf_forecast_dimentions dim,
               ozf_forecast_products prod,
               ozf_forecast_customers mkt,
               ozf_forecast_periods time,
               ams_base_sales_mv bs
          where dim.obj_type = p_obj_type
          and   dim.obj_id   = p_obj_id
          and dim.obj_type = prod.obj_type
          and dim.obj_id   = prod.obj_id
          and dim.product_attribute_context = prod.product_attribute_context
          and dim.product_attribute = prod.product_attribute
          and dim.product_attr_value = prod.product_attr_value
          and dim.obj_type = mkt.obj_type
          and dim.obj_id   = mkt.obj_id
          and dim.qualifier_grouping_no = mkt.qualifier_grouping_no
          and dim.obj_type = time.obj_type
          and dim.obj_id   = time.obj_id
          and bs.product_id = prod.product_id
          and bs.cust_account_id = mkt.cust_account_id
          and bs.ordered_date between time.start_date and time.end_date
          and dim.product_attribute_context = NVL(l_product_attribute_context, dim.product_attribute_context)
          and dim.product_attribute = NVL(l_product_attribute, dim.product_attribute)
          and dim.product_attr_value = NVL(l_product_attr_value, dim.product_attr_value)
          and dim.qualifier_grouping_no = NVL(l_qualifier_grouping_no, dim.qualifier_grouping_no)
          and time.period_number = NVL(l_period_number,time.period_number)
          and DECODE(mkt.site_use_code,
                        'BILL_TO', bs.bill_to_site_id,
                        'SHIP_TO', bs.ship_to_site_id, 99) = NVL(mkt.SITE_USE_ID,99)  ;
*/

 CURSOR get_products(l_qualifier_grouping_no IN NUMBER)  IS
 SELECT min(forecast_dimention_id) forecast_dimention_id,
        product_attribute_context,
        product_attribute,
        product_attr_value
 FROM ozf_forecast_dimentions
 WHERE obj_type = p_obj_type
 AND obj_id = p_obj_id
 AND forecast_id = p_forecast_id
 AND qualifier_grouping_no = NVL(l_qualifier_grouping_no, qualifier_grouping_no)
 GROUP BY
    product_attribute_context,
    product_attribute,
    product_attr_value ;

-- RUP1: Modified group by clause

 CURSOR get_markets (l_product_attribute_context IN VARCHAR2,
                     l_product_attribute IN VARCHAR2,
                     l_product_attr_value IN VARCHAR2 )
 IS
   SELECT min(forecast_dimention_id) forecast_dimention_id,
          min(qualifier_grouping_no) qualifier_grouping_no
   FROM   ozf_forecast_dimentions
   WHERE  obj_type = p_obj_type
   AND    obj_id   = p_obj_id
   AND forecast_id = p_forecast_id
   AND product_attribute_context = NVL(l_product_attribute_context, product_attribute_context)
   AND product_attribute = NVL(l_product_attribute, product_attribute)
   AND product_attr_value = NVL(l_product_attr_value, product_attr_value)
   GROUP BY
         qualifier_context,
         qualifier_attribute,
         qualifier_attr_value,
         qualifier_grouping_no ;

 -- R12 modified
 CURSOR get_periods IS
   SELECT forecast_period_id,
          period_number,
          --ADD_MONTHS(start_date,12) start_date,
          --ADD_MONTHS(end_date,12) end_date
          start_date,
          end_date
   FROM ozf_forecast_periods
   --WHERE obj_type = p_obj_type
   WHERE obj_type = 'DISP'
   AND   obj_id   = p_obj_id
   AND (forecast_id IS NULL -- inanaiah: For compatibility with older release
    OR forecast_id = p_forecast_id); -- inanaiah: making periods bound to forecast_id as is the case when creating new version

   -- inanaiah: used to divide the time spread base sales
   CURSOR get_count_periods(p_id IN NUMBER) IS
   SELECT count(forecast_period_id)
   FROM ozf_forecast_periods
   WHERE obj_type = p_obj_type
   AND   obj_id   = p_id
   AND (forecast_id IS NULL -- inanaiah: For compatibility with older release
    OR forecast_id = p_forecast_id); -- inanaiah: making periods bound to forecast_id as is the case when creating new version

   -- inanaiah: used to get the time spread base sales
   CURSOR get_sales_period(p_id IN NUMBER) IS
   SELECT period_number
   FROM ozf_forecast_periods
   WHERE obj_type = p_obj_type -- 'OFFR'
   AND   obj_id   = p_id
   AND (forecast_id IS NULL -- inanaiah: For compatibility with older release
    OR forecast_id = p_forecast_id); -- inanaiah: making periods bound to forecast_id as is the case when creating new version

   --inanaiah: base_quantity_ref used for Offer_code basis
   CURSOR get_offerCPcomb IS
   SELECT base_quantity_ref, offer_code
   FROM ozf_act_forecasts_all
   WHERE forecast_id = p_forecast_id;

   CURSOR offerid_csr(p_offer_code IN VARCHAR2) IS
    SELECT qp_list_header_id --offer_id
    FROM ozf_offers off
    WHERE off.offer_code = p_offer_code;


   l_base_sales NUMBER := 0;
   l_product_attribute_context ozf_forecast_dimentions.product_attribute_context%TYPE;
   l_product_attribute ozf_forecast_dimentions.product_attribute%TYPE;
   l_product_attr_value ozf_forecast_dimentions.product_attr_value%TYPE;
   l_qualifier_grouping_no NUMBER;
   l_period_number NUMBER;

   -- R12
   l_count_periods NUMBER;
   l_total_base_sales NUMBER;

---  l_base_quantity_ref NUMBER; --- its  varchar2  (08/25/2005)
--   l_base_quantity_type NUMBER; --- its  varchar2  (08/25/2005)

   l_base_quantity_ref  ozf_act_forecasts_all.BASE_QUANTITY_REF%TYPE;

   l_offer_code VARCHAR2(30);
   l_obj_id NUMBER := p_obj_id;

  /* Added for promotional goods offer */

  l_node_id NUMBER;
  l_offer_type VARCHAR2(30) := 'OFFR';

  CURSOR get_offer_type
  IS
   SELECT offer_type
   FROM ozf_offers
   WHERE qp_list_header_id = p_obj_id;

  CURSOR get_promotion_type(l_product_attribute_context IN VARCHAR2,
                            l_product_attribute IN VARCHAR2,
                            l_product_attr_value IN VARCHAR2 )
  IS
   SELECT DECODE(qpl.list_line_type_code
                 ,'DIS', DECODE(qpl.operand
                                ,100 , DECODE(qpl.arithmetic_operator
                                              ,'%', 3
                                                  , 2 )
                                     , 2)
                       , 1) promotion_type
   FROM   qp_list_lines qpl,
          qp_pricing_attributes qp
   WHERE qpl.list_header_id = p_obj_id
   AND qpl.list_line_id = qp.list_line_id
   AND qp.excluder_flag = 'N'
   AND qp.product_attribute_context = l_product_attribute_context
   AND qp.product_attribute = l_product_attribute
   AND qp.product_attr_value = l_product_attr_value
   ORDER BY promotion_type;

BEGIN

    IF (OZF_DEBUG_HIGH_ON) THEN
        OZF_Utility_PVT.debug_message(l_full_name || ': Start Create Dimention Facts');
    END IF;

    SAVEPOINT Create_Dimention_Facts;

    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.g_ret_sts_success;

    --dbms_output.put_line( ' ##### 1. create_dimention_facts -- ');
    l_product_attribute_context := p_product_attribute_context;
    l_product_attribute         := p_product_attribute;
    l_product_attr_value        := p_product_attr_value;
    l_qualifier_grouping_no     := p_qualifier_grouping_no ;
    l_period_number             := p_period_number;

    OPEN get_offerCPcomb;
    FETCH get_offerCPcomb INTO l_base_quantity_ref, l_offer_code;
    CLOSE get_offerCPcomb;

    --offerid_csr
    IF (p_base_quantity_type = 'OFFER_CODE')
    THEN
        OPEN offerid_csr(l_offer_code);
        FETCH offerid_csr INTO l_obj_id;
        CLOSE offerid_csr;
    END IF;

    IF (p_dimention = 'PRODUCT')
    THEN
        FOR i IN get_products(p_qualifier_grouping_no)
        LOOP

             l_product_attribute_context := i.product_attribute_context;
             l_product_attribute  := i.product_attribute;
             l_product_attr_value := i.product_attr_value;
/*
             OPEN get_base_sales(l_product_attribute_context,
                                 l_product_attribute,
                                 l_product_attr_value,
                                 l_qualifier_grouping_no,
                                 l_period_number) ;
             FETCH get_base_sales INTO l_base_sales;
             CLOSE get_base_sales;
*/

             --R12 Baseline
             IF (p_base_quantity_type = 'BASELINE')
             THEN
                 l_base_sales := 0;
             ELSIF ((p_base_quantity_type = 'OFFER_CODE') AND (l_base_quantity_ref = to_char(1) ) )
             THEN
                l_base_sales := 0;
             ELSE
                 get_sales(p_obj_type,
                         l_obj_id,
                         l_product_attribute_context,
                         l_product_attribute,
                         l_product_attr_value,
                         l_qualifier_grouping_no,
                         l_period_number,
                         p_forecast_id,
                         l_base_sales) ;
             END IF;

             IF p_obj_type = 'OFFR'
             THEN
                 OPEN get_offer_type;
                 FETCH get_offer_type INTO l_offer_type;
                 CLOSE get_offer_type;
             END IF;

             IF l_offer_type = 'OID'
             THEN

                    FOR j IN get_promotion_type(l_product_attribute_context,
                                                l_product_attribute,
                                                l_product_attr_value)
                    LOOP
                          create_fact( p_dimention,
                                       l_base_sales,
                                       i.forecast_dimention_id,
                                       NULL, NULL,
                                       p_forecast_id,p_activity_metric_id,
                                       p_previous_fact_id, p_root_fact_id,
                                       j.promotion_type );
                          l_base_sales := 0;
                    END LOOP;

             ELSE
----dbms_output.put_line('period_level ' || i.forecast_dimention_id);
                 create_fact( p_dimention,
                              l_base_sales,
                              i.forecast_dimention_id,
                              NULL, NULL,
                              p_forecast_id,p_activity_metric_id,
                              p_previous_fact_id, p_root_fact_id,
                              l_node_id );

             END IF;

        END LOOP;

    ELSIF (p_dimention = 'MARKET')
    THEN

        FOR i IN get_markets(l_product_attribute_context,
                             l_product_attribute,
                             l_product_attr_value)
        LOOP

             l_qualifier_grouping_no := i.qualifier_grouping_no;
/*
             OPEN get_base_sales(l_product_attribute_context,
                                 l_product_attribute,
                                 l_product_attr_value,
                                 l_qualifier_grouping_no,
                                 l_period_number) ;
             FETCH get_base_sales INTO l_base_sales;
             CLOSE get_base_sales;
*/
             --R12 Baseline
             IF (p_base_quantity_type = 'BASELINE')
             THEN
                 l_base_sales := 0;
             ELSIF ((p_base_quantity_type = 'OFFER_CODE') AND (l_base_quantity_ref = to_char(1) ) )
             THEN
                l_base_sales := 0;
             ELSE
                get_sales(p_obj_type,
                         l_obj_id,
                         l_product_attribute_context,
                         l_product_attribute,
                         l_product_attr_value,
                         l_qualifier_grouping_no,
                         l_period_number,
                         p_forecast_id,
                         l_base_sales) ;
             END IF;

             create_fact( p_dimention,
                          l_base_sales,
                          i.forecast_dimention_id,
                          NULL,NULL,
                          p_forecast_id,p_activity_metric_id,
                          p_previous_fact_id, p_root_fact_id,
                          l_node_id );
        END LOOP;

    ELSIF (p_dimention = 'TIME')
    THEN
        --R12 Baseline
        IF (p_base_quantity_type = 'BASELINE')
        THEN
            l_base_sales := 0;
        ELSIF ((p_base_quantity_type = 'OFFER_CODE') AND (l_base_quantity_ref = to_char(1) ) )
        THEN
            l_base_sales := 0;
        ELSE
            OPEN get_count_periods(l_obj_id);
            FETCH get_count_periods INTO l_count_periods;
            CLOSE get_count_periods;

            FOR i IN get_sales_period(l_obj_id)
            LOOP
                get_sales(p_obj_type,
                         l_obj_id,
                         l_product_attribute_context,
                         l_product_attribute,
                         l_product_attr_value,
                         l_qualifier_grouping_no,
                         i.period_number,
                         p_forecast_id,
                         l_base_sales) ;

                l_total_base_sales := l_total_base_sales + l_base_sales;
            END LOOP;

            -- inanaiah: divide the total base sales evenly among the periods
            l_base_sales := ROUND(l_total_base_sales / l_count_periods);

        END IF; -- IF (p_base_quantity_type


        FOR i IN get_periods
        LOOP
            create_fact( p_dimention,
                          l_base_sales,
                          i.forecast_period_id, -- i.period_number,
                          i.start_date,i.end_date,
                          p_forecast_id,p_activity_metric_id,
                          p_previous_fact_id, p_root_fact_id,
                          l_node_id );
        END LOOP;

    END IF;

    IF (OZF_DEBUG_HIGH_ON) THEN
        OZF_Utility_PVT.debug_message(l_full_name || ': End Create Dimention Facts');
    END IF;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      ROLLBACK TO Create_Dimention_Facts;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END create_dimention_facts;


PROCEDURE create_fcst_facts(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  --R12 Baseline
  p_base_quantity_type IN VARCHAR2,

  p_obj_type         IN VARCHAR2,
  p_obj_id           IN NUMBER,
  p_forecast_id      IN NUMBER,
  p_activity_metric_id IN NUMBER,

  p_level            IN VARCHAR2,
  p_dimention        IN VARCHAR2,
  p_fcst_uom         IN VARCHAR2,

  p_start_date       IN DATE,
  p_end_date         IN DATE,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2 )
IS

 l_api_version   CONSTANT NUMBER       := 1.0;
 l_api_name      CONSTANT VARCHAR2(30) := 'create_fcst_facts';
 l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 l_return_status VARCHAR2(1);
 l_msg_count  number(10);
 l_msg_data      varchar2(2000);

 CURSOR level_one_facts IS
   SELECT activity_metric_fact_id,
          fact_reference,
          fact_type
   FROM  ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND   act_metric_used_by_id = p_forecast_id
   AND previous_fact_id IS NULL
   AND root_fact_id IS NULL;

 CURSOR level_two_facts(p_previous_fact_id IN NUMBER) IS
   SELECT activity_metric_fact_id,
          fact_reference,
          fact_type
   FROM  ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND   act_metric_used_by_id = p_forecast_id
   AND   previous_fact_id = p_previous_fact_id
   AND   root_fact_id IS NULL;

 CURSOR get_product_qualfiers(p_forecast_dimention_id IN NUMBER) IS
   SELECT product_attribute_context,
          product_attribute,
          product_attr_value
   FROM ozf_forecast_dimentions
   WHERE forecast_dimention_id = p_forecast_dimention_id
   AND forecast_id = p_forecast_id;

 CURSOR get_market_qualifiers(p_forecast_dimention_id IN NUMBER) IS
   SELECT qualifier_grouping_no
   FROM   ozf_forecast_dimentions
   WHERE  forecast_dimention_id = p_forecast_dimention_id
   AND forecast_id = p_forecast_id;

 l_base_sales NUMBER := 0;

 l_product_attribute_context ozf_forecast_dimentions.product_attribute_context%TYPE;
 l_product_attribute ozf_forecast_dimentions.product_attribute%TYPE;
 l_product_attr_value ozf_forecast_dimentions.product_attr_value%TYPE;
 l_qualifier_grouping_no NUMBER;
 l_period_number NUMBER;

 l_previous_fact_id NUMBER ;
 l_root_fact_id NUMBER;

BEGIN

  IF (OZF_DEBUG_HIGH_ON) THEN
     OZF_Utility_PVT.debug_message(l_full_name || ': Start Create Fcst Facts');
  END IF;

  SAVEPOINT Create_Fcst_Facts;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  --dbms_output.put_line( ' -- 1. create_fcst_facts -- ');

  IF ( p_level = 'ONE' )
  THEN

     DELETE FROM ozf_act_metric_facts_all
     WHERE activity_metric_id = p_activity_metric_id ;
     --

     --R12 Baseline
     IF (p_base_quantity_type <> 'BASELINE')
     THEN
        UPDATE ozf_act_forecasts_all
        SET dimention2 = NULL,
            dimention3 = NULL
        WHERE forecast_id = p_forecast_id ;
     END IF;

    --
    --dbms_output.put_line( ' -- 1.1 create_fcst_facts -- ');
          create_dimention_facts ( p_api_version,
                                   p_init_msg_list,
                                   p_commit,
                                   p_base_quantity_type,
                                   p_obj_type,
                                   p_obj_id,
                                   p_forecast_id,
                                   p_activity_metric_id,
                                   p_dimention,
                                   p_fcst_uom,
                                   l_product_attribute_context,
                                   l_product_attribute,
                                   l_product_attr_value,
                                   l_qualifier_grouping_no,
                                   l_period_number,
                                   l_previous_fact_id,
                                   l_root_fact_id,
                                   x_return_status,
                                   x_msg_count,
                                   x_msg_data);

  END IF ;

  IF ( p_level = 'TWO' )
  THEN

     --
     -- Delete level two and three facts.

     DELETE FROM ozf_act_metric_facts_all
     WHERE activity_metric_id = p_activity_metric_id
     AND   previous_fact_id IS NOT NULL;

       FOR i IN level_one_facts
       LOOP

             l_previous_fact_id := i.activity_metric_fact_id ;

             IF (i.fact_type = 'PRODUCT')
             THEN

                 OPEN get_product_qualfiers(i.fact_reference);
                 FETCH get_product_qualfiers INTO l_product_attribute_context,
                                                  l_product_attribute,
                                                  l_product_attr_value ;
                 CLOSE get_product_qualfiers;

             ELSIF (i.fact_type = 'MARKET')
             THEN

                 OPEN get_market_qualifiers(i.fact_reference);
                 FETCH get_market_qualifiers INTO l_qualifier_grouping_no;
                 CLOSE get_market_qualifiers;

             ELSIF (i.fact_type = 'TIME')
             THEN
                  l_period_number := i.fact_reference;

             END IF;
             --dbms_output.put_line( ' -- 1.2 create_fcst_facts -- ');
             create_dimention_facts ( p_api_version,
                                      p_init_msg_list,
                                      p_commit,
                                      p_base_quantity_type,
                                      p_obj_type,
                                      p_obj_id,
                                      p_forecast_id,
                                      p_activity_metric_id,
                                      p_dimention,
                                      p_fcst_uom,
                                      l_product_attribute_context,
                                      l_product_attribute,
                                      l_product_attr_value,
                                      l_qualifier_grouping_no,
                                      l_period_number,
                                      l_previous_fact_id,
                                      l_root_fact_id,
                                      x_return_status,
                                      x_msg_count,
                                      x_msg_data);

       END LOOP; -- End Level One Records

  END IF;  -- End Level Two

  IF ( p_level = 'THREE' )
  THEN

       FOR i IN level_one_facts
       LOOP
             l_root_fact_id := i.activity_metric_fact_id ;

             IF (i.fact_type = 'PRODUCT')
             THEN

                 OPEN get_product_qualfiers(i.fact_reference)  ;
                 FETCH get_product_qualfiers INTO l_product_attribute_context,
                                                  l_product_attribute,
                                                  l_product_attr_value ;
                 CLOSE get_product_qualfiers;

             ELSIF (i.fact_type = 'MARKET')
             THEN

                 OPEN get_market_qualifiers(i.fact_reference);
                 FETCH get_market_qualifiers INTO l_qualifier_grouping_no;
                 CLOSE get_market_qualifiers;

             ELSIF (i.fact_type = 'TIME')
             THEN
                  l_period_number := i.fact_reference;

             END IF;

             FOR j IN level_two_facts(i.activity_metric_fact_id)
             LOOP

                  l_previous_fact_id := j.activity_metric_fact_id ;

                  IF (j.fact_type = 'PRODUCT')
                  THEN

                     OPEN get_product_qualfiers(j.fact_reference);
                     FETCH get_product_qualfiers INTO l_product_attribute_context,
                                                      l_product_attribute,
                                                      l_product_attr_value ;
                     CLOSE get_product_qualfiers;

                  ELSIF (j.fact_type = 'MARKET')
                  THEN

                     OPEN get_market_qualifiers(j.fact_reference);
                     FETCH get_market_qualifiers INTO l_qualifier_grouping_no;
                     CLOSE get_market_qualifiers;

                  ELSIF (j.fact_type = 'TIME')
                  THEN
                       l_period_number := j.fact_reference ;

                  END IF;
                  --dbms_output.put_line( ' -- 1.3 create_fcst_facts -- ');
                  create_dimention_facts ( p_api_version,
                                           p_init_msg_list,
                                           p_commit,
                                           p_base_quantity_type,
                                           p_obj_type,
                                           p_obj_id,
                                           p_forecast_id,
                                           p_activity_metric_id,
                                           p_dimention,
                                           p_fcst_uom,
                                           l_product_attribute_context,
                                           l_product_attribute,
                                           l_product_attr_value,
                                           l_qualifier_grouping_no,
                                           l_period_number,
                                           l_previous_fact_id,
                                           l_root_fact_id,
                                           x_return_status,
                                           x_msg_count,
                                           x_msg_data);
                  --dbms_output.put_line( ' -- soon after 1.3 -- x_return_status ==> '||x_return_status);

             END LOOP; -- End of Level Two Records(j)

       END LOOP; -- End Level One Records(i)

  END IF;  -- End Level Three

  IF (OZF_DEBUG_HIGH_ON) THEN

  OZF_Utility_PVT.debug_message(l_full_name || ': End Create Fcst Facts');

  END IF;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


END create_fcst_facts;

--***********************************************
--R12 Baseline - Dummy Method for testing
--***********************************************
FUNCTION get_best_fit_lift2 RETURN NUMBER IS BEGIN RETURN .01; END;

--***********************************************
--R12 Baseline
--***********************************************
FUNCTION get_best_fit_lift (
  p_obj_type                  IN VARCHAR2,
  p_obj_id                    IN NUMBER,
  p_forecast_id               IN NUMBER,
  p_base_quantity_ref         IN VARCHAR2,
  p_market_type               IN VARCHAR2,
  p_market_id                 IN NUMBER,
  p_product_attribute_context IN VARCHAR2,
  p_product_attribute         IN VARCHAR2,
  p_product_attr_value        IN VARCHAR2,
  p_product_id                IN NUMBER,
  p_tpr_percent               IN NUMBER,
  p_report_date               IN DATE
)
RETURN NUMBER
IS
 l_api_version   CONSTANT NUMBER       := 1.0;
 l_api_name      CONSTANT VARCHAR2(30) := 'get_best_fit_lift';
 l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_msg_count     number;
 l_msg_data      varchar2(2000);

 CURSOR c_fcst_rec (l_fcst_id IN NUMBER) IS
    SELECT
     PERIOD_LEVEL,
     BASE_QUANTITY_TYPE,
     BASE_QUANTITY_REF,
     FORECAST_SPREAD_TYPE,
     BASE_QUANTITY_START_DATE,
     BASE_QUANTITY_END_DATE,
     INCREMENT_QUOTA,
     FORECAST_UOM_CODE,
     LAST_SCENARIO_ID
    FROM OZF_ACT_FORECASTS_ALL
    WHERE FORECAST_ID = l_fcst_id;

 CURSOR c_wkst_fcst_rec IS
    SELECT
     a.PERIOD_LEVEL,
     a.BASE_QUANTITY_TYPE,
     a.BASE_QUANTITY_REF,
     a.FORECAST_SPREAD_TYPE,
         trunc(b.start_date_active) wkst_start_date_active,
         trunc(b.end_date_active)   wkst_end_date_active,
     a.INCREMENT_QUOTA,
         a.forecast_uom_code,
     a.LAST_SCENARIO_ID
       FROM ozf_act_forecasts_all a,
            ozf_worksheet_headers_b b
       WHERE a.FORECAST_ID = p_forecast_id
       AND   b.worksheet_header_id = NVL(p_obj_id, b.worksheet_header_id)
       AND   a.arc_act_fcast_used_by = NVL(p_obj_type, 'WKST')
       AND   a.act_fcast_used_by_id = b.worksheet_header_id
       AND   b.forecast_generated = DECODE(p_obj_id, NULL, 'N',b.forecast_generated);


 CURSOR c_offr_trade_medium_csr IS
    SELECT
      offperf.channel_id
    FROM
      ozf_offer_performances offperf
    WHERE
         offperf.list_header_id = p_obj_id
    AND  offperf.product_attribute_context =  p_product_attribute_context
    AND  DECODE(offperf.product_attr_value,'ALL','MATCH', offperf.product_attr_value) =
      DECODE(offperf.product_attr_value,'ALL','MATCH', p_product_attr_value)
    AND  DECODE(offperf.product_attribute,'PRICING_ATTRIBUTE3','MATCH', offperf.product_attribute) =
      DECODE(offperf.product_attribute,'PRICING_ATTRIBUTE3','MATCH', p_product_attribute)
    AND  p_report_date between NVL(offperf.start_date, p_report_date) and NVL (offperf.end_date, p_report_date);

 CURSOR c_wkst_trade_medium_csr IS
    SELECT
      offperf.channel_id
    FROM
      ozf_offer_performances offperf
    WHERE
            offperf.used_by = p_obj_type
        AND offperf.used_by = p_obj_id
    AND  offperf.product_attribute_context =  p_product_attribute_context
    AND  DECODE(offperf.product_attr_value,'ALL','MATCH', offperf.product_attr_value) =
      DECODE(offperf.product_attr_value,'ALL','MATCH', p_product_attr_value)
    AND  DECODE(offperf.product_attribute,'PRICING_ATTRIBUTE3','MATCH', offperf.product_attribute) =
      DECODE(offperf.product_attribute,'PRICING_ATTRIBUTE3','MATCH', p_product_attribute)
    AND  p_report_date between NVL(offperf.start_date, p_report_date) and NVL (offperf.end_date, p_report_date);


 CURSOR c_trade_medium_col_name_csr(l_trade_tactic_id NUMBER) IS
    SELECT
      TRADE_TACTIC_COLUMN_NAME
    FROM
      OZF_TRADE_TACTICS_MAPPING
    WHERE DATA_SOURCE = p_base_quantity_ref
    AND TRADE_TACTIC_ID = l_trade_tactic_id
    AND rownum = 1
    ORDER BY CREATION_DATE DESC;

  i                            NUMBER := 0;
  j                            NUMBER := 0;
  l_base_sales                 NUMBER := 0;
  l_product_attribute_context  ozf_forecast_dimentions.product_attribute_context%TYPE;
  l_product_attribute          ozf_forecast_dimentions.product_attribute%TYPE;
  l_product_attr_value         ozf_forecast_dimentions.product_attr_value%TYPE;
  l_qualifier_grouping_no      NUMBER;
  l_period_number              NUMBER;
  l_previous_fact_id           NUMBER ;
  l_root_fact_id               NUMBER;
  l_period_level               OZF_ACT_FORECASTS_ALL.period_level%TYPE;
  l_base_quantity_type         OZF_ACT_FORECASTS_ALL.base_quantity_type%TYPE;
  l_base_quantity_ref          OZF_ACT_FORECASTS_ALL.base_quantity_ref%TYPE;
  l_forecast_spread_type       OZF_ACT_FORECASTS_ALL.forecast_spread_type%TYPE;
  l_base_quantity_start_date   OZF_ACT_FORECASTS_ALL.base_quantity_start_date%TYPE;
  l_base_quantity_end_date     OZF_ACT_FORECASTS_ALL.base_quantity_end_date%TYPE;
  l_increment_quota            OZF_ACT_FORECASTS_ALL.increment_quota%TYPE;
  l_forecast_uom_code          OZF_ACT_FORECASTS_ALL.forecast_uom_code%TYPE;
  l_last_scenario_id           OZF_ACT_FORECASTS_ALL.last_scenario_id%TYPE;
  l_trade_tactic_id1           NUMBER;
  l_trade_tactic_id2           NUMBER;
  l_trade_tactic_id3           NUMBER;
  l_trade_tactic_id4           NUMBER;
  l_trade_tactic_id5           NUMBER;
  l_trade_tactic_id6           NUMBER;
  l_trade_tactic_id7           NUMBER;
  l_trade_tactic_id8           NUMBER;
  l_trade_tactic_id9           NUMBER;
  l_trade_tactic_id10          NUMBER;
  l_trade_tactic_name1         VARCHAR2(30);
  l_trade_tactic_name2         VARCHAR2(30);
  l_trade_tactic_name3         VARCHAR2(30);
  l_trade_tactic_name4         VARCHAR2(30);
  l_trade_tactic_name5         VARCHAR2(30);
  l_trade_tactic_name6         VARCHAR2(30);
  l_trade_tactic_name7         VARCHAR2(30);
  l_trade_tactic_name8         VARCHAR2(30);
  l_trade_tactic_name9         VARCHAR2(30);
  l_trade_tactic_name10        VARCHAR2(30);
  l_lift_factor                NUMBER;
  l_final_lift_sql   VARCHAR2(30000);
  l_lift_factor_sql  VARCHAR2(30000) :=
  ' SELECT MIN(LIFT.LIFT_FACTOR) ' ||
  ' FROM OZF_LIFT_FACTORS_FACTS LIFT, AMS_PARTY_MARKET_SEGMENTS DENORM ' ||
  ' WHERE LIFT.DATA_SOURCE = :L_BASE_QUANTITY_REF '||
  ' AND LIFT.MARKET_TYPE = DENORM.MARKET_QUALIFIER_TYPE '||
  ' AND LIFT.MARKET_ID = DENORM.MARKET_QUALIFIER_REFERENCE '||
  ' AND DENORM.SITE_USE_CODE = :L_MARKET_TYPE '||
  ' AND DENORM.SITE_USE_ID = :L_MARKET_ID '||
  ' AND LIFT.ITEM_LEVEL = ''PRICING_ATTRIBUTE1'' ' ||
  ' AND LIFT.ITEM_ID = :L_PRODUCT_ID '||
  ' AND LIFT.TPR_PERCENT <= :L_TPR_PERCENT '||
  ' AND :L_REPORT_DATE BETWEEN LIFT.TRANSACTION_FROM_DATE AND LIFT.TRANSACTION_TO_DATE ';

  l_where_str  VARCHAR2(10000) := NULL;
  TYPE G_GenericCurType IS REF CURSOR;
  get_lift_factor_csr  G_GenericCurType;  --cursor variable (processed like a PL/SQL variable)


  CURSOR get_offer_type
  IS
   SELECT offer_type
   FROM ozf_offers
   WHERE qp_list_header_id = p_obj_id;

  CURSOR get_promotion_type(l_product_attribute_context IN VARCHAR2,
                            l_product_attribute IN VARCHAR2,
                            l_product_attr_value IN VARCHAR2 )
  IS
   SELECT DECODE(qpl.list_line_type_code
                 ,'DIS', DECODE(qpl.operand
                                ,100 , DECODE(qpl.arithmetic_operator
                                              ,'%', 3
                                                  , 2 )
                                     , 2)
                       , 1) promotion_type
   FROM   qp_list_lines qpl,
          qp_pricing_attributes qp
   WHERE qpl.list_header_id = p_obj_id
   AND qpl.list_line_id = qp.list_line_id
   AND qp.excluder_flag = 'N'
   AND qp.product_attribute_context = l_product_attribute_context
   AND qp.product_attribute = l_product_attribute
   AND qp.product_attr_value = l_product_attr_value
   ORDER BY promotion_type;


BEGIN

  --IF (OZF_DEBUG_HIGH_ON) THEN
  --   OZF_Utility_PVT.debug_message(l_full_name || ': Start get_best_fit_lift ');
  --END IF;

  -- First: Get Offer or Wkst Forecast Header Level Details from the forecast id
  IF p_obj_type = 'OFFR'
  THEN
  -- for OFFR
        OPEN c_fcst_rec(p_forecast_id);
        FETCH c_fcst_rec INTO
             l_period_level,
             l_base_quantity_type,
             l_base_quantity_ref,
             l_forecast_spread_type,
             l_base_quantity_start_date,
             l_base_quantity_end_date,
             l_increment_quota,
             l_forecast_uom_code,
             l_last_scenario_id;
        CLOSE c_fcst_rec;

  ELSIF p_obj_type = 'WKST'
  THEN
  -- for WKST
       OPEN c_fcst_rec(p_forecast_id);
       FETCH c_fcst_rec INTO
             l_period_level,
             l_base_quantity_type,
             l_base_quantity_ref,
             l_forecast_spread_type,
             l_base_quantity_start_date,
             l_base_quantity_end_date,
             l_increment_quota,
             l_forecast_uom_code,
             l_last_scenario_id;
       CLOSE c_fcst_rec;

  END IF;

   -- for the given offer and prod_attr , find all offer performances in 10 variables
   -- find column_names from the mapping table
   -- form the query to find lift factor
   -- return lift factor

   IF p_obj_type = 'OFFR' THEN

       i := 1;
       FOR channel_rec IN c_offr_trade_medium_csr
       LOOP
          CASE i
        WHEN 1 THEN l_trade_tactic_id1 := channel_rec.channel_id;
        WHEN 2 THEN l_trade_tactic_id2 := channel_rec.channel_id;
        WHEN 3 THEN l_trade_tactic_id3 := channel_rec.channel_id;
        WHEN 4 THEN l_trade_tactic_id4 := channel_rec.channel_id;
        WHEN 5 THEN l_trade_tactic_id5 := channel_rec.channel_id;
        WHEN 6 THEN l_trade_tactic_id6 := channel_rec.channel_id;
        WHEN 7 THEN l_trade_tactic_id7 := channel_rec.channel_id;
        WHEN 8 THEN l_trade_tactic_id8 := channel_rec.channel_id;
        WHEN 9 THEN l_trade_tactic_id9 := channel_rec.channel_id;
        WHEN 10 THEN l_trade_tactic_id10 := channel_rec.channel_id;
          END CASE;
          i := i + 1;
          EXIT WHEN i = 11;
       END LOOP;

   ELSIF p_obj_type = 'WKST' THEN

       i := 1;
       FOR channel_rec IN c_wkst_trade_medium_csr
       LOOP
          CASE i
        WHEN 1 THEN l_trade_tactic_id1 := channel_rec.channel_id;
        WHEN 2 THEN l_trade_tactic_id2 := channel_rec.channel_id;
        WHEN 3 THEN l_trade_tactic_id3 := channel_rec.channel_id;
        WHEN 4 THEN l_trade_tactic_id4 := channel_rec.channel_id;
        WHEN 5 THEN l_trade_tactic_id5 := channel_rec.channel_id;
        WHEN 6 THEN l_trade_tactic_id6 := channel_rec.channel_id;
        WHEN 7 THEN l_trade_tactic_id7 := channel_rec.channel_id;
        WHEN 8 THEN l_trade_tactic_id8 := channel_rec.channel_id;
        WHEN 9 THEN l_trade_tactic_id9 := channel_rec.channel_id;
        WHEN 10 THEN l_trade_tactic_id10 := channel_rec.channel_id;
          END CASE;
          i := i + 1;
          EXIT WHEN i = 11;
       END LOOP;
   END IF;

   FOR j IN 1..(i-1)
   LOOP
      CASE j
        WHEN 1 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id1);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name1;
          CLOSE c_trade_medium_col_name_csr;
        WHEN 2 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id2);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name2;
          CLOSE c_trade_medium_col_name_csr;
        WHEN 3 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id3);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name3;
          CLOSE c_trade_medium_col_name_csr;
        WHEN 4 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id4);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name4;
          CLOSE c_trade_medium_col_name_csr;
        WHEN 5 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id5);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name5;
          CLOSE c_trade_medium_col_name_csr;
        WHEN 6 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id6);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name6;
          CLOSE c_trade_medium_col_name_csr;
        WHEN 7 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id7);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name7;
          CLOSE c_trade_medium_col_name_csr;
        WHEN 8 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id8);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name8;
          CLOSE c_trade_medium_col_name_csr;
        WHEN 9 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id9);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name9;
          CLOSE c_trade_medium_col_name_csr;
        WHEN 10 THEN
          OPEN c_trade_medium_col_name_csr(l_trade_tactic_id10);
          FETCH c_trade_medium_col_name_csr into l_trade_tactic_name10;
          CLOSE c_trade_medium_col_name_csr;
      END CASE;
   END LOOP;

/*
Find Best-Fit Tactics:
~~~~~~~~~~~~~~~~~~~~~~
Reduce the data set to those where a Trade Medium matches a tactic in Tactic Category #1.
(If Lifts have "Display", "End-Aisle", & "Secondary Location" tactics in Category #1.
Offer has "Display" as Trade Medium so return these lift records in data set).
Repeat process of matching Trade mediums to Tactic Category #2-10 until a match is not found.
This is the Best-Fit lift.
*/

   IF l_trade_tactic_name1 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name1 || ' = ' || l_trade_tactic_id1;
   END IF;

   IF l_trade_tactic_name2 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name2 || ' = ' || l_trade_tactic_id2;
   END IF;

   IF l_trade_tactic_name3 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name3 || ' = ' || l_trade_tactic_id3;
   END IF;

   IF l_trade_tactic_name4 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name4 || ' = ' || l_trade_tactic_id4;
   END IF;

   IF l_trade_tactic_name5 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name5 || ' = ' || l_trade_tactic_id5;
   END IF;

   IF l_trade_tactic_name6 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name6 || ' = ' || l_trade_tactic_id6;
   END IF;

   IF l_trade_tactic_name7 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name7 || ' = ' || l_trade_tactic_id7;
   END IF;

   IF l_trade_tactic_name8 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name8 || ' = ' || l_trade_tactic_id8;
   END IF;

   IF l_trade_tactic_name9 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name9 || ' = ' || l_trade_tactic_id9;
   END IF;

   IF l_trade_tactic_name10 IS NOT NULL THEN
      l_where_str := l_where_str || ' AND '|| l_trade_tactic_name10 || ' = ' || l_trade_tactic_id10;
   END IF;


   -- Also consider Offer Type and Activity Id When needed ---------
   -- Check for WKST
   -- CHECK query by printing it and execute from TOAD
   -- See how to get discount percent in process_baseline ....

   IF l_where_str IS NOT NULL THEN
      l_final_lift_sql := l_lift_factor_sql || l_where_str;
      --OZF_Utility_PVT.debug_message( ' ~~l_where_str~~=> '|| l_where_str );
   ELSE
      l_final_lift_sql := l_lift_factor_sql;
   END IF;
   --OZF_Utility_PVT.debug_message( ' ~~~l_final_lift_sql~~~~ => '||l_final_lift_sql  );

   OPEN get_lift_factor_csr FOR l_final_lift_sql USING
                                p_base_quantity_ref,
                                p_market_type,
                                p_market_id,
                                p_product_id,
                                p_tpr_percent,
                                p_report_date
                                ;
   FETCH get_lift_factor_csr INTO l_lift_factor;
   CLOSE get_lift_factor_csr ;
   --OZF_Utility_PVT.debug_message( ' ~~~ l_lift_factor  ~~~~ =====> '|| to_char(l_lift_factor)  );


    IF l_lift_factor IS NULL THEN

           --OZF_Utility_PVT.debug_message( ' ~~~ l_lift_factor  IS NULL ~~~~  ');

       l_where_str := NULL;
           l_final_lift_sql := NULL;

       IF l_trade_tactic_name1 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name1 || ' = ' || l_trade_tactic_id1;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name1 || ' IS NULL ) ';
       END IF;

       IF l_trade_tactic_name2 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name2 || ' = ' || l_trade_tactic_id2;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name2 || ' IS NULL ) ';
       END IF;

       IF l_trade_tactic_name3 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name3 || ' = ' || l_trade_tactic_id3;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name3 || ' IS NULL ) ';
       END IF;

       IF l_trade_tactic_name4 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name4 || ' = ' || l_trade_tactic_id4;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name4 || ' IS NULL ) ';
       END IF;

       IF l_trade_tactic_name5 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name5 || ' = ' || l_trade_tactic_id5;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name5 || ' IS NULL ) ';
       END IF;

       IF l_trade_tactic_name6 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name6 || ' = ' || l_trade_tactic_id6;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name6 || ' IS NULL ) ';
       END IF;

       IF l_trade_tactic_name7 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name7 || ' = ' || l_trade_tactic_id7;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name7 || ' IS NULL ) ';
       END IF;

       IF l_trade_tactic_name8 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name8 || ' = ' || l_trade_tactic_id8;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name8 || ' IS NULL ) ';
       END IF;

       IF l_trade_tactic_name9 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name9 || ' = ' || l_trade_tactic_id9;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name9 || ' IS NULL ) ';
       END IF;

       IF l_trade_tactic_name10 IS NOT NULL THEN
          l_where_str := l_where_str || ' AND ('|| l_trade_tactic_name10 || ' = ' || l_trade_tactic_id10;
          l_where_str := l_where_str || ' OR '  || l_trade_tactic_name10 || ' IS NULL ) ';
       END IF;

       IF l_where_str IS NOT NULL THEN
          l_final_lift_sql := l_lift_factor_sql || l_where_str;
              --OZF_Utility_PVT.debug_message( ' ~222~l_where_str~~=> '|| l_where_str );
           ELSE
             l_final_lift_sql := l_lift_factor_sql;
       END IF;

       OPEN get_lift_factor_csr FOR l_final_lift_sql USING
                    p_base_quantity_ref,
                    p_market_type,
                    p_market_id,
                    p_product_id,
                    p_tpr_percent,
                    p_report_date
                    ;
       FETCH get_lift_factor_csr INTO l_lift_factor;
       CLOSE get_lift_factor_csr ;

       --OZF_Utility_PVT.debug_message( ' 2222~~~ l_lift_factor  ~~~~ =====> '||l_lift_factor  );

    END IF; --  IF l_lift_factor IS NULL THEN

/*
    IF l_lift_factor IS NULL THEN
     -- CONSTANT LIFT FACTORS
       IF (p_tpr_percent > 20) THEN l_lift_factor := 20/100;
       ELSIF (p_tpr_percent > 10) THEN l_lift_factor := 10/100;
       ELSE l_lift_factor := 5/100;
       END IF;
    END IF;
*/

--  IF (OZF_DEBUG_HIGH_ON) THEN
--     OZF_Utility_PVT.debug_message(l_full_name || ': End get_best_fit_lift ');
--  END IF;

    RETURN NVL(l_lift_factor, 0);

EXCEPTION
    WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      --OZF_Utility_PVT.debug_message(' get_best_fit_lift : OTHER ERROR ' || sqlerrm );
      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      Return 0; -- i.e. lift is ZERO
END get_best_fit_lift; --end of function


--***********************************************
--R12 Baseline
-- When TPR percent is changed on the UI, then
-- this method will calculate new incremental sales for
-- each of the levels -> PRODUCT, MARKET AND TIME
/*IF there is a change in TPRpercent for a given Product,P1
THEN
   Call this private method -->
      adjust_baseline_spreads(level, fact_id, oldTPRdiscount, newTPRdiscount)
      This method will do these (handled by my code):
           Generate new 3rd Level Spread
           Generate new 2nd Level spread
           Generate new numbers for P1's row (Incremental and RTF only.
           (Note that P1TotalForecast is always sum of P1BaseSales and P1Incremental)

   Then your code should handle
        Updation of HeaderTotalForecast.
        Updation of the HeaderRTF.
*/
--***********************************************
PROCEDURE adjust_baseline_spreads
(
  p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2  := FND_API.g_false,
  p_commit                    IN VARCHAR2  := FND_API.g_false,
  p_obj_type                  IN VARCHAR2,
  p_obj_id                    IN NUMBER,
  p_forecast_id               IN NUMBER,
  p_activity_metric_fact_id   IN NUMBER,
  p_new_tpr_percent           IN NUMBER,
  p_new_incremental_sales     OUT NOCOPY NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2
)
IS
 l_api_version   CONSTANT NUMBER       := 1.0;
 l_api_name      CONSTANT VARCHAR2(30) := 'adjust_baseline_spreads';
 l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_return_status VARCHAR2(1);
 l_msg_count     number;
 l_msg_data      varchar2(2000);

 CURSOR c_fcst_rec (l_fcst_id IN NUMBER) IS
    SELECT
     PERIOD_LEVEL,
     BASE_QUANTITY_TYPE,
     BASE_QUANTITY_REF,
     FORECAST_SPREAD_TYPE,
     DIMENTION1,
     DIMENTION2,
     DIMENTION3,
     BASE_QUANTITY_START_DATE,
     BASE_QUANTITY_END_DATE,
     INCREMENT_QUOTA,
     FORECAST_UOM_CODE,
     LAST_SCENARIO_ID
    FROM OZF_ACT_FORECASTS_ALL
    WHERE FORECAST_ID = l_fcst_id;

 CURSOR c_wkst_fcst_rec IS
    SELECT
     a.PERIOD_LEVEL,
     a.BASE_QUANTITY_TYPE,
     a.BASE_QUANTITY_REF,
     a.FORECAST_SPREAD_TYPE,
     a.DIMENTION1,
     a.DIMENTION2,
     a.DIMENTION3,
         trunc(b.start_date_active) wkst_start_date_active,
         trunc(b.end_date_active)   wkst_end_date_active,
     a.INCREMENT_QUOTA,
         a.forecast_uom_code,
     a.LAST_SCENARIO_ID
       FROM ozf_act_forecasts_all a,
            ozf_worksheet_headers_b b
       WHERE a.FORECAST_ID = p_forecast_id
       AND   b.worksheet_header_id = NVL(p_obj_id, b.worksheet_header_id)
       AND   a.arc_act_fcast_used_by = NVL(p_obj_type, 'WKST')
       AND   a.act_fcast_used_by_id = b.worksheet_header_id
       AND   b.forecast_generated = DECODE(p_obj_id, NULL, 'N',b.forecast_generated);

 CURSOR level_one_facts IS
   SELECT activity_metric_fact_id,
          fact_reference,
          fact_type,
          incremental_sales
   FROM  ozf_act_metric_facts_all
   WHERE activity_metric_fact_id = p_activity_metric_fact_id;

 CURSOR level_two_facts IS
   SELECT activity_metric_fact_id,
          fact_reference,
          fact_type
   FROM  ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND   act_metric_used_by_id = p_forecast_id
   AND   previous_fact_id = p_activity_metric_fact_id
   AND   root_fact_id IS NULL;

 CURSOR level_three_facts(p_previous_fact_id IN NUMBER) IS
   SELECT activity_metric_fact_id,
          fact_reference,
          fact_type
   FROM  ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND   act_metric_used_by_id = p_forecast_id
   AND   previous_fact_id = p_previous_fact_id
   AND   root_fact_id = p_activity_metric_fact_id;

 CURSOR get_product_qualfiers(p_forecast_dimention_id IN NUMBER) IS
   SELECT product_attribute_context,
          product_attribute,
          product_attr_value
   FROM ozf_forecast_dimentions
   WHERE forecast_dimention_id = p_forecast_dimention_id
   AND forecast_id = p_forecast_id;

 CURSOR get_market_qualifiers(p_forecast_dimention_id IN NUMBER) IS
   SELECT qualifier_grouping_no
   FROM   ozf_forecast_dimentions
   WHERE  forecast_dimention_id = p_forecast_dimention_id
   AND forecast_id = p_forecast_id;

 CURSOR get_products(l_qualifier_grouping_no IN NUMBER)  IS
 SELECT min(forecast_dimention_id) forecast_dimention_id,
        product_attribute_context,
        product_attribute,
        product_attr_value
 FROM ozf_forecast_dimentions
 WHERE obj_type = p_obj_type
 AND obj_id = p_obj_id
 AND forecast_id = p_forecast_id
 AND qualifier_grouping_no = NVL(l_qualifier_grouping_no, qualifier_grouping_no)
 GROUP BY
    product_attribute_context,
    product_attribute,
    product_attr_value ;

 CURSOR get_markets (l_product_attribute_context IN VARCHAR2,
                     l_product_attribute IN VARCHAR2,
                     l_product_attr_value IN VARCHAR2 )
 IS
   SELECT min(forecast_dimention_id) forecast_dimention_id,
          min(qualifier_grouping_no) qualifier_grouping_no
   FROM   ozf_forecast_dimentions
   WHERE  obj_type = p_obj_type
   AND    obj_id   = p_obj_id
   AND forecast_id = p_forecast_id
   AND product_attribute_context = NVL(l_product_attribute_context, product_attribute_context)
   AND product_attribute = NVL(l_product_attribute, product_attribute)
   AND product_attr_value = NVL(l_product_attr_value, product_attr_value)
   GROUP BY
         qualifier_context,
         qualifier_attribute,
         qualifier_attr_value,
         qualifier_grouping_no ;

 CURSOR periods_csr IS
    SELECT period_number,
           start_date,
           end_date,
           period_type_id
    FROM ozf_forecast_periods
    WHERE obj_type = p_obj_type
    AND   obj_id   = p_obj_id;

 CURSOR get_sales_period IS
   SELECT period_number
   FROM ozf_forecast_periods
   WHERE obj_type = p_obj_type -- 'OFFR'
   AND   obj_id   = p_obj_id
   AND (forecast_id IS NULL -- inanaiah: For compatibility with older release
    OR forecast_id = p_forecast_id); -- inanaiah: making periods bound to forecast_id as is the case when creating new version ;

 l_orig_incremental_sales     NUMBER := 0;
 l_new_incremental_sales      NUMBER := 0;
 l_activity_metric_id         NUMBER := 0;
 l_base_sales                 NUMBER := 0;
 l_product_attribute_context  ozf_forecast_dimentions.product_attribute_context%TYPE;
 l_product_attribute          ozf_forecast_dimentions.product_attribute%TYPE;
 l_product_attr_value         ozf_forecast_dimentions.product_attr_value%TYPE;
 l_qualifier_grouping_no      NUMBER;
 l_period_number              NUMBER;
 l_previous_fact_id           NUMBER ;
 l_root_fact_id               NUMBER;
 l_period_level               OZF_ACT_FORECASTS_ALL.period_level%TYPE;
 l_base_quantity_type         OZF_ACT_FORECASTS_ALL.base_quantity_type%TYPE;
 l_base_quantity_ref          OZF_ACT_FORECASTS_ALL.base_quantity_ref%TYPE;
 l_forecast_spread_type       OZF_ACT_FORECASTS_ALL.forecast_spread_type%TYPE;
 l_dimention1                 OZF_ACT_FORECASTS_ALL.dimention1%TYPE;
 l_dimention2                 OZF_ACT_FORECASTS_ALL.dimention2%TYPE;
 l_dimention3                 OZF_ACT_FORECASTS_ALL.dimention3%TYPE;
 l_base_quantity_start_date   OZF_ACT_FORECASTS_ALL.base_quantity_start_date%TYPE;
 l_base_quantity_end_date     OZF_ACT_FORECASTS_ALL.base_quantity_end_date%TYPE;
 l_increment_quota            OZF_ACT_FORECASTS_ALL.increment_quota%TYPE;
 l_forecast_uom_code          OZF_ACT_FORECASTS_ALL.forecast_uom_code%TYPE;
 l_last_scenario_id           OZF_ACT_FORECASTS_ALL.last_scenario_id%TYPE;
 l_tpr_percent                NUMBER;
 l_baseline_sales             NUMBER;
 l_incremental_sales          NUMBER;
 l_node_id NUMBER;
 l_offer_type VARCHAR2(30) := 'OFFR';

BEGIN


  IF (OZF_DEBUG_HIGH_ON) THEN
     OZF_Utility_PVT.debug_message(l_full_name || ': Start adjusting baseline product, market and time spreads');
  END IF;

  --
  -- Initialize savepoint.
  --
  SAVEPOINT adjust_baseline_spreads;

  IF FND_API.to_boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;


  -- First: Get Offer or Wkst Forecast Header Level Details from the forecast id
  IF p_obj_type = 'OFFR'
  THEN
  -- for OFFR
        OPEN c_fcst_rec(p_forecast_id);
        FETCH c_fcst_rec INTO
             l_period_level,
             l_base_quantity_type,
             l_base_quantity_ref,
             l_forecast_spread_type,
             l_dimention1,
             l_dimention2,
             l_dimention3,
             l_base_quantity_start_date,
             l_base_quantity_end_date,
             l_increment_quota,
             l_forecast_uom_code,
             l_last_scenario_id;
        CLOSE c_fcst_rec;

  ELSIF p_obj_type = 'WKST'
  THEN
  -- for WKST
       OPEN c_fcst_rec(p_forecast_id);
       FETCH c_fcst_rec INTO
             l_period_level,
             l_base_quantity_type,
             l_base_quantity_ref,
             l_forecast_spread_type,
             l_dimention1,
             l_dimention2,
             l_dimention3,
             l_base_quantity_start_date,
             l_base_quantity_end_date,
             l_increment_quota,
             l_forecast_uom_code,
             l_last_scenario_id;
       CLOSE c_fcst_rec;

  END IF;


       FOR i IN level_one_facts
       LOOP
        --dbms_output.put_line( ' ~~~~~~~~~~~~~~~~~~~~~~~~  Inside i Loop ~~~~~~~~~~~~~~~~~~~ ' );
        --dbms_output.put_line( ' i Loop ~~:  i.activity_metric_fact_id == '|| i.activity_metric_fact_id);

         l_root_fact_id := i.activity_metric_fact_id ;
             l_orig_incremental_sales := i.incremental_sales;

             OPEN get_product_qualfiers(i.fact_reference)  ;
             FETCH get_product_qualfiers INTO l_product_attribute_context,
                                              l_product_attribute,
                                              l_product_attr_value ;
             CLOSE get_product_qualfiers;

         l_tpr_percent := p_new_tpr_percent;

             FOR j IN level_two_facts
             LOOP

         --dbms_output.put_line( ' ~~~~~~~~~~~~~~~~~~~~~~~~  Inside j Loop ~~~~~~~~~~~~~~~~~~~ ' );
         --dbms_output.put_line( ' ~ j Loop ~~:  j.activity_metric_fact_id == '|| j.activity_metric_fact_id);

          l_previous_fact_id := j.activity_metric_fact_id ;

          IF (j.fact_type = 'MARKET')
                  THEN

                     OPEN get_market_qualifiers(j.fact_reference);
                     FETCH get_market_qualifiers INTO l_qualifier_grouping_no;
                     CLOSE get_market_qualifiers;

                  ELSIF (j.fact_type = 'TIME')
                  THEN

               l_period_number := j.fact_reference ;

                  END IF;


             FOR k IN level_three_facts(j.activity_metric_fact_id)
             LOOP

              IF (k.fact_type = 'MARKET')
              THEN

                 OPEN get_market_qualifiers(k.fact_reference);
                 FETCH get_market_qualifiers INTO l_qualifier_grouping_no;
                 CLOSE get_market_qualifiers;

              ELSIF (k.fact_type = 'TIME')
              THEN
                   l_period_number := k.fact_reference ;

              END IF;


                          -- Now, all three dimensions are available: P, T, M
              BEGIN

                  UPDATE ozf_act_metric_facts_all outer
                  SET
                    outer.incremental_sales =
                    (
                    select
                    ROUND(NVL (SUM(sales.baseline_sales * NVL(OZF_FORECAST_UTIL_PVT.get_best_fit_lift
                                          (
                                           p_obj_type,
                                           p_obj_id,
                                           p_forecast_id,
                                           l_base_quantity_ref,
                                           sales.market_type,
                                           sales.market_id,
                                           dim.product_attribute_context,
                                           dim.product_attribute,
                                           dim.product_attr_value,
                                           sales.item_id,
                                           l_tpr_percent,
                                           rpt.report_date
                                          ), 0)
                                                  ) ,0) ) incremental_sales
                    from OZF_BASEline_sales_v sales,
                         ozf_time_day rpt,
                         (select  cust.qualifier_grouping_no,
                              cust.cust_account_id,
                              cust.site_use_code site_use_code,
                              cust.site_use_id site_use_id,
                              prod.product_attribute_context,
                              prod.product_attribute,
                              prod.product_attr_value,
                              prod.product_id inventory_item_id
                           from ozf_forecast_customers cust,
                            ozf_forecast_products prod
                           where prod.obj_type = p_obj_type
                           and prod.obj_id = p_obj_id
                           and prod.obj_type = cust.obj_type
                           and prod.obj_id =  cust.obj_id
                           and cust.site_use_code = 'SHIP_TO'
                          ) cust_prod,
                          ozf_forecast_dimentions dim,
                          ozf_forecast_periods period
                    where dim.obj_type =  p_obj_type
                    and   dim.obj_id   =  p_obj_id
                    AND   dim.forecast_id = p_forecast_id
                    and   dim.product_attribute_context = cust_prod.product_attribute_context
                    and   dim.product_attribute  = cust_prod.product_attribute
                    and   dim.product_attr_value = cust_prod.product_attr_value
                    and   dim.qualifier_grouping_no = cust_prod.qualifier_grouping_no
                    and   cust_prod.site_use_code = sales.market_type
                    and   cust_prod.site_use_id = sales.market_id
                    and   sales.item_level = 'PRICING_ATTRIBUTE1'
                    and   sales.item_id = cust_prod.inventory_item_id
                    and   period.obj_type = 'DISP'
                    and   period.obj_id   = p_obj_id
                    and   period.forecast_id = p_forecast_id
                    and   rpt.report_date between period.start_date and period.end_date
                    and   rpt.report_date_julian = sales.time_id
                    and   sales.period_type_id = 1
                    and   dim.product_attribute_context = l_product_attribute_context
                    and   dim.product_attribute = l_product_attribute
                    and   dim.product_attr_value = l_product_attr_value
                    and   dim.qualifier_grouping_no = l_qualifier_grouping_no
                    and   period.forecast_period_id = l_period_number
                    ),
                    outer.forecast_remaining_quantity = 0
                  WHERE outer.activity_metric_fact_id = k.activity_metric_fact_id
                AND outer.arc_act_metric_used_by = 'FCST'
                AND outer.act_metric_used_by_id = p_forecast_id;

              EXCEPTION
                 WHEN OTHERS THEN
                 NULL;
                 --dbms_output.put_line( ' ~~~~ ERROR in Update Baseline Sales for new TPR Percent -- ');
              END;

             END LOOP; -- End of Level Three Records(k)

         END LOOP; -- End of Level Two Records(j)

       END LOOP; -- End Level One Records(i)

 --- At this point, all numbers will be there at the most granular i.e. at level3

 --- NOW, ROLLUP all numbers FOR LEVEL 2
      UPDATE ozf_act_metric_facts_all outer
      SET (outer.baseline_sales, outer.incremental_sales) =
                          ( SELECT NVL(SUM(inner.baseline_sales),0),NVL(SUM(inner.incremental_sales),0)
                            FROM   ozf_act_metric_facts_all inner
                            WHERE  inner.previous_fact_id = outer.activity_metric_fact_id
                            AND   inner.arc_act_metric_used_by = 'FCST'
                            AND   inner.act_metric_used_by_id = p_forecast_id
                            AND   inner.fact_type = l_dimention3),
           outer.forecast_remaining_quantity = 0
      WHERE
            outer.arc_act_metric_used_by = 'FCST'
      AND   outer.act_metric_used_by_id = p_forecast_id
      AND   outer.fact_type = l_dimention2
      AND   outer.previous_fact_id = p_activity_metric_fact_id;


  IF p_obj_type = 'OFFR'
  THEN
      --- NOW, ROLLUP all numbers FOR LEVEL 1 (this is always 'PRODUCT') -- only for OFFR, not for WKST
      UPDATE ozf_act_metric_facts_all outer
      SET (outer.baseline_sales, outer.incremental_sales) =
                          ( SELECT NVL(SUM(inner.baseline_sales),0),NVL(SUM(inner.incremental_sales),0)
                            FROM   ozf_act_metric_facts_all inner
                            WHERE  inner.previous_fact_id = outer.activity_metric_fact_id
                            AND   inner.arc_act_metric_used_by = 'FCST'
                            AND   inner.act_metric_used_by_id = p_forecast_id
                            AND   inner.fact_type = l_dimention2),
      outer.tpr_percent = l_tpr_percent,
      outer.forecast_remaining_quantity = 0
      WHERE
            outer.arc_act_metric_used_by = 'FCST'
      AND   outer.act_metric_used_by_id = p_forecast_id
      AND   outer.fact_type = l_dimention1
      AND   outer.activity_metric_fact_id = p_activity_metric_fact_id;

      ---- NOW, ROLLUP all numbers FOR FORECAST Header LEVEL
      SELECT NVL(inner.incremental_sales,0) INTO l_new_incremental_sales
      FROM   ozf_act_metric_facts_all inner
      WHERE inner.arc_act_metric_used_by = 'FCST'
      AND   inner.act_metric_used_by_id = p_forecast_id
      AND   inner.activity_metric_fact_id = p_activity_metric_fact_id;

      UPDATE ozf_act_forecasts_all outer
      SET outer.forecast_quantity = outer.forecast_quantity + (l_new_incremental_sales - l_orig_incremental_sales)
      WHERE outer.forecast_id = p_forecast_id;

 ELSIF p_obj_type = 'WKST'
 THEN

    SELECT NVL(SUM(inner.incremental_sales), 0) INTO l_new_incremental_sales
    FROM   ozf_act_metric_facts_all inner
    WHERE  inner.previous_fact_id = p_activity_metric_fact_id
    AND   inner.arc_act_metric_used_by = 'FCST'
    AND   inner.act_metric_used_by_id = p_forecast_id
    AND   inner.fact_type = l_dimention2;

  END IF;

  -- return new incr sales
  p_new_incremental_sales := l_new_incremental_sales;

  IF (OZF_DEBUG_HIGH_ON) THEN
     OZF_Utility_PVT.debug_message(l_full_name || ': End adjusting baseline product, market and time spreads');
  END IF;

EXCEPTION

    WHEN OTHERS THEN

      ROLLBACK TO adjust_baseline_spreads;

      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END adjust_baseline_spreads; --end of procedure

--- Forward Declaration of the procedure
PROCEDURE get_discount_percent (
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,
                    p_obj_type           IN VARCHAR2,
                    p_obj_id             IN NUMBER,
                    p_forecast_id        IN NUMBER,
                    p_product_attribute  IN VARCHAR2,
                    p_product_attr_value IN VARCHAR2,
                    p_currency_code      IN VARCHAR2,
                    x_tpr_percent        OUT NOCOPY NUMBER,
                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2 );

--***********************************************
--R12 Baseline
--***********************************************
PROCEDURE process_baseline_forecast(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,
  p_obj_type         IN VARCHAR2,
  p_obj_id           IN NUMBER,
  p_forecast_id      IN NUMBER,
  p_period_level     IN NUMBER,
  p_activity_metric_id IN NUMBER,
  p_fcst_uom         IN VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2 )
IS

 l_api_version   CONSTANT NUMBER       := 1.0;
 l_api_name      CONSTANT VARCHAR2(30) := 'process_baseline_forecast';
 l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_return_status VARCHAR2(1);
 l_msg_count     number(10);
 l_msg_data      varchar2(2000);

 CURSOR c_fcst_rec IS
    SELECT
     a.PERIOD_LEVEL,
     a.BASE_QUANTITY_TYPE,
     a.BASE_QUANTITY_REF,
     a.FORECAST_SPREAD_TYPE,
     a.DIMENTION1,
     a.DIMENTION2,
     a.DIMENTION3,
     a.BASE_QUANTITY_START_DATE,
     a.BASE_QUANTITY_END_DATE,
     a.INCREMENT_QUOTA,
     a.FORECAST_UOM_CODE,
     a.LAST_SCENARIO_ID,
         b.transaction_currency_code
    FROM OZF_ACT_FORECASTS_ALL a, ozf_offers b
    WHERE a.FORECAST_ID = p_forecast_id
          AND a.arc_act_fcast_used_by = p_obj_type
          AND a.act_fcast_used_by_id = p_obj_id
          AND b.qp_list_header_id = a.act_fcast_used_by_id;

 CURSOR c_wkst_fcst_rec IS
    SELECT
     a.PERIOD_LEVEL,
     a.BASE_QUANTITY_TYPE,
     a.BASE_QUANTITY_REF,
     a.FORECAST_SPREAD_TYPE,
     a.DIMENTION1,
     a.DIMENTION2,
     a.DIMENTION3,
         trunc(b.start_date_active) wkst_start_date_active,
         trunc(b.end_date_active)   wkst_end_date_active,
     a.INCREMENT_QUOTA,
         a.forecast_uom_code,
     a.LAST_SCENARIO_ID,
     b.currency_code
       FROM ozf_act_forecasts_all a,
            ozf_worksheet_headers_b b
       WHERE a.FORECAST_ID = p_forecast_id
       AND   b.worksheet_header_id = NVL(p_obj_id, b.worksheet_header_id)
       AND   a.arc_act_fcast_used_by = NVL(p_obj_type, 'WKST')
       AND   a.act_fcast_used_by_id = b.worksheet_header_id
       AND   b.forecast_generated = DECODE(p_obj_id, NULL, 'N',b.forecast_generated);

 CURSOR level_one_facts IS
   SELECT activity_metric_fact_id,
          fact_reference,
          fact_type
   FROM  ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND   act_metric_used_by_id = p_forecast_id
   AND previous_fact_id IS NULL
   AND root_fact_id IS NULL;

 CURSOR level_two_facts(p_previous_fact_id IN NUMBER) IS
   SELECT activity_metric_fact_id,
          fact_reference,
          fact_type
   FROM  ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND   act_metric_used_by_id = p_forecast_id
   AND   previous_fact_id = p_previous_fact_id
   AND   root_fact_id IS NULL;

 CURSOR level_three_facts(p_root_fact_id IN NUMBER, p_previous_fact_id IN NUMBER) IS
   SELECT activity_metric_fact_id,
          fact_reference,
          fact_type
   FROM  ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND   act_metric_used_by_id = p_forecast_id
   AND   previous_fact_id = p_previous_fact_id
   AND   root_fact_id = p_root_fact_id;

 CURSOR get_product_qualfiers(p_forecast_dimention_id IN NUMBER) IS
   SELECT product_attribute_context,
          product_attribute,
          product_attr_value
   FROM ozf_forecast_dimentions
   WHERE forecast_dimention_id = p_forecast_dimention_id
   AND forecast_id = p_forecast_id;

 CURSOR get_market_qualifiers(p_forecast_dimention_id IN NUMBER) IS
   SELECT qualifier_grouping_no
   FROM   ozf_forecast_dimentions
   WHERE  forecast_dimention_id = p_forecast_dimention_id
   AND forecast_id = p_forecast_id;

 CURSOR get_products(l_qualifier_grouping_no IN NUMBER)  IS
 SELECT min(forecast_dimention_id) forecast_dimention_id,
        product_attribute_context,
        product_attribute,
        product_attr_value
 FROM ozf_forecast_dimentions
 WHERE obj_type = p_obj_type
 AND obj_id = p_obj_id
 AND forecast_id = p_forecast_id
 AND qualifier_grouping_no = NVL(l_qualifier_grouping_no, qualifier_grouping_no)
 GROUP BY
    product_attribute_context,
    product_attribute,
    product_attr_value ;

 CURSOR get_markets (l_product_attribute_context IN VARCHAR2,
                     l_product_attribute IN VARCHAR2,
                     l_product_attr_value IN VARCHAR2 )
 IS
   SELECT min(forecast_dimention_id) forecast_dimention_id,
          min(qualifier_grouping_no) qualifier_grouping_no
   FROM   ozf_forecast_dimentions
   WHERE  obj_type = p_obj_type
   AND    obj_id   = p_obj_id
   AND forecast_id = p_forecast_id
   AND product_attribute_context = NVL(l_product_attribute_context, product_attribute_context)
   AND product_attribute = NVL(l_product_attribute, product_attribute)
   AND product_attr_value = NVL(l_product_attr_value, product_attr_value)
   GROUP BY
         qualifier_context,
         qualifier_attribute,
         qualifier_attr_value,
         qualifier_grouping_no ;

 CURSOR periods_csr IS
    SELECT period_number,
           start_date,
           end_date,
           period_type_id
    FROM ozf_forecast_periods
    WHERE obj_type = p_obj_type
    AND   obj_id   = p_obj_id;

 CURSOR get_sales_period IS
   SELECT period_number
   FROM ozf_forecast_periods
   WHERE obj_type = p_obj_type -- 'OFFR'
   AND   obj_id   = p_obj_id
   AND (forecast_id IS NULL -- inanaiah: For compatibility with older release
    OR forecast_id = p_forecast_id); -- inanaiah: making periods bound to forecast_id as is the case when creating new version ;


 l_activity_metric_id         NUMBER := p_activity_metric_id;
 l_base_sales                 NUMBER := 0;
 l_product_attribute_context  ozf_forecast_dimentions.product_attribute_context%TYPE;
 l_product_attribute          ozf_forecast_dimentions.product_attribute%TYPE;
 l_product_attr_value         ozf_forecast_dimentions.product_attr_value%TYPE;
 l_qualifier_grouping_no      NUMBER;
 l_period_number              NUMBER;
 l_previous_fact_id           NUMBER ;
 l_root_fact_id               NUMBER;
 l_period_level               OZF_ACT_FORECASTS_ALL.period_level%TYPE;
 l_base_quantity_type         OZF_ACT_FORECASTS_ALL.base_quantity_type%TYPE;
 l_base_quantity_ref          OZF_ACT_FORECASTS_ALL.base_quantity_ref%TYPE;
 l_forecast_spread_type       OZF_ACT_FORECASTS_ALL.forecast_spread_type%TYPE;
 l_dimention1                 OZF_ACT_FORECASTS_ALL.dimention1%TYPE;
 l_dimention2                 OZF_ACT_FORECASTS_ALL.dimention2%TYPE;
 l_dimention3                 OZF_ACT_FORECASTS_ALL.dimention3%TYPE;
 l_base_quantity_start_date   OZF_ACT_FORECASTS_ALL.base_quantity_start_date%TYPE;
 l_base_quantity_end_date     OZF_ACT_FORECASTS_ALL.base_quantity_end_date%TYPE;
 l_increment_quota            OZF_ACT_FORECASTS_ALL.increment_quota%TYPE;
 l_forecast_uom_code          OZF_ACT_FORECASTS_ALL.forecast_uom_code%TYPE;
 l_last_scenario_id           OZF_ACT_FORECASTS_ALL.last_scenario_id%TYPE;
 l_tpr_percent                NUMBER;
 l_baseline_sales             NUMBER;
 l_incremental_sales          NUMBER;

  /* Added for promotional goods offer */
  l_node_id NUMBER;
  l_offer_type VARCHAR2(30) := 'OFFR';
  l_currency_code VARCHAR2(30) := 'USD';

  CURSOR get_offer_type
  IS
   SELECT offer_type
   FROM ozf_offers
   WHERE qp_list_header_id = p_obj_id;

  CURSOR get_promotion_type(l_product_attribute_context IN VARCHAR2,
                            l_product_attribute IN VARCHAR2,
                            l_product_attr_value IN VARCHAR2 )
  IS
   SELECT DECODE(qpl.list_line_type_code
                 ,'DIS', DECODE(qpl.operand
                                ,100 , DECODE(qpl.arithmetic_operator
                                              ,'%', 3
                                                  , 2 )
                                     , 2)
                       , 1) promotion_type
   FROM   qp_list_lines qpl,
          qp_pricing_attributes qp
   WHERE qpl.list_header_id = p_obj_id
   AND qpl.list_line_id = qp.list_line_id
   AND qp.excluder_flag = 'N'
   AND qp.product_attribute_context = l_product_attribute_context
   AND qp.product_attribute = l_product_attribute
   AND qp.product_attr_value = l_product_attr_value
   ORDER BY promotion_type;


BEGIN


  IF (OZF_DEBUG_HIGH_ON) THEN
     OZF_Utility_PVT.debug_message(l_full_name || ': Start Process Baseline Forecast ');
  END IF;

  --
  -- Initialize savepoint.
  --
  SAVEPOINT process_baseline_forecast;

  IF FND_API.to_boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;


  -- First: Get Offer or Wkst Forecast Header Level Details from the forecast id
  IF p_obj_type = 'OFFR'
  THEN
  -- for OFFR
        OPEN c_fcst_rec;
        FETCH c_fcst_rec INTO
             l_period_level,
             l_base_quantity_type,
             l_base_quantity_ref,
             l_forecast_spread_type,
             l_dimention1,
             l_dimention2,
             l_dimention3,
             l_base_quantity_start_date,
             l_base_quantity_end_date,
             l_increment_quota,
             l_forecast_uom_code,
             l_last_scenario_id,
             l_currency_code;
        CLOSE c_fcst_rec;

  ELSIF p_obj_type = 'WKST'
  THEN
  -- for WKST
       OPEN c_wkst_fcst_rec;
       FETCH c_wkst_fcst_rec INTO
             l_period_level,
             l_base_quantity_type,
             l_base_quantity_ref,
             l_forecast_spread_type,
             l_dimention1,
             l_dimention2,
             l_dimention3,
             l_base_quantity_start_date,
             l_base_quantity_end_date,
             l_increment_quota,
             l_forecast_uom_code,
             l_last_scenario_id,
             l_currency_code;
       CLOSE c_wkst_fcst_rec;

  END IF;

  -- Second: Set Defaults, both for, OFFR and WKST
  IF (l_dimention1 IS NULL OR l_dimention2 IS NULL OR l_dimention3 IS NULL )
  THEN
      l_dimention1 := 'PRODUCT';
      l_dimention2 := 'MARKET';
      l_dimention3 := 'TIME';
  END IF;


 -- If period_level is not chosen by the user on the UI, then default it to WEEKLY
 l_period_level := NVL(p_period_level, NVL(l_period_level, 16));


 -- Third : create fact rows for all 3 dimensions
        create_fcst_facts(p_api_version,
                          p_init_msg_list,
                          p_commit,
                          l_base_quantity_type,
                          p_obj_type,
                          p_obj_id,
                          p_forecast_id,
                          l_activity_metric_id,
                          'ONE', -- p_level,
                          l_dimention1,
                          l_forecast_uom_code,
                          l_base_quantity_start_date,
                          l_base_quantity_end_date,
                          l_return_status,
                          x_msg_count,
                          x_msg_data);

        create_fcst_facts(p_api_version,
                          p_init_msg_list,
                          p_commit,
                          l_base_quantity_type,
                          p_obj_type,
                          p_obj_id,
                          p_forecast_id,
                          l_activity_metric_id,
                          'TWO', -- p_level,
                          l_dimention2,
                          l_forecast_uom_code,
                          l_base_quantity_start_date,
                          l_base_quantity_end_date,
                          l_return_status,
                          x_msg_count,
                          x_msg_data);

    create_fcst_facts(p_api_version,
                          p_init_msg_list,
                          p_commit,
                          l_base_quantity_type,
                          p_obj_type,
                          p_obj_id,
                          p_forecast_id,
                          l_activity_metric_id,
                          'THREE', -- p_level,
                          l_dimention3,
                          l_forecast_uom_code,
                          l_base_quantity_start_date,
                          l_base_quantity_end_date,
                          l_return_status,
                          x_msg_count,
                          x_msg_data);
    --dbms_output.put_line( ' STATUS After level 3 facts ~~~~~~  => '||l_return_status );



 -- Fourth : Get baseline sales from 3rd party baseline sales MV
 --        : Get best fit Lift from 3rd party Lift factors

    -- Process for P->M->T or P->T->M
    ---- At this point all FACTS are present
    ---- Now PROCESS the THIRD LEVEL records only (most granular record)

    ---- For each 1st level
    ---------For each 2nd level
    ------------For each 3rd level records
    ---------------- GET the Base Sales for each record
    ---------------- GET the best-fit-lift for each record (offer_id, forecast_id will be passed)
    ---------------- Calculate the incremental sales
    ------------end loop; 3rd level
    ---------end loop; 2nd level
    ---- end loop; 1st level


       FOR i IN level_one_facts
       LOOP
        --dbms_output.put_line( ' ~~~~~~~~~~~~~~~~~~~~~~~~  Inside i Loop ~~~~~~~~~~~~~~~~~~~ ' );
        --dbms_output.put_line( ' i Loop ~~:  i.activity_metric_fact_id == '|| i.activity_metric_fact_id);

            l_root_fact_id := i.activity_metric_fact_id ;

             OPEN get_product_qualfiers(i.fact_reference)  ;
             FETCH get_product_qualfiers INTO l_product_attribute_context,
                                              l_product_attribute,
                                              l_product_attr_value ;
             CLOSE get_product_qualfiers;

    --dbms_output.put_line( ' ~~~~~~~i.activity_metric_fact_id~~~~~~~~~~~~ '||i.activity_metric_fact_id );
    --dbms_output.put_line( ' ~~ level_one_facts ~~:  p_obj_type == '|| p_obj_type);
    --dbms_output.put_line( ' ~~ level_one_facts ~~:  p_obj_id == '|| p_obj_id);
    --dbms_output.put_line( ' ~~ level_one_facts ~~:  p_forecast_id == '||p_forecast_id );
    --dbms_output.put_line( ' ~~ level_one_facts ~~:  l_product_attribute == '|| l_product_attribute);
    --dbms_output.put_line( ' ~~ level_one_facts ~~:  l_product_attr_value == '|| l_product_attr_value);
    --dbms_output.put_line( ' ~~ level_one_facts ~~:  l_currency_code == '|| l_currency_code);
    --dbms_output.put_line( ' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ' );

         get_discount_percent
           (p_api_version,
            p_init_msg_list,
            p_commit,
            p_obj_type,
            p_obj_id,
            p_forecast_id,
            l_product_attribute,
            l_product_attr_value,
            l_currency_code,
            l_tpr_percent,
            x_return_status,
            x_msg_count,
            x_msg_data);
             --dbms_output.put_line( ' ~~ level_one_facts ~~:  x_return_status == '|| x_return_status );
             --dbms_output.put_line( ' ~~ level_one_facts ~~:  l_tpr_percent == '|| l_tpr_percent );

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

             UPDATE ozf_act_metric_facts_all prod_fact
             SET tpr_percent = NVL(l_tpr_percent,0)
             WHERE prod_fact.activity_metric_fact_id = i.activity_metric_fact_id
             AND prod_fact.arc_act_metric_used_by = 'FCST'
             AND prod_fact.act_metric_used_by_id = p_forecast_id;

         FOR j IN level_two_facts(i.activity_metric_fact_id)
         LOOP

         --dbms_output.put_line( ' ~~~~~~~~~~~~~~~~~~~~~~~~  Inside j Loop ~~~~~~~~~~~~~~~~~~~ ' );
         --dbms_output.put_line( ' ~ j Loop ~~:  j.activity_metric_fact_id == '|| j.activity_metric_fact_id);

          l_previous_fact_id := j.activity_metric_fact_id ;

          IF (j.fact_type = 'MARKET')
                  THEN

                     OPEN get_market_qualifiers(j.fact_reference);
                     FETCH get_market_qualifiers INTO l_qualifier_grouping_no;
                     CLOSE get_market_qualifiers;

                  ELSIF (j.fact_type = 'TIME')
                  THEN

               l_period_number := j.fact_reference ;

                  END IF;


             FOR k IN level_three_facts(i.activity_metric_fact_id, j.activity_metric_fact_id)
             LOOP

              IF (k.fact_type = 'MARKET')
              THEN

                 OPEN get_market_qualifiers(k.fact_reference);
                 FETCH get_market_qualifiers INTO l_qualifier_grouping_no;
                 CLOSE get_market_qualifiers;

              ELSIF (k.fact_type = 'TIME')
              THEN
                   l_period_number := k.fact_reference ;

              END IF;

             --dbms_output.put_line( ' ~~~~~~~~~~~~~~~~~~~~~~~~  Inside k Loop ~~~~~~~~~~~~~~~~~~~ ' );
             --dbms_output.put_line( ' ~~~~~~~~~~~~~~~~~~~ ' );
             --dbms_output.put_line( ' ~~ k Loop ~~:  l_forecast_period_id == '|| l_period_number);
             --dbms_output.put_line( ' ~~ k Loop ~~:  k.activity_metric_fact_id == '|| k.activity_metric_fact_id);
             --dbms_output.put_line( ' ~~ k Loop ~~:  l_product_attribute_context == '|| l_product_attribute_context );
             --dbms_output.put_line( ' ~~ k Loop ~~:  l_product_attribute == '|| l_product_attribute);
             --dbms_output.put_line( ' ~~ k Loop ~~:  l_product_attr_value == '|| l_product_attr_value );
             --dbms_output.put_line( ' ~~ k Loop ~~:  l_qualifier_grouping_no  == '|| l_qualifier_grouping_no );
             --dbms_output.put_line( ' ~~~~~~~~~~~~~~~~~~~ ' );
             --dbms_output.put_line( ' ~~ k Loop ~~:  l_tpr_percent == '|| l_tpr_percent );
             --dbms_output.put_line( ' ~~ k Loop ~~:  p_obj_type == '|| p_obj_type);
             --dbms_output.put_line( ' ~~ k Loop ~~:  p_obj_id == '|| p_obj_id);
             --dbms_output.put_line( ' ~~ k Loop ~~:  p_forecast_id == '||p_forecast_id );
             --dbms_output.put_line( ' ~~ k Loop ~~:  l_base_quantity_ref == '|| l_base_quantity_ref);
             --dbms_output.put_line( ' ~~~~~~~~~~~~~~~~~~~ ' );


              -- Now, all three dimensions are available: P, T, M
              BEGIN

                  UPDATE ozf_act_metric_facts_all outer
                  SET (outer.baseline_sales, outer.incremental_sales) =
                    (
                    select
                    ROUND(NVL (SUM(sales.baseline_sales) ,0) ) baseline_sales,
                    DECODE(l_tpr_percent, NULL, 0, ROUND(NVL (SUM(sales.baseline_sales * NVL(OZF_FORECAST_UTIL_PVT.get_best_fit_lift
                                          (
                                           p_obj_type,
                                           p_obj_id,
                                           p_forecast_id,
                                           l_base_quantity_ref,
                                           sales.market_type,
                                           sales.market_id,
                                           dim.product_attribute_context,
                                           dim.product_attribute,
                                           dim.product_attr_value,
                                           sales.item_id,
                                           l_tpr_percent,
                                           rpt.report_date
                                          ), 0)
                                                  ) ,0) ) )incremental_sales
                    from OZF_BASEline_sales_v sales,
                         ozf_time_day rpt,
                         (select  cust.qualifier_grouping_no,
                              cust.cust_account_id,
                              cust.site_use_code site_use_code,
                              cust.site_use_id site_use_id,
                              prod.product_attribute_context,
                              prod.product_attribute,
                              prod.product_attr_value,
                              prod.product_id inventory_item_id
                           from ozf_forecast_customers cust,
                            ozf_forecast_products prod
                           where prod.obj_type = p_obj_type
                           and prod.obj_id = p_obj_id
                           and prod.obj_type = cust.obj_type
                           and prod.obj_id =  cust.obj_id
                           and cust.site_use_code = 'SHIP_TO'
                          ) cust_prod,
                          ozf_forecast_dimentions dim,
                          ozf_forecast_periods period
                    where dim.obj_type =  p_obj_type
                    and   dim.obj_id   =  p_obj_id
                    AND   dim.forecast_id = p_forecast_id
                    and   dim.product_attribute_context = cust_prod.product_attribute_context
                    and   dim.product_attribute  = cust_prod.product_attribute
                    and   dim.product_attr_value = cust_prod.product_attr_value
                    and   dim.qualifier_grouping_no = cust_prod.qualifier_grouping_no
                    and   cust_prod.site_use_code = sales.market_type
                    and   cust_prod.site_use_id = sales.market_id
                    and   sales.item_level = 'PRICING_ATTRIBUTE1'
                    and   sales.item_id = cust_prod.inventory_item_id
                    and   period.obj_type = 'DISP'
                    and   period.obj_id   = p_obj_id
                    and   period.forecast_id = p_forecast_id
                    and   rpt.report_date between period.start_date and period.end_date
                    and   rpt.report_date_julian = sales.time_id
                    and   sales.period_type_id = 1
                    and   dim.product_attribute_context = l_product_attribute_context
                    and   dim.product_attribute = l_product_attribute
                    and   dim.product_attr_value = l_product_attr_value
                    and   dim.qualifier_grouping_no = l_qualifier_grouping_no
                    and   period.forecast_period_id = l_period_number
                    ),
                    outer.forecast_remaining_quantity = 0
                  WHERE outer.activity_metric_fact_id = k.activity_metric_fact_id
                AND outer.arc_act_metric_used_by = 'FCST'
                AND outer.act_metric_used_by_id = p_forecast_id;

              EXCEPTION
                 WHEN OTHERS THEN
                 NULL;
                 --dbms_output.put_line( ' ~~~~ ERROR in Update Baseline Sales for ABOVE record -- ');
              END;


              UPDATE ozf_act_metric_facts_all outer2
                  SET outer2.baseline_sales=0
                  WHERE outer2.activity_metric_fact_id = k.activity_metric_fact_id
                AND outer2.arc_act_metric_used_by = 'FCST'
                AND outer2.act_metric_used_by_id = p_forecast_id
                AND outer2.baseline_sales IS NULL;

              UPDATE ozf_act_metric_facts_all outer3
                  SET outer3.incremental_sales=0
                  WHERE outer3.activity_metric_fact_id = k.activity_metric_fact_id
                AND outer3.arc_act_metric_used_by = 'FCST'
                AND outer3.act_metric_used_by_id = p_forecast_id
                AND outer3.incremental_sales IS NULL;


             END LOOP; -- End of Level Three Records(k)

         END LOOP; -- End of Level Two Records(j)

       END LOOP; -- End Level One Records(i)


 --- At this point, all numbers will be there at the most granular i.e. at level3
 --- NOW, ROLLUP all numbers FOR LEVEL 2
      UPDATE ozf_act_metric_facts_all outer
      SET (outer.baseline_sales, outer.incremental_sales) =
                          ( SELECT NVL(SUM(inner.baseline_sales),0),NVL(SUM(inner.incremental_sales),0)
                            FROM   ozf_act_metric_facts_all inner
                            WHERE  inner.previous_fact_id = outer.activity_metric_fact_id
                            AND   inner.arc_act_metric_used_by = 'FCST'
                            AND   inner.act_metric_used_by_id = p_forecast_id
                            AND   inner.fact_type = l_dimention3),
           outer.forecast_remaining_quantity = 0
      WHERE
            outer.arc_act_metric_used_by = 'FCST'
      AND   outer.act_metric_used_by_id = p_forecast_id
      AND   outer.fact_type = l_dimention2;


--- NOW, ROLLUP all numbers FOR LEVEL 1 (this is always 'PRODUCT')
      UPDATE ozf_act_metric_facts_all outer
      SET (outer.baseline_sales, outer.incremental_sales) =
                          ( SELECT NVL(SUM(inner.baseline_sales),0),NVL(SUM(inner.incremental_sales),0)
                            FROM   ozf_act_metric_facts_all inner
                            WHERE  inner.previous_fact_id = outer.activity_metric_fact_id
                            AND   inner.arc_act_metric_used_by = 'FCST'
                            AND   inner.act_metric_used_by_id = p_forecast_id
                            AND   inner.fact_type = l_dimention2),
           outer.forecast_remaining_quantity = 0
      WHERE
            outer.arc_act_metric_used_by = 'FCST'
      AND   outer.act_metric_used_by_id = p_forecast_id
      AND   outer.fact_type = l_dimention1;
  --dbms_output.put_line( ' ~~~~~~~  DONE -- ROLLUP all numbers FOR LEVEL 1 ~~~~~~~~ ' );


--- NOW, ROLLUP all numbers FOR FORECAST Header LEVEL
--- Also, Make Sure that dimentions are updated to default selection
  UPDATE ozf_act_forecasts_all outer
  SET (outer.forecast_quantity, outer.base_quantity) =
                  ( SELECT (NVL(SUM(inner.baseline_sales),0) + NVL(SUM(inner.incremental_sales),0)) total_forecast,
                    NVL(SUM(inner.baseline_sales),0) baseline_sales
            FROM   ozf_act_metric_facts_all inner
            WHERE inner.arc_act_metric_used_by = 'FCST'
            AND   inner.act_metric_used_by_id = p_forecast_id
            AND   inner.fact_type = l_dimention1),
      outer.dimention1    = l_dimention1,
      outer.dimention2    = l_dimention2,
      outer.dimention3    = l_dimention3,
      outer.period_level  = l_period_level,
      outer.forecast_remaining_quantity = 0
      --last_scenario_id    = NVL(last_scenario_id,0)+1
  WHERE outer.forecast_id = p_forecast_id;

  IF (OZF_DEBUG_HIGH_ON) THEN
     OZF_Utility_PVT.debug_message(l_full_name || ': End Process Baseline Forecast ');
  END IF;

EXCEPTION

    WHEN OTHERS THEN

      ROLLBACK TO process_baseline_forecast;

      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


END process_baseline_forecast; --end of procedure
--***********************************************

PROCEDURE create_wkst_forecasts(
   p_api_version      IN  NUMBER,
   p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
   p_commit           IN  VARCHAR2  := FND_API.g_false,
   p_worksheet_header_id   IN NUMBER ,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2 )
IS
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'create_wkst_forecasts';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  CURSOR c_fcst_rec IS
  SELECT b.worksheet_header_id,
         trunc(b.start_date_active) wkst_start_date_active,
         trunc(b.end_date_active)   wkst_end_date_active,
         a.forecast_id ,
         a.period_level,       /* DAY, WEEK, MONTH, QTR */
         a.forecast_uom_code,
         a.base_quantity_type, /* LAST_YEAR_SAME_PERIOD, OFFER_CODE, CUSTOM_DATE_RANGE */
         a.base_quantity_start_date,
         a.base_quantity_end_date,
         a.base_quantity_ref   /* OFFER_CODE  or BASELINE SOURCE */
  FROM ozf_act_forecasts_all a,
       ozf_worksheet_headers_b b
  WHERE b.worksheet_header_id = NVL(p_worksheet_header_id,  b.worksheet_header_id)
  AND   a.arc_act_fcast_used_by = 'WKST'
  AND   a.act_fcast_used_by_id = b.worksheet_header_id
  AND   b.forecast_generated = DECODE(p_worksheet_header_id, NULL, 'N',b.forecast_generated);

  CURSOR offer_dates_csr(p_offer_code IN VARCHAR2) IS
  SELECT NVL(qp.start_date_active,trunc(SYSDATE)) start_date_active,
         NVL(qp.end_date_active, trunc(SYSDATE)) end_date_active
  FROM  qp_list_headers_b qp,
        ozf_offers off
  WHERE off.offer_code = p_offer_code
  AND   off.qp_list_header_id = qp.list_header_id ;

  l_forecast_id              NUMBER;
  l_period_level             VARCHAR2(30);
  l_forecast_uom_code        VARCHAR2(30);
  l_base_quantity_type       VARCHAR2(30);
  l_base_quantity_start_date DATE;
  l_base_quantity_end_date   DATE;
  l_base_quantity_ref        VARCHAR2(30);

  l_wkst_start_date DATE;
  l_wkst_end_date   DATE;

  l_activity_metric_id NUMBER;
  l_worksheet_header_id NUMBER;

BEGIN

   IF (OZF_DEBUG_HIGH_ON)
   THEN
      OZF_Utility_PVT.debug_message(l_full_name || ': Start Create Wkst Forecasts');
   END IF;

   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_Wkst_Forecasts;

   IF FND_API.to_boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   --  Start
   -- Process for all Worksheets for which forecast is not generated
   FOR i IN c_fcst_rec
   LOOP

        l_worksheet_header_id := i.worksheet_header_id;
        l_wkst_start_date     := i.wkst_start_date_active;
        l_wkst_end_date       := i.wkst_end_date_active;
        l_forecast_id         := i.forecast_id;
        l_period_level        := i.period_level;
        l_forecast_uom_code   := i.forecast_uom_code;
        l_base_quantity_type  := i.base_quantity_type;
        l_base_quantity_ref   := i.base_quantity_ref;

        IF l_base_quantity_type = 'LAST_YEAR_SAME_PERIOD'
        THEN

           l_base_quantity_start_date := ADD_MONTHS(l_wkst_start_date, -12);
           l_base_quantity_end_date   := ADD_MONTHS(l_wkst_end_date, -12);

        ELSIF l_base_quantity_type = 'OFFER_CODE'
        THEN

          OPEN offer_dates_csr(l_base_quantity_ref);
          FETCH offer_dates_csr INTO l_base_quantity_start_date,l_base_quantity_end_date;
          CLOSE offer_dates_csr;

        ELSIF l_base_quantity_type = 'CUSTOM_DATE_RANGE'
        THEN

            l_base_quantity_start_date := i.base_quantity_start_date;
            l_base_quantity_end_date := i.base_quantity_end_date;

        --R12 Baseline
        ELSIF (l_base_quantity_type = 'BASELINE')
        THEN

            l_base_quantity_start_date := l_wkst_start_date;
            l_base_quantity_end_date := l_wkst_end_date;
        END IF;

    -- R12 modified
   -- Create Forecast
        create_forecast(
                     p_api_version,
                     p_init_msg_list,
                     p_commit,
                     'WKST', -- p_obj_type ,
                     l_worksheet_header_id, -- p_obj_id   ,
                     l_forecast_uom_code ,

                     l_base_quantity_start_date,
                     l_base_quantity_end_date,
                     l_base_quantity_type,
                     l_base_quantity_ref,
                     null,
                     l_base_quantity_ref,

                     l_forecast_id,
                     l_activity_metric_id, -- 11510
                     l_return_status,
                     x_msg_count,
                     x_msg_data) ;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     -- Create dimentions

     create_dimentions (
                        p_api_version,
                        p_init_msg_list,
                        p_commit,
                        'WKST', -- p_obj_type ,
                        l_worksheet_header_id, --p_obj_id ,
                        l_forecast_id,
                        l_return_status,
                        x_msg_count,
                        x_msg_data ) ;


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Create products

     populate_fcst_products(
                              p_api_version,
                              p_init_msg_list,
                              p_commit,
                              'WKST', --p_obj_type ,
                              l_worksheet_header_id, --p_obj_id ,
                              l_forecast_id,
                              l_return_status,
                              x_msg_count,
                              x_msg_data ) ;


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Create customers

     populate_fcst_customers(
                              p_api_version,
                              p_init_msg_list,
                              p_commit,
                              'WKST', -- p_obj_type,
                              l_worksheet_header_id, --p_obj_id,
                              l_forecast_id,
                              l_return_status,
                              x_msg_count,
                              x_msg_data);


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     IF l_base_quantity_type <> 'BASELINE' AND l_period_level IS NOT NULL
     THEN

         populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           'WKST', --p_obj_type,
                           l_worksheet_header_id, --p_obj_id,
                           l_base_quantity_start_date,
                           l_base_quantity_end_date,
                           l_period_level,
                           l_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

     END IF;


     IF (l_base_quantity_type = 'BASELINE')
     THEN

        l_period_level := NVL(l_period_level, 16); -- WEEKLY

        populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           'DISP', --p_obj_type,
                           l_worksheet_header_id, --p_obj_id,
                           l_base_quantity_start_date,
                           l_base_quantity_end_date,
                           l_period_level,
                           l_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

        populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           'WKST', --p_obj_type,
                           l_worksheet_header_id, --p_obj_id,
                           l_base_quantity_start_date,
                           l_base_quantity_end_date,
                           l_period_level,
                           l_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;


        process_baseline_forecast(p_api_version,
                          p_init_msg_list,
                          p_commit,
                          'WKST',
                          l_worksheet_header_id,
                          l_forecast_id,
                          l_period_level,
                          l_activity_metric_id,
                          l_forecast_uom_code,
                          l_return_status,
                          x_msg_count,
                          x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


     ELSE

        create_fcst_facts(p_api_version,
                          p_init_msg_list,
                          p_commit,
                          l_base_quantity_type,
                          'WKST', -- p_obj_type,
                          l_worksheet_header_id, -- p_obj_id,
                          l_forecast_id,
                          l_activity_metric_id,
                          'ONE', -- p_level,
                          'PRODUCT', -- p_dimention,
                          l_forecast_uom_code,
                          l_base_quantity_start_date,
                          l_base_quantity_end_date,
                          l_return_status,
                          x_msg_count,
                          x_msg_data);


        IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;


        create_fcst_facts(p_api_version,
                          p_init_msg_list,
                          p_commit,
                          l_base_quantity_type,
                          'WKST', --p_obj_type,
                          l_worksheet_header_id , -- p_obj_id,
                          l_forecast_id,
                          l_activity_metric_id,
                          'TWO', -- p_level,
                          'TIME', -- p_dimention,
                          l_forecast_uom_code,
                          l_base_quantity_start_date,
                          l_base_quantity_end_date,
                          l_return_status,
                          x_msg_count,
                          x_msg_data);

        IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;


        UPDATE ozf_act_forecasts_all
        SET base_quantity = ( SELECT NVL(SUM(base_quantity),0)
                            FROM   ozf_act_metric_facts_all
                            WHERE arc_act_metric_used_by = 'FCST'
                            AND   act_metric_used_by_id = l_forecast_id
                            AND   fact_type = 'PRODUCT') ,
          dimention1    = 'PRODUCT',
          dimention2    = 'TIME'
        WHERE forecast_id = l_forecast_id;


     END IF; --IF (l_base_quantity_type = 'BASELINE')


     --IF p_worksheet_header_id is null THEN
     UPDATE ozf_worksheet_headers_b
     SET forecast_generated = 'Y'
     WHERE worksheet_header_id = l_worksheet_header_id;


   END LOOP;

   IF (OZF_DEBUG_HIGH_ON)
   THEN
      OZF_Utility_PVT.debug_message(l_full_name || ': End Create Wkst Forecasts');
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Create_Wkst_Forecasts;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Create_Wkst_Forecasts;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN OTHERS THEN

      ROLLBACK TO Create_Wkst_Forecasts;
      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END ; -- create_wkst_forecasts


------------------------------------------------
PROCEDURE create_base_sales(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_obj_type         IN VARCHAR2,
  p_obj_id           IN NUMBER,
  p_forecast_id      IN NUMBER,
  p_activity_metric_id IN NUMBER,

  p_level            IN VARCHAR2,
  p_dimention        IN VARCHAR2,
  p_fcst_uom         IN VARCHAR2,

  p_start_date       IN DATE,
  p_end_date         IN DATE,
  p_period_level     IN VARCHAR2,
  --R12
  p_base_quantity_type IN VARCHAR2,
  p_base_quantity_ref  IN VARCHAR2,
  p_last_forecast_id   IN NUMBER,
  p_base_quantity_start_date IN DATE,
  p_base_quantity_end_date   IN DATE,
  p_offer_code       IN VARCHAR2,

  x_fcst_return_rec  OUT NOCOPY fcst_return_rec_type,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2

)
IS
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'create_base_sales';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  TYPE uom_tbl IS TABLE OF varchar2(3);
  l_uom_tbl uom_tbl;
  l_count NUMBER;
  l_tbl_count NUMBER;

  l_forecast_id  NUMBER;
  l_base_sales   NUMBER := 0;
  l_spread_type VARCHAR2(30);
  l_period_level VARCHAR2(30);
  l_fcst_uom     VARCHAR2(3);
  l_flag_error boolean := false;

  -- 11510
  l_activity_metric_id NUMBER;

  -- For R12
  l_base_quantity_type       VARCHAR2(30);
  l_base_quantity_start_date DATE;
  l_base_quantity_end_date   DATE;
  l_base_quantity_ref        VARCHAR2(30);
  l_last_scenario_id         NUMBER;
  l_offer_code               VARCHAR2(30);
  l_offer_id                 NUMBER;
  l_disp_type                VARCHAR2(4) := 'DISP';
  l_new_count                NUMBER;
  l_common_count             NUMBER;

  -- For R12, use for copy_forecast
  l_base_quantity_start_dttemp DATE;
  l_base_quantity_end_dttemp   DATE;

  CURSOR c_fcst_rec (l_fcst_id IN NUMBER) IS
    SELECT forecast_spread_type,
           period_level,
           forecast_uom_code,
           base_quantity_type,
           base_quantity_start_date,
           base_quantity_end_date,
           base_quantity_ref,   /* Third party*/
           last_scenario_id,
           offer_code
    FROM ozf_act_forecasts_all
    WHERE forecast_id = l_fcst_id;

  CURSOR offer_dates_csr(p_offer_code IN VARCHAR2) IS
    SELECT NVL(qp.start_date_active,trunc(SYSDATE)) start_date_active,
           NVL(qp.end_date_active, trunc(SYSDATE)) end_date_active
    FROM qp_list_headers_b qp,
         ozf_offers off
    WHERE off.offer_code = p_offer_code
    AND   off.qp_list_header_id = qp.list_header_id ;

  CURSOR offer_id_csr(p_offer_code IN VARCHAR2) IS
    SELECT qp_list_header_id --offer_id
    FROM ozf_offers off
    WHERE off.offer_code = p_offer_code;
--    AND offer_type = 'OFFR' ;

  CURSOR c_get_activity_metric_id(p_fcast_id IN NUMBER) IS
   SELECT activity_metric_id
   FROM ozf_act_metrics_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id;

BEGIN

   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name || ': Start Create Base Sales');

   END IF;

   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_Base_Sales;


  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;


--dbms_output.put_line( ' -- b4 starting p_base_quantity_type:  -- '||p_base_quantity_type);
  l_base_quantity_start_date := p_start_date;
  l_base_quantity_end_date := p_end_date;

  -- Dates used for calculating periods and sales
  -- Use p_start_date, p_end_date for the second iteration and
  -- do not use it to call get_sales. Useful for display.

  -- For LYSP, calculate the value in this procedure.
--dbms_output.put_line( ' -- b4 setting dates, start_date:  -- '||l_base_quantity_start_date);
  --dbms_output.put_line( ' -- b4 setting dates, end_date:  -- '||l_base_quantity_end_date);
  IF (p_base_quantity_type = 'LAST_YEAR_SAME_PERIOD' )
  THEN
    l_base_quantity_start_date := ADD_MONTHS(l_base_quantity_start_date,-12);
    l_base_quantity_end_date := ADD_MONTHS(l_base_quantity_end_date,-12);
  ELSIF (p_base_quantity_type = 'OFFER_CODE' )
  THEN
    OPEN offer_dates_csr(p_offer_code);
    FETCH offer_dates_csr INTO l_base_quantity_start_date, l_base_quantity_end_date;
    CLOSE offer_dates_csr;
  ELSIF (p_base_quantity_type = 'CUSTOM_DATE_RANGE')
  THEN
    l_base_quantity_start_date := p_base_quantity_start_date ;
    l_base_quantity_end_date := p_base_quantity_end_date ;
    --R12 Baseline
  ELSIF (p_base_quantity_type = 'BASELINE')
  THEN
    l_base_quantity_start_date := l_base_quantity_start_date; -- curr offer start date
    l_base_quantity_end_date := l_base_quantity_end_date ; -- curr offer end date
  END IF;

  IF ( p_forecast_id IS NULL )
  THEN
----dbms_output.put_line( ' -- p_forecast_id is NULL -- ');
    IF p_last_forecast_id <> 0 -- This will determine the button clicked
    THEN
    --dbms_output.put_line( ' -- p_last_forecast_id  <> 0:  -- '||p_last_forecast_id );
       OPEN c_fcst_rec(p_last_forecast_id);
       FETCH c_fcst_rec INTO l_spread_type, l_period_level, l_fcst_uom,
        l_base_quantity_type, l_base_quantity_start_dttemp, l_base_quantity_end_dttemp,
        l_base_quantity_ref, l_last_scenario_id, l_offer_code;
       CLOSE c_fcst_rec;

    END IF; --IF p_last_forecast_id <> 0 -- This will determine the button clicked

    --dbms_output.put_line( ' -- AFTER setting dates, start_date:  -- '||l_base_quantity_start_date);
    --dbms_output.put_line( ' -- AFTER setting dates, end_date:  -- '||l_base_quantity_end_date);
    -- Create forecast Header
    --dbms_output.put_line( ' -- 1 -- ');
     create_forecast(
                     p_api_version,
                     p_init_msg_list,
                     p_commit,
                     p_obj_type ,
                     p_obj_id   ,
                     p_fcst_uom ,
                     l_base_quantity_start_date,
                     l_base_quantity_end_date,
                     p_base_quantity_type,
                     p_base_quantity_ref,
                     l_last_scenario_id,
                     p_offer_code,
                     l_forecast_id,
                     l_activity_metric_id, -- 11510
                     l_return_status,
                     x_msg_count,
                     x_msg_data) ;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    x_fcst_return_rec.forecast_id := l_forecast_id;

     -- Create dimentions
--dbms_output.put_line( ' -- 2 -- ');

     create_dimentions (
                        p_api_version,
                        p_init_msg_list,
                        p_commit,
                        p_obj_type ,
                        p_obj_id ,
                        l_forecast_id,
                        l_return_status,
                        x_msg_count,
                        x_msg_data ) ;


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     -- Create products
--dbms_output.put_line( ' -- 3 -- ');

     populate_fcst_products(
                              p_api_version,
                              p_init_msg_list,
                              p_commit,
                              p_obj_type ,
                              p_obj_id ,
                              l_forecast_id,
                              l_return_status,
                              x_msg_count,
                              x_msg_data ) ;


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Create customers

--dbms_output.put_line( ' -- 4 -- ');
     populate_fcst_customers(
                              p_api_version,
                              p_init_msg_list,
                              p_commit,
                              p_obj_type,
                              p_obj_id,
                              l_forecast_id,
                              l_return_status,
                              x_msg_count,
                              x_msg_data);


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


--dbms_output.put_line( ' -- test offer_code -- ');
    IF (p_base_quantity_type = 'OFFER_CODE')
    THEN
    --dbms_output.put_line( ' -- Yes Offer code:p_offer_code -  -- '||p_offer_code);

        OPEN offer_id_csr(p_offer_code);
        FETCH offer_id_csr INTO l_offer_id;
        CLOSE offer_id_csr;
    --dbms_output.put_line( ' -- Offer id:  -- '|| l_offer_id);

        create_dimentions (
                        p_api_version,
                        p_init_msg_list,
                        p_commit,
                        p_obj_type,--l_disp_type ,
                        l_offer_id ,
                        l_forecast_id,
                        l_return_status,
                        x_msg_count,
                        x_msg_data ) ;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
--dbms_output.put_line( ' -- Got dimension:  -- ');
     -- Create products
        populate_fcst_products(
                              p_api_version,
                              p_init_msg_list,
                              p_commit,
                              p_obj_type,--l_disp_type ,
                              l_offer_id ,
                              l_forecast_id,
                              l_return_status,
                              x_msg_count,
                              x_msg_data ) ;


        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     -- Create customers
        populate_fcst_customers(
                              p_api_version,
                              p_init_msg_list,
                              p_commit,
                              p_obj_type,--l_disp_type,
                              l_offer_id,
                              l_forecast_id,
                              l_return_status,
                              x_msg_count,
                              x_msg_data);


        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --dbms_output.put_line( ' -- 5 -- ');
        populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           l_disp_type,
                           l_offer_id,
                           l_base_quantity_start_date,
                           l_base_quantity_end_date,
                           128, -- p_period_level,
                           l_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --dbms_output.put_line( ' -- 5.a -- ');
        -- for get_sales() useful for period csr
        populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           p_obj_type,
                           l_offer_id,
                           l_base_quantity_start_date,
                           l_base_quantity_end_date,
                           128, -- p_period_level,
                           l_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF; -- IF (p_base_quantity_type = 'OFFER_CODE')


    --R12 Baseline
    IF (p_base_quantity_type <> 'BASELINE')
    THEN
    -- Create periods
    -- two entries - one for display purpose and other for get_sales

    --dbms_output.put_line( ' -- 5 a-- ');
         populate_fcst_periods(p_api_version,
                          p_init_msg_list,
                          p_commit,
                          l_disp_type,
                          p_obj_id,
                          p_start_date,
                          p_end_date,
                          128, -- p_period_level,
                          l_forecast_id,
                          l_return_status,
                          x_msg_count,
                          x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       --dbms_output.put_line( ' -- 5 b-- ');
        populate_fcst_periods(p_api_version,
                              p_init_msg_list,
                              p_commit,
                              p_obj_type,
                              p_obj_id,
                              l_base_quantity_start_date,
                              l_base_quantity_end_date,
                              128, -- p_period_level,
                              l_forecast_id,
                              l_return_status,
                              x_msg_count,
                              x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF; --IF (p_base_quantity_type <> 'BASELINE')


    -- consider BASELINE later
    --dbms_output.put_line( ' -- 5 c-- ');
    IF (p_base_quantity_type = 'OFFER_CODE')
    THEN
        SELECT count(*) INTO l_new_count FROM (
            SELECT product_attribute_context, product_attribute, product_attr_value,
                   qualifier_grouping_no, qualifier_context, qualifier_attribute,
                   qualifier_attr_value
            FROM ozf_forecast_dimentions
            WHERE obj_id = p_obj_id
            AND obj_type = p_obj_type
            AND forecast_id = l_forecast_id);

        SELECT count(*) INTO l_common_count FROM (
            SELECT product_attribute_context, product_attribute, product_attr_value,
                    qualifier_grouping_no, qualifier_context, qualifier_attribute,
                    qualifier_attr_value
            FROM ozf_forecast_dimentions
            WHERE obj_id = p_obj_id
            AND obj_type = p_obj_type
            AND forecast_id = l_forecast_id
            INTERSECT
            SELECT product_attribute_context, product_attribute, product_attr_value,
                    qualifier_grouping_no, qualifier_context, qualifier_attribute,
                    qualifier_attr_value
            FROM ozf_forecast_dimentions
            WHERE obj_id = l_offer_id
            AND obj_type = l_disp_type
            AND forecast_id = l_forecast_id);

        IF (l_new_count = l_common_count)
        THEN
        --dbms_output.put_line( ' -- EQ x_spread_count -- ' || x_spread_count);
            x_fcst_return_rec.spread_count := 2;

            get_sales ( p_obj_type, --l_disp_type,
                 l_offer_id,
                 NULL ,       -- p_product_attribute_context IN VARCHAR2,
                 NULL ,       -- p_product_attribute         IN VARCHAR2,
                 NULL ,       -- p_product_attr_value        IN VARCHAR2,
                 NULL ,       -- p_qualifier_grouping_no     IN NUMBER,
                 NULL ,       -- p_period_number             IN NUMBER,
                 l_forecast_id,
                 l_base_sales ) ;

        ELSE
        --dbms_output.put_line( ' -- NEQ x_spread_count -- ' || x_spread_count);
            x_fcst_return_rec.spread_count := 1;

            l_base_sales := 0;
        END IF;
        --dbms_output.put_line( ' -- x_spread_count -- ' || x_spread_count);


    --R12 Baseline
    -- ELSE
    ELSIF (p_base_quantity_type <> 'BASELINE')
    THEN

       get_sales ( p_obj_type ,
                 p_obj_id   ,
                 NULL ,       -- p_product_attribute_context IN VARCHAR2,
                 NULL ,       -- p_product_attribute         IN VARCHAR2,
                 NULL ,       -- p_product_attr_value        IN VARCHAR2,
                 NULL ,       -- p_qualifier_grouping_no     IN NUMBER,
                 NULL ,       -- p_period_number             IN NUMBER,
                 l_forecast_id,
                 l_base_sales ) ;
        --dbms_output.put_line( ' -- NO x_spread_count -- ' || x_spread_count);

    END IF; -- IF (p_base_quantity_type = 'OFFER_CODE')


     --R12 Baseline
     IF (p_base_quantity_type <> 'BASELINE')
     THEN
       --dbms_output.put_line( ' -- 6 -- ' || l_base_sales);
         UPDATE ozf_act_forecasts_all
         SET base_quantity = ROUND(NVL(l_base_sales,0)),
             dimention1 = p_dimention,
             base_quantity_ref = x_fcst_return_rec.spread_count -- base_quantity_ref used in OFFER_CODE basis
         WHERE forecast_id = l_forecast_id;
        --dbms_output.put_line( ' -- 7 -- '|| l_forecast_id);
     END IF;


  ELSE --   IF ( p_forecast_id IS NULL )


      ----dbms_output.put_line( ' -- **** UPDATing **** p_forecast_id == '||p_forecast_id);
      OPEN c_fcst_rec(p_forecast_id);
      FETCH c_fcst_rec INTO l_spread_type, l_period_level, l_fcst_uom,
        l_base_quantity_type, l_base_quantity_start_date, l_base_quantity_end_date,
        l_base_quantity_ref, l_last_scenario_id, l_offer_code;

      CLOSE c_fcst_rec;

     OPEN c_get_activity_metric_id (p_forecast_id);
     FETCH c_get_activity_metric_id INTO l_activity_metric_id;
     CLOSE c_get_activity_metric_id;

    --R12 Baseline
      IF (p_base_quantity_type = 'BASELINE')
      THEN

        -- If period_level is not chosen by the user on the UI, then default it to WEEKLY
        l_period_level := NVL(p_period_level, NVL(l_period_level, 16));

        populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           l_disp_type,---'DISP'
                           p_obj_id,
                           p_start_date,
                           p_end_date,
                           l_period_level,
                           p_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           p_obj_type,---'OFFR' or 'WKST'
                           p_obj_id,
                           p_start_date,
                           p_end_date,
                           l_period_level,
                           p_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        process_baseline_forecast(p_api_version,
                          p_init_msg_list,
                          p_commit,
                          p_obj_type,
                          p_obj_id,
                          p_forecast_id,
                          l_period_level,
                          l_activity_metric_id,
                          p_fcst_uom,
                          l_return_status,
                          x_msg_count,
                          x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

          GOTO end_of_create_base_sales;
      END IF;


    --dbms_output.put_line( ' -- UPDATE FCST -- ');
      IF (p_dimention='TIME')
      THEN
        -- baseline not considered.
        IF (l_base_quantity_type = 'OFFER_CODE')
        THEN
            OPEN offer_id_csr(l_offer_code);
            FETCH offer_id_csr INTO l_offer_id;
            CLOSE offer_id_csr;

            populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           l_disp_type,
                           l_offer_id,
                           l_base_quantity_start_date,
                           l_base_quantity_end_date,
                           p_period_level,
                           p_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

            -- for get_sales() useful for period csr
            populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           p_obj_type,
                           l_offer_id,
                           l_base_quantity_start_date,
                           l_base_quantity_end_date,
                           p_period_level,
                           p_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

    --dbms_output.put_line( ' -- Update - periods 2222 -- ');
        populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           l_disp_type,
                           p_obj_id,
                           p_start_date,
                           p_end_date,
                           p_period_level,
                           p_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

        populate_fcst_periods(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           p_obj_type,
                           p_obj_id,
                           l_base_quantity_start_date,
                           l_base_quantity_end_date,
                           p_period_level,
                           p_forecast_id,
                           l_return_status,
                           x_msg_count,
                           x_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;

      IF l_fcst_uom <> FND_PROFILE.VALUE('OZF_FORECAST_DEFAULT_UOM')
      THEN
          NULL;
/*
         UPDATE ozf_act_forecasts_all
         SET base_quantity = ROUND(NVL(l_base_sales,0))
         WHERE forecast_id = p_forecast_id;
*/
      END IF;

    --dbms_output.put_line( ' -- Update -  create_fcst_facts -- ');
     -- Now create facts for the level
        -- R12 modified
        create_fcst_facts(p_api_version,
                          p_init_msg_list,
                          p_commit,
                          l_base_quantity_type,
                          p_obj_type,
                          p_obj_id,
                          p_forecast_id,
                          p_activity_metric_id,
                          p_level,
                          p_dimention,
                          p_fcst_uom,
                          l_base_quantity_start_date, --p_start_date,
                          l_base_quantity_end_date, --p_end_date,
                          l_return_status,
                          x_msg_count,
                          x_msg_data);

        IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;
    --dbms_output.put_line( ' -- Update -  allocate_facts -- ');
         allocate_facts(
                      p_api_version   ,
                      p_init_msg_list ,
                      p_commit        ,

                      p_forecast_id ,
                      p_dimention  ,

                      l_return_status  ,
                      x_msg_count      ,
                      x_msg_data       );

        IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;


  END IF; -- forecast_id null ?

--dbms_output.put_line( ' -- 13 -- ');


  <<end_of_create_base_sales>>

  IF (OZF_DEBUG_HIGH_ON) THEN

  OZF_Utility_PVT.debug_message(l_full_name || ': End Create Base Sales');

  END IF;
--dbms_output.put_line( ' -- 15 -- ');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Create_Base_Sales;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Create_Base_Sales;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN OTHERS THEN

      ROLLBACK TO Create_Base_Sales;
      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END create_base_sales;


---------------------------------------------------------------
---------------------------------------------------------------

  PROCEDURE fcst_remqty(
                        p_api_version        IN  NUMBER,
                        p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                        p_commit             IN  VARCHAR2  := FND_API.g_false,

                        p_forecast_id        IN  NUMBER,

                        x_return_status      OUT NOCOPY VARCHAR2,
                        x_msg_count          OUT NOCOPY NUMBER,
                        x_msg_data           OUT NOCOPY VARCHAR2
                       )
  IS

   l_one_f_quan NUMBER := 0;
   l_two_f_quan NUMBER := 0;
   l_three_f_quan NUMBER := 0;

   CURSOR C1(p_fcast_id IN NUMBER) IS
   SELECT activity_metric_fact_id, fact_value
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id
   AND previous_fact_id IS NULL
   AND root_fact_id IS NULL
   and nvl(node_id,1) <> 3 ;

   CURSOR C2(prev_fact_id IN NUMBER, p_used_by_id IN NUMBER) IS
   SELECT  activity_metric_fact_id, fact_value
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_used_by_id
   AND root_fact_id IS NULL
   AND previous_fact_id = prev_fact_id
   and nvl(node_id,1) <> 3 ;


   CURSOR C3(prev_fact_id IN NUMBER, p_used_by_id IN NUMBER) IS
   SELECT activity_metric_fact_id, fact_value
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_used_by_id
   AND root_fact_id IS NOT NULL
   AND previous_fact_id = prev_fact_id
   and nvl(node_id,1) <> 3;

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'Fcst_Remaining_Qty';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

 BEGIN

   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name || ': Start Fcst Remaining Qty');

   END IF;
   SAVEPOINT Fcst_Remaining_Qty;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;


   FOR record_l_one IN C1(p_forecast_id) LOOP

         l_two_f_quan := 0;

         FOR record_l_two IN C2(record_l_one.activity_metric_fact_id, p_forecast_id) LOOP
               l_three_f_quan := 0;

               FOR record_l_three IN C3(record_l_two.activity_metric_fact_id, p_forecast_id) LOOP

                l_three_f_quan := l_three_f_quan + record_l_three.fact_value;

               END LOOP;

               IF(l_three_f_quan <> 0) THEN
                 UPDATE ozf_act_metric_facts_all
                 SET FORECAST_REMAINING_QUANTITY = record_l_two.fact_value - l_three_f_quan
                 WHERE activity_metric_fact_id = record_l_two.activity_metric_fact_id;

               END IF;

               l_two_f_quan := l_two_f_quan + record_l_two.fact_value;

        END LOOP;

        IF(l_two_f_quan <> 0) THEN
          UPDATE ozf_act_metric_facts_all
          SET FORECAST_REMAINING_QUANTITY = record_l_one.fact_value - l_two_f_quan
          WHERE activity_metric_fact_id = record_l_one.activity_metric_fact_id;

        END IF;

        l_one_f_quan := l_one_f_quan + record_l_one.fact_value;

   END LOOP;

   UPDATE ozf_act_forecasts_all
   SET FORECAST_REMAINING_QUANTITY = forecast_quantity - l_one_f_quan
   WHERE forecast_id = p_forecast_id;


   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name || ': End Fcst Remaining Qty');

   END IF;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      ROLLBACK TO Fcst_Remaining_Qty;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


 END fcst_remqty;

 PROCEDURE fcst_BL_remqty(
                        p_api_version        IN  NUMBER,
                        p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                        p_commit             IN  VARCHAR2  := FND_API.g_false,

                        p_forecast_id        IN  NUMBER,

                        x_return_status      OUT NOCOPY VARCHAR2,
                        x_msg_count          OUT NOCOPY NUMBER,
                        x_msg_data           OUT NOCOPY VARCHAR2
                       )
  IS

   l_one_f_quan NUMBER := 0;
   l_two_f_quan NUMBER := 0;
   l_three_f_quan NUMBER := 0;

   CURSOR C1(p_fcast_id IN NUMBER) IS
   SELECT activity_metric_fact_id, incremental_sales
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id
   AND previous_fact_id IS NULL
   AND root_fact_id IS NULL
   and nvl(node_id,1) <> 3 ;

   CURSOR C2(prev_fact_id IN NUMBER, p_used_by_id IN NUMBER) IS
   SELECT  activity_metric_fact_id, incremental_sales
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_used_by_id
   AND root_fact_id IS NULL
   AND previous_fact_id = prev_fact_id
   and nvl(node_id,1) <> 3 ;


   CURSOR C3(prev_fact_id IN NUMBER, p_used_by_id IN NUMBER) IS
   SELECT activity_metric_fact_id, incremental_sales
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_used_by_id
   AND root_fact_id IS NOT NULL
   AND previous_fact_id = prev_fact_id
   and nvl(node_id,1) <> 3;

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'Fcst_BL_Remaining_Qty';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

 BEGIN

   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name || ': Start Fcst Baseline Remaining Qty');

   END IF;
   SAVEPOINT Fcst_BL_Remaining_Qty;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   FOR record_l_one IN C1(p_forecast_id) LOOP

         l_two_f_quan := 0;

         FOR record_l_two IN C2(record_l_one.activity_metric_fact_id, p_forecast_id) LOOP
               l_three_f_quan := 0;

               FOR record_l_three IN C3(record_l_two.activity_metric_fact_id, p_forecast_id) LOOP

                l_three_f_quan := l_three_f_quan + record_l_three.incremental_sales;

               END LOOP;

               IF(l_three_f_quan <> 0) THEN
                 UPDATE ozf_act_metric_facts_all
                 SET FORECAST_REMAINING_QUANTITY = record_l_two.incremental_sales - l_three_f_quan
                 WHERE activity_metric_fact_id = record_l_two.activity_metric_fact_id;

               END IF;

               l_two_f_quan := l_two_f_quan + record_l_two.incremental_sales;

        END LOOP;

        IF(l_two_f_quan <> 0) THEN
          UPDATE ozf_act_metric_facts_all
          SET FORECAST_REMAINING_QUANTITY = record_l_one.incremental_sales - l_two_f_quan
          WHERE activity_metric_fact_id = record_l_one.activity_metric_fact_id;

        END IF;

        l_one_f_quan := l_one_f_quan + record_l_one.incremental_sales;

   END LOOP;

   UPDATE ozf_act_forecasts_all
   SET FORECAST_REMAINING_QUANTITY = forecast_quantity - base_quantity - l_one_f_quan
   WHERE forecast_id = p_forecast_id;


   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name || ': End Fcst Remaining Qty');

   END IF;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      ROLLBACK TO Fcst_BL_Remaining_Qty;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


 END fcst_BL_remqty;

PROCEDURE freeze_check(
                       p_api_version        IN  NUMBER,
                       p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                       p_commit             IN  VARCHAR2  := FND_API.g_false,

                       p_forecast_id        IN NUMBER,

                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2
                      )
  IS

  CURSOR C_FcstRecord(p_fcast_id IN NUMBER) IS
     SELECT forecast_remaining_quantity
     FROM ozf_act_forecasts_all
     WHERE forecast_id = p_fcast_id;

  CURSOR C_LevelOneRecords(p_fcast_id IN NUMBER) IS
     SELECT activity_metric_fact_id, fact_type, forecast_remaining_quantity
     FROM ozf_act_metric_facts_all
     WHERE arc_act_metric_used_by = 'FCST'
     AND act_metric_used_by_id = p_fcast_id
     AND previous_fact_id IS NULL
     AND root_fact_id IS NULL;

  CURSOR C_LevelTwoRecords(p_fcast_id IN NUMBER, p_prev_id IN NUMBER) IS
     SELECT activity_metric_fact_id, fact_type, forecast_remaining_quantity
     FROM ozf_act_metric_facts_all
     WHERE arc_act_metric_used_by = 'FCST'
     AND act_metric_used_by_id = p_fcast_id
     AND previous_fact_id IS NOT NULL
     AND root_fact_id IS NULL
     AND previous_fact_id = p_prev_id;

  -- variable to hold the forecast_remaining_quantity for forecast record
  l_fcast_remaining_qty NUMBER := 0;
  l_flag_fcst boolean := false;
  l_flag_level_one boolean := false;
  l_flag_level_two boolean := false;
  l_flag_error boolean := false;
  l_dimention1 VARCHAR2(9);
  l_dimention2 VARCHAR2(9);


  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'Freeze_Check';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

   BEGIN

   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name || ': Start Freeze Check');

   END IF;
   SAVEPOINT freeze_check;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

  --  Check if the forecast_remaining_quantity (=0 or not) for the forecast record
   OPEN C_FcstRecord(p_forecast_id);
   FETCH C_FcstRecord INTO l_fcast_remaining_qty ;
   CLOSE C_FcstRecord;

   IF (l_fcast_remaining_qty <> 0) THEN
        l_flag_fcst := true;
        l_flag_error := true;
   END IF;


   FOR level_one_record IN C_LevelOneRecords(p_forecast_id) LOOP
     -- See if we can have an array and store the
     -- activity_metric_fact_id's of those recs for which forecast_remaining_quantity <> 0

      IF (level_one_record.forecast_remaining_quantity <> 0) THEN
           l_flag_level_one := true;
           l_flag_error := true;
           l_dimention1 := level_one_record.fact_type;
      END IF;

      FOR level_two_record IN C_LevelTwoRecords(p_forecast_id, level_one_record.activity_metric_fact_id) LOOP
         IF (level_two_record.forecast_remaining_quantity <> 0) THEN
             l_flag_level_two := true;
             l_flag_error := true;
             l_dimention2 := level_two_record.fact_type;
         END IF;
      END LOOP;
   END LOOP;


   IF (l_flag_error = true) THEN
      -- forecast_remaining_quantity <> 0 for some record
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

          IF (l_flag_fcst = true) THEN
           FND_MESSAGE.Set_Name ('OZF', 'OZF_FCST_HEADER_QTY_REMAINING');
           FND_MSG_PUB.Add;
          END IF;

          IF (l_flag_level_one = true) THEN
           FND_MESSAGE.Set_Name ('OZF', 'OZF_FCST_LEVEL_QTY_REMAINING');
           FND_MESSAGE.Set_Token('DIMENTION', l_dimention1 );
           FND_MSG_PUB.Add;
          END IF;

          IF (l_flag_level_two = true) THEN
           FND_MESSAGE.Set_Name ('OZF', 'OZF_FCST_LEVEL_QTY_REMAINING');
           FND_MESSAGE.Set_Token('DIMENTION', l_dimention2 );
           FND_MSG_PUB.Add;
          END IF;

       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name || ': End Freeze Check');

   END IF;

   EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO freeze_check;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


  END freeze_check;



  --Procedure for creating a copy of an existing forecast
   PROCEDURE copy_forecast(
                            p_api_version        IN  NUMBER,
                            p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                            p_commit             IN  VARCHAR2  := FND_API.g_false,
                            p_forecast_id        IN   NUMBER,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_msg_count          OUT NOCOPY NUMBER,
                            x_msg_data           OUT NOCOPY VARCHAR2
                           )
  IS

  -- cursor to generate new Forecast ID's
  CURSOR c_act_forecast_id IS
   SELECT ozf_act_forecasts_all_s.NEXTVAL
   FROM   dual;

  -- cursor to generate new Activity Metric ID's
  CURSOR c_act_metric_id IS
   SELECT ozf_act_metrics_all_s.NEXTVAL
   FROM   dual;

  -- obtain the activity_metric_id based on a given forecast_id
  CURSOR c_get_activity_metric_id(p_fcast_id IN NUMBER) IS
   SELECT activity_metric_id
   FROM ozf_act_metrics_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id;


  CURSOR C_GetFactsLevelOne(p_fcast_id IN NUMBER, p_activity_metric_id IN NUMBER) IS
   SELECT activity_metric_fact_id,
          fact_type,
          base_quantity,
          fact_reference,
          from_date,
          to_date,
          fact_value,
          fact_percent,
          previous_fact_id,
          root_fact_id,
          forecast_remaining_quantity,
          forward_buy_quantity,
          node_id
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id
   AND activity_metric_id = p_activity_metric_id
   AND root_fact_id IS NULL
   AND previous_fact_id IS NULL;

  CURSOR C_GetFactsLevelTwo(p_fcast_id IN NUMBER, p_activity_metric_id IN NUMBER, p_previous_fact_id IN NUMBER) IS
   SELECT activity_metric_fact_id,
          fact_type,
          base_quantity,
          fact_reference,
          from_date,
          to_date,
          fact_value,
          fact_percent,
          previous_fact_id,
          root_fact_id,
          forecast_remaining_quantity,
          forward_buy_quantity,
          node_id
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id
   AND activity_metric_id = p_activity_metric_id
   AND root_fact_id IS NULL
   AND previous_fact_id IS NOT NULL
   AND previous_fact_id = p_previous_fact_id;

  CURSOR C_GetFactsLevelThree(p_fcast_id IN NUMBER, p_activity_metric_id IN NUMBER,
                              p_previous_fact_id IN NUMBER, p_root_fact_id IN NUMBER) IS
   SELECT activity_metric_fact_id,
          fact_type,
          base_quantity,
          fact_reference,
          from_date,
          to_date,
          fact_value,
          fact_percent,
          previous_fact_id,
          root_fact_id,
          forecast_remaining_quantity,
          forward_buy_quantity,
          node_id
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id
   AND activity_metric_id = p_activity_metric_id
   AND previous_fact_id = p_previous_fact_id
   AND root_fact_id = p_root_fact_id;

  l_forecast_id NUMBER := 0;
  l_activity_metric_id NUMBER := 0;
  l_previous_activity_metric_id NUMBER := 0;
  l_act_metric_fact_id_level_1 NUMBER := 0;
  l_act_metric_fact_id_level_2 NUMBER := 0;
  l_act_metric_fact_id_level_3 NUMBER := 0;


  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'copy_forecast';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);


  BEGIN

    SAVEPOINT copy_forecast;

    IF (OZF_DEBUG_HIGH_ON) THEN

    OZF_Utility_PVT.debug_message(l_full_name || ': start refresh parties');

    END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;


  -- Insert a new forecast record in the ozf_act_forecasts_all table taking the given forecastId as input
  OPEN c_act_forecast_id;
  FETCH c_act_forecast_id INTO l_forecast_id;
  CLOSE c_act_forecast_id;

  INSERT INTO ozf_act_forecasts_all
              (forecast_id
              ,forecast_type
              ,arc_act_fcast_used_by
              ,act_fcast_used_by_id
              ,creation_date
              ,created_from
              ,created_by
              ,last_update_date
              ,last_updated_by
              ,last_update_login
              ,program_application_id
              ,program_id
              ,program_update_date
              ,request_id
              ,object_version_number
              ,hierarchy
              ,hierarchy_level
              ,level_value
              ,forecast_calendar
              ,period_level
              ,forecast_period_id
              ,forecast_date
              ,forecast_uom_code
              ,forecast_quantity
              ,forward_buy_quantity
              ,forward_buy_period
              ,base_quantity
              ,context
              ,attribute_category
              ,org_id
              ,forecast_remaining_quantity
              ,forecast_remaining_percent
              ,base_quantity_type
              ,forecast_spread_type
              ,dimention1
              ,dimention2
              ,dimention3
              ,last_scenario_id
              ,freeze_flag
              ,price_list_id
              ,base_quantity_start_date
              ,base_quantity_end_date
              ,base_quantity_ref
              ,offer_code
              )
   SELECT     l_forecast_id
              ,a.forecast_type
              ,a.arc_act_fcast_used_by
              ,a.act_fcast_used_by_id
              ,SYSDATE
              ,a.created_from
              ,FND_GLOBAL.User_ID
              ,SYSDATE
              ,FND_GLOBAL.User_ID
              ,FND_GLOBAL.Conc_Login_ID
              ,a.program_application_id
              ,a.program_id
              ,a.program_update_date
              ,a.request_id
              ,1 --object_version_number
              ,a.hierarchy
              ,a.hierarchy_level
              ,a.level_value
              ,a.forecast_calendar
              ,a.period_level
              ,a.forecast_period_id
              ,a.forecast_date
              ,a.forecast_uom_code
              ,a.forecast_quantity
              ,a.forward_buy_quantity
              ,a.forward_buy_period
              ,a.base_quantity
              ,a.context
              ,a.attribute_category
              ,MO_GLOBAL.GET_CURRENT_ORG_ID()-- org_id
              ,a.forecast_remaining_quantity
              ,a.forecast_remaining_percent
              ,a.base_quantity_type
              ,a.forecast_spread_type
              ,a.dimention1
              ,a.dimention2
              ,a.dimention3
              ,a.last_scenario_id + 1
              ,'N'
              ,a.price_list_id
              ,a.base_quantity_start_date
              ,a.base_quantity_end_date
              ,a.base_quantity_ref
              ,a.offer_code
    FROM ozf_act_forecasts_all a
    WHERE forecast_id = p_forecast_id;


   -- Insert a new activity metric record in the ozf_act_metrics_all table taking the given forecastId as input

   OPEN c_act_metric_id;
   FETCH c_act_metric_id INTO l_activity_metric_id;
   CLOSE c_act_metric_id;

   INSERT INTO ozf_act_metrics_all (
         activity_metric_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         object_version_number,
         act_metric_used_by_id,
         arc_act_metric_used_by,
         purchase_req_raised_flag,
         application_id,
         sensitive_data_flag,
         budget_id,
         metric_id,
         transaction_currency_code,
         trans_forecasted_value,
         trans_committed_value,
         trans_actual_value,
         functional_currency_code,
         func_forecasted_value,
         dirty_flag,
         func_committed_value,
         func_actual_value,
         last_calculated_date,
         variable_value,
         computed_using_function_value,
         metric_uom_code,
         org_id,
         attribute_category,
         difference_since_last_calc,
         activity_metric_origin_id,
         arc_activity_metric_origin,
         days_since_last_refresh,
         scenario_id,
         SUMMARIZE_TO_METRIC,
         hierarchy_id,
         start_node,
         from_level,
         to_level,
         from_date,
         TO_DATE,
         amount1,
         amount2,
         amount3,
         percent1,
         percent2,
         percent3,
         published_flag,
         pre_function_name,
         post_function_name,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         description,
         act_metric_date,
         depend_act_metric
   )

   SELECT l_activity_metric_id,
          SYSDATE,
          Fnd_Global.User_ID,
          SYSDATE,
          Fnd_Global.User_ID,
          Fnd_Global.Conc_Login_ID,
          1, --Object Version Number
          l_forecast_id,
          b.arc_act_metric_used_by,
          NVL(b.purchase_req_raised_flag,'N'),
          b.application_id,
          b.sensitive_data_flag,
          b.budget_id,
          b.metric_id,
          b.transaction_currency_code,
          b.trans_forecasted_value,
          b.trans_committed_value,
          b.trans_actual_value,
          b.functional_currency_code,
          b.func_forecasted_value,
          NVL(b.dirty_flag,'Y'),
          b.func_committed_value,
          b.func_actual_value,
          b.last_calculated_date,
          b.variable_value,
          b.computed_using_function_value,
          b.metric_uom_code,
          MO_GLOBAL.GET_CURRENT_ORG_ID() , -- org_id
          b.attribute_category,
          b.difference_since_last_calc,
          b.activity_metric_origin_id,
          b.arc_activity_metric_origin,
          b.days_since_last_refresh,
          b.scenario_id,
          b.SUMMARIZE_TO_METRIC,
          b.hierarchy_id,
          b.start_node,
          b.from_level,
          b.to_level,
          b.from_date,
          b.TO_DATE,
          b.amount1,
          b.amount2,
          b.amount3,
          b.percent1,
          b.percent2,
          b.percent3,
          b.published_flag,
          b.pre_function_name,
          b.post_function_name,
          b.attribute1,
          b.attribute2,
          b.attribute3,
          b.attribute4,
          b.attribute5,
          b.attribute6,
          b.attribute7,
          b.attribute8,
          b.attribute9,
          b.attribute10,
          b.attribute11,
          b.attribute12,
          b.attribute13,
          b.attribute14,
          b.attribute15,
          b.description,
          b.act_metric_date,
          b.depend_act_metric
   FROM ozf_act_metrics_all b
   WHERE act_metric_used_by_id = p_forecast_id
   AND arc_act_metric_used_by = 'FCST';

  -- Insert new row in the ozf_act_metric_facts_all table for
  -- each existing row in ozf_act_metric_facts_all (based on a given act_metric_used_by_id and activity_metric_id)

   OPEN c_get_activity_metric_id(p_forecast_id);
   FETCH c_get_activity_metric_id INTO l_previous_activity_metric_id;
   CLOSE c_get_activity_metric_id;

  -- Looping through existing level one fact records and inserting new level one records
   FOR level_one_fact_record IN C_GetFactsLevelOne(
                                                   p_forecast_id,
                                                   l_previous_activity_metric_id
                                                  )
   LOOP
     -- generating activity_metric_fact_id for each record in Level One with the sequence
     --l_act_metric_fact_id_level_1 := ozf_act_metric_facts_all_s.nextval;
     SELECT ozf_act_metric_facts_all_s.nextval INTO l_act_metric_fact_id_level_1 FROM dual;

     INSERT INTO ozf_act_metric_facts_all (
                   ACTIVITY_METRIC_FACT_ID ,
                   LAST_UPDATE_DATE ,
                   LAST_UPDATED_BY,
                   CREATION_DATE,
                   CREATED_BY,
                   OBJECT_VERSION_NUMBER,
                   ACT_METRIC_USED_BY_ID,
                   ARC_ACT_METRIC_USED_BY,
                   VALUE_TYPE,
                   ACTIVITY_METRIC_ID,
                   TRANS_FORECASTED_VALUE,
                   FUNCTIONAL_CURRENCY_CODE,
                   FUNC_FORECASTED_VALUE,
                   ORG_ID,
                   DE_METRIC_ID,
                   TIME_ID1,
                   FROM_DATE,
                   TO_DATE,
                   FACT_VALUE,
                   FACT_PERCENT,
                   BASE_QUANTITY,
                   ROOT_FACT_ID,
                   PREVIOUS_FACT_ID,
                   FACT_TYPE,
                   FACT_REFERENCE,
                   last_update_login,
                   FORECAST_REMAINING_QUANTITY,
                   FORWARD_BUY_QUANTITY,
                   NODE_ID
                   )
      VALUES  (    l_act_metric_fact_id_level_1,
                   SYSDATE,
                   Fnd_Global.User_ID,
                   SYSDATE,
                   Fnd_Global.User_ID,
                   1,
                   l_forecast_id,
                   'FCST',
                   'NUMERIC',
                   l_activity_metric_id,
                   0,
                   'NONE',
                   0,
                   MO_GLOBAL.GET_CURRENT_ORG_ID(),
                   0,
                   0,
                   level_one_fact_record.from_date,
                   level_one_fact_record.to_date,
                   level_one_fact_record.fact_value,
                   level_one_fact_record.fact_percent,
                   NVL(level_one_fact_record.base_quantity,0),
                   level_one_fact_record.root_fact_id, -- will be NULL
                   level_one_fact_record.previous_fact_id, -- will be NULL
                   level_one_fact_record.fact_type,
                   level_one_fact_record.fact_reference,
                   fnd_global.login_id,
                   level_one_fact_record.forecast_remaining_quantity,
                   level_one_fact_record.forward_buy_quantity,
                   level_one_fact_record.node_id
               );

      -- loop through each existing record in Level Two (for a given previous_fact_id)
      -- and insert new level two record for each one of them
       FOR level_two_fact_record IN C_GetFactsLevelTwo(
                                                       p_forecast_id,
                                                       l_previous_activity_metric_id,
                                                       level_one_fact_record.activity_metric_fact_id -- previous_fact_id
                                                       )
       LOOP

       -- generating activity_metric_fact_id for each record in Level Two with the sequence
         --l_act_metric_fact_id_level_2 := ozf_act_metric_facts_all_s.nextval;
         SELECT ozf_act_metric_facts_all_s.nextval INTO l_act_metric_fact_id_level_2 FROM dual;

         INSERT INTO ozf_act_metric_facts_all (
                   ACTIVITY_METRIC_FACT_ID ,
                   LAST_UPDATE_DATE ,
                   LAST_UPDATED_BY,
                   CREATION_DATE,
                   CREATED_BY,
                   OBJECT_VERSION_NUMBER,
                   ACT_METRIC_USED_BY_ID,
                   ARC_ACT_METRIC_USED_BY,
                   VALUE_TYPE,
                   ACTIVITY_METRIC_ID,
                   TRANS_FORECASTED_VALUE,
                   FUNCTIONAL_CURRENCY_CODE,
                   FUNC_FORECASTED_VALUE,
                   ORG_ID,
                   DE_METRIC_ID,
                   TIME_ID1,
                   FROM_DATE,
                   TO_DATE,
                   FACT_VALUE,
                   FACT_PERCENT,
                   BASE_QUANTITY,
                   ROOT_FACT_ID,
                   PREVIOUS_FACT_ID,
                   FACT_TYPE,
                   FACT_REFERENCE,
                   last_update_login,
                   FORECAST_REMAINING_QUANTITY,
                   FORWARD_BUY_QUANTITY,
                   NODE_ID
                   )
         VALUES  ( l_act_metric_fact_id_level_2,
                   SYSDATE,
                   Fnd_Global.User_ID,
                   SYSDATE,
                   Fnd_Global.User_ID,
                   1,
                   l_forecast_id,
                   'FCST',
                   'NUMERIC',
                   l_activity_metric_id,
                   0,
                   'NONE',
                   0,
                   MO_GLOBAL.GET_CURRENT_ORG_ID(),
                   0,
                   0,
                   level_two_fact_record.from_date,
                   level_two_fact_record.to_date,
                   level_two_fact_record.fact_value,
                   level_two_fact_record.fact_percent,
                   NVL(level_two_fact_record.base_quantity,0),
                   level_two_fact_record.root_fact_id, -- will be NULL
                   l_act_metric_fact_id_level_1, -- newly generated Level One activity_metric_fact_id
                   level_two_fact_record.fact_type,
                   level_two_fact_record.fact_reference,
                   fnd_global.login_id,
                   level_two_fact_record.forecast_remaining_quantity,
                   level_two_fact_record.forward_buy_quantity,
                   level_two_fact_record.node_id
                 );


       -- loop through each existing record in Level Three( for a given previous_fact_id and root_fact_id)
       -- and insert new level three record for each one of them
       FOR level_three_fact_record IN C_GetFactsLevelThree(
                                                           p_forecast_id,
                                                           l_previous_activity_metric_id,
                                                           level_two_fact_record.activity_metric_fact_id,
                                                           level_one_fact_record.activity_metric_fact_id
                                                          )
       LOOP

       -- generating activity_metric_fact_id for each new record in Level Three with the sequence
         --l_act_metric_fact_id_level_3 := ozf_act_metric_facts_all_s.nextval;
         SELECT ozf_act_metric_facts_all_s.nextval INTO l_act_metric_fact_id_level_3 FROM dual;

         INSERT INTO ozf_act_metric_facts_all (
                   ACTIVITY_METRIC_FACT_ID ,
                   LAST_UPDATE_DATE ,
                   LAST_UPDATED_BY,
                   CREATION_DATE,
                   CREATED_BY,
                   OBJECT_VERSION_NUMBER,
                   ACT_METRIC_USED_BY_ID,
                   ARC_ACT_METRIC_USED_BY,
                   VALUE_TYPE,
                   ACTIVITY_METRIC_ID,
                   TRANS_FORECASTED_VALUE,
                   FUNCTIONAL_CURRENCY_CODE,
                   FUNC_FORECASTED_VALUE,
                   ORG_ID,
                   DE_METRIC_ID,
                   TIME_ID1,
                   FROM_DATE,
                   TO_DATE,
                   FACT_VALUE,
                   FACT_PERCENT,
                   BASE_QUANTITY,
                   ROOT_FACT_ID,
                   PREVIOUS_FACT_ID,
                   FACT_TYPE,
                   FACT_REFERENCE,
                   last_update_login,
                   FORECAST_REMAINING_QUANTITY,
                   FORWARD_BUY_QUANTITY,
                   NODE_ID
                   )
         VALUES  ( l_act_metric_fact_id_level_3,
                   SYSDATE,
                   Fnd_Global.User_ID,
                   SYSDATE,
                   Fnd_Global.User_ID,
                   1,
                   l_forecast_id,
                   'FCST',
                   'NUMERIC',
                   l_activity_metric_id,
                   0,
                   'NONE',
                   0,
                   MO_GLOBAL.GET_CURRENT_ORG_ID(),
                   0,
                   0,
                   level_three_fact_record.from_date,
                   level_three_fact_record.to_date,
                   level_three_fact_record.fact_value,
                   level_three_fact_record.fact_percent,
                   NVL(level_three_fact_record.base_quantity,0),
                   l_act_metric_fact_id_level_1, -- newly generated Level One activity_metric_fact_id
                   l_act_metric_fact_id_level_2, -- newly generated Level Two activity_metric_fact_id
                   level_three_fact_record.fact_type,
                   level_three_fact_record.fact_reference,
                   fnd_global.login_id,
                   level_three_fact_record.forecast_remaining_quantity,
                   level_three_fact_record.forward_buy_quantity,
                   level_three_fact_record.node_id
                 );

         END LOOP; -- end of level three loop

       END LOOP; -- end of level two loop

   END LOOP; -- end of level one loop



   EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      ROLLBACK TO copy_forecast;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);




   END copy_forecast;



  PROCEDURE cascade_update(
                           p_api_version        IN  NUMBER,
                           p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                           p_commit             IN  VARCHAR2  := FND_API.g_false,

                           p_id                 IN   NUMBER,
                           p_value              IN   NUMBER,
                           p_fwd_buy_value      IN   NUMBER,
                           p_fcast_id           IN   NUMBER,
                           p_cascade_flag       IN   NUMBER,

                           x_return_status      OUT NOCOPY VARCHAR2,
                           x_msg_count          OUT NOCOPY NUMBER,
                           x_msg_data           OUT NOCOPY VARCHAR2
                           )
  IS

  l_fact_percent NUMBER := 0;
  l_fact_value NUMBER := 0;
  l_forward_buy_quantity NUMBER := 0;
  l_parent_fact_value NUMBER := 0;
  l_parent_fwd_buy_qty NUMBER := 0;
  l_temp_parent_fact_value NUMBER := 0;
  l_temp_parent_fwd_buy_qty NUMBER := 0;
  l_fcst_remaining_quantity NUMBER := 0;
  l_cascade_flag NUMBER := 0;

  l_temp_count NUMBER := 0;
  l_temp_sub_count NUMBER := 0;
  l_temp_counter NUMBER := 0;
  l_temp_sub_counter NUMBER := 0;
  l_fval_sum_minus_last_rec NUMBER := 0;
  l_fwdbuy_sum_minus_last_rec NUMBER := 0;
  l_fwd_buy_sum_all_recs NUMBER := 0;
  l_fwd_buy_sum_all_sub_recs NUMBER := 0;
  l_temp_previous_fact_id NUMBER := 1;
  l_temp_sub_previous_fact_id NUMBER := 1;



  CURSOR C_FindRecords(p_prev_id IN NUMBER,
                       p_fcast_id IN NUMBER ) IS
  SELECT activity_metric_fact_id,
                 previous_fact_id,
                 forecast_remaining_quantity,
                 fact_type,
                 fact_reference,
                 from_date,
                 to_date,
                 fact_value,
                 fact_percent,
                 root_fact_id,
                 forward_buy_quantity
  FROM ozf_act_metric_facts_all
  WHERE arc_act_metric_used_by = 'FCST'
  AND act_metric_used_by_id = p_fcast_id
  AND previous_fact_id = p_prev_id
  order by 6; -- added this on 04/09/02 for Forward Buy calculations for TIME


  CURSOR C_FindSubRecords(p_prev_id IN NUMBER,
                          p_fcast_id IN NUMBER ) IS
  SELECT activity_metric_fact_id,
                 previous_fact_id,
                 fact_type,
                 fact_reference,
                 from_date,
                 to_date,
                 fact_value,
                 fact_percent,
                 root_fact_id,
                 forward_buy_quantity
  FROM ozf_act_metric_facts_all
  WHERE arc_act_metric_used_by = 'FCST'
  AND act_metric_used_by_id = p_fcast_id
  AND previous_fact_id = p_prev_id
  AND root_fact_id IS NOT NULL
  order by 6; -- added this on 04/09/02 for Forward Buy calculations for TIME

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'Cascade_Update';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  BEGIN

  --  IF (OZF_DEBUG_HIGH_ON) THEN    OZF_Utility_PVT.debug_message(l_full_name || ': start refresh parties');  END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


 IF (p_cascade_flag = 4) THEN
   -- Cascade_Update called on its own (not from Cascade_Level_One)

   -- Get the fact value and forward buy qty of parent from database and compare them with the input API values.
    -- There can be 4 scenarios:
    -- 1. None of the values have been changed on UI (could happen when they change and reset back to previous values )
            -- so, dont need to do anything, i.e. DO NOT CASCADE (set l_cascade_flag = 0)
    -- 2. Just the fact value has been changed on UI (UI fact value different from database fact value)
            -- so, just cascade down the fact value change (set l_cascade_flag = 1)
    -- 3. Just the forward buy value has been changed on UI (UI forward buy value different from database forward buy value)
            -- so, just cascade down the forward buy value change (set l_cascade_flag = 2)
    -- 4. Both the fact value and forward buy changed on UI
            -- so, cascade down both the value changes. (set l_cascade_flag = 3)


   -- Get the fact value and forward buy value for the parent
   SELECT fact_value, forward_buy_quantity
   INTO l_parent_fact_value, l_parent_fwd_buy_qty
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id
   AND activity_metric_fact_id = p_id;

   IF ( (p_value = l_parent_fact_value) AND (p_fwd_buy_value = l_parent_fwd_buy_qty) ) THEN
      l_cascade_flag := 0;
   ELSIF ( (p_value <> l_parent_fact_value) AND (p_fwd_buy_value = l_parent_fwd_buy_qty) ) THEN
      l_cascade_flag := 1;
   ELSIF ( (p_value = l_parent_fact_value) AND (p_fwd_buy_value <> l_parent_fwd_buy_qty) ) THEN
      l_cascade_flag := 2;
   ELSIF ( (p_value <> l_parent_fact_value) AND (p_fwd_buy_value <> l_parent_fwd_buy_qty) ) THEN
      l_cascade_flag := 3;
   END IF;

 ELSIF (p_cascade_flag <> 4) THEN
   -- Cascade_Update called from Cascade_Level_One procedure
   l_cascade_flag := p_cascade_flag;

 END IF;

   ----dbms_output.put_line('l_cascade_flag before entering 1st loop ' || l_cascade_flag );

   --Only do something if values have been changed
   IF ( l_cascade_flag <> 0 ) THEN

    -- Loop through possible existing second level facts
    FOR facts_record IN C_FindRecords(p_id, p_fcast_id) LOOP
     ----dbms_output.put_line('Entered 1st loop ' );

     IF (l_temp_previous_fact_id <> facts_record.previous_fact_id) THEN
         SELECT count(*), sum(forward_buy_quantity)
         INTO l_temp_count, l_fwd_buy_sum_all_recs
         FROM ozf_act_metric_facts_all
         WHERE arc_act_metric_used_by = 'FCST'
         AND act_metric_used_by_id = p_fcast_id
         AND previous_fact_id = facts_record.previous_fact_id;

         SELECT forecast_remaining_quantity INTO l_fcst_remaining_quantity
         FROM ozf_act_metric_facts_all
         WHERE arc_act_metric_used_by = 'FCST'
         AND act_metric_used_by_id = p_fcast_id
         AND activity_metric_fact_id = facts_record.previous_fact_id;

         ----dbms_output.put_line('The count with previous_fact_id ' || facts_record.previous_fact_id || ' is ' || l_temp_count);
         l_temp_previous_fact_id := facts_record.previous_fact_id;
     END IF;

      -- Increment the counter to check for the last record in each set
     l_temp_counter := l_temp_counter + 1;

     IF ( (l_temp_counter <> l_temp_count) OR (l_fcst_remaining_quantity <> 0) ) THEN

        -- this check is true when last rec reached and this if loop entered, so set counter = 0
        IF ( l_temp_counter = l_temp_count) THEN
           l_temp_counter := 0;
        END IF;

        IF (l_cascade_flag = 1) THEN
           l_fact_value := round(p_value * facts_record.fact_percent * .01);
           IF (p_value <> 0) THEN
               l_fact_percent := l_fact_value * 100 / p_value;
           ELSIF (p_value = 0) THEN
               l_fact_percent := facts_record.fact_percent;
           END IF;

           -- forward buy remains unchanged
           l_forward_buy_quantity := facts_record.forward_buy_quantity;

        ELSIF (l_cascade_flag = 2) THEN
         -- Changed on 04/09/02
         IF ( (facts_record.fact_type = 'TIME') AND (l_temp_counter <> l_temp_count) ) THEN
             l_forward_buy_quantity := 0;
         ELSIF ( (facts_record.fact_type = 'TIME') AND (l_temp_counter = l_temp_count) ) THEN
             l_forward_buy_quantity := p_fwd_buy_value;
         ELSE
           IF (l_fwd_buy_sum_all_recs <> 0) THEN
               l_forward_buy_quantity := (facts_record.forward_buy_quantity * p_fwd_buy_value) / l_fwd_buy_sum_all_recs;
           ELSIF (l_fwd_buy_sum_all_recs = 0) THEN
               -- for time being, assigning the values equally (if all of the child recs have 0's)
               -- l_forward_buy_quantity := p_fwd_buy_value / l_temp_count; -- Commented on 04/09/02
               l_forward_buy_quantity := p_fwd_buy_value * facts_record.fact_percent * .01;
           END IF;
         END IF;

         -- fact value and fact percent remain unchanged
         l_fact_value := facts_record.fact_value;
         l_fact_percent := facts_record.fact_percent;

        ELSIF (l_cascade_flag = 3) THEN
           l_fact_value := round(p_value * facts_record.fact_percent * .01);

           IF (p_value <> 0) THEN
               l_fact_percent := l_fact_value * 100 / p_value;
           ELSIF (p_value = 0) THEN
               l_fact_percent := facts_record.fact_percent;
           END IF;

           -- changed on 04/09/02
           IF ( (facts_record.fact_type = 'TIME') AND (l_temp_counter <> l_temp_count) ) THEN
             l_forward_buy_quantity := 0;
           ELSIF ( (facts_record.fact_type = 'TIME') AND (l_temp_counter = l_temp_count) ) THEN
             l_forward_buy_quantity := p_fwd_buy_value;
           ELSE
             IF (l_fwd_buy_sum_all_recs <> 0) THEN
               l_forward_buy_quantity := (facts_record.forward_buy_quantity * p_fwd_buy_value) / l_fwd_buy_sum_all_recs;
             ELSIF (l_fwd_buy_sum_all_recs = 0) THEN
               -- for time being, assigning the values equally (if all of the child recs have 0's)
               -- l_forward_buy_quantity := p_fwd_buy_value / l_temp_count; -- Commented on 04/09/02
               l_forward_buy_quantity := p_fwd_buy_value * facts_record.fact_percent * .01;
             END IF;
           END IF;

        END IF;

        -- Not the last record with this given previous_fact_id.
        -- So do a normal update of fact_percent and fact_value
        -- this will also work for the last record if the RemainingFcstQty of its parent <> 0

        ----dbms_output.put_line('Update 1st : factVal = ' || l_fact_value || ' Perc ' || round(l_fact_percent,4) ||' fwd ' || round(l_forward_buy_quantity));

        UPDATE ozf_act_metric_facts_all
        SET fact_value = l_fact_value,
            fact_percent = round(l_fact_percent,4),
            forward_buy_quantity = round(l_forward_buy_quantity)
        WHERE activity_metric_fact_id = facts_record.activity_metric_fact_id;

        l_temp_parent_fact_value := l_fact_value;
        l_temp_parent_fwd_buy_qty := round(l_forward_buy_quantity);


     ELSIF ( (l_temp_counter = l_temp_count) AND (l_fcst_remaining_quantity = 0) ) THEN

        -- Last record in the current set with the given previous_fact_id.
        -- Counter reset to 0 for the next set of records with another previous_fact_id
        -- this will only work for the last record if the RemainingFcstQty of its parent = 0
        -- this logic is needed so that RemainingFcstQty is never negative
        l_temp_counter := 0;

        --Calculating the l_fval_sum_minus_last_rec since this is the last record in this set
        SELECT NVL(sum(fact_value),0), NVL(sum(forward_buy_quantity),0)
        INTO l_fval_sum_minus_last_rec, l_fwdbuy_sum_minus_last_rec
        FROM   ozf_act_metric_facts_all
        WHERE  arc_act_metric_used_by = 'FCST'
        AND act_metric_used_by_id = p_fcast_id
        AND previous_fact_id = facts_record.previous_fact_id
        AND activity_metric_fact_id <> facts_record.activity_metric_fact_id ;

        IF (l_cascade_flag = 1) THEN
           l_fact_value := round(p_value - l_fval_sum_minus_last_rec);
           IF (p_value <> 0) THEN
               l_fact_percent := l_fact_value * 100 / p_value;
           ELSIF (p_value = 0) THEN
               l_fact_percent := facts_record.fact_percent;
           END IF;

           -- forward buy remains unchanged
           l_forward_buy_quantity := facts_record.forward_buy_quantity;
        ELSIF (l_cascade_flag = 2) THEN
           l_forward_buy_quantity := round(p_fwd_buy_value - l_fwdbuy_sum_minus_last_rec);

           -- fact value and fact percent remain unchanged
           l_fact_value := facts_record.fact_value;
           l_fact_percent := facts_record.fact_percent;
        ELSIF (l_cascade_flag = 3) THEN
           l_fact_value := round(p_value - l_fval_sum_minus_last_rec);
           IF (p_value <> 0) THEN
               l_fact_percent := l_fact_value * 100 / p_value;
           ELSIF (p_value = 0) THEN
               l_fact_percent := facts_record.fact_percent;
           END IF;

           l_forward_buy_quantity := round(p_fwd_buy_value - l_fwdbuy_sum_minus_last_rec);
        END IF;

        ----dbms_output.put_line('Update: factVal = ' || l_fact_value || ' Perc ' || round(l_fact_percent,4) || ' fwd ' || round(l_forward_buy_quantity));

        UPDATE ozf_act_metric_facts_all
        SET fact_value = l_fact_value,
            fact_percent = round(l_fact_percent,4),
            forward_buy_quantity = l_forward_buy_quantity
        WHERE activity_metric_fact_id = facts_record.activity_metric_fact_id;

        l_temp_parent_fact_value := l_fact_value;
        l_temp_parent_fwd_buy_qty := l_forward_buy_quantity;

     END IF;

       -- -- Loop through possible existing third level facts
        FOR facts_subrecord IN C_FindSubRecords(facts_record.activity_metric_fact_id, p_fcast_id) LOOP

           IF (l_temp_sub_previous_fact_id <> facts_subrecord.previous_fact_id) THEN
                SELECT count(*), sum(forward_buy_quantity)
                INTO l_temp_sub_count, l_fwd_buy_sum_all_sub_recs
                FROM ozf_act_metric_facts_all
                WHERE arc_act_metric_used_by = 'FCST'
                AND act_metric_used_by_id = p_fcast_id
                AND previous_fact_id = facts_subrecord.previous_fact_id
                AND root_fact_id IS NOT NULL;

              ----dbms_output.put_line('The count with previous_fact_id ' || facts_subrecord.previous_fact_id || ' is ' || l_temp_count);
                l_temp_sub_previous_fact_id := facts_subrecord.previous_fact_id;
           END IF;

           -- Increment the counter to check for the last record in each set
           l_temp_sub_counter := l_temp_sub_counter + 1;

           IF ( (l_temp_sub_counter <> l_temp_sub_count) OR (facts_record.forecast_remaining_quantity <> 0) ) THEN

             -- this check is true when last rec reached and this if loop entered, so set counter = 0
             IF ( l_temp_sub_counter = l_temp_sub_count) THEN
                l_temp_sub_counter := 0;
             END IF;

             IF (l_cascade_flag = 1) THEN
                l_fact_value := round(l_temp_parent_fact_value * facts_subrecord.fact_percent * .01);
                IF (l_temp_parent_fact_value <> 0) THEN
                   l_fact_percent := l_fact_value * 100 / l_temp_parent_fact_value;
                ELSIF (l_temp_parent_fact_value = 0) THEN
                   l_fact_percent := facts_subrecord.fact_percent;
                END IF;

                -- forward buy remains unchanged
                l_forward_buy_quantity := facts_subrecord.forward_buy_quantity;

             ELSIF (l_cascade_flag = 2) THEN
               -- Changed on 04/09/02
               IF ( (facts_subrecord.fact_type = 'TIME') AND (l_temp_sub_counter <> l_temp_sub_count) ) THEN
                   l_forward_buy_quantity := 0;
               ELSIF ( (facts_subrecord.fact_type = 'TIME') AND (l_temp_sub_counter = l_temp_sub_count) ) THEN
                   l_forward_buy_quantity := l_temp_parent_fwd_buy_qty;
               ELSE
                   IF (l_fwd_buy_sum_all_sub_recs <> 0) THEN
                     l_forward_buy_quantity :=
                      (facts_subrecord.forward_buy_quantity * l_temp_parent_fwd_buy_qty) / l_fwd_buy_sum_all_sub_recs;
                   ELSIF (l_fwd_buy_sum_all_sub_recs = 0) THEN
                     -- for time being, assigning the values equally (if all of the child recs have 0's)
                     -- l_forward_buy_quantity := l_temp_parent_fwd_buy_qty / l_temp_sub_count; -- Commented on 04/09/02
                     l_forward_buy_quantity := l_temp_parent_fwd_buy_qty * facts_subrecord.fact_percent * .01;
                   END IF;
               END IF;

               -- fact value and fact percent remain unchanged
               l_fact_value := facts_subrecord.fact_value;
               l_fact_percent := facts_subrecord.fact_percent;

             ELSIF (l_cascade_flag = 3) THEN
                l_fact_value := round(l_temp_parent_fact_value * facts_subrecord.fact_percent * .01);
                ----dbms_output.put_line('ParentfactVal ' || facts_record.fact_value || 'subPer ' || facts_subrecord.fact_percent || ' SubfactVal ' || l_fact_value);
                IF (l_temp_parent_fact_value <> 0) THEN
                   l_fact_percent := l_fact_value * 100 / l_temp_parent_fact_value;
                ELSIF (l_temp_parent_fact_value = 0) THEN
                   l_fact_percent := facts_subrecord.fact_percent;
                END IF;

                -- Changed on 04/09/02
                IF ( (facts_subrecord.fact_type = 'TIME') AND (l_temp_sub_counter <> l_temp_sub_count) ) THEN
                    l_forward_buy_quantity := 0;
                ELSIF ( (facts_subrecord.fact_type = 'TIME') AND (l_temp_sub_counter = l_temp_sub_count) ) THEN
                    l_forward_buy_quantity := l_temp_parent_fwd_buy_qty;
                ELSE
                    IF (l_fwd_buy_sum_all_sub_recs <> 0) THEN
                     l_forward_buy_quantity :=
                      (facts_subrecord.forward_buy_quantity * l_temp_parent_fwd_buy_qty) / l_fwd_buy_sum_all_sub_recs;
                    ELSIF (l_fwd_buy_sum_all_sub_recs = 0) THEN
                     -- for time being, assigning the values equally (if all of the child recs have 0's)
                     -- l_forward_buy_quantity := l_temp_parent_fwd_buy_qty / l_temp_sub_count; -- Commented on 04/09/02
                     l_forward_buy_quantity := l_temp_parent_fwd_buy_qty * facts_subrecord.fact_percent * .01;
                    END IF;
                END IF;

             END IF;

             -- Not the last record with this given previous_fact_id.
             -- So do a normal update of fact_percent and fact_value
             -- this will also work for the last record if the RemainingFcstQty of its parent <> 0

             ----dbms_output.put_line('Update: factVal = ' || l_fact_value || ' Perc ' || round(l_fact_percent,4)|| ' fwd ' || round(l_forward_buy_quantity));

             UPDATE ozf_act_metric_facts_all
             SET fact_value = l_fact_value,
                 fact_percent = round(l_fact_percent,4),
                 forward_buy_quantity = round(l_forward_buy_quantity)
             WHERE activity_metric_fact_id = facts_subrecord.activity_metric_fact_id;

           ELSIF ( (l_temp_sub_counter = l_temp_sub_count) AND (facts_record.forecast_remaining_quantity = 0) ) THEN
             -- Last record in the current set with the given previous_fact_id.
             -- Counter reset to 0 for the next set of records with another previous_fact_id
             -- this will only work for the last record if the RemainingFcstQty of its parent = 0
             -- this logic is needed so that RemainingFcstQty is never negative
             l_temp_sub_counter := 0;

             --Calculating the l_fval_sum_minus_last_rec since this is the last record in this set
             SELECT NVL(sum(fact_value),0), NVL(sum(forward_buy_quantity),0)
             INTO l_fval_sum_minus_last_rec, l_fwdbuy_sum_minus_last_rec
             FROM   ozf_act_metric_facts_all
             WHERE  arc_act_metric_used_by = 'FCST'
             AND act_metric_used_by_id = p_fcast_id
             AND previous_fact_id = facts_subrecord.previous_fact_id
             AND root_fact_id IS NOT NULL
             AND activity_metric_fact_id <> facts_subrecord.activity_metric_fact_id ;

             IF (l_cascade_flag = 1) THEN
                l_fact_value := round(l_temp_parent_fact_value - l_fval_sum_minus_last_rec);
                IF (l_temp_parent_fact_value <> 0) THEN
                   l_fact_percent := l_fact_value * 100 / l_temp_parent_fact_value;
                ELSIF (l_temp_parent_fact_value = 0) THEN
                   l_fact_percent := facts_subrecord.fact_percent;
                END IF;

                -- forward buy remains unchanged
                l_forward_buy_quantity := facts_subrecord.forward_buy_quantity;
             ELSIF (l_cascade_flag = 2) THEN
                l_forward_buy_quantity := round(l_temp_parent_fwd_buy_qty - l_fwdbuy_sum_minus_last_rec);

                -- fact value and fact percent remain unchanged
                l_fact_value := facts_subrecord.fact_value;
                l_fact_percent := facts_subrecord.fact_percent;
             ELSIF (l_cascade_flag = 3) THEN
                l_fact_value := round(l_temp_parent_fact_value - l_fval_sum_minus_last_rec);
                IF (l_temp_parent_fact_value <> 0) THEN
                   l_fact_percent := l_fact_value * 100 / l_temp_parent_fact_value;
                ELSIF (l_temp_parent_fact_value = 0) THEN
                   l_fact_percent := facts_subrecord.fact_percent;
                END IF;

                l_forward_buy_quantity := round(l_temp_parent_fwd_buy_qty - l_fwdbuy_sum_minus_last_rec);
             END IF;

             ----dbms_output.put_line('Update: factVal = ' || l_fact_value || ' Perc ' || round(l_fact_percent,4) || ' fwd ' || round(l_forward_buy_quantity));

             UPDATE ozf_act_metric_facts_all
             SET fact_value = l_fact_value,
                 fact_percent = round(l_fact_percent,4),
                 forward_buy_quantity = l_forward_buy_quantity
             WHERE activity_metric_fact_id = facts_subrecord.activity_metric_fact_id;

           END IF;


        END LOOP;

   END LOOP;

   -- commented here , call placed in java after Update called
   --fcst_remqty(p_fcast_id);


  END IF;

   EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_OFFER_PARTY_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


 END cascade_update;



 PROCEDURE cascade_first_level(
                    p_api_version        IN  NUMBER,
                    p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                    p_commit             IN  VARCHAR2  := FND_API.g_false,

                    p_fcast_value        IN   NUMBER,
                    p_fwd_buy_value      IN   NUMBER,
                    p_fcast_id           IN   NUMBER,
                    p_cascade_flag       IN   NUMBER,

                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_msg_count          OUT NOCOPY NUMBER,
                    x_msg_data           OUT NOCOPY VARCHAR2
                   )
 IS

 l_fact_percent NUMBER := 0;
 l_fact_value NUMBER := 0;
 l_forward_buy_quantity NUMBER := 0;
 l_parent_fact_value NUMBER := 0;
 l_parent_fwd_buy_qty NUMBER := 0;
 l_fcst_remaining_quantity NUMBER := 0;
 l_cascade_flag NUMBER := 0;
 l_temp_count NUMBER := 0;
 l_temp_counter NUMBER := 0;
 l_fwd_buy_sum_all_recs NUMBER := 0;
 l_fval_sum_minus_last_rec NUMBER := 0;
 l_fwdbuy_sum_minus_last_rec NUMBER := 0;

 CURSOR C_LevelOneRecords(p_forecast_id IN NUMBER) IS
  SELECT activity_metric_fact_id,
                 previous_fact_id,
                 forecast_remaining_quantity,
                 fact_type,
                 fact_reference,
                 from_date,
                 to_date,
                 fact_value,
                 fact_percent,
                 root_fact_id,
                 forward_buy_quantity
  FROM ozf_act_metric_facts_all
  WHERE arc_act_metric_used_by = 'FCST'
  AND act_metric_used_by_id = p_forecast_id
  AND previous_fact_id IS NULL
  AND root_fact_id IS NULL
  order by 6; --changed on 04/09/02

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'Cascade_Level_One';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);


  BEGIN

  --  IF (OZF_DEBUG_HIGH_ON) THEN    OZF_Utility_PVT.debug_message(l_full_name || ': start refresh parties');  END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   /* Commented for now (since values retrieved in Java class
   SELECT forecast_quantity, forward_buy_quantity, forecast_remaining_quantity
   INTO l_parent_fact_value, l_parent_fwd_buy_qty, l_fcst_remaining_quantity
   FROM ozf_act_forecasts_all
   WHERE forecast_id = p_fcast_id;
   */

   SELECT forecast_remaining_quantity
   INTO l_fcst_remaining_quantity
   FROM ozf_act_forecasts_all
   WHERE forecast_id = p_fcast_id;

   /* Commented for now (since values retrieved in Java class
   IF ( (p_fcast_value = l_parent_fact_value) AND (p_fwd_buy_value = l_parent_fwd_buy_qty) ) THEN
      l_cascade_flag := 0;
   ELSIF ( (p_fcast_value <> l_parent_fact_value) AND (p_fwd_buy_value = l_parent_fwd_buy_qty) ) THEN
      l_cascade_flag := 1;
   ELSIF ( (p_fcast_value = l_parent_fact_value) AND (p_fwd_buy_value <> l_parent_fwd_buy_qty) ) THEN
      l_cascade_flag := 2;
   ELSIF ( (p_fcast_value <> l_parent_fact_value) AND (p_fwd_buy_value <> l_parent_fwd_buy_qty) ) THEN
      l_cascade_flag := 3;
   END IF;
   */

   l_cascade_flag := p_cascade_flag;

   -- Consider if we need to enter the loop if l_cascade_flag := 0
   --------------------------------

   SELECT count(*), sum(forward_buy_quantity)
   INTO l_temp_count, l_fwd_buy_sum_all_recs
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id
   AND previous_fact_id IS NULL
   AND root_fact_id IS NULL;

   FOR facts_record IN C_LevelOneRecords(p_fcast_id) LOOP

     -- Increment the counter to check for the last record in each set
     l_temp_counter := l_temp_counter + 1;

     IF ( (l_temp_counter <> l_temp_count) OR (l_fcst_remaining_quantity <> 0) ) THEN

       IF (l_cascade_flag = 1) THEN
           l_fact_value := round(p_fcast_value * facts_record.fact_percent * .01);
           IF (p_fcast_value <> 0) THEN
               l_fact_percent := l_fact_value * 100 / p_fcast_value;
           ELSIF (p_fcast_value = 0) THEN
               l_fact_percent := facts_record.fact_percent;
           END IF;

           -- forward buy remains unchanged
           l_forward_buy_quantity := facts_record.forward_buy_quantity;
       ELSIF (l_cascade_flag = 2) THEN
           -- Changed on 04/09/02
           IF ( (facts_record.fact_type = 'TIME') AND (l_temp_counter <> l_temp_count) ) THEN
               l_forward_buy_quantity := 0;
           ELSIF ( (facts_record.fact_type = 'TIME') AND (l_temp_counter = l_temp_count) ) THEN
               l_forward_buy_quantity := p_fwd_buy_value;
           ELSE
               IF (l_fwd_buy_sum_all_recs <> 0) THEN
                   l_forward_buy_quantity := (facts_record.forward_buy_quantity * p_fwd_buy_value) / l_fwd_buy_sum_all_recs;
               ELSIF (l_fwd_buy_sum_all_recs = 0) THEN
                   -- for time being, assigning the values equally (if all of the child recs have 0's)
                   --l_forward_buy_quantity := p_fwd_buy_value / l_temp_count; -- Commented on APR 04/09/02
                   l_forward_buy_quantity := p_fwd_buy_value * facts_record.fact_percent * .01;
               END IF;
           END IF;

           -- fact value and fact percent remain unchanged
           l_fact_value := facts_record.fact_value;
           l_fact_percent := facts_record.fact_percent;

       ELSIF (l_cascade_flag = 3) THEN
           l_fact_value := round(p_fcast_value * facts_record.fact_percent * .01);
           IF (p_fcast_value <> 0) THEN
               l_fact_percent := l_fact_value * 100 / p_fcast_value;
           ELSIF (p_fcast_value = 0) THEN
               l_fact_percent := facts_record.fact_percent;
           END IF;

           -- Changed on 04/09/02
           IF ( (facts_record.fact_type = 'TIME') AND (l_temp_counter <> l_temp_count) ) THEN
               l_forward_buy_quantity := 0;
           ELSIF ( (facts_record.fact_type = 'TIME') AND (l_temp_counter = l_temp_count) ) THEN
               l_forward_buy_quantity := p_fwd_buy_value;
           ELSE
               IF (l_fwd_buy_sum_all_recs <> 0) THEN
                   l_forward_buy_quantity := (facts_record.forward_buy_quantity * p_fwd_buy_value) / l_fwd_buy_sum_all_recs;
               ELSIF (l_fwd_buy_sum_all_recs = 0) THEN
                   -- for time being, assigning the values equally (if all of the child recs have 0's)
                   --l_forward_buy_quantity := p_fwd_buy_value / l_temp_count; -- Commented on APR 04/09/02
                   l_forward_buy_quantity := p_fwd_buy_value * facts_record.fact_percent * .01;
               END IF;
           END IF;

       END IF;

       UPDATE ozf_act_metric_facts_all
       SET fact_value = l_fact_value,
           fact_percent = round(l_fact_percent,4),
           forward_buy_quantity = round(l_forward_buy_quantity)
       WHERE activity_metric_fact_id = facts_record.activity_metric_fact_id;

       ----dbms_output.put_line('Updated: factVal = ' || l_fact_value || ' Perc ' || round(l_fact_percent,4)
       --|| ' fwd ' || round(l_forward_buy_quantity) || ' cascadeFlag '||l_cascade_flag);

       -- call Cascade_Update with the proper cascade flag
       cascade_update(p_api_version,
                      p_init_msg_list,
                      p_commit,
                      facts_record.activity_metric_fact_id,
                      l_fact_value,
                      round(l_forward_buy_quantity),
                      p_fcast_id,
                      l_cascade_flag,
                      x_return_status,
                      x_msg_count,
                      x_msg_data
                     );

     ELSIF ( (l_temp_counter = l_temp_count) AND (l_fcst_remaining_quantity = 0) ) THEN

       --Calculating the l_fval_sum_minus_last_rec since this is the last record in this set
        SELECT NVL(sum(fact_value),0), NVL(sum(forward_buy_quantity),0)
        INTO l_fval_sum_minus_last_rec, l_fwdbuy_sum_minus_last_rec
        FROM   ozf_act_metric_facts_all
        WHERE  arc_act_metric_used_by = 'FCST'
        AND act_metric_used_by_id = p_fcast_id
        AND previous_fact_id IS NULL
        AND root_fact_id IS NULL
        AND activity_metric_fact_id <> facts_record.activity_metric_fact_id ;

        IF (l_cascade_flag = 1) THEN
           l_fact_value := round(p_fcast_value - l_fval_sum_minus_last_rec);
           IF (p_fcast_value <> 0) THEN
               l_fact_percent := l_fact_value * 100 / p_fcast_value;
           ELSIF (p_fcast_value = 0) THEN
               l_fact_percent := facts_record.fact_percent;
           END IF;

           -- forward buy remains unchanged
           l_forward_buy_quantity := facts_record.forward_buy_quantity;
        ELSIF (l_cascade_flag = 2) THEN
           l_forward_buy_quantity := round(p_fwd_buy_value - l_fwdbuy_sum_minus_last_rec);

           -- fact value and fact percent remain unchanged
           l_fact_value := facts_record.fact_value;
           l_fact_percent := facts_record.fact_percent;
        ELSIF (l_cascade_flag = 3) THEN
           l_fact_value := round(p_fcast_value - l_fval_sum_minus_last_rec);
           IF (p_fcast_value <> 0) THEN
               l_fact_percent := l_fact_value * 100 / p_fcast_value;
           ELSIF (p_fcast_value = 0) THEN
               l_fact_percent := facts_record.fact_percent;
           END IF;

           l_forward_buy_quantity := round(p_fwd_buy_value - l_fwdbuy_sum_minus_last_rec);
        END IF;


        UPDATE ozf_act_metric_facts_all
        SET fact_value = l_fact_value,
            fact_percent = round(l_fact_percent,4),
            forward_buy_quantity = l_forward_buy_quantity
        WHERE activity_metric_fact_id = facts_record.activity_metric_fact_id;
        ----dbms_output.put_line('Updated: factVal = ' || l_fact_value || ' Perc ' || round(l_fact_percent,4)
       --|| ' fwd ' || round(l_forward_buy_quantity) || ' cascadeFlag '||l_cascade_flag);

        -- call Cascade_Update with the proper cascade flag
        cascade_update(p_api_version,
                       p_init_msg_list,
                       p_commit,
                       facts_record.activity_metric_fact_id,
                       l_fact_value,
                       round(l_forward_buy_quantity),
                       p_fcast_id,
                       l_cascade_flag,
                       x_return_status,
                       x_msg_count,
                       x_msg_data
                      );

     END IF;

   END LOOP;

   EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_OFFER_PARTY_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


 END cascade_first_level;



  PROCEDURE p_Calc_Val(p_base_quantity                 IN   NUMBER,
                       p_fcast_quantity                IN   NUMBER,
                       p_spread_type                   IN   VARCHAR2,
                       b_quantity                      IN   NUMBER,
                       act_metric_fact_id              IN   NUMBER,
                       count_records                   IN   NUMBER,
                       x_fact_value                    OUT NOCOPY NUMBER
                       )
  IS
  BEGIN

    IF (p_spread_type = 'ACROSS_ALL_EVENLY') THEN
       -- Split Total Forecast Qty by total number of rows
        x_fact_value := p_fcast_quantity / count_records;

    ELSIF (p_spread_type = 'BASELINE_RATIO') THEN
      IF ( p_base_quantity = 0 )
      THEN
        x_fact_value := 0;
      ELSE
        x_fact_value := p_fcast_quantity * b_quantity / p_base_quantity;
      END IF;
    END IF;

  END p_Calc_Val;


PROCEDURE calc_perc(
                    p_api_version        IN  NUMBER,
                    p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                    p_commit             IN  VARCHAR2  := FND_API.g_false,

                    p_used_by_id IN NUMBER,
                    p_level_num IN NUMBER,
                    p_spread_type IN VARCHAR2,

                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_msg_count          OUT NOCOPY NUMBER,
                    x_msg_data           OUT NOCOPY VARCHAR2
                   )
  IS

   l_temp_count NUMBER := 1;
   l_temp_counter NUMBER := 0;
   l_fval_sum_minus_last_rec NUMBER := 0;
   l_fwdbuy_sum_minus_last_rec NUMBER := 0;
   l_fact_percent NUMBER := 0;
   l_fact_value NUMBER := 0;
   l_forward_buy_quantity NUMBER := 0;
   l_temp_fact_value NUMBER := 0;
   l_temp_previous_fact_id NUMBER := 1;
   l_level_num NUMBER := 0;

   l_rounded_val NUMBER := 0;
   l_counter NUMBER := 0;
   l_x_counter NUMBER := 0;
   l_x_value NUMBER := 0;
   l_y_counter NUMBER := 0;
   l_y_value NUMBER := 0;
   l_check_counter NUMBER := 0;
   l_check_count_counter NUMBER := 0;

   CURSOR C1 IS
   SELECT a.activity_metric_fact_id,
                  a.previous_fact_id,
                  a.base_quantity level_one_bq,
                  a.fact_type level_one_fact_type,
                  a.fact_reference,
                  a.from_date,
                  a.to_date,
                  a.fact_value,
                  a.fact_percent,
                  a.root_fact_id,
                  b.base_quantity overall_base_quantity,
                  b.forecast_quantity overall_forecast_quantity,
                  b.forward_buy_quantity overall_fwd_buy_qty
   FROM ozf_act_metric_facts_all a, ozf_act_forecasts_all b
   WHERE a.arc_act_metric_used_by = 'FCST'
   AND a.act_metric_used_by_id = p_used_by_id
   AND a.previous_fact_id IS NULL
   AND b.forecast_id = a.act_metric_used_by_id
   and nvl(a.node_id,1) <> 3
   order by 6;

   CURSOR C2 IS
   SELECT f1.base_quantity level_one_bq,
                  f1.fact_value level_one_fact_val,
                  f.activity_metric_fact_id level_two_fact_id,
                  f.previous_fact_id,
                  f.base_quantity level_two_bq,
                  f.fact_type level_two_fact_type,
                  f.fact_reference,
                  f.from_date,
                  f.to_date,
                  f.fact_value,
                  f.fact_percent,
                  f.root_fact_id,
                  f1.forward_buy_quantity level_one_fwd_buy_qty
   FROM ozf_act_metric_facts_all f, ozf_act_metric_facts_all f1
   WHERE f.arc_act_metric_used_by = 'FCST'
   AND f.act_metric_used_by_id = p_used_by_id
   AND f.previous_fact_id IS NOT NULL
   AND f.root_fact_id IS NULL
   AND f.previous_fact_id = f1.activity_metric_fact_id
   and nvl(f.node_id,1) <> 3
   order by 4,8;

   CURSOR C3 IS
   SELECT f1.base_quantity level_two_bq,
                  f1.fact_value level_two_fact_val,
                  f.activity_metric_fact_id level_three_fact_id,
                  f.previous_fact_id,
                  f.base_quantity level_three_bq,
                  f.fact_type level_three_fact_type,
                  f.fact_reference,
                  f.from_date,
                  f.to_date,
                  f.fact_value,
                  f.fact_percent,
                  f.root_fact_id,
                  f1.forward_buy_quantity level_two_fwd_buy_qty
    FROM ozf_act_metric_facts_all f, ozf_act_metric_facts_all f1
    WHERE f.arc_act_metric_used_by = 'FCST'
    AND f.act_metric_used_by_id = p_used_by_id
    AND f.root_fact_id IS NOT NULL
    AND f.previous_fact_id = f1.activity_metric_fact_id
    and nvl(f.node_id,1) <> 3
    order by 4,8;

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'Calc_Perc';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);


  BEGIN

   --  IF (OZF_DEBUG_HIGH_ON) THEN    OZF_Utility_PVT.debug_message(l_full_name || ': start refresh parties');  END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   l_level_num := p_level_num;

   LOOP

   IF (l_level_num = 1) THEN

          SELECT count(*)
          INTO l_temp_count
          FROM   ozf_act_metric_facts_all
          WHERE  arc_act_metric_used_by = 'FCST'
          AND act_metric_used_by_id = p_used_by_id
          AND previous_fact_id IS NULL
          AND root_fact_id IS NULL
          and nvl(node_id,1) <> 3;

     FOR rec IN C1 LOOP
         l_temp_counter := l_temp_counter + 1;
         l_counter := l_counter + 1;

         IF(p_spread_type = 'ACROSS_ALL_EVENLY') THEN
            IF( l_check_counter = 0 ) THEN
             l_rounded_val := round(rec.overall_forecast_quantity / l_temp_count);
             IF( (l_temp_count * l_rounded_val) > rec.overall_forecast_quantity ) THEN
                l_x_counter := (l_rounded_val * l_temp_count) - rec.overall_forecast_quantity;
                l_x_value := l_rounded_val - 1;
                l_y_counter :=  l_temp_count - l_x_counter;
                l_y_value := l_rounded_val;
             ELSIF( (l_temp_count * l_rounded_val) < rec.overall_forecast_quantity ) THEN
                l_x_counter := rec.overall_forecast_quantity - (l_rounded_val * l_temp_count);
                l_x_value := l_rounded_val + 1;
                l_y_counter :=  l_temp_count - l_x_counter;
                l_y_value := l_rounded_val;
             ELSE
                l_x_counter := 0;
                l_y_counter := l_temp_count;
                l_y_value := l_rounded_val;
             END IF;

             l_check_counter := 1;
            END IF;

            IF( l_x_counter = 0 ) THEN
               l_fact_value := l_y_value;
            ELSIF( (l_x_counter <> 0) AND (l_counter <= l_x_counter) ) THEN
               l_fact_value := l_x_value;
            ELSIF( (l_x_counter <> 0) AND (l_counter > l_x_counter) ) THEN
               l_fact_value := l_y_value;
            END IF;

         ELSIF(p_spread_type = 'BASELINE_RATIO') THEN
           IF (l_temp_counter <> l_temp_count) THEN
             p_Calc_Val(rec.overall_base_quantity,
                        rec.overall_forecast_quantity,
                        p_spread_type,
                        rec.level_one_bq,
                        rec.activity_metric_fact_id,
                        l_temp_count,
                        l_temp_fact_value);

             l_fact_value := round(l_temp_fact_value);
           ELSIF (l_temp_counter = l_temp_count) THEN
             SELECT NVL(sum(fact_value),0)
             INTO l_fval_sum_minus_last_rec
             FROM   ozf_act_metric_facts_all
             WHERE  arc_act_metric_used_by = 'FCST'
             AND act_metric_used_by_id = p_used_by_id
             AND previous_fact_id IS NULL
             AND root_fact_id IS NULL
             AND activity_metric_fact_id <> rec.activity_metric_fact_id
             and nvl(node_id,1) <> 3;

             l_fact_value := round(rec.overall_forecast_quantity - l_fval_sum_minus_last_rec);
           END IF;

         END IF;

         IF( rec.overall_forecast_quantity = 0 ) THEN
            l_fact_percent := 0.0000;
         ELSIF ( rec.overall_forecast_quantity <> 0 ) THEN
            l_fact_percent := l_fact_value * 100 / rec.overall_forecast_quantity;
         END IF;

         -- Changed on 04/09/02
         IF( (rec.level_one_fact_type = 'TIME') AND (l_temp_counter <> l_temp_count) ) THEN
            l_forward_buy_quantity := 0;
         ELSIF ( (rec.level_one_fact_type = 'TIME') AND (l_temp_counter = l_temp_count) ) THEN
            l_forward_buy_quantity := rec.overall_fwd_buy_qty;
         ELSIF ( (rec.level_one_fact_type <> 'TIME') AND (l_temp_counter <> l_temp_count) ) THEN
            l_forward_buy_quantity := round(rec.overall_fwd_buy_qty * l_fact_percent * 0.01);
         ELSIF ( (rec.level_one_fact_type <> 'TIME') AND (l_temp_counter = l_temp_count) ) THEN
            -- So, calculate the last record's fact value such that the total sum of fact values = Total Fcast Qty.
            SELECT NVL(sum(forward_buy_quantity),0)
            INTO l_fwdbuy_sum_minus_last_rec
            FROM   ozf_act_metric_facts_all
            WHERE  arc_act_metric_used_by = 'FCST'
            AND act_metric_used_by_id = p_used_by_id
            AND previous_fact_id IS NULL
            AND root_fact_id IS NULL
            AND activity_metric_fact_id <> rec.activity_metric_fact_id
            and nvl(node_id,1) <> 3 ;

            l_forward_buy_quantity := round(rec.overall_fwd_buy_qty - l_fwdbuy_sum_minus_last_rec);
         END IF;

         UPDATE ozf_act_metric_facts_all
         SET fact_value = l_fact_value,
             fact_percent = round(l_fact_percent,4),
             forward_buy_quantity = l_forward_buy_quantity
         WHERE activity_metric_fact_id = rec.activity_metric_fact_id;


     END LOOP;

    -- fcst_remqty(p_used_by_id);


   ELSIF(l_level_num = 2) THEN

     -- The exact count is sent for any SPREAD TYPE to update the last record appropriately in p_Calc_Val
     -- and avoid the RemToForecast rounding problem

      FOR rec IN C2 LOOP

            l_counter := l_counter + 1;

            IF (l_temp_previous_fact_id <> rec.previous_fact_id) THEN
              -- counter set to 1 so that we can loop thru subset recs properly and update values
              l_counter := 1;


                SELECT count(*) INTO l_temp_count
                FROM ozf_act_metric_facts_all
                WHERE arc_act_metric_used_by = 'FCST'
                AND act_metric_used_by_id = p_used_by_id
                AND previous_fact_id = rec.previous_fact_id
                AND root_fact_id IS NULL
                and nvl(node_id,1) <> 3;



              -- Calculating fact values and the x, y counters for each subset once for EVENLY
              IF(p_spread_type = 'ACROSS_ALL_EVENLY') THEN
                l_rounded_val := round(rec.level_one_fact_val / l_temp_count);
                IF( (l_temp_count * l_rounded_val) > rec.level_one_fact_val ) THEN
                   l_x_counter := (l_rounded_val * l_temp_count) - rec.level_one_fact_val;
                   l_x_value := l_rounded_val - 1;
                   l_y_counter :=  l_temp_count - l_x_counter;
                   l_y_value := l_rounded_val;
                ELSIF( (l_temp_count * l_rounded_val) < rec.level_one_fact_val ) THEN
                   l_x_counter := rec.level_one_fact_val - (l_rounded_val * l_temp_count);
                   l_x_value := l_rounded_val + 1;
                   l_y_counter :=  l_temp_count - l_x_counter;
                   l_y_value := l_rounded_val;
                ELSE
                   l_x_counter := 0;
                   l_y_counter := l_temp_count;
                   l_y_value := l_rounded_val;
                END IF;
              END IF;

              -- set previous fact id so that we dont enter this one for just the first rec in each subset
              l_temp_previous_fact_id := rec.previous_fact_id;

            END IF;

            IF(p_spread_type = 'ACROSS_ALL_EVENLY') THEN
               IF( l_x_counter = 0 ) THEN
                  l_fact_value := l_y_value;
               ELSIF( (l_x_counter <> 0) AND (l_counter <= l_x_counter) ) THEN
                  l_fact_value := l_x_value;
               ELSIF( (l_x_counter <> 0) AND (l_counter > l_x_counter) ) THEN
                  l_fact_value := l_y_value;
               END IF;
            ELSIF(p_spread_type = 'BASELINE_RATIO') THEN
              IF (l_counter <> l_temp_count) THEN
                p_Calc_Val(rec.level_one_bq,
                           rec.level_one_fact_val,
                           p_spread_type,
                           rec.level_two_bq,
                           rec.level_two_fact_id,
                           l_temp_count,
                           l_temp_fact_value);

                l_fact_value := round(l_temp_fact_value);
              ELSIF (l_counter = l_temp_count) THEN
               --Calculating the l_fval_sum_minus_last_rec since this is the last record in this set
                SELECT NVL(sum(fact_value),0)
                INTO l_fval_sum_minus_last_rec
                FROM   ozf_act_metric_facts_all
                WHERE  arc_act_metric_used_by = 'FCST'
                AND act_metric_used_by_id = p_used_by_id
                AND previous_fact_id = rec.previous_fact_id
                AND root_fact_id IS NULL
                AND activity_metric_fact_id <> rec.level_two_fact_id
                and nvl(node_id,1) <> 3 ;

                l_fact_value := round(rec.level_one_fact_val - l_fval_sum_minus_last_rec);
              END IF;
            END IF;

            IF ( rec.level_one_fact_val = 0 ) THEN
                l_fact_percent := 0.0000;
            ELSIF ( rec.level_one_fact_val <> 0 ) THEN
                l_fact_percent := l_fact_value * 100 / rec.level_one_fact_val;
            END IF;

            -- Changed on 04/09/02
            IF( (rec.level_two_fact_type = 'TIME') AND (l_counter <> l_temp_count) ) THEN
                l_forward_buy_quantity := 0;
            ELSIF ( (rec.level_two_fact_type = 'TIME') AND (l_counter = l_temp_count) ) THEN
                l_forward_buy_quantity := rec.level_one_fwd_buy_qty;
            ELSIF ( (rec.level_two_fact_type <> 'TIME') AND (l_counter <> l_temp_count) ) THEN
                l_forward_buy_quantity := round(rec.level_one_fwd_buy_qty * l_fact_percent * 0.01);
            ELSIF ( (rec.level_two_fact_type <> 'TIME') AND (l_counter = l_temp_count) ) THEN
               -- So, calculate the last record's fact value such that the total sum of fact values = Total Fcast Qty.
                SELECT NVL(sum(forward_buy_quantity),0)
                INTO l_fwdbuy_sum_minus_last_rec
                FROM   ozf_act_metric_facts_all
                WHERE  arc_act_metric_used_by = 'FCST'
                AND act_metric_used_by_id = p_used_by_id
                AND previous_fact_id = rec.previous_fact_id
                AND root_fact_id IS NULL
                AND activity_metric_fact_id <> rec.level_two_fact_id
                and nvl(node_id,1) <> 3 ;

                l_forward_buy_quantity := round(rec.level_one_fwd_buy_qty - l_fwdbuy_sum_minus_last_rec);
            END IF;

            UPDATE ozf_act_metric_facts_all
            SET fact_value = l_fact_value,
                fact_percent = round(l_fact_percent,4),
                forward_buy_quantity = l_forward_buy_quantity
            WHERE activity_metric_fact_id = rec.level_two_fact_id
             and nvl( node_id,1) <> 3;


      END LOOP;


   ELSIF(l_level_num = 3) THEN

    -- The exact count is sent for any SPREAD TYPE to update the last record appropriately in p_Calc_Val
    -- and avoid the RemToForecast rounding problem

     FOR rec IN C3 LOOP

            l_counter := l_counter + 1;

            IF (l_temp_previous_fact_id <> rec.previous_fact_id) THEN
              -- counter set to 1 so that we can loop thru subset recs properly and update values
              l_counter := 1;


                SELECT count(*) INTO l_temp_count
                FROM ozf_act_metric_facts_all
                WHERE arc_act_metric_used_by = 'FCST'
                AND act_metric_used_by_id = p_used_by_id
                AND previous_fact_id = rec.previous_fact_id
                AND root_fact_id IS NOT NULL
                and nvl(node_id,1) <> 3;



              -- Calculating fact values and the x, y counters for each subset once for EVENLY
              IF(p_spread_type = 'ACROSS_ALL_EVENLY') THEN
                l_rounded_val := round(rec.level_two_fact_val / l_temp_count);
                IF( (l_temp_count * l_rounded_val) > rec.level_two_fact_val ) THEN
                   l_x_counter := (l_rounded_val * l_temp_count) - rec.level_two_fact_val;
                   l_x_value := l_rounded_val - 1;
                   l_y_counter :=  l_temp_count - l_x_counter;
                   l_y_value := l_rounded_val;
                ELSIF( (l_temp_count * l_rounded_val) < rec.level_two_fact_val ) THEN
                   l_x_counter := rec.level_two_fact_val - (l_rounded_val * l_temp_count);
                   l_x_value := l_rounded_val + 1;
                   l_y_counter :=  l_temp_count - l_x_counter;
                   l_y_value := l_rounded_val;
                ELSE
                   l_x_counter := 0;
                   l_y_counter := l_temp_count;
                   l_y_value := l_rounded_val;
                END IF;
              END IF;

              -- set previous fact id so that we dont enter this one for just the first rec in each subset
              l_temp_previous_fact_id := rec.previous_fact_id;

            END IF;

            IF(p_spread_type = 'ACROSS_ALL_EVENLY') THEN
               IF( l_x_counter = 0 ) THEN
                  l_fact_value := l_y_value;
               ELSIF( (l_x_counter <> 0) AND (l_counter <= l_x_counter) ) THEN
                  l_fact_value := l_x_value;
               ELSIF( (l_x_counter <> 0) AND (l_counter > l_x_counter) ) THEN
                  l_fact_value := l_y_value;
               END IF;
            ELSIF(p_spread_type = 'BASELINE_RATIO') THEN
              IF (l_counter <> l_temp_count) THEN
                p_Calc_Val(rec.level_two_bq,
                           rec.level_two_fact_val,
                           p_spread_type,
                           rec.level_three_bq,
                           rec.level_three_fact_id,
                           l_temp_count,
                           l_temp_fact_value);

                l_fact_value := round(l_temp_fact_value);
              ELSIF (l_counter = l_temp_count) THEN
                --Calculating the l_fval_sum_minus_last_rec since this is the last record in this set
                SELECT NVL(sum(fact_value),0)
                INTO l_fval_sum_minus_last_rec
                FROM   ozf_act_metric_facts_all
                WHERE  arc_act_metric_used_by = 'FCST'
                AND act_metric_used_by_id = p_used_by_id
                AND previous_fact_id = rec.previous_fact_id
                AND root_fact_id IS NOT NULL
                AND activity_metric_fact_id <> rec.level_three_fact_id
                and nvl(node_id,1) <> 3;

                l_fact_value := round(rec.level_two_fact_val - l_fval_sum_minus_last_rec);
              END IF;
            END IF;

            IF ( rec.level_two_fact_val = 0 ) THEN
                l_fact_percent := 0.0000;
            ELSIF ( rec.level_two_fact_val <> 0 ) THEN
                l_fact_percent := l_fact_value * 100 / rec.level_two_fact_val;
            END IF;

            -- Changed on 04/09/02
            IF( (rec.level_three_fact_type = 'TIME') AND (l_counter <> l_temp_count) ) THEN
                l_forward_buy_quantity := 0;
            ELSIF ( (rec.level_three_fact_type = 'TIME') AND (l_counter = l_temp_count) ) THEN
                l_forward_buy_quantity := rec.level_two_fwd_buy_qty;
            ELSIF ( (rec.level_three_fact_type <> 'TIME') AND (l_counter <> l_temp_count) ) THEN
                l_forward_buy_quantity := round(rec.level_two_fwd_buy_qty * l_fact_percent * 0.01);
            ELSIF ( (rec.level_three_fact_type <> 'TIME') AND (l_counter = l_temp_count) ) THEN
               -- So, calculate the last record's fact value such that the total sum of fact values = Total Fcast Qty.
                SELECT NVL(sum(forward_buy_quantity),0)
                INTO l_fwdbuy_sum_minus_last_rec
                FROM   ozf_act_metric_facts_all
                WHERE  arc_act_metric_used_by = 'FCST'
                AND act_metric_used_by_id = p_used_by_id
                AND previous_fact_id = rec.previous_fact_id
                AND root_fact_id IS NOT NULL
                AND activity_metric_fact_id <> rec.level_three_fact_id
                and nvl(node_id,1) <> 3;

                l_forward_buy_quantity := round(rec.level_two_fwd_buy_qty - l_fwdbuy_sum_minus_last_rec);
            END IF;

            UPDATE ozf_act_metric_facts_all
            SET fact_value = l_fact_value,
                fact_percent = round(l_fact_percent,4),
                forward_buy_quantity = l_forward_buy_quantity
            WHERE activity_metric_fact_id = rec.level_three_fact_id;

      END LOOP;


   END IF;

   --- Incremented so that calc_perc gets called for all the present levels when CalculateSpreads button clicked
   l_level_num := l_level_num + 1;

   -- Exits after this check when calc_perc called on clicking the Generate button
   IF( p_level_num IN (1, 2, 3)) THEN
    EXIT;
   END IF;

   EXIT WHEN l_level_num > 3;

   END LOOP;

    EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_OFFER_PARTY_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END calc_perc;

  PROCEDURE get_list_price(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_type             IN  VARCHAR2,
                    p_obj_id               IN  NUMBER,
                    p_forecast_id          IN  NUMBER,
                    p_product_attribute    IN  VARCHAR2,
                    p_product_attr_value   IN  VARCHAR2,
                    p_fcst_uom             IN  VARCHAR2,
                    p_currency_code        IN  VARCHAR2,
                    p_price_list_id        IN  NUMBER,

                    x_list_price           OUT NOCOPY NUMBER,
                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2
                   )
  IS


  p_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
  p_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
  p_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
  p_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
  p_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
  p_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
  p_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
  p_control_rec               QP_PREQ_GRP.CONTROL_RECORD_TYPE;
  x_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
  x_line_qual                 QP_PREQ_GRP.QUAL_TBL_TYPE;
  x_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
  x_line_detail_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
  x_line_detail_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
  x_line_detail_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
  x_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
  x_return_stat               VARCHAR2(240);
  x_return_status_text        VARCHAR2(240);
  qual_rec                    QP_PREQ_GRP.QUAL_REC_TYPE;
  line_attr_rec               QP_PREQ_GRP.LINE_ATTR_REC_TYPE;
  line_rec                    QP_PREQ_GRP.LINE_REC_TYPE;
  rltd_rec                    QP_PREQ_GRP.RELATED_LINES_REC_TYPE;

  l_version VARCHAR2(240);
  l_counter NUMBER;
  I BINARY_INTEGER;

  l_status_code VARCHAR2(240);
  l_status_text VARCHAR2(2000);

  CURSOR c_market_qualifiers IS
  SELECT qualifier_context,
         qualifier_attribute,
         qualifier_attr_value,
         comparison_operator_code
  FROM ozf_forecast_dimentions
  WHERE obj_type = p_obj_type
  AND obj_id = p_obj_id
  AND forecast_id = p_forecast_id
  AND product_attribute_context = 'ITEM'
  AND product_attribute = p_product_attribute
  AND product_attr_value = p_product_attr_value;

  CURSOR c_wkst_qualifiers IS
  SELECT qualifier_context,
         qualifier_attribute,
         qualifier_attr_value,
         comparison_operator_code
  FROM ozf_worksheet_qualifiers
  WHERE worksheet_header_id = p_obj_id;

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'Get_List_Price';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);


  BEGIN

  --  IF (OZF_DEBUG_HIGH_ON) THEN    OZF_Utility_PVT.debug_message(l_full_name || ': start get_list_price ');  END IF;

      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

      IF NOT FND_API.compatible_api_call(l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      x_return_status := FND_API.g_ret_sts_success;

      -- Passing Information to the Pricing Engine

      -- Setting up the control record variables
      p_control_rec.pricing_event := 'LINE';
      p_control_rec.calculate_flag := 'N';
      p_control_rec.simulation_flag := 'Y';

      -- Request Line (Order Line) Information
      line_rec.request_type_code :='ONT';
      line_rec.line_id :=999;
      line_rec.line_Index := 1 ;                    -- Request Line Index
      line_rec.line_type_code := 'LINE';            -- LINE or ORDER(Summary Line)
      line_rec.pricing_effective_date := SYSDATE;   -- Pricing as of what date ?
      line_rec.active_date_first := SYSDATE;        -- Can be Ordered Date or Ship Date
      line_rec.active_date_second := SYSDATE;       -- Can be Ordered Date or Ship Date
      line_rec.active_date_first_type := 'NO TYPE'; -- ORD/SHIP
      line_rec.active_date_second_type :='NO TYPE'; -- ORD/SHIP
      line_rec.line_quantity := 1;                  -- Ordered Quantity
      line_rec.line_uom_code := p_fcst_uom;         -- Ordered UOM Code
      line_rec.currency_code := p_currency_code;    -- Currency Code
      line_rec.price_flag := 'Y';                   -- Price Flag can have 'Y' ,
                                                    -- 'N'(No pricing) , 'P'(Phase)
      p_line_tbl(1) := line_rec;

      -- Pricing Attributes Passed In
      line_attr_rec.LINE_INDEX := 1 ;
      line_attr_rec.PRICING_CONTEXT := 'ITEM';
      line_attr_rec.PRICING_ATTRIBUTE := p_product_attribute;
      line_attr_rec.PRICING_ATTR_VALUE_FROM := p_product_attr_value;

      line_attr_rec.VALIDATED_FLAG :='N';
      p_line_attr_tbl(1):= line_attr_rec;

      -- Market Qualifiers
      l_counter := 1;

      qual_rec.LINE_INDEX := 1;
      qual_rec.QUALIFIER_CONTEXT :='MODLIST';
      qual_rec.QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE4';
      qual_rec.QUALIFIER_ATTR_VALUE_FROM := TO_CHAR(p_price_list_id);
      qual_rec.COMPARISON_OPERATOR_CODE := '=';
      qual_rec.VALIDATED_FLAG :='Y';
      p_qual_tbl(l_counter):= qual_rec;

      IF p_obj_type <> 'WKST'
      THEN
          --
          FOR i IN c_market_qualifiers
          LOOP
              l_counter := l_counter+1 ;

              qual_rec.LINE_INDEX := 1;
              qual_rec.QUALIFIER_CONTEXT := i.QUALIFIER_CONTEXT;
              qual_rec.QUALIFIER_ATTRIBUTE := i.QUALIFIER_ATTRIBUTE;
              qual_rec.QUALIFIER_ATTR_VALUE_FROM := i.QUALIFIER_ATTR_VALUE;
              qual_rec.COMPARISON_OPERATOR_CODE := i.COMPARISON_OPERATOR_CODE;
              qual_rec.VALIDATED_FLAG :='Y';

              p_qual_tbl(l_counter):= qual_rec;
             --
          END LOOP;
      ELSE
         null;

          FOR i IN c_wkst_qualifiers
          LOOP
              l_counter := l_counter+1 ;

              qual_rec.LINE_INDEX := 1;
              qual_rec.QUALIFIER_CONTEXT := i.QUALIFIER_CONTEXT;
              qual_rec.QUALIFIER_ATTRIBUTE := i.QUALIFIER_ATTRIBUTE;
              qual_rec.QUALIFIER_ATTR_VALUE_FROM := i.QUALIFIER_ATTR_VALUE;
              qual_rec.COMPARISON_OPERATOR_CODE := i.COMPARISON_OPERATOR_CODE;
              qual_rec.VALIDATED_FLAG :='Y';

              p_qual_tbl(l_counter):= qual_rec;
             --
          END LOOP;

      END IF;

      -- Actual Call to the Pricing Engine
      QP_PREQ_GRP.PRICE_REQUEST
          (p_line_tbl,
           p_qual_tbl,
           p_line_attr_tbl,
           p_line_detail_tbl,
           p_line_detail_qual_tbl,
           p_line_detail_attr_tbl,
           p_related_lines_tbl,
           p_control_rec,
           x_line_tbl,
           x_line_qual,
           x_line_attr_tbl,
           x_line_detail_tbl,
           x_line_detail_qual_tbl,
           x_line_detail_attr_tbl,
           x_related_lines_tbl,
           x_return_stat,
           x_return_status_text);

     IF x_return_stat = 'E'
     THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.set_name('OZF', 'OZF_FCST_GET_LISTPRICE_FAILURE');
         FND_MESSAGE.set_token('ERR_MSG',x_return_status_text);
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
     ELSE

        I := x_line_tbl.FIRST;
        IF I IS NOT NULL
        THEN
             x_list_price := x_line_tbl(I).line_unit_price;
             l_status_code := x_line_tbl(I).status_code ;
             l_status_text := x_line_tbl(I).status_text;
        END IF;

        IF l_status_code <> 'UPDATED'
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.set_name('OZF', 'OZF_FCST_GET_LISTPRICE_FAILURE');
            FND_MESSAGE.set_token('ERR_MSG',l_status_text);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;

        END IF;

     END IF;


   EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      IF (OZF_DEBUG_HIGH_ON) THEN

      OZF_Utility_PVT.debug_message('Validate_get_list_price_of_goods: ' || substr(sqlerrm, 1, 100));
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_FCST_GET_LISTPRICE_FAILURE');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


  END get_list_price;


  --R12 : called from Wkst Forecast - Baseline
  FUNCTION get_product_list_price(
           p_activity_metric_fact_id IN  NUMBER)
  RETURN NUMBER IS

   l_api_version   CONSTANT     NUMBER := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_product_list_price';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_init_msg_list              VARCHAR2(30)  := FND_API.g_false;
   l_commit                     VARCHAR2(30)  := FND_API.g_false;
   l_return_status              VARCHAR2(1);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);

   l_list_price                 NUMBER;

   l_obj_type                   VARCHAR2(30);
   l_obj_id                     NUMBER;
   l_product_attribute_context  ozf_forecast_dimentions.product_attribute_context%TYPE;
   l_product_attribute          ozf_forecast_dimentions.product_attribute%TYPE;
   l_product_attr_value         ozf_forecast_dimentions.product_attr_value%TYPE;
   l_fcst_uom                   OZF_ACT_FORECASTS_ALL.forecast_uom_code%TYPE;
   l_currency_code              ozf_worksheet_headers_b.currency_code%TYPE;
   l_price_list_id              NUMBER;
   l_forecast_id                NUMBER;


  BEGIN

    SELECT
     fcst.ARC_ACT_FCAST_USED_BY,
     wkst.WORKSHEET_HEADER_ID,
     dim.product_attribute_context,
     dim.product_attribute,
     dim.product_attr_value,
     fcst.FORECAST_UOM_CODE,
     wkst.currency_code,
     wkst.price_list_id,
     fcst.forecast_id
    INTO
     l_obj_type           ,
     l_obj_id             ,
     l_product_attribute_context,
     l_product_attribute  ,
     l_product_attr_value ,
     l_fcst_uom           ,
     l_currency_code      ,
     l_price_list_id      ,
     l_forecast_id
    FROM
     ozf_act_metric_facts_all fact,
     OZF_ACT_FORECASTS_ALL fcst,
     ozf_forecast_dimentions dim,
     ozf_worksheet_headers_b wkst
    WHERE
         fact.activity_metric_fact_id = p_activity_metric_fact_id
     AND fcst.FORECAST_ID = fact.act_metric_used_by_id
     AND fact.arc_act_metric_used_by = 'FCST'
     AND dim.forecast_dimention_id = fact.fact_reference
     AND dim.forecast_id = fact.act_metric_used_by_id
     AND wkst.WORKSHEET_HEADER_ID = fcst.ACT_FCAST_USED_BY_ID
     AND fcst.ARC_ACT_FCAST_USED_BY = 'WKST';

     get_list_price(
                     l_api_version        ,
                     l_init_msg_list      ,
                     l_commit             ,
                     l_obj_type           ,
                     l_obj_id             ,
             l_forecast_id        ,
                     l_product_attribute  ,
                     l_product_attr_value ,
                     l_fcst_uom           ,
                     l_currency_code      ,
                     l_price_list_id      ,
                     l_list_price         ,
                     l_return_status      ,
                     l_msg_count          ,
                     l_msg_data           );

     RETURN NVL(l_list_price,0);

  EXCEPTION
      WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
        THEN
          FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        --OZF_Utility_PVT.debug_message(' get_product_list_price : OTHER ERROR ' || sqlerrm );
        FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                  p_count   => l_msg_count,
                                  p_data    => l_msg_data);
        Return 33; -- i.e. list price is ZERO
  END get_product_list_price; --end of function


  PROCEDURE calc_cost_of_goods(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_type             IN VARCHAR2,
                    p_obj_id               IN NUMBER,
                    p_product_attribute    IN VARCHAR2,
                    p_product_attr_value   IN VARCHAR2,
                    p_fcst_uom             IN VARCHAR2,

                    x_standard_cost        OUT NOCOPY NUMBER,
                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2
                   )
  IS

   l_temp_item_cost NUMBER := 0;
   l_standard_cost NUMBER := 0;
   l_flag_error boolean := false;
/*
   CURSOR c_products IS
    SELECT product_id
    FROM ozf_forecast_products
    WHERE obj_type = p_obj_type
    AND   obj_id = p_obj_id
    AND   product_attribute_context = 'ITEM'
    AND   product_attribute = p_product_attribute
    AND   product_attr_value = p_product_attr_value ;
*/
   CURSOR c_products (p_org_id NUMBER) IS
    SELECT prod.product_id,
           inv_prod.primary_uom_code
    FROM ozf_forecast_products prod,
         mtl_system_items_b inv_prod
    WHERE prod.obj_type = p_obj_type
    AND   prod.obj_id = p_obj_id
    AND   product_attribute_context = 'ITEM'
    AND   product_attribute = p_product_attribute
    AND   product_attr_value = p_product_attr_value
    AND   prod.product_id = inv_prod.inventory_item_id
    AND   inv_prod.organization_id = p_org_id;

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'Calc_Cost_Of_Goods';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  l_org_id NUMBER ;
  l_counter NUMBER := 0;
  l_conv_item_cost NUMBER;

  BEGIN

  SAVEPOINT calc_cost_of_goods;

  --  IF (OZF_DEBUG_HIGH_ON) THEN    OZF_Utility_PVT.debug_message(l_full_name || ': start refresh parties');  END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   l_org_id := FND_PROFILE.VALUE('QP_ORGANIZATION_ID') ;

   FOR i IN c_products(l_org_id)
   LOOP

     l_temp_item_cost :=  CST_COST_API.get_item_cost( 1
                                                     ,i.product_id
                                                     ,l_org_id
                                                     ,NULL
                                                     ,NULL);

     IF p_fcst_uom <> i.primary_uom_code
     THEN

        IF l_temp_item_cost IS NOT NULL
        THEN
             l_conv_item_cost :=  inv_convert.inv_um_convert( i.product_id,
                                                              null,
                                                              1,
                                                              i.primary_uom_code,
                                                              p_fcst_uom,
                                                              null, null);
        END IF;
        IF l_conv_item_cost = -99999
        THEN
           l_temp_item_cost := NULL;
        ELSE
          l_temp_item_cost := l_conv_item_cost;
        END IF;
     END IF;

     IF (l_temp_item_cost is null)
     THEN

          l_flag_error := true;
          l_standard_cost := null;

     ELSIF (l_temp_item_cost is not null)
     THEN
          l_counter := l_counter + 1;
          l_standard_cost := l_standard_cost + l_temp_item_cost;

     END IF;

   END LOOP;

   -- Cost of Good for a Item Category is always the average cost
   -- of all the items in the Category.

   IF l_standard_cost IS NOT NULL
   THEN
      x_standard_cost := round(l_standard_cost/l_counter,2);
   ELSE
      x_standard_cost := NULL;
   END IF;

   EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      -- IF (OZF_DEBUG_HIGH_ON) THEN  OZF_Utility_PVT.debug_message('Validate_Standard_Cost_Of_Goods: ' || substr(sqlerrm, 1, 100)); END IF;
      ROLLBACK TO calc_cost_of_goods;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_FCST_CALC_COG_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


 END calc_cost_of_goods;

PROCEDURE get_other_costs (p_obj_type           IN VARCHAR2,
                           p_obj_id             IN VARCHAR2,
                           p_product_attribute  IN VARCHAR2,
                           p_product_attr_value IN VARCHAR2,
                           p_uom                IN VARCHAR2,
                           p_other_costs        OUT NOCOPY VARCHAR2)
IS
    l_item_key varchar2(30);
    l_parameter_list wf_parameter_list_t;

BEGIN

  l_item_key := p_obj_id ||'_'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list := WF_PARAMETER_LIST_T();

  wf_event.AddParameterToList(p_name           => 'P_OBJ_TYPE',
                              p_value          => p_obj_type,
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_OBJ_ID',
                              p_value          => p_obj_id,
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_PRODUCT_ATTRIBUTE_CONTEXT',
                              p_value          => 'ITEM',
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_PRODUCT_ATTRIBUTE',
                              p_value          => p_product_attribute,
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_PRODUCT_ATTR_VALUE',
                              p_value          => p_product_attr_value,
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_UOM',
                              p_value          => p_uom,
                              p_parameterlist  => l_parameter_list);


  wf_event.raise3( p_event_name => 'oracle.apps.ozf.planning.OtherCosts',
                  p_event_key  => l_item_key,
                  p_parameter_list => l_parameter_list);

  p_other_costs := wf_event.GetValueForParameter(p_name => 'P_OTHER_COSTS',
                                                 p_parameterlist => l_parameter_list);

END;


  --R12 : called from Wlst Forecast - Baseline
  FUNCTION get_product_cost(
           p_activity_metric_fact_id IN  NUMBER)
  RETURN NUMBER IS

   l_api_version   CONSTANT     NUMBER := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_product_cost';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_init_msg_list              VARCHAR2(30)  := FND_API.g_false;
   l_commit                     VARCHAR2(30)  := FND_API.g_false;
   l_return_status              VARCHAR2(1);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);

   l_standard_cost              NUMBER;
   l_other_costs                NUMBER;

   l_obj_type                   VARCHAR2(30);
   l_obj_id                     NUMBER;
   l_product_attribute_context  ozf_forecast_dimentions.product_attribute_context%TYPE;
   l_product_attribute          ozf_forecast_dimentions.product_attribute%TYPE;
   l_product_attr_value         ozf_forecast_dimentions.product_attr_value%TYPE;
   l_fcst_uom                   OZF_ACT_FORECASTS_ALL.forecast_uom_code%TYPE;
   l_currency_code              ozf_worksheet_headers_b.currency_code%TYPE;
   l_price_list_id              NUMBER;


  BEGIN

    SELECT
     fcst.ARC_ACT_FCAST_USED_BY,
     wkst.WORKSHEET_HEADER_ID,
     dim.product_attribute_context,
     dim.product_attribute,
     dim.product_attr_value,
     fcst.FORECAST_UOM_CODE,
     wkst.currency_code,
     wkst.price_list_id
    INTO
     l_obj_type           ,
     l_obj_id             ,
     l_product_attribute_context,
     l_product_attribute  ,
     l_product_attr_value ,
     l_fcst_uom           ,
     l_currency_code      ,
     l_price_list_id
    FROM
     ozf_act_metric_facts_all fact,
     OZF_ACT_FORECASTS_ALL fcst,
     ozf_forecast_dimentions dim,
     ozf_worksheet_headers_b wkst
    WHERE
         fact.activity_metric_fact_id = p_activity_metric_fact_id
     AND fcst.FORECAST_ID = fact.act_metric_used_by_id
     AND fact.arc_act_metric_used_by = 'FCST'
     AND dim.forecast_dimention_id = fact.fact_reference
     AND dim.forecast_id = fact.act_metric_used_by_id
     AND wkst.WORKSHEET_HEADER_ID = fcst.ACT_FCAST_USED_BY_ID
     AND fcst.ARC_ACT_FCAST_USED_BY = 'WKST';

     calc_cost_of_goods(
                     l_api_version        ,
                     l_init_msg_list      ,
                     l_commit             ,
                     l_obj_type           ,
                     l_obj_id             ,
                     l_product_attribute  ,
                     l_product_attr_value ,
                     l_fcst_uom           ,
                     l_standard_cost      ,
                     l_return_status      ,
                     l_msg_count          ,
                     l_msg_data           );


    -- Get Other Costs here
    get_other_costs (l_obj_type ,
                     l_obj_id   ,
                     l_product_attribute  ,
                     l_product_attr_value ,
                     l_fcst_uom           ,
                     l_other_costs   ) ;



    IF l_other_costs IS NOT NULL
    THEN
       l_standard_cost := NVL(l_standard_cost,0) + l_other_costs;
    END IF;

    RETURN NVL(l_standard_cost,0);  -- return total cost for Product

  EXCEPTION
      WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
        THEN
          FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        --OZF_Utility_PVT.debug_message(' get_product_cost : OTHER ERROR ' || sqlerrm );
        FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                  p_count   => l_msg_count,
                                  p_data    => l_msg_data);
        Return 100; -- i.e. cost is ZERO
  END get_product_cost; --end of function


--R12 : gives exact or equivalent discount percent
PROCEDURE get_discount_percent (
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,
                    p_obj_type           IN VARCHAR2,
                    p_obj_id             IN NUMBER,
                    p_forecast_id        IN NUMBER,
                    p_product_attribute  IN VARCHAR2,
                    p_product_attr_value IN VARCHAR2,
                    p_currency_code      IN VARCHAR2,
                    x_tpr_percent        OUT NOCOPY NUMBER,
                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2 )
IS

    l_discount_value NUMBER := 0 ;

    CURSOR c_fcst_info IS
    SELECT a.forecast_uom_code,
           a.price_list_id
    FROM ozf_act_forecasts_all a
    WHERE a.forecast_id = p_forecast_id ;

    CURSOR c_type_of_offer IS
    SELECT offer_type
    FROM   ozf_offers
    WHERE  qp_list_header_id = p_obj_id;

    CURSOR c_offer_type IS
    SELECT min(b.offer_type) offer_type,
           sum(a.line_lumpsum_qty) total_qty
    FROM  ams_act_products a ,
          ozf_offers b
    WHERE a.arc_act_product_used_by = p_obj_type
    AND   a.act_product_used_by_id  = p_obj_id
    AND   b.qp_list_header_id = a.act_product_used_by_id ;


    CURSOR c_lumpsum_discount(p_lumpsum_qty NUMBER) IS
    SELECT DECODE(b.distribution_type,
                 'AMT', 100 * a.line_lumpsum_qty/b.lumpsum_amount,
                 '%'  , a.line_lumpsum_qty,
                 'QTY', 100 * a.line_lumpsum_qty/p_lumpsum_qty ) lumpsum_disc
    from ams_act_products a,
         ozf_offers b
    where a.arc_act_product_used_by = p_obj_type
    and a.act_product_used_by_id = p_obj_id
    and a.act_product_used_by_id = b.qp_list_header_id
    and a.excluded_flag = 'N'
    and NVL(a.inventory_item_id,a.category_id) = p_product_attr_value;

    CURSOR c_offer_discounts IS
    SELECT qpl.operand,
           qpl.arithmetic_operator
    FROM qp_pricing_attributes pa,
         qp_list_lines qpl,
         ozf_offers a
    WHERE a.qp_list_header_id = p_obj_id
    AND qpl.list_header_id = a.qp_list_header_id
    AND qpl.list_line_id = pa.list_line_id
    AND pa.excluder_flag = 'N'
    AND pa.product_attribute_context = 'ITEM'
    AND pa.product_attribute = p_product_attribute
    AND pa.product_attr_value = p_product_attr_value ;

--R12--Volume Offer Discount is MAX discount
    CURSOR c_volume_offer_discounts IS
    SELECT
       ODL.DISCOUNT_TYPE arithmetic_operator,
       MAX(DIS.DISCOUNT) operand
    FROM
       OZF_OFFERS OFFR,
       OZF_OFFER_DISCOUNT_LINES ODL,
       OZF_OFFER_DISCOUNT_PRODUCTS ODP,
       OZF_OFFER_DISCOUNT_LINES DIS
    WHERE
        OFFR.QP_LIST_HEADER_ID = p_obj_id
    AND OFFR.OFFER_ID = ODL.OFFER_ID
    AND ODL.TIER_TYPE = 'PBH'
    AND ODP.OFFER_ID = OFFR.OFFER_ID
    AND ODP.OFFER_DISCOUNT_LINE_ID = ODL.OFFER_DISCOUNT_LINE_ID
    AND ODP.APPLY_DISCOUNT_FLAG = 'Y'
    AND DIS.parent_discount_line_id = ODL.OFFER_DISCOUNT_LINE_ID
    AND DIS.TIER_TYPE = 'DIS'
    AND DIS.OFFER_ID = ODL.OFFER_ID
    AND ODP.PRODUCT_CONTEXT = 'ITEM'
    AND ODP.PRODUCT_ATTRIBUTE = p_product_attribute
    AND ODP.PRODUCT_ATTR_VALUE = p_product_attr_value
    GROUP BY
     ODL.DISCOUNT_TYPE;


    CURSOR c_wkst_discounts IS
    SELECT prd.operand,
           prd.arithmetic_operator
    from ozf_worksheet_lines prd,
         ozf_worksheet_headers_b hdr
    where 'WKST' = p_obj_type
    and hdr.worksheet_header_id = p_obj_id
    and hdr.worksheet_header_id = prd.worksheet_header_id
    AND prd.exclude_flag = 'N'
    AND prd.product_attribute_context = 'ITEM'
    AND prd.product_attribute = p_product_attribute
    AND prd.product_attr_value = p_product_attr_value;

    l_currency VARCHAR2(240);
    l_fcst_uom VARCHAR2(30);
    l_price_list_id NUMBER;
    l_list_price    NUMBER;
    l_standard_cost NUMBER;
    l_offer_type2 VARCHAR2(30);
    l_offer_type VARCHAR2(30);
    l_lumpsum_qty NUMBER;
    l_api_version   CONSTANT NUMBER       := 1.0;
    l_api_name      CONSTANT VARCHAR2(30) := 'get_discount_percent';
    l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
    l_return_status VARCHAR2(1);


BEGIN

   SAVEPOINT get_discount_percent;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


    OPEN c_fcst_info;
    FETCH c_fcst_info INTO l_fcst_uom,l_price_list_id;
    CLOSE c_fcst_info;


    get_list_price(
                   p_api_version        ,
                   p_init_msg_list      ,
                   p_commit             ,

                   p_obj_type           ,
                   p_obj_id             ,
                   p_forecast_id        ,
                   p_product_attribute  ,
                   p_product_attr_value ,
                   l_fcst_uom           ,
                   p_currency_code      ,
                   l_price_list_id      ,

                   l_list_price         ,
                   x_return_status      ,
                   x_msg_count          ,
                   x_msg_data           );

---  l_list_price := 100;

/*
    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;
*/
    IF p_obj_type = 'OFFR'
    THEN

         OPEN c_offer_type;
         FETCH c_offer_type INTO l_offer_type2, l_lumpsum_qty;
         CLOSE c_offer_type;

--R12 ---------
         OPEN c_type_of_offer;
         FETCH c_type_of_offer INTO l_offer_type;
         CLOSE c_type_of_offer;

-- Support Forecast:        LUMPSUM, ACCRUAL,DEAL,OFF_INVOICE, ORDER,TERMS, OID,VOLUME_OFFER
-- Do Not Support Forecast: SCAN_DATA, NET_ACCRUAL


         IF l_offer_type = 'LUMPSUM' --- LUMPSUM
         THEN

             OPEN c_lumpsum_discount(l_lumpsum_qty);
             FETCH c_lumpsum_discount INTO l_discount_value;
             CLOSE c_lumpsum_discount;

         ELSIF l_offer_type = 'VOLUME_OFFER'  --- VOLUME_OFFER
         THEN

                 FOR i IN c_volume_offer_discounts
                 LOOP

                     IF (i.arithmetic_operator = '%')
                     THEN
                           l_discount_value := NVL(i.operand,0);
                     ELSIF (i.arithmetic_operator = 'AMT') and NVL(l_list_price,0) <> 0
                     THEN
                           l_discount_value := 100 * NVL(i.operand,0)/ l_list_price ;
                     ELSE
                           l_discount_value := 0;
                     END IF;

                 END LOOP;


         ELSE -- ACCRUAL,DEAL,OFF_INVOICE,OID,ORDER,TERMS
                 FOR i IN c_offer_discounts
                 LOOP

                     IF (i.arithmetic_operator = '%')
                     THEN
                           l_discount_value := NVL(i.operand,0);
                     ELSIF (i.arithmetic_operator = 'NEWPRICE') and NVL(l_list_price,0) <> 0
                     THEN
                           l_discount_value := 100 * (1 - NVL(i.operand,0)/ l_list_price) ;
                     ELSIF (i.arithmetic_operator = 'AMT') and NVL(l_list_price,0) <> 0
                     THEN
                           l_discount_value := 100 * NVL(i.operand,0)/ l_list_price ;
                     ELSIF (i.arithmetic_operator = 'LUMPSUM')
                     THEN
                           l_discount_value := 0; -- Functionally, is there a better approach
                     ELSE
                           l_discount_value := 0;
                     END IF;

                 END LOOP;

         END IF;


    ELSIF p_obj_type = 'WKST'
    THEN
    ---- Worksheet Discounts (same for all offer types)

         FOR i IN c_wkst_discounts
                 LOOP

                     IF (i.arithmetic_operator = '%')
                     THEN
                           l_discount_value := NVL(i.operand,0);
                     ELSIF (i.arithmetic_operator = 'NEWPRICE') and NVL(l_list_price,0) <> 0
                     THEN
                           l_discount_value := 100 * (1 - NVL(i.operand,0)/ l_list_price) ;
                     ELSIF (i.arithmetic_operator = 'AMT') and NVL(l_list_price,0) <> 0
                     THEN
                           l_discount_value := 100 * NVL(i.operand,0)/ l_list_price ;
                     ELSIF (i.arithmetic_operator = 'LUMPSUM')
                     THEN
                           l_discount_value := 0; -- Functionally, is there a better approach
                     ELSE
                           l_discount_value := 0;
                     END IF;

                 END LOOP;

    ELSE
        l_discount_value := 0;
    END IF;

    x_tpr_percent    := l_discount_value;

EXCEPTION

    WHEN FND_API.g_exc_error THEN

      ROLLBACK TO get_discount_percent;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN

      ROLLBACK TO get_discount_percent;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO get_discount_percent;
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_FCST_GET_DISC_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


END get_discount_percent ;


PROCEDURE get_discount_info(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_type           IN VARCHAR2,
                    p_obj_id             IN NUMBER,
                    p_forecast_id        IN NUMBER,
                    p_currency_code      IN VARCHAR2,
                    p_product_attribute  IN VARCHAR2,
                    p_product_attr_value IN VARCHAR2,
                    p_node_id            IN NUMBER,

                    x_list_price         OUT NOCOPY NUMBER,
                    x_discount_type      OUT NOCOPY VARCHAR2,
                    x_discount_value     OUT NOCOPY NUMBER,
                    x_standard_cost        OUT NOCOPY NUMBER,

                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2 )
IS

    l_discount_type VARCHAR2(60);
    l_discount_value NUMBER := 0 ;

    CURSOR c_fcst_info IS
    SELECT a.forecast_uom_code,
           a.price_list_id
    FROM ozf_act_forecasts_all a
    WHERE a.forecast_id = p_forecast_id ;

    CURSOR c_offer_type IS
    SELECT min(b.offer_type) offer_type,
           sum(a.line_lumpsum_qty) total_qty
    FROM  ams_act_products a ,
          ozf_offers b
    WHERE a.arc_act_product_used_by = p_obj_type
    AND   a.act_product_used_by_id  = p_obj_id
    AND   b.qp_list_header_id = a.act_product_used_by_id ;

--R12 ----
    CURSOR c_type_of_offer IS
    SELECT offer_type
    FROM   ozf_offers
    WHERE  qp_list_header_id = p_obj_id;

    CURSOR c_lumpsum_discount(p_lumpsum_qty NUMBER) IS
    SELECT DECODE(b.distribution_type,
                 'AMT', a.line_lumpsum_qty,
                 '%'  , (b.lumpsum_amount*a.line_lumpsum_qty)/100 ,
                 'QTY', (a.line_lumpsum_qty * b.lumpsum_amount)/p_lumpsum_qty ) lumpsum_disc
    from ams_act_products a,
         ozf_offers b
    where a.arc_act_product_used_by = p_obj_type
    and a.act_product_used_by_id = p_obj_id
    and a.act_product_used_by_id = b.qp_list_header_id
    and a.excluded_flag = 'N'
    and NVL(a.inventory_item_id,a.category_id) = p_product_attr_value;

/*
                  ,'VOLUME_OFFER'
                  ,''
                  ,OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE', a.offer_type)
                  )
*/

    CURSOR c_offer_discounts IS
    SELECT TRIM(
           DECODE(a.offer_type
                  ,'DEAL'
                  ,DECODE(qpl.accrual_flag
                          ,'Y', OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE','ACCRUAL')
                              , OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE','OFF_INVOICE')
                         )
                  ,'VOLUME_OFFER'
                  ,DECODE(qpl.accrual_flag
                          ,'Y', OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE','ACCRUAL')
                              , OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE','OFF_INVOICE')
                         ) ||':'
                  , '') ||
           ' ' || qpl.operand || ' ' ||
           DECODE(qpl.arithmetic_operator,'%','%',' ')
           ) discount,
           qpl.operand,
           qpl.arithmetic_operator
    FROM qp_pricing_attributes pa,
         qp_list_lines qpl,
         ozf_offers a
    WHERE a.qp_list_header_id = p_obj_id
    AND qpl.list_header_id = a.qp_list_header_id
    AND qpl.list_line_id = pa.list_line_id
    AND pa.excluder_flag = 'N'
    AND pa.product_attribute_context = 'ITEM'
    AND pa.product_attribute = p_product_attribute
    AND pa.product_attr_value = p_product_attr_value ;


    CURSOR c_obj_discounts IS
    SELECT DECODE(a.offer_type
                  ,'DEAL'
                  ,DECODE(qpl.accrual_flag
                          ,'Y', OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE','ACCRUAL')
                              , OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE','OFF_INVOICE')
                         )
                  ,OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE', a.offer_type)
                  ) ||
           ' ' ||
           qpl.operand ||
           ' ' ||
           DECODE(qpl.arithmetic_operator,'%','%',' ') discount,
           qpl.operand,
           qpl.arithmetic_operator
    FROM qp_pricing_attributes pa,
         qp_list_lines qpl,
         ozf_act_offers a
    WHERE a.arc_act_offer_used_by = p_obj_type
    AND a.act_offer_used_by_id  = p_obj_id
    AND qpl.list_header_id = a.qp_list_header_id
    AND qpl.list_line_id = pa.list_line_id
    AND pa.excluder_flag = 'N'
    AND pa.product_attribute_context = 'ITEM'
    AND pa.product_attribute = p_product_attribute
    AND pa.product_attr_value = p_product_attr_value ;

--R12 -- Volume Offer Discounts
    CURSOR c_volume_offer_discounts IS
    SELECT TRIM(
                DECODE(OFFR.VOLUME_OFFER_TYPE
                      ,'ACCRUAL', OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE','ACCRUAL')
                                , OZF_Utility_PVT.get_lookup_meaning('OZF_OFFER_TYPE','OFF_INVOICE')
                      )
                || ':'
                || ' '
                || MAX(DIS.DISCOUNT)
                || ' '
                || DECODE(ODL.DISCOUNT_TYPE,'%','%',' ')
               ) discount,
        ODL.DISCOUNT_TYPE arithmetic_operator,
        MAX(DIS.DISCOUNT) operand
    FROM
        OZF_OFFERS OFFR,
        OZF_OFFER_DISCOUNT_LINES ODL,
        OZF_OFFER_DISCOUNT_PRODUCTS ODP,
        OZF_OFFER_DISCOUNT_LINES DIS
    WHERE
        OFFR.QP_LIST_HEADER_ID = p_obj_id
    AND OFFR.OFFER_ID = ODL.OFFER_ID
    AND ODL.TIER_TYPE = 'PBH'
    AND ODP.OFFER_ID = OFFR.OFFER_ID
    AND ODP.OFFER_DISCOUNT_LINE_ID = ODL.OFFER_DISCOUNT_LINE_ID
    AND ODP.APPLY_DISCOUNT_FLAG = 'Y'
    AND DIS.parent_discount_line_id = ODL.OFFER_DISCOUNT_LINE_ID
    AND DIS.TIER_TYPE = 'DIS'
    AND DIS.OFFER_ID = ODL.OFFER_ID
    AND ODP.PRODUCT_CONTEXT = 'ITEM'
    AND ODP.PRODUCT_ATTRIBUTE = p_product_attribute
    AND ODP.PRODUCT_ATTR_VALUE = p_product_attr_value
    GROUP BY
     ODL.DISCOUNT_TYPE,
     OFFR.VOLUME_OFFER_TYPE;

    l_currency VARCHAR2(240);
    l_fcst_uom VARCHAR2(30);
    l_price_list_id NUMBER;
    l_list_price    NUMBER;
    l_standard_cost NUMBER;

    l_offer_type2 VARCHAR2(30);
    l_offer_type VARCHAR2(30);
    l_lumpsum_qty NUMBER;

    l_api_version   CONSTANT NUMBER       := 1.0;
    l_api_name      CONSTANT VARCHAR2(30) := 'get_discount_info';
    l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
    l_return_status VARCHAR2(1);

    -- Used by other costs event
    l_item_key varchar2(30);
    l_parameter_list wf_parameter_list_t;
    l_offer_id NUMBER;
    l_other_costs VARCHAR2(2000);

BEGIN

   SAVEPOINT get_discount_info;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


    OPEN c_fcst_info;
    FETCH c_fcst_info INTO l_fcst_uom,l_price_list_id;
    CLOSE c_fcst_info;


    get_list_price(
                   p_api_version        ,
                   p_init_msg_list      ,
                   p_commit             ,

                   p_obj_type           ,
                   p_obj_id             ,
           p_forecast_id        ,
                   p_product_attribute  ,
                   p_product_attr_value ,
                   l_fcst_uom           ,
                   p_currency_code      ,
                   l_price_list_id      ,

                   l_list_price         ,
                   x_return_status      ,
                   x_msg_count          ,
                   x_msg_data           );

/*
    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;
*/
    IF p_obj_type = 'OFFR'
    THEN

         OPEN c_offer_type;
         FETCH c_offer_type INTO l_offer_type2, l_lumpsum_qty;
         CLOSE c_offer_type;

--R12---------------
         OPEN c_type_of_offer;
         FETCH c_type_of_offer INTO l_offer_type;
         CLOSE c_type_of_offer;

         IF (l_offer_type = 'LUMPSUM')
         THEN

             OPEN c_lumpsum_discount(l_lumpsum_qty);
             FETCH c_lumpsum_discount INTO l_discount_value;
             CLOSE c_lumpsum_discount;

             l_discount_type := l_offer_type;

         ELSIF (l_offer_type = 'VOLUME_OFFER')
         THEN

--begin: volume offer ------------------------------------
            IF NVL(p_node_id,2) > 1
            THEN
                 FOR i IN c_volume_offer_discounts
                 LOOP
                     IF l_discount_type IS NULL
                     THEN
                          l_discount_type := i.discount ;
                     ELSE
                          l_discount_type := l_discount_type || ' + ' ||  i.discount;
                     END IF;

                     IF (i.arithmetic_operator = '%')
                     THEN
                           l_discount_value := NVL(l_discount_value,0) +
                                              (( NVL(l_list_price,0) * NVL(i.operand,0) )/100);
                     ELSE
                           l_discount_value := NVL(l_discount_value,0) + NVL(i.operand,0) ;
                     END IF;

                 END LOOP;
            ELSE
                   l_discount_type := ' - ';
                   l_discount_value := 0 ;
            END IF;
--END: volume offer ------------------------------------

         ELSE

            IF NVL(p_node_id,2) > 1
            THEN
                 FOR i IN c_offer_discounts
                 LOOP
                     IF l_discount_type IS NULL
                     THEN
                          l_discount_type := i.discount ;
                     ELSE
                          l_discount_type := l_discount_type || ' + ' ||  i.discount;
                     END IF;

                     IF (i.arithmetic_operator = '%')
                     THEN
                           l_discount_value := NVL(l_discount_value,0) +
                                              (( NVL(l_list_price,0) * NVL(i.operand,0) )/100);
                     ELSIF (i.arithmetic_operator = 'NEWPRICE')
                     THEN
                           l_discount_value := NVL(l_discount_value,0) +  (NVL(l_list_price,0) - NVL(i.operand,0));
                     ELSE
                           l_discount_value := NVL(l_discount_value,0) + NVL(i.operand,0) ;
                     END IF;

                 END LOOP;
            ELSE
                   l_discount_type := ' - ';
                   l_discount_value := 0 ;
            END IF;

         END IF;


     ELSE

         FOR i IN c_obj_discounts
         LOOP

              IF l_discount_type IS NULL
              THEN
                  l_discount_type := i.discount ;
              ELSE
                  l_discount_type := l_discount_type || ' + ' ||  i.discount;
              END IF;

              IF (i.arithmetic_operator = '%')
              THEN
                  l_discount_value := l_discount_value + ( ( NVL(l_list_price,0) * i.operand )/100 ) ;
              ELSE
                  l_discount_value := l_discount_value + i.operand ;
              END IF;

          END LOOP;

    END IF;

    x_discount_type  := l_discount_type;
    x_discount_value := l_discount_value;
    x_list_price     := l_list_price;

    calc_cost_of_goods(
                    p_api_version,
                    p_init_msg_list,
                    p_commit       ,

                    p_obj_type     ,
                    p_obj_id       ,
                    p_product_attribute,
                    p_product_attr_value,
                    l_fcst_uom,

                    l_standard_cost ,
                    x_return_status ,
                    x_msg_count     ,
                    x_msg_data
                   ) ;

    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- x_standard_cost := l_standard_cost ;

    -- Get Other Costs here
    OZF_FORECAST_UTIL_PVT.get_other_costs (p_obj_type ,
                                           p_obj_id   ,
                                           p_product_attribute  ,
                                           p_product_attr_value ,
                                           l_fcst_uom           ,
                                           l_other_costs   ) ;

/*
  l_item_key := p_obj_id ||'_'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list := WF_PARAMETER_LIST_T();

  wf_event.AddParameterToList(p_name           => 'P_OBJ_TYPE',
                              p_value          => 'OFFR',
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_OBJ_ID',
                              p_value          => p_obj_id,
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_PRODUCT_ATTRIBUTE_CONTEXT',
                              p_value          => 'ITEM',
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_PRODUCT_ATTRIBUTE',
                              p_value          => p_product_attribute,
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_PRODUCT_ATTR_VALUE',
                              p_value          => p_product_attr_value,
                              p_parameterlist  => l_parameter_list);
  wf_event.AddParameterToList(p_name           => 'P_UOM',
                              p_value          => l_fcst_uom,
                              p_parameterlist  => l_parameter_list);


  wf_event.raise3( p_event_name => 'oracle.apps.ozf.planning.OtherCosts',
                  p_event_key  => l_item_key,
                  p_parameter_list => l_parameter_list);


  l_other_costs := wf_event.GetValueForParameter(p_name => 'P_OTHER_COSTS',
                                                p_parameterlist => l_parameter_list);
*/

    --
  IF l_other_costs IS NOT NULL
  THEN
      l_standard_cost := NVL(l_standard_cost,0) + l_other_costs;
  END IF;

    IF l_standard_cost IS NULL
    THEN

      NULL;
/*
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_COG_MISSING');
             FND_MESSAGE.Set_Token('PRODUCT', p_product_attr_value );
             FND_MSG_PUB.Add;
             RAISE FND_API.g_exc_error;
        END IF;
*/
    ELSE
       x_standard_cost := l_standard_cost;
    END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN

      ROLLBACK TO get_discount_info;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN FND_API.g_exc_unexpected_error THEN

      ROLLBACK TO get_discount_info;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO get_discount_info;
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_FCST_GET_DISC_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


END get_discount_info ;



PROCEDURE get_actual_sales(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_type             IN VARCHAR2,
                    p_obj_id               IN NUMBER,
                    p_product_attribute    IN VARCHAR2,
                    p_product_attr_value   IN VARCHAR2,
                    p_fcst_uom             IN VARCHAR2,
                    p_cogs                 IN NUMBER,

                    x_actual_units         OUT NOCOPY NUMBER,
                    x_actual_revenue       OUT NOCOPY NUMBER,
                    x_actual_costs         OUT NOCOPY NUMBER,
                    x_roi                  OUT NOCOPY NUMBER,

                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2 )
IS

CURSOR c_actual_data IS
SELECT o.offer_type,
       p.product_id,
       line.order_quantity_uom,
       NVL(line.shipped_quantity, line.ordered_quantity) ordered_quantity,
       inv_convert.inv_um_convert( p.product_id,
                                   null,
                                   DECODE(line.line_category_code
                                          ,'ORDER', line.shipped_quantity
                                                  ,-NVL(line.shipped_quantity,line.ordered_quantity)
                                         ),
                                   line.order_quantity_uom,
                                   p_fcst_uom,
                                   null, null) conv_ordered_quantity,
       DECODE(line.line_category_code,
              'ORDER', line.unit_list_price,
                      -line.unit_list_price) unit_list_price,
       DECODE(line.line_category_code,
              'ORDER', -adj.adjusted_amount
                     ,  adj.adjusted_amount) adjusted_amount,
       adj.accrual_flag
FROM   ozf_forecast_products p,
       ozf_offers o,
       oe_price_adjustments adj,
       oe_order_lines_all line
WHERE p.obj_type = p_obj_type
AND   p.obj_id   = p_obj_id
AND   p.product_attribute_context = 'ITEM'
AND   p.product_attribute = p_product_attribute
AND   p.product_attr_value = p_product_attr_value
AND   o.qp_list_header_id = p.obj_id
AND   adj.list_header_id = p.obj_id
AND   adj.line_id = line.line_id
AND   line.inventory_item_id = p.product_id
AND   line.open_flag = 'N'
AND   line.cancelled_flag = 'N';

--
-- AND << add filter on oe_order_lines to pick closed lines >>
-- AND << add filter to process returns >>
--

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'get_actual_sales';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

   l_actual_revenue     NUMBER ;
   l_tot_actual_revenue NUMBER := 0;

   l_roi_revenue        NUMBER ;
   l_tot_roi_revenue    NUMBER := 0;

   l_promotion_cost     NUMBER ;
   l_tot_promotion_cost NUMBER := 0;

   l_actual_units       NUMBER ;
   l_tot_actual_units   NUMBER := 0;

   l_actual_costs       NUMBER ;
   l_is_disc_exp        VARCHAR2(10) := FND_PROFILE.VALUE('OZF_TREAT_DISCOUNT_AS_EXPENSE') ;

BEGIN

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;


   FOR i IN c_actual_data
   LOOP

       IF l_is_disc_exp = 'Y'
       THEN
           -- Discount must be treated as expense.
           -- It will increase the cost and does not effect the revenue
           l_actual_revenue := i.ordered_quantity * i.unit_list_price ;
           l_promotion_cost := i.ordered_quantity * i.adjusted_amount ;
       ELSE
           -- Discount is not an expense
           -- It will reduce the revenue and does not effect the cost
           l_actual_revenue :=  i.ordered_quantity * (i.unit_list_price - i.adjusted_amount);
           l_promotion_cost := 0;
       END IF;

       l_tot_actual_revenue := l_tot_actual_revenue + l_actual_revenue;
       l_tot_actual_units   := l_tot_actual_units   + i.conv_ordered_quantity;
       l_tot_promotion_cost := l_tot_promotion_cost + l_promotion_cost;


/*
       IF i.accrual_flag = 'Y'
       THEN
           l_actual_revenue := i.ordered_quantity * i.unit_list_price ;
           l_roi_revenue := i.ordered_quantity * i.unit_list_price;
       ELSE
           l_actual_revenue := i.ordered_quantity * (i.unit_list_price - i.adjusted_amount);
           l_roi_revenue := i.ordered_quantity * i.unit_list_price ;
       END IF;

       l_promotion_cost := i.ordered_quantity * i.adjusted_amount;

       l_tot_actual_revenue := l_tot_actual_revenue + l_actual_revenue;
       l_tot_roi_revenue    := l_tot_roi_revenue + l_roi_revenue;
       l_tot_actual_units   := l_tot_actual_units + i.conv_ordered_quantity;
       l_tot_promotion_cost := l_tot_promotion_cost + l_promotion_cost;
*/

   END LOOP;

   l_actual_units   := l_tot_actual_units;
   l_actual_revenue := l_tot_actual_revenue;
   l_actual_costs   := (l_actual_units * p_cogs) + l_tot_promotion_cost;

   x_roi := round((l_tot_actual_revenue - l_actual_costs)/l_actual_costs,2) ;

   x_actual_units   := l_actual_units;
   x_actual_revenue := l_actual_revenue;
   x_actual_costs   := l_actual_costs;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

END get_actual_sales;


PROCEDURE allocate_facts(
                      p_api_version        IN  NUMBER,
                      p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                      p_commit             IN  VARCHAR2  := FND_API.g_false,

                      p_used_by_id IN NUMBER,
                      p_dimention  IN VARCHAR2,

                      x_return_status      OUT NOCOPY VARCHAR2,
                      x_msg_count          OUT NOCOPY NUMBER,
                      x_msg_data           OUT NOCOPY VARCHAR2
                   ) IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'Allocate_Facts';
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

   -- RUP1: Modified Where Clause

   CURSOR c1 IS
   SELECT a.offer_type,
          nvl(a.transaction_currency_code,a.fund_request_curr_code),
          b.forecast_spread_type
   FROM ozf_offers a,
        ozf_act_forecasts_all b
   WHERE b.forecast_id = p_used_by_id
   AND   DECODE(b.arc_act_fcast_used_by,'OFFR',b.act_fcast_used_by_id,-99)
                       = a.qp_list_header_id(+);

   CURSOR c2 IS
   SELECT distinct count(act_metric_used_by_id)
   FROM  ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND   act_metric_used_by_id = p_used_by_id
   AND   fact_type = p_dimention
   GROUP by previous_fact_id;

   l_offer_type VARCHAR2(30);
   l_currency_code VARCHAR2(30);
   l_spread_type VARCHAR2(30);

   l_dimention_count NUMBER := 0;

BEGIN

   SAVEPOINT allocate_facts;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c1;
   FETCH c1 INTO l_offer_type, l_currency_code, l_spread_type;
   CLOSE c1;

   IF (l_offer_type = 'OID' AND p_dimention='PRODUCT')
   THEN
         allocate_pg_facts( p_api_version ,
                            p_init_msg_list,
                            p_commit,
                            p_used_by_id  ,
                            p_dimention   ,
                            l_currency_code,
                            x_return_status ,
                            x_msg_count  ,
                            x_msg_data  );

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
   ELSE
   -- Update all records

   IF (l_spread_type <> 'BASELINE_RATIO')
   THEN
        OPEN c2;
        FETCH c2 INTO l_dimention_count;
        CLOSE c2;
   END IF;

   UPDATE ozf_act_metric_facts_all f
   SET (fact_value, fact_percent, forward_buy_quantity ) =
   ( SELECT ROUND( a.fact_value ) ,
            ROUND( a.fact_value * 100 / a.total_forecast_quantity ) fact_percent,
            ROUND( (a.fact_value * 100 / a.total_forecast_quantity)
                  * DECODE(f.fact_type,'TIME',0,a.total_forward_buy_quantity)
                  * 0.01 ) forward_buy_quantity
      FROM
          ( SELECT DECODE(fcst.forecast_spread_type , 'BASELINE_RATIO'
                          ,         ( NVL(previous_fact.fact_value,fcst.forecast_quantity)
                                      * fact.base_quantity
                                    )/DECODE( NVL(previous_fact.base_quantity, fcst.base_quantity),0,1,
                                            NVL(previous_fact.base_quantity, fcst.base_quantity)
                                          )

                          ,       ( NVL(previous_fact.fact_value, fcst.forecast_quantity)/l_dimention_count
                                  /*( SELECT COUNT(f1.act_metric_used_by_id)
                                      FROM ozf_act_metric_facts_all f1
                                      WHERE f1.act_metric_used_by_id = fact.act_metric_used_by_id
                                      AND   f1.arc_act_metric_used_by = 'FCST'
                                      AND   f1.fact_type= p_dimention
                                      AND   NVL(f1.previous_fact_id,-99) =
                                                    NVL(previous_fact.activity_metric_fact_id,-99)
                                    ) */
                                   )
                         ) fact_value,
                    fact.activity_metric_fact_id,
                    DECODE( NVL(previous_fact.fact_value, fcst.forecast_quantity),
                            0,1,
                            NVL(previous_fact.fact_value, fcst.forecast_quantity)
                          ) total_forecast_quantity,
                    NVL(previous_fact.forward_buy_quantity, fcst.forward_buy_quantity) total_forward_buy_quantity
            FROM
                 ozf_act_forecasts_all fcst,
                 ozf_act_metric_facts_all fact,
                 ozf_act_metric_facts_all previous_fact
            WHERE
                 fact.act_metric_used_by_id = fcst.forecast_id
            AND  fact.previous_fact_id = previous_fact.activity_metric_fact_id(+)
            AND  fact.act_metric_used_by_id = p_used_by_id
            AND  fact.arc_act_metric_used_by = 'FCST'
            AND  fact.fact_type = p_dimention
          ) a
      WHERE a.activity_metric_fact_id = f.activity_metric_fact_id
   )
   WHERE f.act_metric_used_by_id = p_used_by_id
   AND   f.arc_act_metric_used_by = 'FCST'
   AND   f.fact_type = p_dimention ;

   END IF;
  -- Adjust the last record

   UPDATE ozf_act_metric_facts_all f
   SET ( fact_value, forward_buy_quantity)   =
       ( SELECT f.fact_value + a.adj_fact_value,
                f.forward_buy_quantity + a.adj_fwd_buy_quantity
         FROM
              ( SELECT   NVL(MIN(previous_fact.fact_value), MIN(fcst.forecast_quantity)) -
                         SUM(fact.fact_value) adj_fact_value,
                         NVL(MIN(previous_fact.forward_buy_quantity), MIN(fcst.forward_buy_quantity)) -
                         SUM(fact.forward_buy_quantity) adj_fwd_buy_quantity,
                         MAX(fact.activity_metric_fact_id) activity_metric_fact_id
                FROM ozf_act_forecasts_all fcst,
                     ozf_act_metric_facts_all fact,
                     ozf_act_metric_facts_all previous_fact
                WHERE fact.act_metric_used_by_id = p_used_by_id
                AND   fact.arc_act_metric_used_by = 'FCST'
                AND   fact.fact_type = p_dimention
                AND   fact.act_metric_used_by_id = fcst.forecast_id
                AND   NVL(fact.node_id,1) <> 3
                AND   fact.previous_fact_id = previous_fact.activity_metric_fact_id(+)
                GROUP BY fact.previous_fact_id
              ) a
         WHERE a.activity_metric_fact_id = f.activity_metric_fact_id
       )
    WHERE activity_metric_fact_id in (SELECT MAX(activity_metric_fact_id)
                                     FROM ozf_act_metric_facts_all
                                     WHERE act_metric_used_by_id = p_used_by_id
                                     AND   arc_act_metric_used_by = 'FCST'
                                     AND   fact_type =  p_dimention
                                     AND   NVL(node_id,1) <> 3
                                     GROUP BY previous_fact_id ) ;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO allocate_facts ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  allocate_facts;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  allocate_facts;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

END allocate_facts ;



PROCEDURE get_volume_offer_discount(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_type             IN VARCHAR2,
                    p_obj_id               IN NUMBER,
                    p_forecast_id          IN NUMBER,
                    p_currency_code        IN VARCHAR2,

                    p_product_attribute    IN VARCHAR2,
                    p_product_attr_value   IN VARCHAR2,

                    x_discount_type_code   OUT NOCOPY VARCHAR2,
                    x_discount             OUT NOCOPY NUMBER,

                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2 )
IS

    l_last_discount NUMBER :=0;
    l_discount NUMBER ;
    l_counter NUMBER := 0;
    l_volume_type NUMBER := 0;
    l_overall_volume NUMBER := 0;
    l_overall_fcst_volume NUMBER := 0;
    l_overall_converted_volume NUMBER := 0;
    l_flag_first_visit BOOLEAN := true;
    l_flag_error BOOLEAN := false;
    l_list_price NUMBER;
    l_fcst_uom VARCHAR2(30);
    l_price_list_id NUMBER;

    CURSOR c_fcst_info IS
    SELECT a.forecast_uom_code,
           a.price_list_id
    FROM ozf_act_forecasts_all a
    WHERE a.forecast_id = p_forecast_id ;

--R12 ---
    CURSOR c_fcst_products_info (p_offer_discount_line_id NUMBER) IS
    SELECT dim.product_attribute,
           dim.product_attribute_context,
           dim.product_attr_value,
           prod.qty,
           prod.forecast_dimention_id
    FROM ozf_forecast_dimentions dim,
         (select fact.fact_reference forecast_dimention_id,
                 DECODE(fcst.BASE_QUANTITY_TYPE,
                        'BASELINE',
                        SUM(fact.BASELINE_SALES + fact.INCREMENTAL_SALES),
                        sum(fact.fact_value)) qty
          from ozf_act_metric_facts_all fact,
               OZF_ACT_FORECASTS_ALL fcst
          where fact.fact_type = 'PRODUCT'
          and fact.arc_act_metric_used_by = 'FCST'
          and fact.act_metric_used_by_id = p_forecast_id
          AND FACT.ACT_METRIC_USED_BY_ID = FCST.FORECAST_ID
          group by fact.fact_reference,fcst.BASE_QUANTITY_TYPE) prod,
          OZF_OFFER_DISCOUNT_LINES ODL,
          OZF_OFFER_DISCOUNT_PRODUCTS ODP
    WHERE prod.forecast_dimention_id = dim.forecast_dimention_id
      AND dim.forecast_id = p_forecast_id
      AND ODL.OFFER_DISCOUNT_LINE_ID = p_offer_discount_line_id
      AND ODL.TIER_TYPE = 'PBH'
      AND ODP.OFFER_DISCOUNT_LINE_ID = ODL.OFFER_DISCOUNT_LINE_ID
--      AND ODP.APPLY_DISCOUNT_FLAG = 'Y'
      AND ODP.INCLUDE_VOLUME_FLAG = 'Y' -- get those products whoose sales is to be counted
      AND ODP.PRODUCT_CONTEXT = dim.product_attribute_context
      AND ODP.PRODUCT_ATTRIBUTE = dim.product_attribute
      AND ODP.PRODUCT_ATTR_VALUE = dim.product_attr_value;

/*
    CURSOR c_fcst_products_info IS
    SELECT dim.product_attribute,
           dim.product_attribute_context,
           dim.product_attr_value,
           prod.qty,
           prod.forecast_dimention_id
    FROM ozf_forecast_dimentions dim,
         (select fact_reference forecast_dimention_id, sum(fact_value) qty
          from ozf_act_metric_facts_all
          where fact_type = 'PRODUCT'
          and arc_act_metric_used_by = 'FCST'
          and act_metric_used_by_id = p_forecast_id
          group by fact_reference ) prod
    WHERE prod.forecast_dimention_id = dim.forecast_dimention_id
     AND dim.forecast_id = p_forecast_id;
*/

--R12 ----
    CURSOR c_volume_tiers_info IS
    SELECT
      ODP.OFFER_DISCOUNT_LINE_ID ,
      DIS.volume_from   tier_value_from,
      DIS.volume_to     tier_value_to,
      DIS.discount      discount,
      ODL.discount_type discount_type_code,
      ODL.volume_type   volume_type,
      ODL.uom_code      uom_code
    FROM
      OZF_OFFERS OFFR,
      OZF_OFFER_DISCOUNT_LINES ODL,
      OZF_OFFER_DISCOUNT_PRODUCTS ODP,
      OZF_OFFER_DISCOUNT_LINES DIS
    WHERE
        OFFR.QP_LIST_HEADER_ID = p_obj_id
    AND OFFR.OFFER_ID = ODL.OFFER_ID
    AND ODL.TIER_TYPE = 'PBH'
    AND ODP.OFFER_ID = OFFR.OFFER_ID
    AND ODP.OFFER_DISCOUNT_LINE_ID = ODL.OFFER_DISCOUNT_LINE_ID
    AND ODP.APPLY_DISCOUNT_FLAG = 'Y'
    AND DIS.parent_discount_line_id = ODL.OFFER_DISCOUNT_LINE_ID
    AND DIS.TIER_TYPE = 'DIS'
    AND DIS.OFFER_ID = ODL.OFFER_ID
    AND ODP.PRODUCT_CONTEXT = 'ITEM'
    AND ODP.PRODUCT_ATTRIBUTE = p_product_attribute
    AND ODP.PRODUCT_ATTR_VALUE = p_product_attr_value;

/*
    CURSOR c_volume_tiers_info IS
    SELECT tier_value_from,
           tier_value_to,
           discount,
           discount_type_code,
           volume_type,
           uom_code
    FROM ozf_volume_offer_tiers
    WHERE qp_list_header_id = p_obj_id;
*/


   CURSOR c_fcst_to_voloffr_uom_conv(l_fcst_qty IN NUMBER,
                                      l_fcst_uom IN VARCHAR2,
                                      l_voloffr_uom IN VARCHAR2) IS
   SELECT inv_convert.inv_um_convert( null,
                                      null,
                                      l_fcst_qty,
                                      l_fcst_uom,
                                      l_voloffr_uom, null, null) converted_qty
   from dual;

    l_api_version   CONSTANT NUMBER       := 1.0;
    l_api_name      CONSTANT VARCHAR2(30) := 'get_volume_offer_discount';
    l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
    l_return_status VARCHAR2(1);

BEGIN

   SAVEPOINT get_volume_offer_discount;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_fcst_info;
   FETCH c_fcst_info INTO l_fcst_uom,l_price_list_id;
   CLOSE c_fcst_info;

   FOR i IN c_volume_tiers_info
    LOOP
     -- Do this only once when initial counter is = 0;
     IF (l_counter = 0) THEN
        IF (i.volume_type = 'PRICING_ATTRIBUTE10') THEN
           l_volume_type := 1;
           FOR j IN c_fcst_products_info (i.offer_discount_line_id)
           LOOP
                l_overall_fcst_volume := l_overall_fcst_volume + j.qty;
           END LOOP;
        ELSIF (i.volume_type = 'PRICING_ATTRIBUTE12') THEN
           l_volume_type := 2;
           FOR j IN c_fcst_products_info (i.offer_discount_line_id)
           LOOP
                get_list_price(
                        p_api_version        ,
                        p_init_msg_list      ,
                        p_commit             ,

                        p_obj_type           ,
                        p_obj_id             ,
            p_forecast_id        ,
                        j.product_attribute  ,
                        j.product_attr_value ,
                        l_fcst_uom           ,
                        p_currency_code      ,
                        l_price_list_id      ,

                        l_list_price         ,
                        x_return_status      ,
                        x_msg_count          ,
                        x_msg_data           );
/*
                IF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                END IF;
*/
                -- Get List price and multiply by quantity to get overall value in amount
                l_overall_volume := l_overall_volume + l_list_price * j.qty ;
           END LOOP;
        END IF;

        l_counter := 1;
        x_discount_type_code := i.discount_type_code;

     END IF;


     IF( (l_volume_type = 1) AND (l_flag_first_visit = true) ) THEN

           OPEN c_fcst_to_voloffr_uom_conv(l_overall_fcst_volume, l_fcst_uom, i.uom_code);
           FETCH c_fcst_to_voloffr_uom_conv INTO l_overall_volume ;
           CLOSE c_fcst_to_voloffr_uom_conv ;

           IF l_overall_volume = -99999
           THEN

                l_flag_error := true;

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_UOM_CONVERSION_MISSING');
                      FND_MESSAGE.Set_Token('CURRENT_UOM', l_fcst_uom); -- replace with p_fcst_uom
                      FND_MESSAGE.Set_Token('ORDER_UOM', i.uom_code);
                      FND_MSG_PUB.Add;
                END IF;

           END IF;

           IF(l_flag_error = true) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
           END IF;

           -- Set to false since we need to find this overall converted volume just once
           l_flag_first_visit := false;

     END IF;

     -- Compare this overall number with the tier number ranges and get the discount. Set the discount and code.
/*
     IF ( (i.tier_value_from IS NOT NULL) AND
          (i.tier_value_to IS NOT NULL) AND
          (l_overall_volume >= i.tier_value_from) AND
          (l_overall_volume <= i.tier_value_to) )
     THEN
        l_discount := i.discount;
        EXIT;
     END IF;
*/

     IF l_overall_volume <= NVL(i.tier_value_to,l_overall_volume)
     THEN
       l_discount := i.discount;
       EXIT;
     END IF;
     l_last_discount := i.discount;
   END LOOP;

   IF( l_discount IS NOT NULL ) THEN
        x_discount := l_discount;
   ELSE
        x_discount := l_last_discount;
   END IF;


EXCEPTION

WHEN FND_API.g_exc_error THEN

      ROLLBACK TO get_volume_offer_discount;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

WHEN FND_API.g_exc_unexpected_error THEN

      ROLLBACK TO get_volume_offer_discount;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

WHEN OTHERS THEN

      ROLLBACK TO get_volume_offer_discount;
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_GET_VOLUME_OFFER_DISCOUNT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END get_volume_offer_discount;



PROCEDURE allocate_pg_facts(
                      p_api_version        IN  NUMBER,
                      p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
                      p_commit             IN  VARCHAR2  := FND_API.g_false,

                      p_used_by_id IN NUMBER,
                      p_dimention  IN VARCHAR2,
                      p_currency_code IN VARCHAR2,

                      x_return_status      OUT NOCOPY VARCHAR2,
                      x_msg_count          OUT NOCOPY NUMBER,
                      x_msg_data           OUT NOCOPY VARCHAR2
                   ) IS

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'allocate_pg_facts';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  TYPE products_ratio_rec IS RECORD
  (
     product_attribute_context  VARCHAR2(30),
     product_attribute          VARCHAR2(30),
     product_attr_value         VARCHAR2(240),
     ratio_qty                  NUMBER,
     node_id                    NUMBER(1)
  );

  TYPE products_ratio_tbl IS TABLE OF products_ratio_rec;

  CURSOR get_product_facts IS
  select  dim.product_attribute_context,
          dim.product_attribute,
          dim.product_attr_value,
          fact.activity_metric_fact_id,
          fact.node_id,
          NVL(previous_fact.fact_value,fcst.forecast_quantity) total_forecast,
          NVL(previous_fact.forward_buy_quantity, fcst.forward_buy_quantity) total_forward_buy,
          fcst.forecast_uom_code
  from ozf_act_metric_facts_all fact,
       ozf_forecast_dimentions dim ,
       ozf_act_metric_facts_all previous_fact,
       ozf_act_forecasts_all fcst
  where fcst.forecast_id = p_used_by_id
  and   fact.arc_act_metric_used_by = 'FCST'
  and   fact.act_metric_used_by_id = fcst.forecast_id
  and   fact.fact_type = p_dimention
  and   fact.fact_reference = dim.forecast_dimention_id
  AND   dim.forecast_id = p_used_by_id
  and   fact.previous_fact_id = previous_fact.activity_metric_fact_id(+)
  order by fact.activity_metric_fact_id;

  CURSOR get_all_ratios IS
  select NVL(prod.pricing_attribute,'PRICING_ATTRIBUTE10') pricing_attribute,
         DECODE(disc.list_line_type_code,
                'DIS',disc.benefit_uom_code
                 ,prod.product_uom_code) offer_product_uom_code,
         DECODE(disc.list_line_type_code,
                 'DIS',disc.benefit_qty
                 ,prod.pricing_attr_value_from) offer_product_qty,
         fcst.forecast_uom_code,
         inv_convert.inv_um_convert(
                   null,
                   null,
                   DECODE(disc.list_line_type_code,
                         'DIS',disc.benefit_qty
                         ,prod.pricing_attr_value_from) ,
                    DECODE(disc.list_line_type_code,
                          'DIS',disc.benefit_uom_code
                          ,prod.product_uom_code) ,
                   fcst.forecast_uom_code,
                   null,
                   null) converted_ratio,
         disc.operand,
         disc.arithmetic_operator,
         prod.product_attribute_context,
         prod.product_attribute,
         prod.product_attr_value,
         disc.list_line_type_code,
         fcst.price_list_id,
         disc.list_header_id
  from  qp_pricing_attributes prod,
        qp_list_lines disc,
        ozf_act_forecasts_all fcst
  where fcst.forecast_id = p_used_by_id
  and  fcst.arc_act_fcast_used_by = 'OFFR'
  and  disc.list_header_id = fcst.act_fcast_used_by_id
  and  disc.list_line_id = prod.list_line_id;

  l_fact_forward_buy   NUMBER;
  l_total_forecast     NUMBER;
  l_list_price         NUMBER;
  l_rec_count          NUMBER := 0;
  l_fact_value         NUMBER;
  l_fact_percent       NUMBER;
  l_ratio              NUMBER;
  l_total_ratio        NUMBER := 0;
  l_per_unit_value     NUMBER := 0;
  l_flag_error boolean := false;
  l_products_ratio_tbl products_ratio_tbl;

BEGIN

   SAVEPOINT allocate_pg_facts;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   /*
      1. Get all conversions first
      2. If pricing_attribute is PRICING_ATTRBUTE12, then the Buy is in
         amount. Convert the amount into quantity.
      3. If all conversions are complete, then populated the product_ration_tbl
   */

    l_products_ratio_tbl := products_ratio_tbl();


    FOR i IN get_all_ratios
    LOOP
        l_ratio := 0;


        IF i.pricing_attribute = 'PRICING_ATTRIBUTE10'
        THEN
             IF i.converted_ratio = -99999
             THEN
                  l_flag_error := true;

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        FND_MESSAGE.Set_Name ('OZF', 'OZF_TP_UOM_CONVERSION_MISSING');
                        FND_MESSAGE.Set_Token('CURRENT_UOM', i.forecast_uom_code);
                        FND_MESSAGE.Set_Token('ORDER_UOM', i.offer_product_uom_code);
                        FND_MSG_PUB.Add;
                  END IF;
             ELSE
                  l_ratio :=  i.converted_ratio ;
             END IF;
        ELSE

            IF i.price_list_id IS NULL
            THEN
                  l_flag_error := true;

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      FND_MESSAGE.Set_Name ('OZF', 'OZF_PRICE_LIST_NEEDED');
                      FND_MSG_PUB.Add;
                  END IF;

            ELSE

             get_list_price(
                        p_api_version        ,
                        p_init_msg_list      ,
                        p_commit             ,

                        'OFFR'               ,
                        i.list_header_id     ,
            p_used_by_id         , -- forecast_id
                        i.product_attribute  ,
                        i.product_attr_value ,
                        i.forecast_uom_code  ,
                        p_currency_code      ,
                        i.price_list_id      ,

                        l_list_price         ,
                        x_return_status      ,
                        x_msg_count          ,
                        x_msg_data           );

             IF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
             ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
             END IF;

             l_ratio := i.offer_product_qty/l_list_price ;

             END IF;

        END IF;

        l_rec_count := l_rec_count + 1;
        l_products_ratio_tbl.extend;
        l_products_ratio_tbl(l_rec_count).product_attribute_context := i.product_attribute_context;
        l_products_ratio_tbl(l_rec_count).product_attribute         := i.product_attribute;
        l_products_ratio_tbl(l_rec_count).product_attr_value        := i.product_attr_value;
        l_products_ratio_tbl(l_rec_count).ratio_qty                 := l_ratio;

        IF (i.list_line_type_code = 'DIS')
        THEN
            IF (i.operand = 100 AND i.arithmetic_operator = '%')
            THEN
                l_products_ratio_tbl(l_rec_count).node_id  := 3;
            ELSE
                l_products_ratio_tbl(l_rec_count).node_id  := 2;
                l_total_ratio := l_total_ratio + l_ratio;
            END IF;
        ELSE
            l_products_ratio_tbl(l_rec_count).node_id  := 1;
            l_total_ratio := l_total_ratio + l_ratio;
        END IF;

    END LOOP;

    IF(l_flag_error = true)
    THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Proceed only when all the conversions and ratios are resolved

    l_ratio := 0;

    FOR i IN get_product_facts
    LOOP

         FOR j IN 1..l_products_ratio_tbl.count
         LOOP

            IF ( l_products_ratio_tbl(j).product_attribute = i.product_attribute
                 AND
                 l_products_ratio_tbl(j).product_attr_value = i.product_attr_value
                 AND
                 l_products_ratio_tbl(j).node_id = i.node_id
               )
            THEN
                 l_ratio := l_products_ratio_tbl(j).ratio_qty;
                 EXIT;
           END IF;

         END LOOP;

         IF i.node_id = 3
         THEN
              l_per_unit_value := round(i.total_forecast/l_total_ratio) ;
              l_fact_value := l_per_unit_value * l_ratio;
              l_fact_percent := 0;
         ELSE
              IF (i.total_forecast = 0)
              THEN
                  l_total_forecast := 1;
              ELSE
                  l_total_forecast := i.total_forecast ;
              END IF;

              l_fact_value :=  round( (i.total_forecast*l_ratio)/l_total_ratio );
              l_fact_percent := round(l_fact_value*100/l_total_forecast);
              l_fact_forward_buy := round( (i.total_forward_buy*l_ratio)/l_total_ratio );

         END IF;

         UPDATE ozf_act_metric_facts_all
         SET    fact_value = l_fact_value,
                fact_percent = l_fact_percent,
                forward_buy_quantity = l_fact_forward_buy
         WHERE  activity_metric_fact_id = i.activity_metric_fact_id;

    END LOOP;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO allocate_pg_facts ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  allocate_pg_facts;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  allocate_pg_facts;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

END ;

PROCEDURE cascade_baseline_update(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
    p_commit             IN  VARCHAR2  := FND_API.g_false,
    p_id                 IN  NUMBER,
    p_value              IN  NUMBER,
    p_fcast_id           IN  NUMBER,
    p_rem_value          IN  NUMBER,
    p_cascade_flag       IN  NUMBER,
    p_tpr_percent        IN  NUMBER,
    p_obj_type           IN  VARCHAR2,
    p_obj_id             IN  NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
 )
  IS

  l_fact_percent NUMBER := 0;
  l_fact_value NUMBER := 0;
  l_parent_fact_value NUMBER := 0;
  l_tpr_percent NUMBER := 0;
  l_fact_type VARCHAR2(10);
  l_temp_parent_fact_value NUMBER := 0;
  l_cascade_flag NUMBER := 0;

  l_temp_count NUMBER := 0;
  l_temp_sub_count NUMBER := 0;
  l_temp_counter NUMBER := 0;
  l_temp_sub_counter NUMBER := 0;
  l_fval_sum_minus_last_rec NUMBER := 0;
  l_fact_value_sum_all_recs NUMBER := 0;
  l_temp_sub_previous_fact_id NUMBER := 1;
  l_fact_value_sum_all_sub_recs NUMBER := 0;
  l_total_rem_value NUMBER := 0;

  l_current_fact_value NUMBER := 0;
  l_rem_value NUMBER := 0;
  l_new_incr NUMBER := 0;
  l_delta NUMBER := 0;

  CURSOR C_FindRecords(p_prev_id IN NUMBER,
                       p_fcast_id IN NUMBER ) IS
  SELECT activity_metric_fact_id,
                previous_fact_id,
                forecast_remaining_quantity,
                fact_type,
                fact_reference,
                from_date,
                to_date,
                incremental_sales,
                root_fact_id
  FROM ozf_act_metric_facts_all
  WHERE arc_act_metric_used_by = 'FCST'
  AND act_metric_used_by_id = p_fcast_id
  AND previous_fact_id = p_prev_id
  order by 6;

  CURSOR C_FindSubRecords(p_prev_id IN NUMBER,
                          p_fcast_id IN NUMBER ) IS
  SELECT activity_metric_fact_id,
         previous_fact_id,
         fact_type,
         fact_reference,
         from_date,
         to_date,
         incremental_sales,
         root_fact_id
  FROM ozf_act_metric_facts_all
  WHERE arc_act_metric_used_by = 'FCST'
  AND act_metric_used_by_id = p_fcast_id
  AND previous_fact_id = p_prev_id
  AND root_fact_id IS NOT NULL
  order by 6;

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'Cascade_Baseline_Update';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  l_delta := p_rem_value;

  -- fact_value is the incremental_sales

  IF (p_cascade_flag = 4) THEN
    -- Cascade_Baseline_Update called directly (not from Cascade_baseline_levels)
    -- Get the fact value for the parent
    SELECT incremental_sales, tpr_percent, fact_type
    INTO l_parent_fact_value, l_tpr_percent, l_fact_type
    FROM ozf_act_metric_facts_all
    WHERE arc_act_metric_used_by = 'FCST'
    AND act_metric_used_by_id = p_fcast_id
    AND activity_metric_fact_id = p_id;

    IF ( l_fact_type = 'PRODUCT' AND p_tpr_percent <> l_tpr_percent ) THEN
        adjust_baseline_spreads(l_api_version,
                  p_init_msg_list,
                  p_commit,
                  p_obj_type,
                  p_obj_id,
                  p_fcast_id,
                  p_id,
                  p_tpr_percent,
                  l_new_incr,
                  l_return_status,
                  x_msg_count,
                  x_msg_data
        );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        GOTO end_of_cascade_baseline_update;

    END IF;

    IF ( p_value = l_parent_fact_value)  THEN
        l_cascade_flag := 0;
    ELSIF (p_value <> l_parent_fact_value) THEN
        l_cascade_flag := 1;
    END IF;

  ELSIF (p_cascade_flag <> 4) THEN
    -- Cascade_Baseline_Update called from Cascade_baseline_levels procedure
    l_cascade_flag := p_cascade_flag;
  END IF;

  --Only do something if values have been changed
  IF ( l_cascade_flag <> 0 ) THEN

    SELECT count(*), sum(incremental_sales)
    INTO l_temp_count, l_fact_value_sum_all_recs
    FROM ozf_act_metric_facts_all
    WHERE arc_act_metric_used_by = 'FCST'
    AND act_metric_used_by_id = p_fcast_id
    AND previous_fact_id = p_id;

    SELECT incremental_sales, forecast_remaining_quantity
    INTO l_current_fact_value, l_total_rem_value
    FROM ozf_act_metric_facts_all
    WHERE arc_act_metric_used_by = 'FCST'
    AND act_metric_used_by_id = p_fcast_id
    AND activity_metric_fact_id = p_id;

    l_delta := p_value - l_current_fact_value + l_total_rem_value;

    -- Loop through possible existing second level facts
    FOR facts_record IN C_FindRecords(p_id, p_fcast_id) LOOP
        -- Increment the counter to check for the last record in each set
        l_temp_counter := l_temp_counter + 1;
        l_fact_value := 0;

        IF (l_temp_counter <> l_temp_count) THEN
            --(old Incr / (total old incr) * l_delta) + old Incr
            IF (l_fact_value_sum_all_recs = 0) THEN
                l_fact_value := round(facts_record.incremental_sales * l_delta);
            ELSE
                l_fact_value := round(facts_record.incremental_sales / l_fact_value_sum_all_recs * l_delta);
            END IF;
            l_fact_value := l_fact_value + facts_record.incremental_sales;

        ELSIF (l_temp_counter = l_temp_count) THEN
            -- Last record in the current set with the given previous_fact_id.
            -- Counter reset to 0 for the next set of records with another previous_fact_id
            l_temp_counter := 0;

            --Calculating the l_fval_sum_minus_last_rec since this is the last record in this set
            SELECT NVL(sum(incremental_sales),0)
            INTO l_fval_sum_minus_last_rec
            FROM ozf_act_metric_facts_all
            WHERE arc_act_metric_used_by = 'FCST'
            AND act_metric_used_by_id = p_fcast_id
            AND previous_fact_id = facts_record.previous_fact_id
            AND activity_metric_fact_id <> facts_record.activity_metric_fact_id ;

            l_fact_value := round(p_value - l_fval_sum_minus_last_rec);

        END IF;

        l_rem_value := l_fact_value - facts_record.incremental_sales  + facts_record.forecast_remaining_quantity;

        -- update the Remaining to Forecast only it is no the last level. Else, set it to 0.
        UPDATE ozf_act_metric_facts_all
         SET incremental_sales = l_fact_value
             --forecast_remaining_quantity = decode(sign(l_rem_value), -1, decode(root_fact_id,NULL,l_rem_value, 0),0)
        WHERE activity_metric_fact_id = facts_record.activity_metric_fact_id;

        l_temp_parent_fact_value := l_fact_value;

        -- cascade the changes down always
        --IF (l_rem_value > 0) THEN

            -- Loop through possible existing third level facts
            FOR facts_subrecord IN C_FindSubRecords(facts_record.activity_metric_fact_id, p_fcast_id) LOOP
                IF (l_temp_sub_previous_fact_id <> facts_subrecord.previous_fact_id) THEN
                    SELECT count(*), sum(incremental_sales)
                    INTO l_temp_sub_count, l_fact_value_sum_all_sub_recs
                    FROM ozf_act_metric_facts_all
                    WHERE arc_act_metric_used_by = 'FCST'
                    AND act_metric_used_by_id = p_fcast_id
                    AND previous_fact_id = facts_subrecord.previous_fact_id
                    AND root_fact_id IS NOT NULL;

                    l_temp_sub_previous_fact_id := facts_subrecord.previous_fact_id;
                END IF;

                -- Increment the counter to check for the last record in each set
                l_temp_sub_counter := l_temp_sub_counter + 1;

                IF (l_temp_sub_counter <> l_temp_sub_count) THEN

                    --(old Incr / (total old incr) * l_rem_value) + old Incr
                    IF (l_fact_value_sum_all_sub_recs = 0) THEN
                        l_fact_value := round(facts_subrecord.incremental_sales *  l_rem_value);
                    ELSE
                        l_fact_value := round(facts_subrecord.incremental_sales / l_fact_value_sum_all_sub_recs *  l_rem_value);
                    END IF;
                    l_fact_value := l_fact_value + facts_subrecord.incremental_sales;

                ELSIF (l_temp_sub_counter = l_temp_sub_count) THEN
                    -- Last record in the current set with the given previous_fact_id.
                    -- Counter reset to 0 for the next set of records with another previous_fact_id
                    l_temp_sub_counter := 0;

                    --Calculating the l_fval_sum_minus_last_rec since this is the last record in this set
                    SELECT NVL(sum(incremental_sales),0)
                    INTO l_fval_sum_minus_last_rec
                    FROM   ozf_act_metric_facts_all
                    WHERE  arc_act_metric_used_by = 'FCST'
                    AND act_metric_used_by_id = p_fcast_id
                    AND previous_fact_id = facts_subrecord.previous_fact_id
                    AND root_fact_id IS NOT NULL
                    AND activity_metric_fact_id <> facts_subrecord.activity_metric_fact_id ;

                    l_fact_value := round(l_temp_parent_fact_value - l_fval_sum_minus_last_rec);

                END IF;

               UPDATE ozf_act_metric_facts_all
               SET incremental_sales = l_fact_value
               WHERE activity_metric_fact_id = facts_subrecord.activity_metric_fact_id;

            END LOOP; -- subrecord

       --END IF;

    END LOOP; --fact_record

  END IF;

  <<end_of_cascade_baseline_update>>

  IF (OZF_DEBUG_HIGH_ON) THEN

  OZF_Utility_PVT.debug_message(l_full_name || ': End cascade baseline update');

  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_OFFER_PARTY_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

 END cascade_baseline_update;

 PROCEDURE cascade_baseline_levels(
        p_api_version        IN NUMBER,
        p_init_msg_list      IN VARCHAR2  := FND_API.g_false,
        p_commit             IN VARCHAR2  := FND_API.g_false,
        p_fcast_value        IN NUMBER,
        p_fcast_id           IN NUMBER,
        p_cascade_flag       IN NUMBER,
        p_obj_type           IN VARCHAR2,
        p_obj_id             IN NUMBER,
        x_return_status      OUT NOCOPY VARCHAR2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_msg_data           OUT NOCOPY VARCHAR2
    )
 IS

 l_total_fcst_value NUMBER := 0;
 l_total_base_qty NUMBER := 0;

 l_fact_percent NUMBER := 0;
 l_fact_value NUMBER := 0;
 l_rem_value NUMBER := 0;
 l_total_rem_value NUMBER := 0;
 l_delta NUMBER := 0;

 l_temp_count NUMBER := 0;
 l_temp_counter NUMBER := 0;
 l_fact_value_sum_all_recs NUMBER := 0;
 l_fval_sum_minus_last_rec NUMBER := 0;
 l_tpr_percent NUMBER := 0;

 CURSOR C_LevelOneRecords(p_forecast_id IN NUMBER) IS
  SELECT activity_metric_fact_id,
                 previous_fact_id,
                 forecast_remaining_quantity,
                 fact_type,
                 fact_reference,
                 from_date,
                 to_date,
                 incremental_sales,
                 root_fact_id
  FROM ozf_act_metric_facts_all
  WHERE arc_act_metric_used_by = 'FCST'
  AND act_metric_used_by_id = p_forecast_id
  AND previous_fact_id IS NULL
  AND root_fact_id IS NULL
  order by 6;

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'Cascade_baseline_levels';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  BEGIN
   IF (OZF_DEBUG_HIGH_ON) THEN
      OZF_Utility_PVT.debug_message(l_full_name || ': Start Cascade Baseline Levels');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
   THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   -- fact_value is the incremental_sales

   SELECT forecast_quantity, base_quantity, forecast_remaining_quantity
   INTO l_total_fcst_value, l_total_base_qty, l_total_rem_value
   FROM ozf_act_forecasts_all
   WHERE forecast_id = p_fcast_id;

   SELECT count(*), sum(incremental_sales)
   INTO l_temp_count, l_fact_value_sum_all_recs
   FROM ozf_act_metric_facts_all
   WHERE arc_act_metric_used_by = 'FCST'
   AND act_metric_used_by_id = p_fcast_id
   AND previous_fact_id IS NULL
   AND root_fact_id IS NULL;

   l_delta := p_fcast_value - l_total_fcst_value + l_total_rem_value;

   FOR facts_record IN C_LevelOneRecords(p_fcast_id) LOOP

      -- Increment the counter to check for the last record in each set
      l_temp_counter := l_temp_counter + 1;
      l_fact_value := 0;

      IF (l_temp_counter <> l_temp_count) THEN
        -- here l_delta = NewTF - OldTF + Rem
        --(old Incr / (total old incr) * (NewTF - OldTF + Rem) ) + old Incr
        --(old Incr / (total old incr) * Parent's Rem Qty) + old Incr
        IF (l_fact_value_sum_all_recs = 0) THEN
           l_fact_value := round(facts_record.incremental_sales * l_delta);
        ELSE
            l_fact_value := round(facts_record.incremental_sales / l_fact_value_sum_all_recs * l_delta);
        END IF;
        l_fact_value := l_fact_value + facts_record.incremental_sales;

      ELSIF (l_temp_counter = l_temp_count) THEN

       --Calculating the l_fval_sum_minus_last_rec since this is the last record in this set
        SELECT NVL(sum(incremental_sales),0)
        INTO l_fval_sum_minus_last_rec
        FROM ozf_act_metric_facts_all
        WHERE arc_act_metric_used_by = 'FCST'
        AND act_metric_used_by_id = p_fcast_id
        AND previous_fact_id IS NULL
        AND root_fact_id IS NULL
        AND activity_metric_fact_id <> facts_record.activity_metric_fact_id ;

        -- base_quantity is subtracted from new TF to get the Incr value of the header
        l_fact_value := round(p_fcast_value - l_total_base_qty - l_fval_sum_minus_last_rec);

     END IF;

     l_rem_value := l_fact_value - facts_record.incremental_sales  + facts_record.forecast_remaining_quantity;

     -- cascade the changes down always
   --IF (l_rem_value > 0) THEN
      -- call Cascade_Baseline_Update with the proper cascade flag
      cascade_baseline_update(p_api_version,
                       p_init_msg_list,
                       p_commit,
                       facts_record.activity_metric_fact_id,
                       l_fact_value,
                       p_fcast_id,
                       l_rem_value,
                       p_cascade_flag,
                       l_tpr_percent,
                       p_obj_type,
                       p_obj_id,
                       x_return_status,
                       x_msg_count,
                       x_msg_data
                      );

    UPDATE ozf_act_metric_facts_all
     SET incremental_sales = l_fact_value
        --forecast_remaining_quantity = decode(sign(l_rem_value), -1, l_rem_value, 0)
    WHERE activity_metric_fact_id = facts_record.activity_metric_fact_id;

   END LOOP;

   UPDATE ozf_act_forecasts_all
   SET forecast_quantity = p_fcast_value
   WHERE forecast_id = p_fcast_id;

   IF (OZF_DEBUG_HIGH_ON) THEN
    OZF_Utility_PVT.debug_message(l_full_name || ': End Cascade Baseline Levels');
   END IF;

   EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_OFFER_PARTY_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


 END cascade_baseline_levels;

END OZF_FORECAST_UTIL_PVT ;

/
