--------------------------------------------------------
--  DDL for Package Body OZF_TP_UTIL_QUERIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TP_UTIL_QUERIES" AS
/* $Header: ozfvtpqb.pls 120.4 2005/12/19 13:21:15 gramanat ship $ */
g_pkg_name   CONSTANT VARCHAR2(30):='OZF_TP_UTIL_QUERIES';

AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

-- ------------------------------------------------------------------
-- ------------------------
-- Public Function
-- ------------------------
-- HISTORY
--       created   16-DEC-2003    mkothari
-- Name: get_alert
-- Desc: Called from Dashboard Account and Product VOs to get alert.
-- Note: Distinct alert_types are = { MTD, QTD, YTD, BACK_ORDER,
--                                    OUTSTAND_ORDER }
-- ------------------------------------------------------------------

FUNCTION get_a_alert(p_object_id         IN NUMBER,
                   p_object_type       IN VARCHAR2,
                   p_report_date       IN DATE,
                   p_resource_id       IN NUMBER,
                   p_alert_type        IN VARCHAR2,
                   p_alert_for         IN VARCHAR2)
 RETURN VARCHAR2
 IS
  x_return_value varchar2(250) ;

 BEGIN
     IF p_object_type = 'PARTY' OR p_object_type = 'BILL_TO' then
        x_return_value := 'UNDEFINED';
     ELSIF p_object_type = 'SHIP_TO' THEN
        IF p_alert_type = 'MTD' THEN
          SELECT
            MTD_ALERT INTO x_return_value
          FROM
            ozf_quota_alerts
          WHERE
               ship_to_site_use_id = p_object_id
          AND report_date = p_report_date
          AND resource_id = p_resource_id
          AND alert_for = p_alert_for;
        ELSIF p_alert_type = 'QTD' THEN
          SELECT
            QTD_ALERT INTO x_return_value
          FROM
            ozf_quota_alerts
          WHERE
               ship_to_site_use_id = p_object_id
          AND report_date = p_report_date
          AND resource_id = p_resource_id
          AND alert_for = p_alert_for;
        ELSIF p_alert_type = 'YTD' THEN
          SELECT
            YTD_ALERT INTO x_return_value
          FROM
            ozf_quota_alerts
          WHERE
               ship_to_site_use_id = p_object_id
          AND report_date = p_report_date
          AND resource_id = p_resource_id
          AND alert_for = p_alert_for;
        ELSIF p_alert_type = 'BACK_ORDER' THEN
          SELECT
            BACK_ORDER_ALERT INTO x_return_value
          FROM
            ozf_quota_alerts
          WHERE
               ship_to_site_use_id = p_object_id
          AND report_date = p_report_date
          AND resource_id = p_resource_id
          AND alert_for = p_alert_for;
        ELSIF p_alert_type = 'OUTSTAND_ORDER' THEN
          SELECT
            OUTSTAND_ORDER_ALERT INTO x_return_value
          FROM
            ozf_quota_alerts
          WHERE
               ship_to_site_use_id = p_object_id
          AND report_date = p_report_date
          AND resource_id = p_resource_id
          AND alert_for = p_alert_for;
        END IF;
     END IF;

     RETURN (x_return_value);

 EXCEPTION
     WHEN OTHERS THEN
      -- dbms_output.put_line(sqlerrm(sqlcode));
      RETURN NULL;
END get_a_alert;

-- ------------------------------------------------------------------
-- ------------------------
-- Public Function
-- ------------------------
-- HISTORY
--       created   16-DEC-2003    mkothari
-- Name: get_alert
-- Desc: Called from Dashboard Account and Product VOs to get alert.
-- Note: Distinct alert_types are = { MTD, QTD, YTD, BACK_ORDER,
--                                    OUTSTAND_ORDER }
-- ------------------------------------------------------------------

FUNCTION get_alert(p_site_use_id       IN NUMBER,
                   p_cust_account_id   IN NUMBER,
                   p_report_date       IN DATE,
                   p_resource_id       IN NUMBER,
                   p_alert_type        IN VARCHAR2,
                   p_alert_for         IN VARCHAR2)
 RETURN VARCHAR2
 IS
  x_return_value varchar2(250) ;

 BEGIN

     IF p_alert_type = 'MTD' THEN
       SELECT
         MTD_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           cust_account_id = p_cust_account_id
       AND ship_to_site_use_id = p_site_use_id
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     ELSIF p_alert_type = 'QTD' THEN
       SELECT
         QTD_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           cust_account_id = p_cust_account_id
       AND ship_to_site_use_id = p_site_use_id
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     ELSIF p_alert_type = 'YTD' THEN
       SELECT
         YTD_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           cust_account_id = p_cust_account_id
       AND ship_to_site_use_id = p_site_use_id
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     ELSIF p_alert_type = 'BACK_ORDER' THEN
       SELECT
         BACK_ORDER_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           cust_account_id = p_cust_account_id
       AND ship_to_site_use_id = p_site_use_id
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     ELSIF p_alert_type = 'OUTSTAND_ORDER' THEN
       SELECT
         OUTSTAND_ORDER_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           cust_account_id = p_cust_account_id
       AND ship_to_site_use_id = p_site_use_id
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     END IF;

     RETURN (x_return_value);

 EXCEPTION
     WHEN OTHERS THEN
      -- dbms_output.put_line(sqlerrm(sqlcode));
      RETURN NULL;
END get_alert;


-----------------------------------------------------------
-- ------------------------------------------------------------------
-- ------------------------
-- Public Function
-- ------------------------
-- HISTORY
--       created   16-DEC-2003    mkothari
-- Name: get_alert - OVERLOADED FUNCTION -- NO LONGER OVRLOADED NOW
-- Desc: Called from Dashboard Account and Product VOs to get alert.
-- Note: Distinct alert_types are = { MTD, QTD, YTD, BACK_ORDER,
--                                    OUTSTAND_ORDER }
-- ------------------------------------------------------------------

FUNCTION get_p_alert(p_product_attribute  IN VARCHAR2,
                   p_product_attr_value IN NUMBER,
                   p_report_date        IN DATE,
                   p_resource_id        IN NUMBER,
                   p_alert_type         IN VARCHAR2,
                   p_alert_for          IN VARCHAR2)
 RETURN VARCHAR2
 IS
  x_return_value varchar2(250) ;

 BEGIN

     IF p_alert_type = 'MTD' THEN
       SELECT
         MTD_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           product_attribute = p_product_attribute
       AND product_attr_value = p_product_attr_value
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     ELSIF p_alert_type = 'QTD' THEN
       SELECT
         QTD_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           product_attribute = p_product_attribute
       AND product_attr_value = p_product_attr_value
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     ELSIF p_alert_type = 'YTD' THEN
       SELECT
         YTD_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           product_attribute = p_product_attribute
       AND product_attr_value = p_product_attr_value
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     ELSIF p_alert_type = 'BACK_ORDER' THEN
       SELECT
         BACK_ORDER_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           product_attribute = p_product_attribute
       AND product_attr_value = p_product_attr_value
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     ELSIF p_alert_type = 'OUTSTAND_ORDER' THEN
       SELECT
         OUTSTAND_ORDER_ALERT INTO x_return_value
       FROM
         ozf_quota_alerts
       WHERE
           product_attribute = p_product_attribute
       AND product_attr_value = p_product_attr_value
       AND report_date = p_report_date
       AND resource_id = p_resource_id
       AND alert_for = p_alert_for;
     END IF;

     RETURN (x_return_value);

 EXCEPTION
     WHEN OTHERS THEN
      -- dbms_output.put_line(sqlerrm(sqlcode));
      RETURN NULL;
END get_p_alert;


-----------------------------------------------------------
-- PROCEDURE
--    get_activity_description
--
-- HISTORY
--
------------------------------------------------------------

FUNCTION get_party_name(p_site_use_id IN NUMBER)
RETURN VARCHAR2
is
 CURSOR org_cursor
 IS
 SELECT
     NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99) from DUAL;


  x_return_value varchar2(250);
  l_org_id NUMBER;
BEGIN
      OPEN org_cursor;
      FETCH org_cursor into l_org_id;
      CLOSE org_cursor;

      Select p.party_name||' '||d.location into x_return_value
        from hz_parties p,
             hz_cust_acct_sites c,
             hz_cust_site_uses d,
             hz_cust_accounts e
       where d.site_use_id = p_site_use_id
         and d.cust_acct_site_id = c.cust_acct_site_id
         and e.cust_account_id = c.cust_account_id
         and p.party_id = e.party_id;

      RETURN (x_return_value);
 EXCEPTION
    WHEN OTHERS THEN
          RETURN (to_char(p_site_use_id));

END;

-----------------------------------------------------------
-- PROCEDURE
--    get_activity_description
--
-- HISTORY
--
------------------------------------------------------------

FUNCTION get_activity_description(activity_class IN VARCHAR2 DEFAULT NULL,activity_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(250) ;

BEGIN
       if activity_class = 'CSCH' then
          SELECT schedule_name
            INTO x_return_value
            FROM ams_campaign_schedules_tl
           WHERE schedule_id = activity_id
             AND language = userenv('LANG');
       elsif activity_class = 'OFFR' then
          SELECT description
            INTO x_return_value
            FROM qp_list_headers_tl
           WHERE list_header_id = activity_id
             AND language = userenv('LANG');
       elsif activity_class = 'CAMP' OR activity_class = 'ECAM' OR activity_class = 'TRDP' then
          SELECT campaign_name
            INTO x_return_value
            FROM ams_campaigns_all_tl
           WHERE campaign_id = activity_id
             AND language = userenv('LANG');
       end if;

        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_activity_description;


FUNCTION get_activity_access(p_object_class IN VARCHAR2,p_object_id IN NUMBER,p_resource_id IN NUMBER) RETURN VARCHAR2
is
  x_return_value varchar2(1) ;
  x_object_count  NUMBER;
  l_resource_id   NUMBER;

BEGIN

      IF p_object_class = 'OFFR' THEN
         select count(act.object_id)  into x_object_count
           from ams_act_access_denorm act, qp_list_headers_b qp, ozf_offers off
          where act.object_id = p_object_id
            and act.object_type = p_object_class
            and act.resource_id= p_resource_id
            and qp.list_header_id = act.object_id
            and off.qp_list_header_id = act.object_id
            and qp.source_system_code =  FND_PROFILE.VALUE('QP_SOURCE_SYSTEM_CODE')
            and NVL(off.budget_offer_yn,'N') = 'N';
      ELSIF p_object_class = 'CSCH' THEN
            select count(act.object_id) into x_object_count
              from ams_act_access_denorm act
             where act.object_id = p_object_id
               and act.object_type = p_object_class
               and act.resource_id= p_resource_id;
      END IF;

      IF x_object_count = 0  THEN
         x_return_value := 'N';
      ELSE
         x_return_value := 'Y';
      END IF;
      RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_activity_access;


FUNCTION get_uom_conv(p_object_id IN VARCHAR2
                     ,p_qty       IN NUMBER
                     ,p_from_uom  IN VARCHAR2
                     ,p_to_uom    IN VARCHAR2) RETURN NUMBER
is
  x_return_value NUMBER;

BEGIN

      select inv_convert.inv_um_convert(p_object_id,null,p_qty,p_from_uom,p_to_uom,null,null)
        into x_return_value
        from dual;
      RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_uom_conv;


PROCEDURE get_list_price(
                    p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2  := FND_API.g_false,
                    p_commit               IN  VARCHAR2  := FND_API.g_false,

                    p_obj_id               IN  NUMBER,
                    p_obj_type             IN  VARCHAR2,
                    p_product_attribute    IN  VARCHAR2,
                    p_product_attr_value   IN  VARCHAR2,
                    p_fcst_uom             IN  VARCHAR2,
                    p_currency_code        IN  VARCHAR2,
                    p_price_list_id        IN  NUMBER,
                    p_qualifier_tbl        IN  OZF_TP_UTIL_QUERIES.QUALIFIER_TBL_TYPE,

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

  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'Get_List_Price';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status VARCHAR2(1);

  CURSOR c_market_qualifiers IS
  SELECT qualifier_context,
         qualifier_attribute,
         qualifier_attr_value
  FROM ozf_worksheet_qualifiers
  WHERE worksheet_header_id = p_obj_id;


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

      /* If p_obj_type is passed then use the qualifiers defined */
      /* else iterate thru the array and add them to qual_rec. */
      if p_obj_type is not null then
         FOR i IN c_market_qualifiers
         LOOP
             l_counter := l_counter+1 ;

             qual_rec.LINE_INDEX := 1;
             qual_rec.QUALIFIER_CONTEXT := i.QUALIFIER_CONTEXT;
             qual_rec.QUALIFIER_ATTRIBUTE := i.QUALIFIER_ATTRIBUTE;
             qual_rec.QUALIFIER_ATTR_VALUE_FROM := i.QUALIFIER_ATTR_VALUE;
             qual_rec.COMPARISON_OPERATOR_CODE := '=';
             qual_rec.VALIDATED_FLAG :='Y';
             p_qual_tbl(l_counter):= qual_rec;
          END LOOP;
       else
          IF p_qualifier_tbl.COUNT > 0 THEN
             FOR i IN p_qualifier_tbl.first..p_qualifier_tbl.last LOOP
                IF p_qualifier_tbl.EXISTS(i) THEN
                   l_counter := l_counter+1 ;
                   qual_rec.LINE_INDEX := 1;
                   qual_rec.QUALIFIER_CONTEXT := p_qualifier_tbl(i).qualifier_context;
                   qual_rec.QUALIFIER_ATTRIBUTE := p_qualifier_tbl(i).qualifier_attribute;
                   qual_rec.QUALIFIER_ATTR_VALUE_FROM := p_qualifier_tbl(i).qualifier_attr_value;
                   qual_rec.COMPARISON_OPERATOR_CODE := '=';
                   qual_rec.VALIDATED_FLAG :='Y';
                   p_qual_tbl(l_counter):= qual_rec;
                end if;
             end loop;
          end if;
      end if;
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
         FND_MESSAGE.set_name('AMS', 'AMS_FCST_GET_LISTPRICE_FAILURE');
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
            FND_MESSAGE.set_name('AMS', 'AMS_FCST_GET_LISTPRICE_FAILURE');
            FND_MESSAGE.set_token('ERR_MSG',l_status_text);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;

        END IF;

     END IF;


   EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Validate_get_list_price_of_goods: ' || substr(sqlerrm, 1, 100));
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (
         p_encoded       =>     FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('AMS', 'AMS_FCST_GET_LISTPRICE_FAILURE');
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

  -- Function used in OZF_ORDER_SALES_V

  FUNCTION get_quota_unit RETURN VARCHAR2
   IS
    -- inanaiah - R12 change
    /*
    CURSOR sys_csr IS
    SELECT NVL(quota_unit,'Q')
    FROM ozf_sys_parameters;
    */

    l_quota_unit VARCHAR2(1);

  BEGIN

     -- inanaiah - R12 change
     /*
     OPEN sys_csr;
     FETCH sys_csr INTO l_quota_unit;
     CLOSE sys_csr;
     */
     RETURN fnd_profile.value('OZF_TP_QUOTA_ALLOCATION_BY'); --l_quota_unit ;

  END get_quota_unit;

FUNCTION get_item_descr (  p_FlexField_Name IN VARCHAR2
                          ,p_Context_Name IN VARCHAR2
                          ,p_attribute_name IN VARCHAR2
                          ,p_attr_value IN VARCHAR2 ) RETURN VARCHAR2 IS

  l_item_name varchar2(240) := NULL;
  l_category_name varchar2(240) := NULL;

  CURSOR c_category_descr IS
  SELECT
       NVL(d.category_desc, c.description) cat_descr
       --NVL(d.concat_cat_parentage, c.description) cat_descr
  FROM  mtl_default_category_sets a,
      mtl_category_sets_b b,
      mtl_categories_v c,
      ENI_PROD_DEN_HRCHY_PARENTS_V d
  WHERE a.functional_area_id IN (7, 11)
  AND a.category_set_id = b.category_set_id
  AND b.structure_id = c.structure_id
  AND c.category_id = d.category_id(+)
  AND c.category_id = p_attr_value;



  BEGIN

     IF p_attribute_name = 'PRICING_ATTRIBUTE1' THEN
       l_item_name:=QP_PRICE_LIST_LINE_UTIL.GET_PRODUCT_VALUE(p_FlexField_Name,p_Context_Name,p_attribute_name,p_attr_value);
       RETURN l_item_name;
     ELSE
       OPEN c_category_descr;
       FETCH c_category_descr INTO l_category_name;
       CLOSE c_category_descr;
       RETURN l_category_name;
     END IF;
     RETURN NULL;

  END get_item_descr;

-- Used to get the description of an inventory_item
FUNCTION get_item_name ( p_inventory_item_id IN NUMBER) RETURN VARCHAR2 IS

  l_item_name varchar2(240) := NULL;

  BEGIN

     select description into l_item_name
       from mtl_system_items_vl
      where inventory_item_id = p_inventory_item_id
        and organization_id = fnd_profile.value('QP_ORGANIZATION_ID');

    return l_item_name;

  END get_item_name;

-- Used to get the cost of an inventory_item
FUNCTION get_item_cost ( p_inventory_item_id IN NUMBER) RETURN NUMBER IS

  l_item_cost NUMBER := NULL;

  BEGIN

     l_item_cost :=  CST_COST_API.get_item_cost(1,p_inventory_item_id,fnd_profile.value('QP_ORGANIZATION_ID'), NULL,NULL);

     return l_item_cost;

  END get_item_cost;



END OZF_TP_UTIL_QUERIES;

/
