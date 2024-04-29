--------------------------------------------------------
--  DDL for Package Body OZF_NET_ACCRUAL_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_NET_ACCRUAL_ENGINE_PVT" AS
/* $Header: ozfvnaeb.pls 120.11.12010000.6 2010/02/17 08:49:00 nepanda ship $ */

 G_DEBUG_LOW       BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
 TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

FUNCTION validate_customer( p_invoice_to_org_id IN NUMBER,
                            p_ship_to_org_id    IN NUMBER,
                            p_sold_to_org_id    IN NUMBER)
RETURN VARCHAR2
IS

  -- Segment and buying group has no acct info. use party_id for validation
  CURSOR c_party_id IS
  SELECT party_id
  FROM   hz_cust_accounts
  WHERE  cust_account_id = p_sold_to_org_id;

  CURSOR c_customer_qualified(p_party_id NUMBER) IS
  SELECT 'Y'
  FROM   ozf_na_customers_temp
  WHERE  (
           (site_use_id = p_invoice_to_org_id AND site_use_code = 'BILL_TO') OR
           (site_use_id = p_ship_to_org_id    AND site_use_code = 'SHIP_TO') OR
           (party_id    = p_party_id          AND site_use_code IS NULL) OR
           (party_id = -1)
         )
  AND ROWNUM = 1;

  CURSOR c_cust_acct_qualified(p_party_id NUMBER) IS
  SELECT 'Y'
  FROM   ozf_na_customers_temp
  WHERE  (
           (cust_account_id = p_sold_to_org_id) OR
           (party_id        = p_party_id AND site_use_code IS NULL) OR
           (party_id = -1)
         )
  AND ROWNUM = 1;

  l_customer_qualified VARCHAR2(1) := 'N';
  l_party_id           NUMBER;

BEGIN

  OPEN  c_party_id;
  FETCH c_party_id INTO l_party_id;
  CLOSE c_party_id;

  IF p_invoice_to_org_id IS NULL AND p_ship_to_org_id IS NULL
  THEN
     --
     OPEN  c_cust_acct_qualified(l_party_id);
     FETCH c_cust_acct_qualified INTO l_customer_qualified;
     CLOSE c_cust_acct_qualified;
     --
  ELSE
     --
     OPEN  c_customer_qualified(l_party_id);
     FETCH c_customer_qualified INTO l_customer_qualified;
     CLOSE c_customer_qualified;
     --
  END IF;

  RETURN l_customer_qualified;

END validate_customer;


-- Used for retrocative Offer Adjustment

FUNCTION validate_customer( p_invoice_to_org_id IN NUMBER,
                            p_ship_to_org_id    IN NUMBER,
                            p_sold_to_org_id    IN NUMBER,
                            p_qp_list_header_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_party_id IS -- segment and buying group has no acct info. use party_id for validation
  SELECT party_id
  FROM   hz_cust_accounts
  WHERE  cust_account_id = p_sold_to_org_id;

  CURSOR c_customer_qualified(p_party_id NUMBER) IS
  SELECT 'Y'
  FROM   ozf_activity_customers
  WHERE  (
           (site_use_id = p_invoice_to_org_id AND site_use_code = 'BILL_TO') OR
           (site_use_id = p_ship_to_org_id    AND site_use_code = 'SHIP_TO') OR
           (party_id    = p_party_id          AND site_use_code IS NULL)     OR
           (party_id = -1)
         )
  AND    object_class = 'OFFR'
  AND    object_id = p_qp_list_header_id
  AND    ROWNUM = 1;

  CURSOR c_cust_acct_qualified(p_party_id NUMBER) IS
  SELECT 'Y'
  FROM   ozf_activity_customers
  WHERE  (
           (cust_account_id = p_sold_to_org_id) OR
           (party_id        = p_party_id AND site_use_code IS NULL) OR
           (party_id = -1)
         )
    AND    object_class = 'OFFR'
    AND    object_id = p_qp_list_header_id
    AND    ROWNUM = 1;

  l_customer_qualified VARCHAR2(1) := 'N';
  l_party_id           NUMBER;
BEGIN
  --
  OPEN  c_party_id;
  FETCH c_party_id INTO l_party_id;
  CLOSE c_party_id;

  IF p_invoice_to_org_id IS NULL AND p_ship_to_org_id IS NULL
  THEN
    --
    OPEN  c_cust_acct_qualified(l_party_id);
    FETCH c_cust_acct_qualified INTO l_customer_qualified;
    CLOSE c_cust_acct_qualified;
    --
  ELSE
    --
    OPEN  c_customer_qualified(l_party_id);
    FETCH c_customer_qualified INTO l_customer_qualified;
    CLOSE c_customer_qualified;
    --
  END IF;

  IF l_customer_qualified = 'Y' THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
END validate_customer;


FUNCTION validate_prm_customer( p_offer_id     IN NUMBER,
                                p_country_code IN VARCHAR2
)
RETURN VARCHAR2
IS

  -- Partner Referral Net Accrual Offers
  -- Will always have Territory as a qualifier
  CURSOR c_terr_id IS
  SELECT qualifier_attr_value terr_id
  FROM   ozf_offer_qualifiers
  WHERE  offer_id = p_offer_id;

  CURSOR c_terr_qual_id(p_terr_id NUMBER) IS
  SELECT terr_qual_id
  FROM   jtf_terr_qual_all
  WHERE  terr_id = p_terr_id;

  CURSOR c_country_count(p_terr_qual_id NUMBER) IS
  SELECT COUNT(1)
  FROM   jtf_terr_values_all
  WHERE  low_value_char = p_country_code
  AND    terr_qual_id = p_terr_qual_id;

  l_customer_qualified VARCHAR2(1);
  l_country_count      NUMBER;

BEGIN

  FOR l_terr_id IN c_terr_id
  LOOP
    --
    l_customer_qualified := 'Y';

    FOR l_terr_qual_id IN c_terr_qual_id(l_terr_id.terr_id) LOOP
      l_country_count := 0;

      OPEN  c_country_count(l_terr_qual_id.terr_qual_id);
      FETCH c_country_count INTO l_country_count;
      CLOSE c_country_count;

      IF l_country_count = 0 THEN
        l_customer_qualified := 'N';
        EXIT;
      END IF;
    END LOOP;

    IF l_customer_qualified = 'Y' THEN
      EXIT;
    END IF;
  END LOOP;

  RETURN l_customer_qualified;
END validate_prm_customer;

-- Called from Offer Product Backdated Adjustment

FUNCTION validate_product( p_inventory_item_id IN NUMBER,
                           p_qp_list_header_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_product_qualified IS
  SELECT 'Y'
  FROM   DUAL
  WHERE EXISTS(SELECT 1
               FROM   ozf_activity_products
               WHERE  item = p_inventory_item_id
               AND    item_type = 'PRICING_ATTRIBUTE1'
               AND    object_class = 'OFFR'
               AND    object_id = p_qp_list_header_id);

  l_product_qualified VARCHAR2(1);

BEGIN
   --
   OPEN  c_product_qualified;
   FETCH c_product_qualified INTO l_product_qualified;
   CLOSE c_product_qualified;

   IF l_product_qualified = 'Y' THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;
   --
END validate_product;


PROCEDURE refresh_parties( p_offer_id         IN NUMBER,
                           p_calling_from_den IN VARCHAR2,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2,
                           x_party_stmt       OUT NOCOPY VARCHAR2
)
IS

  CURSOR c_no_groups IS
  SELECT COUNT(*)
  FROM   ozf_offer_qualifiers
  WHERE  offer_id = p_offer_id
  AND    active_flag = 'Y';

  CURSOR c_groups IS
  SELECT qualifier_id
  FROM   ozf_offer_qualifiers
  WHERE  offer_id = p_offer_id
  AND    active_flag = 'Y';

  CURSOR c_qualifiers(p_qualifier_id NUMBER) IS
  SELECT NVL(qualifier_context,
             DECODE(qualifier_attribute,
                    'BUYER', 'CUSTOMER_GROUP',
                    'CUSTOMER_BILL_TO', 'CUSTOMER',
                    'CUSTOMER', 'CUSTOMER',
                    'LIST', 'CUSTOMER_GROUP',
                    'SEGMENT', 'CUSTOMER_GROUP',
                    'TERRITORY', 'TERRITORY',
                    'SHIP_TO', 'CUSTOMER')) qualifier_context,
         DECODE(qualifier_attribute,
                'BUYER', 'QUALIFIER_ATTRIBUTE3',
                'CUSTOMER_BILL_TO', 'QUALIFIER_ATTRIBUTE14',
                'CUSTOMER', 'QUALIFIER_ATTRIBUTE2',
                'LIST', 'QUALIFIER_ATTRIBUTE1',
                'SEGMENT', 'QUALIFIER_ATTRIBUTE2',
                'TERRITORY', 'QUALIFIER_ATTRIBUTE1',
                'SHIP_TO', 'QUALIFIER_ATTRIBUTE11',
                qualifier_attribute) qualifier_attribute,
         qualifier_attr_value,
         '=' comparison_operator_code
  FROM   ozf_offer_qualifiers
  WHERE  qualifier_id = p_qualifier_id;

  l_api_name      CONSTANT VARCHAR2(30) := 'refresh_parties';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_stmt_temp     VARCHAR2(32000)        := NULL;
  l_no_query_flag VARCHAR2(1)            := 'N';
  l_no_groups     NUMBER;
  l_no_lines      NUMBER;
  l_group_index   NUMBER;
  l_line_index    NUMBER;

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  OPEN  c_no_groups;
  FETCH c_no_groups INTO l_no_groups;
  CLOSE c_no_groups;

  IF G_DEBUG_LOW
  THEN
     ozf_utility_pvt.write_conc_log('Number of Market Eligibilites: '||l_no_groups);
  END IF;

  IF l_no_groups > 0
  THEN
     --
     l_group_index := 1;

     FOR i IN c_groups
     LOOP
        --
        l_line_index := 1;
        -- Currently NA qualifiers does not support grouping, each group has only 1 line
        l_no_lines := 1;
        --
        FND_DSQL.add_text('(');
        --
        FOR j IN c_qualifiers(i.qualifier_id)
        LOOP
           --
           l_stmt_temp := NULL;
           l_stmt_temp := ozf_offr_elig_prod_denorm_pvt.get_sql(p_context         => j.qualifier_context,
                                                               p_attribute       => j.qualifier_attribute,
                                                               p_attr_value_from => j.qualifier_attr_value,
                                                               p_attr_value_to   => NULL,--j.qualifier_attr_value_to,
                                                               p_comparison      => j.comparison_operator_code,
                                                               p_type            => 'ELIG');
           IF l_stmt_temp IS NULL
           THEN
               --
               l_no_query_flag := 'Y';
               EXIT;
               --
           ELSE
               --
               IF l_line_index < l_no_lines
               THEN
                 --
                 FND_DSQL.add_text(' INTERSECT ');
                 l_line_index := l_line_index + 1;
                 --
               END IF;
               --
           END IF;
           --
        END LOOP; -- c_qualifiers
        --
        FND_DSQL.add_text(')');
        --
        IF l_group_index < l_no_groups
        THEN
           --
           FND_DSQL.add_text(' UNION ');
           l_group_index := l_group_index + 1;
           --
        END IF;
        --
     END LOOP; -- c_groups
     --
  ELSE
     --
--     FND_DSQL.add_text('(SELECT -1 party_id,-1 cust_account_id, -1 cust_acct_site_id, -1 site_use_id,'' '' site_use_code FROM DUAL)');
     FND_DSQL.add_text('(SELECT -1 qp_qualifier_id, -1 qp_qualifier_group, -1 party_id,-1 cust_account_id, -1 cust_acct_site_id, -1 site_use_id,'' '' site_use_code FROM DUAL)');
     --
  END IF;

  IF p_calling_from_den = 'N' OR l_no_query_flag = 'N'
  THEN
     --
     x_party_stmt := FND_DSQL.get_text(FALSE);
     --
  ELSE
     --
     x_party_stmt := NULL;
     --
  END IF;

  IF G_DEBUG_LOW
  THEN
     --
     ozf_utility_pvt.write_conc_log('1:'||substr(x_party_stmt,945,250));
     ozf_utility_pvt.write_conc_log('2:'||substr(x_party_stmt,1195,250));
     ozf_utility_pvt.write_conc_log('3:'||substr(x_party_stmt,1445,250));
     --
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
END refresh_parties;


PROCEDURE populate_customers( p_offer_id      IN  NUMBER
                             ,x_return_status OUT NOCOPY VARCHAR2
                             ,x_msg_count     OUT NOCOPY NUMBER
                             ,x_msg_data      OUT NOCOPY VARCHAR2)
IS
  --
  l_api_name      CONSTANT VARCHAR2(30) := 'populate_customers';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_stmt_denorm VARCHAR2(32000) := NULL;
  l_stmt_offer  VARCHAR2(32000) := NULL;
  l_stmt_debug  VARCHAR2(32000) := NULL;
  l_denorm_csr  NUMBER;
  l_ignore      NUMBER;
  --
BEGIN
  --
  x_return_status := FND_API.g_ret_sts_success;

  -- denorm parties
  FND_DSQL.init;
  FND_DSQL.add_text('INSERT INTO ozf_na_customers_temp(');
  FND_DSQL.add_text('creation_date,created_by,last_update_date,last_updated_by,');
  FND_DSQL.add_text('last_update_login,confidential_flag,');
  FND_DSQL.add_text('object_id,object_type,object_status,object_class,object_desc,parent_id,parent_class,');
  FND_DSQL.add_text('parent_desc,ask_for_flag,active_flag,source_code,marketing_medium_id,start_date,end_date,');
  FND_DSQL.add_text('party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code,');
  FND_DSQL.add_text('qualifier_attribute,qualifier_context) ');
  FND_DSQL.add_text('SELECT SYSDATE,FND_GLOBAL.user_id,SYSDATE,');
  FND_DSQL.add_text('FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id,NULL,');
  FND_DSQL.add_bind(p_offer_id);
  FND_DSQL.add_text(',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL');
  FND_DSQL.add_text(',party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code, ');
  FND_DSQL.add_text(' decode(site_use_code,''BILL_TO'',''QUALIFIER_ATTRIBUTE14'',''SHIP_TO'',''QUALIFIER_ATTRIBUTE11'',substr(site_use_code,INSTR(site_use_code,'':'')+1)) qualifier_attribute,');
  FND_DSQL.add_text(' decode(site_use_code,''BILL_TO'',''CUSTOMER'',''SHIP_TO'',''CUSTOMER'',substr(site_use_code,0,INSTR(site_use_code,'':'')-1)) qualifier_context');
  FND_DSQL.add_text(' FROM (');


  ozf_utility_pvt.write_conc_log('-- Refresh_Parties (+)');

  /* refresh parties would get all the parties for the offer_id and add to FND_DSQL*/
  refresh_parties(p_offer_id         => p_offer_id,
                  p_calling_from_den => 'Y',
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data,
                  x_party_stmt       => l_stmt_offer);

  ozf_utility_pvt.write_conc_log('-- Refresh_Parties (-) With Status: ' || x_return_status );

  IF x_return_status = FND_API.g_ret_sts_unexp_error
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF l_stmt_offer IS NOT NULL
  THEN
    --
--    FND_DSQL.add_text(' UNION select -1 party_id, -1 cust_account_id, -1 cust_acct_site_id, ');
    FND_DSQL.add_text(' UNION select -1 qp_qualifier_id, -1 qp_qualifier_group, -1 party_id, -1 cust_account_id, -1 cust_acct_site_id, ');
    FND_DSQL.add_text(' to_number(qualifier_attr_value) site_use_id, ');
    FND_DSQL.add_text(' qualifier_context||'':''||qualifier_attribute  site_use_code ');
    FND_DSQL.add_text(' FROM ozf_offer_qualifiers WHERE offer_id = ');
    FND_DSQL.add_bind(p_offer_id);
    FND_DSQL.add_text(' and qualifier_context||'':''||qualifier_attribute not in ');
    FND_DSQL.add_text(' (''CUSTOMER:PRICING_ATTRIBUTE11'',''CUSTOMER:QUALIFIER_ATTRIBUTE14'')');
    FND_DSQL.add_text(' and qualifier_context not in (''MODLIST'') ');
    FND_DSQL.add_text(' and qualifier_attribute < ''A'' ');
    FND_DSQL.add_text(')');

    l_denorm_csr := DBMS_SQL.open_cursor;
    FND_DSQL.set_cursor(l_denorm_csr);
    l_stmt_debug := FND_DSQL.get_text(TRUE);
    l_stmt_denorm := FND_DSQL.get_text(FALSE);
    DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
    FND_DSQL.do_binds;
    l_ignore := DBMS_SQL.execute(l_denorm_csr);
    dbms_sql.close_cursor(l_denorm_csr);
    --
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      ozf_utility_pvt.write_conc_log(l_stmt_debug);
      ozf_utility_pvt.write_conc_log(SQLERRM);

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END populate_customers;


FUNCTION get_func_area(p_category_id IN NUMBER) RETURN NUMBER
IS
  --
  CURSOR c_func_area IS
  SELECT a.functional_area_id
  FROM   mtl_default_category_sets a,
         mtl_category_sets_b b,
         mtl_categories c
  WHERE a.functional_area_id in (7,11)
  AND   a.category_set_id = b.category_set_id
  AND   c.structure_id = b.structure_id
  AND   c.category_id =  p_category_id;
  --
  l_func_area_id NUMBER;
BEGIN

 OPEN c_func_area;
 FETCH c_func_area INTO l_func_area_id;
 CLOSE c_func_area;

 RETURN l_func_area_id;
END;

PROCEDURE populate_prod_line( p_offer_id      IN  NUMBER
                             ,x_return_status OUT NOCOPY VARCHAR2
                             ,x_msg_count     OUT NOCOPY NUMBER
                             ,x_msg_data      OUT NOCOPY VARCHAR2)
IS
  --
  CURSOR c_product IS
  SELECT product_id,
         product_level,
         off_discount_product_id,
         offer_discount_line_id,
         NVL(uom_code, 'NA') uom_code
  FROM   ozf_offer_discount_products
  WHERE  excluder_flag = 'N'
  AND    offer_id = p_offer_id;

  CURSOR c_exclusion(p_off_discount_product_id NUMBER) IS
  SELECT product_level,
         product_id
  FROM   ozf_offer_discount_products
  WHERE  parent_off_disc_prod_id = p_off_discount_product_id
  AND    excluder_flag = 'Y';

  CURSOR c_discount(p_offer_discount_line_id NUMBER) IS
  SELECT discount,
         discount_type,
         NVL(volume_from,0),
         volume_to,
         DECODE(volume_type, 'PRICING_ATTRIBUTE12', 'AMT', 'PRICING_ATTRIBUTE10', 'QTY', NULL, 'NA')
  FROM   ozf_offer_discount_lines
  WHERE  offer_discount_line_id = p_offer_discount_line_id;


  l_api_name      CONSTANT VARCHAR2(30) := 'populate_prod_line';
  l_discount      NUMBER;
  l_discount_type VARCHAR2(30);
  l_volume_from   NUMBER;
  l_volume_to     NUMBER;
  l_volume_type   VARCHAR2(30);
  l_org_id        NUMBER;
  l_denorm_csr    NUMBER;
  l_ignore        NUMBER;
  l_func_area_id  NUMBER;
  l_stmt_denorm   VARCHAR2(32000) := NULL;
  l_stmt_debug    VARCHAR2(32000) := NULL;

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  l_org_id := fnd_profile.value('QP_ORGANIZATION_ID');

  FOR l_product IN c_product
  LOOP
     --
     OPEN  c_discount(l_product.offer_discount_line_id);
     FETCH c_discount INTO l_discount,
                           l_discount_type,
                           l_volume_from,
                           l_volume_to,
                           l_volume_type;
     CLOSE c_discount;

     IF l_product.product_level = 'FAMILY'
     THEN
        --
        l_func_area_id := get_func_area(l_product.product_id);

        IF G_DEBUG_LOW THEN
           --
           ozf_utility_pvt.write_conc_log('Functional Area for category: ' || l_func_area_id);
           ozf_utility_pvt.write_conc_log('Off_Discount_Product_Id:' || l_product.off_discount_product_id);
           --
        END IF;
        --
     END IF;

     FND_DSQL.init;
     FND_DSQL.add_text('INSERT INTO ozf_na_products_temp(inventory_item_id,product_level,discount,discount_type,volume_from,volume_to,volume_type,uom) ');
     FND_DSQL.add_text('SELECT inventory_item_id,');
     FND_DSQL.add_bind(l_product.product_level);
     FND_DSQL.add_text(',');
     FND_DSQL.add_bind(l_discount);
     FND_DSQL.add_text(',');
     FND_DSQL.add_bind(l_discount_type);
     FND_DSQL.add_text(',');
     FND_DSQL.add_bind(l_volume_from);
     FND_DSQL.add_text(',');
     FND_DSQL.add_bind(l_volume_to);
     FND_DSQL.add_text(',');
     FND_DSQL.add_bind(l_volume_type);
     FND_DSQL.add_text(',');
     FND_DSQL.add_bind(l_product.uom_code);
     FND_DSQL.add_text(' FROM (');

     IF l_product.product_level = 'FAMILY'
     THEN
        --
        IF l_func_area_id = 11
        THEN
            -- Functional Area is PRFA.
            --
            FND_DSQL.add_text('SELECT inventory_item_id FROM mtl_item_categories mtl,eni_prod_denorm_hrchy_v epdhv WHERE mtl.category_set_id  = epdhv.category_set_id AND mtl.category_id = epdhv.child_id AND mtl.organization_id = ');
            FND_DSQL.add_bind(l_org_id);
            FND_DSQL.add_text(' AND epdhv.parent_id = ');
            FND_DSQL.add_bind(l_product.product_id);
            --
        ELSE
            -- Functional Area id OMFA
            FND_DSQL.add_text('SELECT inventory_item_id FROM mtl_item_categories WHERE organization_id = ');
            FND_DSQL.add_bind(l_org_id);
            FND_DSQL.add_text(' AND category_id = ');
            FND_DSQL.add_bind(l_product.product_id);
            --
        END IF;
        --
     ELSIF l_product.product_level = 'PRODUCT'
     THEN
        --
        FND_DSQL.add_text('SELECT ');
        FND_DSQL.add_bind(l_product.product_id);
        FND_DSQL.add_text(' inventory_item_id FROM DUAL');
        --
     END IF;

     FOR l_exclusion IN c_exclusion(l_product.off_discount_product_id)
     LOOP
        --
        FND_DSQL.add_text(' MINUS ');

        IF l_exclusion.product_level = 'PRODUCT'
        THEN
           --
           FND_DSQL.add_text('SELECT ');
           FND_DSQL.add_bind(l_exclusion.product_id);
           FND_DSQL.add_text(' inventory_item_id FROM DUAL');
           --
        ELSIF l_exclusion.product_level = 'FAMILY'
        THEN
           --
           IF l_func_area_id = 11
           THEN
               -- Functional Area is PRFA.
               --
               FND_DSQL.add_text('SELECT inventory_item_id FROM mtl_item_categories mtl,eni_prod_denorm_hrchy_v epdhv WHERE mtl.category_set_id  = epdhv.category_set_id AND mtl.category_id = epdhv.child_id AND mtl.organization_id = ');
               FND_DSQL.add_bind(l_org_id);
               FND_DSQL.add_text(' AND epdhv.parent_id = ');
               FND_DSQL.add_bind(l_exclusion.product_id);
               --
           ELSE
               -- Functional Area id OMFA
               FND_DSQL.add_text('SELECT inventory_item_id FROM mtl_item_categories WHERE organization_id = ');
               FND_DSQL.add_bind(l_org_id);
               FND_DSQL.add_text(' AND category_id = ');
               FND_DSQL.add_bind(l_exclusion.product_id);
               --
           END IF;
           --
        END IF;
        --
    END LOOP;

    FND_DSQL.add_text(')');

    l_denorm_csr := DBMS_SQL.open_cursor;
    FND_DSQL.set_cursor(l_denorm_csr);
    l_stmt_debug := FND_DSQL.get_text(TRUE);
    l_stmt_denorm := FND_DSQL.get_text(FALSE);
    DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
    FND_DSQL.do_binds;
    l_ignore := DBMS_SQL.execute(l_denorm_csr);
    dbms_sql.close_cursor(l_denorm_csr);
    --
  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      ozf_utility_pvt.write_conc_log(l_stmt_debug);
      ozf_utility_pvt.write_conc_log(SQLERRM);

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END populate_prod_line;


PROCEDURE populate_prod_tier( p_offer_id      IN  NUMBER
                             ,x_return_status OUT NOCOPY VARCHAR2
                             ,x_msg_count     OUT NOCOPY NUMBER
                             ,x_msg_data      OUT NOCOPY VARCHAR2)
IS
  --
  CURSOR c_product IS
  SELECT product_id,
         product_level,
         off_discount_product_id,
         NVL(uom_code, 'NA') uom_code
  FROM   ozf_offer_discount_products
  WHERE  excluder_flag = 'N'
  AND    offer_id = p_offer_id;

  CURSOR c_discount IS
  SELECT discount,
         discount_type,
         NVL(volume_from,0) volume_from,
         volume_to,
         DECODE(volume_type, 'PRICING_ATTRIBUTE12', 'AMT', 'PRICING_ATTRIBUTE10', 'QTY', NULL, 'NA') volume_type
  FROM   ozf_offer_discount_lines
  WHERE  offer_id = p_offer_id;

  l_api_name      CONSTANT VARCHAR2(30) := 'populate_prod_tier';
  l_discount      NUMBER;
  l_discount_type VARCHAR2(30);
  l_volume_from   NUMBER;
  l_volume_to     NUMBER;
  l_volume_type   VARCHAR2(30);
  l_org_id        NUMBER;
  l_denorm_csr    NUMBER;
  l_ignore        NUMBER;
  l_func_area_id  NUMBER;
  l_stmt_denorm   VARCHAR2(32000) := NULL;
  l_stmt_debug    VARCHAR2(32000) := NULL;

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  l_org_id := fnd_profile.value('QP_ORGANIZATION_ID');
  ozf_utility_pvt.write_conc_log(l_api_name);

  FOR l_product IN c_product
  LOOP
     --

     IF l_product.product_level = 'FAMILY'
     THEN
        --
        l_func_area_id := get_func_area(l_product.product_id);
        --
     END IF;

     FOR l_discount IN c_discount
     LOOP
        --
       -- IF G_DEBUG_LOW THEN
           --
           ozf_utility_pvt.write_conc_log('off_discount_product_id:' || l_product.off_discount_product_id);
           ozf_utility_pvt.write_conc_log('Functional Area for category: ' || l_func_area_id);
           --
      --  END IF;

        FND_DSQL.init;
        FND_DSQL.add_text('INSERT INTO ozf_na_products_temp(inventory_item_id,product_level,discount,discount_type,volume_from,volume_to,volume_type,uom) ');
        FND_DSQL.add_text('SELECT inventory_item_id,');
        FND_DSQL.add_bind(l_product.product_level);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(l_discount.discount);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(l_discount.discount_type);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(l_discount.volume_from);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(l_discount.volume_to);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(l_discount.volume_type);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(l_product.uom_code);
        FND_DSQL.add_text(' FROM (');

        IF l_product.product_level = 'FAMILY'
        THEN
          --
          IF l_func_area_id = 11
          THEN
              -- Functional Area is PRFA.
              --
              FND_DSQL.add_text('SELECT inventory_item_id FROM mtl_item_categories mtl,eni_prod_denorm_hrchy_v epdhv WHERE mtl.category_set_id  = epdhv.category_set_id AND mtl.category_id = epdhv.child_id AND mtl.organization_id = ');
              FND_DSQL.add_bind(l_org_id);
              FND_DSQL.add_text(' AND epdhv.parent_id = ');
              FND_DSQL.add_bind(l_product.product_id);
              --
          ELSE
              -- Functional Area id OMFA
              FND_DSQL.add_text('SELECT inventory_item_id FROM mtl_item_categories WHERE organization_id = ');
              FND_DSQL.add_bind(l_org_id);
              FND_DSQL.add_text(' AND category_id = ');
              FND_DSQL.add_bind(l_product.product_id);
              --
          END IF;
          --
      ELSIF l_product.product_level = 'PRODUCT'
      THEN
         --
         FND_DSQL.add_text('SELECT ');
         FND_DSQL.add_bind(l_product.product_id);
         FND_DSQL.add_text(' inventory_item_id FROM DUAL');
         --
      END IF;

      FND_DSQL.add_text(')');

      l_denorm_csr := DBMS_SQL.open_cursor;
      FND_DSQL.set_cursor(l_denorm_csr);
      l_stmt_debug := FND_DSQL.get_text(TRUE);
      l_stmt_denorm := FND_DSQL.get_text(FALSE);
      DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
      FND_DSQL.do_binds;
      l_ignore := DBMS_SQL.execute(l_denorm_csr);
      dbms_sql.close_cursor(l_denorm_csr);



      --
    END LOOP; -- end of discount tiers
    --
  END LOOP; -- end of products




  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      ozf_utility_pvt.write_conc_log(l_stmt_debug);
      ozf_utility_pvt.write_conc_log(SQLERRM);

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END populate_prod_tier;


FUNCTION get_accrualed_amount(p_product_id IN NUMBER
                             ,p_line_amt   IN NUMBER
                             ,p_quantity   IN NUMBER
                             ,p_uom        IN VARCHAR2)
RETURN NUMBER
IS
  --
  CURSOR c_disc_for_item_count IS
  SELECT COUNT(*)
  FROM   ozf_na_products_temp
  WHERE  inventory_item_id = p_product_id
  AND    product_level = 'PRODUCT';

  CURSOR c_discount_for_cat IS
  SELECT discount,
         discount_type,
         volume_type,
         volume_from,
         volume_to,
         uom
  FROM   ozf_na_products_temp
  WHERE  inventory_item_id = p_product_id
  AND    product_level = 'FAMILY';

  CURSOR c_discount_for_item IS
  SELECT discount,
         discount_type,
         volume_type,
         volume_from,
         volume_to, uom
  FROM   ozf_na_products_temp
  WHERE  inventory_item_id = p_product_id
  AND    product_level = 'PRODUCT';

  l_max_accrual         NUMBER;
  l_line_accrual        NUMBER;
  l_disc_for_item_count NUMBER;
  l_volume_qualified    VARCHAR2(1);

BEGIN
   --
   OPEN  c_disc_for_item_count;
   FETCH c_disc_for_item_count INTO l_disc_for_item_count;
   CLOSE c_disc_for_item_count;

   l_max_accrual := 0;

   IF l_disc_for_item_count = 0
   THEN
      --
      FOR l_discount_for_cat IN c_discount_for_cat
      LOOP
         --
         l_line_accrual := 0;
         l_volume_qualified := 'N';

         -- check if order satisfies amt/qty requirement
         IF ( l_discount_for_cat.volume_type = 'AMT' )
         THEN
             --
             IF ( p_line_amt >= l_discount_for_cat.volume_from
                  AND
                  p_line_amt <= l_discount_for_cat.volume_to )
             THEN
                --
                l_volume_qualified := 'Y';
                --
             ELSE
                --
                l_volume_qualified := 'N';
                --
             END IF;
             --
         ELSIF ( l_discount_for_cat.volume_type = 'QTY' )
         THEN
             --
             IF ( p_quantity >= l_discount_for_cat.volume_from
                  AND
                  p_quantity <= l_discount_for_cat.volume_to )
             THEN
                --
                l_volume_qualified := 'Y';
                --
             ELSE
                --
                l_volume_qualified := 'N';
                --
             END IF;
             --
         ELSIF ( l_discount_for_cat.volume_type = 'NA' )
         THEN
             --
             l_volume_qualified := 'Y';
             --
         END IF;



         IF l_volume_qualified = 'Y'
         THEN
             --
             IF l_discount_for_cat.discount_type = '%'
             THEN
                --
                l_line_accrual := p_line_amt * l_discount_for_cat.discount / 100;
                --
             ELSE
                --
                l_line_accrual := l_discount_for_cat.discount;
                --
             END IF;
             --
         END IF;

         -- Memorizes larger accrual amount
         IF l_line_accrual > l_max_accrual
         THEN
            l_max_accrual:= l_line_accrual;
         END IF;

        -- IF G_DEBUG_LOW THEN
            ozf_utility_pvt.write_conc_log('Product belongs to a Category on the Offer');
            ozf_utility_pvt.write_conc_log('ItmId/Qty/Amt/VolType/DiscType/disc/VolQual?');
            ozf_utility_pvt.write_conc_log(p_product_id || '/' ||
                                           p_quantity   || '/' ||
                                           p_line_amt   || '/' ||
                                           l_discount_for_cat.volume_type   || '/' ||
                                           l_discount_for_cat.discount_type || '/' ||
                                           l_discount_for_cat.discount      || '/' ||
                                           l_volume_qualified );
        -- END IF;
         --
      END LOOP;
      --
  ELSE
      -- discount for the item exists. take this value as accrualed discount
      FOR l_discount_for_item IN c_discount_for_item
      LOOP
       ozf_utility_pvt.write_conc_log('l_volume_qualified '||l_volume_qualified);
       ozf_utility_pvt.write_conc_log('l_discount_for_item.volume_from '|| l_discount_for_item.volume_from);
       ozf_utility_pvt.write_conc_log('l_discount_for_item.volume_to '|| l_discount_for_item.volume_to);
       ozf_utility_pvt.write_conc_log('l_discount_for_item.volume_type '|| l_discount_for_item.volume_type);
         ozf_utility_pvt.write_conc_log('p_line_amt '|| p_line_amt);
         ozf_utility_pvt.write_conc_log('l_discount_for_item.discount '|| l_discount_for_item.discount);
          ozf_utility_pvt.write_conc_log('l_discount_for_item.discount_type '|| l_discount_for_item.discount_type);
         --
         l_line_accrual := 0;
         l_volume_qualified := 'N';
         -- check if order satisfies amt/qty requirement
         IF ( l_discount_for_item.volume_type = 'AMT' )
         THEN
            --
            IF ( p_line_amt >= l_discount_for_item.volume_from
                 AND
                 p_line_amt <= l_discount_for_item.volume_to )
            THEN
                --
                l_volume_qualified := 'Y';
                --
            ELSE
                --
                l_volume_qualified := 'N';
                --
            END IF;
            --
         ELSIF ( l_discount_for_item.volume_type = 'QTY' )
         THEN
            --
            IF ( p_quantity >= l_discount_for_item.volume_from
                 AND
                 p_quantity <= l_discount_for_item.volume_to )
            THEN
                --
                l_volume_qualified := 'Y';
                --
            ELSE
                --
                l_volume_qualified := 'N';
                --
            END IF;
            --
         ELSIF ( l_discount_for_item.volume_type = 'NA' )
         THEN
            --
            l_volume_qualified := 'Y';
            --
         END IF;

         -- Calculate Accrual Amount
         IF l_volume_qualified = 'Y'
         THEN
            --
            IF ( l_discount_for_item.discount_type = '%' )
            THEN
               --
               l_line_accrual := p_line_amt * l_discount_for_item.discount / 100;
               --
            ELSE
               --
               l_line_accrual := l_discount_for_item.discount * p_quantity; -- give discount based on quantity
               --
            END IF;
            --
         END IF;
         -- memorizes larger accrual amount
         IF l_line_accrual > l_max_accrual
         THEN
            --
            l_max_accrual:= l_line_accrual;
            --
         END IF;

         IF G_DEBUG_LOW THEN
            ozf_utility_pvt.write_conc_log('ItmId/Qty/Amt/VolType/DiscType/disc/VolQual?/MaxAccr');
            ozf_utility_pvt.write_conc_log(p_product_id || '/' ||
                                           p_quantity   || '/' ||
                                           p_line_amt   || '/' ||
                                           l_discount_for_item.volume_type   || '/' ||
                                           l_discount_for_item.discount_type || '/' ||
                                           l_discount_for_item.discount      || '/' ||
                                           l_volume_qualified                || '/' ||
                                           l_max_accrual );
         END IF;
         --
     END LOOP;
     --
  END IF;

  RETURN l_max_accrual;

END get_accrualed_amount;


FUNCTION get_pv_accrual_amount(p_product_id   IN NUMBER
                              ,p_line_amt     IN NUMBER
                              ,p_offer_id     IN NUMBER
                              ,p_org_id       IN NUMBER
                              ,p_list_hdr_id  IN NUMBER
                              ,p_referral_id  IN NUMBER
                              ,p_order_hdr_id IN NUMBER)
RETURN NUMBER
IS
  -- given category, find max compensation from referral tables
  CURSOR c_maximum_compensation(p_category_id NUMBER) IS
  SELECT b.maximum_compensation
  FROM   pv_ge_benefits_vl a, pv_benft_products b
  WHERE  a.benefit_id = b.benefit_id
  AND    a.benefit_type_code = 'PVREFFRL'
  AND    a.additional_info_1 = p_offer_id
  AND    b.product_category_id = p_category_id;

  -- find accruals already made by the referral
  CURSOR c_existing_accruals IS
  SELECT NVL(DECODE(gl_posted_flag, 'Y', plan_curr_amount), 0) line_amount, product_id
  FROM   ozf_funds_utilized_all_b
  WHERE  reference_type = 'LEAD_REFERRAL'
  AND    reference_id = p_referral_id
  AND    plan_type = 'OFFR'
  AND    plan_id = p_list_hdr_id
  AND    object_type = 'ORDER'
  AND    object_id = p_order_hdr_id;

  l_discount         NUMBER;
  l_category_id      NUMBER;
  l_discount_temp    NUMBER;
  l_category_id_temp NUMBER; -- temperorily store category id for accrualed items
  l_max_compensation NUMBER;
  l_accrualed_amount NUMBER := 0;
  l_acc_amt_order    NUMBER := 0;
  l_return_value     NUMBER := 0;
  l_stmt             VARCHAR2(2000);
BEGIN
   --
   l_stmt := 'SELECT';
   l_stmt := l_stmt || ' DISTINCT  FIRST_VALUE(a.discount) OVER (PARTITION BY epdhv.child_id ORDER BY c.category_level_num DESC NULLS LAST) discount, ' ;
   l_stmt := l_stmt || ' FIRST_VALUE(b.product_id) OVER (PARTITION BY epdhv.child_id ORDER BY c.category_level_num DESC NULLS LAST) product_id ';
   l_stmt := l_stmt || ' FROM ozf_offer_discount_lines a, ';
   l_stmt := l_stmt || ' ozf_offer_discount_products b, ';
   l_stmt := l_stmt || ' eni_prod_den_hrchy_parents_v c, ';
   l_stmt := l_stmt || ' mtl_item_categories mic, ';
   l_stmt := l_stmt || ' eni_prod_denorm_hrchy_v epdhv ';
   l_stmt := l_stmt || ' WHERE a.offer_discount_line_id = b.offer_discount_line_id ';
   l_stmt := l_stmt || ' AND a.offer_id = :1 ';
   l_stmt := l_stmt || ' AND mic.inventory_item_id = :2 ';
   l_stmt := l_stmt || ' AND mic.category_set_id = epdhv.category_set_id ';
   l_stmt := l_stmt || ' AND mic.category_id = epdhv.child_id ';
   l_stmt := l_stmt || ' AND mic.organization_id = :3 ';
   l_stmt := l_stmt || ' AND b.product_id = epdhv.parent_id ';
   l_stmt := l_stmt || ' AND epdhv.parent_id = c.category_id';

   IF G_DEBUG_LOW THEN
      ozf_utility_pvt.write_conc_log('Statement is : ' || l_stmt);
      ozf_utility_pvt.write_conc_log('Bind var is  : ' || p_product_id);
   END IF;

   EXECUTE IMMEDIATE l_stmt INTO l_discount, l_category_id USING p_offer_id, p_product_id, p_org_id;

   IF G_DEBUG_LOW THEN
      ozf_utility_pvt.write_conc_log('Discount    : ' || l_discount);
      ozf_utility_pvt.write_conc_log('Category_Id : ' || l_category_id);
   END IF;

   IF ( l_discount IS NOT NULL AND l_category_id IS NOT NULL )
   THEN
      -- Discount rule exists
      l_acc_amt_order := p_line_amt * l_discount / 100;

      OPEN  c_maximum_compensation(l_category_id);
      FETCH c_maximum_compensation INTO l_max_compensation;
      CLOSE c_maximum_compensation;

      IF G_DEBUG_LOW THEN
         ozf_utility_pvt.write_conc_log('accrual for order line:'||l_acc_amt_order);
         ozf_utility_pvt.write_conc_log('max compensation:'||l_max_compensation);
      END IF;

      FOR i IN c_existing_accruals
      LOOP
         --
         EXECUTE IMMEDIATE l_stmt INTO l_discount_temp, l_category_id_temp USING p_offer_id, i.product_id, p_org_id;
         --
         IF l_category_id_temp = l_category_id
         THEN
            -- Other item from same category found
            l_accrualed_amount := l_accrualed_amount + i.line_amount;
            --
         END IF;
         --
      END LOOP;

      IF ( l_max_compensation IS NULL OR
           (l_max_compensation - l_accrualed_amount >= l_acc_amt_order)
         )
      THEN
         --
         l_return_value := l_acc_amt_order;
         --
      ELSE
         --
         l_return_value := l_max_compensation - l_accrualed_amount;
         --
      END IF;
      --
  END IF;
  --
  RETURN l_return_value;
  --
END get_pv_accrual_amount;

PROCEDURE log_exception(p_act_budgets_rec IN ozf_actbudgets_pvt.act_budgets_rec_type,
                        p_act_util_rec    IN ozf_actbudgets_pvt.act_util_rec_type)
IS
  CURSOR c_na_conc_exception_id IS
  SELECT ozf_na_conc_exceptions_s.NEXTVAL
  FROM   DUAL;

  CURSOR c_pk_exist(p_na_conc_exception_id NUMBER) IS
  SELECT 1
  FROM   DUAL
  WHERE EXISTS (SELECT 1
                FROM   ozf_na_conc_exceptions
                WHERE  na_conc_exception_id = p_na_conc_exception_id);

  l_na_conc_exception_id NUMBER;
  l_pk_exist NUMBER;
BEGIN
  ozf_utility_pvt.write_conc_log('Writing exception log for offer ' || p_act_budgets_rec.act_budget_used_by_id);
  LOOP
    l_pk_exist := NULL;

    OPEN  c_na_conc_exception_id;
    FETCH c_na_conc_exception_id INTO l_na_conc_exception_id;
    CLOSE c_na_conc_exception_id;

    OPEN  c_pk_exist(l_na_conc_exception_id);
    FETCH c_pk_exist INTO l_pk_exist;
    CLOSE c_pk_exist;

    EXIT WHEN l_pk_exist IS NULL;
  END LOOP;

  INSERT INTO ozf_na_conc_exceptions(na_conc_exception_id
                                    ,act_budget_used_by_id
                                    ,arc_act_budget_used_by
                                    ,budget_source_type
                                    ,budget_source_id
                                    ,request_amount
                                    ,request_currency
                                    ,request_date
                                    ,status_code
                                    ,approved_amount
                                    ,approved_in_currency
                                    ,approval_date
                                    ,approver_id
                                    ,transfer_type
                                    ,requester_id
                                    ,object_type
                                    ,object_id
                                    ,product_level_type
                                    ,product_id
                                    ,cust_account_id
                                    ,utilization_type
                                    ,adjustment_date
                                    ,gl_date
                                    ,billto_cust_account_id
                                    ,reference_type
                                    ,reference_id
                                    ,order_line_id
                                    ,org_id)
                              VALUES(l_na_conc_exception_id
                                    ,p_act_budgets_rec.act_budget_used_by_id
                                    ,p_act_budgets_rec.arc_act_budget_used_by
                                    ,p_act_budgets_rec.budget_source_type
                                    ,p_act_budgets_rec.budget_source_id
                                    ,p_act_budgets_rec.request_amount
                                    ,p_act_budgets_rec.request_currency
                                    ,p_act_budgets_rec.request_date
                                    ,p_act_budgets_rec.status_code
                                    ,p_act_budgets_rec.approved_amount
                                    ,p_act_budgets_rec.approved_in_currency
                                    ,p_act_budgets_rec.approval_date
                                    ,p_act_budgets_rec.approver_id
                                    ,p_act_budgets_rec.transfer_type
                                    ,p_act_budgets_rec.requester_id
                                    ,p_act_util_rec.object_type
                                    ,p_act_util_rec.object_id
                                    ,p_act_util_rec.product_level_type
                                    ,p_act_util_rec.product_id
                                    ,p_act_util_rec.cust_account_id
                                    ,p_act_util_rec.utilization_type
                                    ,p_act_util_rec.adjustment_date
                                    ,p_act_util_rec.gl_date
                                    ,p_act_util_rec.billto_cust_account_id
                                    ,p_act_util_rec.reference_type
                                    ,p_act_util_rec.reference_id
                                    ,p_act_util_rec.order_line_id
                                    ,p_act_util_rec.org_id);
END log_exception;


PROCEDURE process_exceptions IS

  CURSOR c_exception_rec IS
  SELECT *
  FROM   ozf_na_conc_exceptions;

  l_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
  l_act_util_rec    ozf_actbudgets_pvt.act_util_rec_type;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_act_budget_id   NUMBER;
  l_utilized_amount NUMBER := 0;

BEGIN
  --
  FOR l_exception_rec IN c_exception_rec
  LOOP
    --
    IF G_DEBUG_LOW
    THEN
       ozf_utility_pvt.write_conc_log('Processing exception Id = ' || l_exception_rec.na_conc_exception_id);
    END IF;

    l_return_status := FND_API.g_ret_sts_success; -- bug 3655853

    l_act_budgets_rec.act_budget_used_by_id := l_exception_rec.act_budget_used_by_id;
    l_act_budgets_rec.arc_act_budget_used_by := l_exception_rec.arc_act_budget_used_by;
    l_act_budgets_rec.budget_source_type := l_exception_rec.budget_source_type;
    l_act_budgets_rec.budget_source_id := l_exception_rec.budget_source_id;
    l_act_budgets_rec.request_amount := l_exception_rec.request_amount;
    l_act_budgets_rec.request_currency := l_exception_rec.request_currency;
    l_act_budgets_rec.request_date := l_exception_rec.request_date;
    l_act_budgets_rec.status_code := l_exception_rec.status_code;
    l_act_budgets_rec.approved_amount := l_exception_rec.approved_amount;
    l_act_budgets_rec.approved_in_currency := l_exception_rec.approved_in_currency;
    l_act_budgets_rec.approval_date := l_exception_rec.approval_date;
    l_act_budgets_rec.approver_id := l_exception_rec.approver_id;
    l_act_budgets_rec.transfer_type := l_exception_rec.transfer_type;
    l_act_budgets_rec.requester_id := l_exception_rec.requester_id;

    l_act_util_rec.object_type := l_exception_rec.object_type;
    l_act_util_rec.object_id := l_exception_rec.object_id;
    l_act_util_rec.product_level_type := l_exception_rec.product_level_type;
    l_act_util_rec.product_id := l_exception_rec.product_id;
    l_act_util_rec.cust_account_id := l_exception_rec.cust_account_id;
    l_act_util_rec.utilization_type := l_exception_rec.utilization_type;
    l_act_util_rec.adjustment_date := l_exception_rec.adjustment_date;
    l_act_util_rec.gl_date := l_exception_rec.gl_date;
    l_act_util_rec.billto_cust_account_id := l_exception_rec.billto_cust_account_id;
    l_act_util_rec.reference_type := l_exception_rec.reference_type;
    l_act_util_rec.reference_id := l_exception_rec.reference_id;
    l_act_util_rec.order_line_id := l_exception_rec.order_line_id;
    l_act_util_rec.org_id := l_exception_rec.org_id;

    ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => l_return_status
                                               ,x_msg_count       => l_msg_count
                                               ,x_msg_data        => l_msg_data
                                               ,p_act_budgets_rec => l_act_budgets_rec
                                               ,p_act_util_rec    => l_act_util_rec
                                               ,x_act_budget_id   => l_act_budget_id
                                               ,x_utilized_amount => l_utilized_amount);

    IF G_DEBUG_LOW
    THEN
      ozf_utility_pvt.write_conc_log('Exception_id - Status: ' || l_exception_rec.na_conc_exception_id
                                                               || ' - '
                                                               || l_return_status);
      ozf_utility_pvt.write_conc_log('Utilization Amount Created: ' || l_utilized_amount);
    END IF;

    IF l_return_status = FND_API.g_ret_sts_success
    THEN
      --
      DELETE FROM ozf_na_conc_exceptions
      WHERE na_conc_exception_id = l_exception_rec.na_conc_exception_id;
      --
    END IF;
    l_utilized_amount := 0;
    --
  END LOOP; -- Done Processing exception records

END process_exceptions;


--------------------
-- Main Procedure
--------------------

PROCEDURE net_accrual_engine( ERRBUF          OUT NOCOPY VARCHAR2,
                              RETCODE         OUT NOCOPY VARCHAR2,
                              p_as_of_date    IN  VARCHAR2,
                              p_offer_id      IN  NUMBER DEFAULT NULL)
IS
  --
  CURSOR c_net_accrual_offers IS
  SELECT ozf.offer_id,
         ozf.qp_list_header_id,
         ozf.latest_na_completion_date,
         ozf.custom_setup_id,
         ozf.tier_level,
         NVL(ozf.transaction_currency_code, ozf.fund_request_curr_code) fund_request_curr_code,
         transaction_currency_code,
         ozf.qualifier_id,
         ozf.na_rule_header_id,
         ozf.owner_id,
         TRUNC(qp.start_date_active) start_date_active,
         TRUNC(qp.end_date_active + 1) - (1/86400) end_date_active,
         qp.orig_org_id,
         qp_tl.description offer_name,
         ozf.sales_method_flag,
         NVL(ozf.resale_line_id_processed, 0) resale_line_id_processed
  FROM   ozf_offers ozf,
         qp_list_headers_b qp,
         qp_list_headers_tl qp_tl
  WHERE  ozf.offer_type = 'NET_ACCRUAL'
  AND    ozf.status_code = 'ACTIVE'
  AND    ozf.offer_id = NVL(p_offer_id, ozf.offer_id)
  AND    ozf.qp_list_header_id = qp.list_header_id
  AND    qp.list_header_id = qp_tl.list_header_id
--  AND    qp.orig_org_id =  TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10))
  AND    qp_tl.language = USERENV('LANG');

  CURSOR c_na_rule_lines(p_na_rule_header_id NUMBER) IS
  SELECT na_deduction_rule_id
  FROM   ozf_na_rule_lines
  WHERE  na_rule_header_id = p_na_rule_header_id
  AND    active_flag = 'Y';

  CURSOR c_na_deduction_rule(p_deduction_rule_id NUMBER) IS
  SELECT a.na_deduction_rule_id,
         a.transaction_source_code,
         a.transaction_type_code,
         a.deduction_identifier_id,
         a.deduction_identifier_org_id,
         b.name
  FROM ozf_na_deduction_rules_b a,
       ozf_na_deduction_rules_tl b
  WHERE a.na_deduction_rule_id = b.na_deduction_rule_id
  AND   b.language = USERENV('LANG')
  AND   a.na_deduction_rule_id = p_deduction_rule_id;

  l_na_deduction_rule c_na_deduction_rule%ROWTYPE;



  CURSOR c_order_line (p_start_date DATE,
                       p_end_date   DATE,
                       p_offer_org_id     NUMBER) IS
  SELECT /*+ ordered use_hash(OL) full(OL) use_nl(OH) */
         ol.header_id,
         ol.line_id,
         ol.actual_shipment_date,
         ol.fulfillment_date,
         ol.invoice_to_org_id,
         ol.ship_to_org_id,
         ol.sold_to_org_id,
         ol.inventory_item_id,
         ol.shipped_quantity,
         ol.fulfilled_quantity,
         ol.invoiced_quantity,
         ol.pricing_quantity,
         ol.pricing_quantity_uom,
         ol.unit_selling_price,
         ol.org_id,
         NVL(ol.actual_shipment_date,ol.fulfillment_date) conv_date,
         oh.transactional_curr_code
  FROM   ( SELECT /*+ no_merge */ DISTINCT INVENTORY_ITEM_ID FROM OZF_NA_PRODUCTS_TEMP ) na,
         oe_order_lines_all ol,
         oe_order_headers_all oh
  WHERE  ol.inventory_item_id = na.inventory_item_id
  AND ol.flow_status_code IN ('SHIPPED','CLOSED')
  AND ol.cancelled_flag = 'N'
  AND ol.line_category_code <> 'RETURN'
  AND ( NVL(ol.actual_shipment_date,ol.fulfillment_date)
         BETWEEN p_start_date AND p_end_date
      )
  AND ol.org_id = NVL(p_offer_org_id, ol.org_id)
  AND ol.header_id = oh.header_id;

  CURSOR c_idsm_line (p_offer_start_date DATE,
                      p_offer_end_date   DATE,
                      p_offer_org_id     NUMBER,
                      p_resale_line_id   NUMBER) IS
  SELECT resale_header_id header_id,
         resale_line_id line_id,
         date_ordered actual_shipment_date,
         NULL fulfillment_date,
         bill_to_site_use_id invoice_to_org_id,
         ship_to_site_use_id ship_to_org_id,
         bill_to_cust_account_id sold_to_org_id,
         inventory_item_id,
         quantity shipped_quantity,
         quantity fulfilled_quantity,
         quantity invoiced_quantity,
         quantity pricing_quantity,
         uom_code pricing_quantity_uom,
         selling_price unit_selling_price,
         org_id,
         NVL(exchange_rate_date, date_ordered) conv_date,
         currency_code transactional_curr_code
  FROM   ozf_resale_lines_all
  WHERE  inventory_item_id IN ( SELECT na.inventory_item_id
                                     FROM ozf_na_products_temp na)
--  AND ol.flow_status_code IN ('SHIPPED','CLOSED')
--  AND ol.cancelled_flag = 'N'
--  AND ol.line_category_code <> 'RETURN'
  AND   TRUNC(date_ordered) >= TRUNC(p_offer_start_date)
  AND   TRUNC(date_ordered) <= TRUNC(NVL(p_offer_end_date, SYSDATE))
  AND   org_id = NVL(p_offer_org_id, org_id)
  AND   quantity > 0
  AND   resale_header_id > p_resale_line_id
  ORDER BY resale_line_id;

  CURSOR c_ar_trx_line_details( p_cust_trx_type_id  NUMBER,
                                p_start_date        DATE,
                                p_end_date          DATE,
                                p_org_id            NUMBER
                              ) IS
  SELECT NVL(a.extended_amount, 0) extended_amount,
         a.inventory_item_id,
         a.quantity_credited,
         a.quantity_invoiced,
         a.uom_code,
         b.sold_to_customer_id,
         b.bill_to_site_use_id,
         b.ship_to_site_use_id,
         b.invoice_currency_code,
         b.customer_trx_id,
         b.complete_flag,
         b.trx_date conv_date,
         a.customer_trx_line_id
  FROM   ra_customer_trx_lines_all a,
         ra_customer_trx_all b
  WHERE  a.inventory_item_id IN ( SELECT na.inventory_item_id
                                  FROM   ozf_na_products_temp na)
  AND    a.line_type       = 'LINE'
  AND    a.customer_trx_id = b.customer_trx_id
  AND    b.complete_flag   = 'Y'
  AND    b.cust_trx_type_id = p_cust_trx_type_id
  AND    b.trx_date BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date)
  AND    b.org_id = p_org_id;


  CURSOR c_return_line (p_order_type_id NUMBER,
                        p_start_date    DATE,
                        p_end_date      DATE) IS
  SELECT /*+ ordered use_hash(OL) full(OL) use_nl(OH) */
         ol.header_id,
         ol.line_id,
         ol.actual_shipment_date,
         ol.fulfillment_date,
         ol.invoice_to_org_id,
         ol.ship_to_org_id,
         ol.sold_to_org_id,
         ol.inventory_item_id,
         ol.shipped_quantity,
         ol.fulfilled_quantity,
         ol.invoiced_quantity,
         ol.pricing_quantity,
         ol.pricing_quantity_uom,
         ol.unit_selling_price,
         ol.org_id,
         NVL(ol.actual_arrival_date,ol.fulfillment_date) conv_date,
         oh.transactional_curr_code
  FROM   ( SELECT /*+ no_merge */ DISTINCT INVENTORY_ITEM_ID FROM OZF_NA_PRODUCTS_TEMP ) NA,
         oe_order_lines_all ol,
         oe_order_headers_all oh
  WHERE  ol.inventory_item_id = na.inventory_item_id
  AND ol.open_flag = 'N'
  AND ol.cancelled_flag = 'N'
  AND ol.line_category_code = 'RETURN'
  AND ( NVL(ol.actual_arrival_date,ol.fulfillment_date)
         BETWEEN p_start_date AND p_end_date
      )
  AND ol.header_id = oh.header_id
  AND oh.order_type_id = p_order_type_id;

  /* Indexes on utilization table
     Not Unique Index: OZF_FUNDS_UTILIZED_ALL_B_N14
     REFERENCE_TYPE  TRX_LINE
     REFERENCE_ID    customer_trx_line_id

     Not Unique Index: OZF_FUNDS_UTILIZED_ALL_B_N19
     OBJECT_TYPE     CM OR DM
     OBJECT_ID       customer_trx_id

     Not Unique Index: OZF_FUNDS_UTILIZED_ALL_B_N9
     PRODUCT_ID          inventory_item_id
     PRODUCT_LEVEL_TYPE  PRODUCT
  */
  CURSOR c_tm_lines(p_activity_media_id NUMBER,
                    p_start_date        DATE,
                    p_end_date          DATE,
                    p_qp_list_header_id NUMBER) IS
  SELECT NVL(DECODE(a.gl_posted_flag, 'Y', a.plan_curr_amount), 0) line_amount,
         a.cust_account_id,
         a.adjustment_date conv_date,
         a.currency_code,
         a.org_id --Added for bug 7030415
  FROM   ozf_funds_utilized_all_b a,
         ozf_offers b,
         ozf_na_products_temp c
  WHERE  a.plan_type = 'OFFR'
  AND    a.plan_id = b.qp_list_header_id
  AND    b.qp_list_header_id <> p_qp_list_header_id
  AND    a.adjustment_date BETWEEN p_start_date and p_end_date
  AND    a.utilization_type IN ('ACCRUAL','ADJUSTMENT')
  AND    b.activity_media_id = p_activity_media_id
  AND    a.product_id = c.inventory_item_id
  AND    a.product_level_type = 'PRODUCT';

  CURSOR c_get_util_amt(p_customer_trx_line_id NUMBER,
                        p_inventory_item_id    NUMBER,
                        p_qp_list_header_id    NUMBER) IS
  SELECT NVL(SUM(plan_curr_amount),0)
  FROM ozf_funds_utilized_all_b
  WHERE reference_type     = 'TRX_LINE'
  AND   reference_id       = p_customer_trx_line_id
  AND   product_id         = p_inventory_item_id
  AND   product_level_type = 'PRODUCT'
  AND   plan_type          = 'OFFR'
  AND   plan_id            = p_qp_list_header_id;

  -- Added for bug 7030415
  CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
  SELECT exchange_rate_type
  FROM   ozf_sys_parameters_all
  WHERE  org_id = p_org_id;


  l_exchange_rate_type VARCHAR2(30) := FND_API.G_MISS_CHAR;
  l_order_line_tbl    t_order_line_tbl;
  l_ar_trx_line_tbl   t_ar_trx_line_tbl;
  l_return_line_tbl   t_order_line_tbl;
  l_idsm_line_tbl     t_order_line_tbl;
  l_batch_size        NUMBER := 1000;

  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);

  l_latest_comp_date   DATE;
  l_as_of_date         DATE;
  l_ar_start_date      DATE;
  l_start_date         DATE;
  l_end_date           DATE;
  l_sysdate            DATE;

  l_customer_qualified VARCHAR2(1);
  l_product_qualified  VARCHAR2(1);

  l_line_amount        NUMBER;
  l_line_acc_amount    NUMBER;

  l_accrual_amount     NUMBER;
  l_existing_util_amt  NUMBER;
  l_ar_dedu_line_amt   NUMBER;
  l_ar_dedu_amount     NUMBER;

  l_om_dedu_line_amt   NUMBER;
  l_om_dedu_amount     NUMBER;

  l_tm_dedu_line_amt   NUMBER;
  l_tm_dedu_amount     NUMBER;

  l_batch_mode         VARCHAR2(10);
  l_orig_batch_mode    VARCHAR2(10);
  l_order_curr_code    VARCHAR2(30);
  l_org_id             NUMBER; -- Inventory Org
  l_offer_org_id       NUMBER; -- Org in Which the offer was created

  l_act_budgets_rec    ozf_actbudgets_pvt.act_budgets_rec_type;
  l_act_util_rec       ozf_actbudgets_pvt.act_util_rec_type;
  l_act_budget_id      NUMBER;
  l_referral_id        NUMBER;
  l_beneficiary_id     NUMBER;
  l_utilization_type   VARCHAR2(30);
  l_reference_type     VARCHAR2(30);
  l_sign               NUMBER;
  l_quantity           NUMBER;
  l_utilized_amount    NUMBER := 0;

  l_rate               NUMBER;
  --nirprasa,12.2
  l_new_line_acc_amount NUMBER;
  l_new_existing_util_amt  NUMBER;
  l_new_ar_dedu_line_amt   NUMBER;
  l_new_ar_dedu_amount     NUMBER;


  -- Used to Validate country code for PRM Net Accrual Offer

  CURSOR c_terr_countries ( p_offer_id IN NUMBER) IS
  SELECT  terr_val.low_value_char
    FROM ozf_offer_qualifiers offer_qual,
         jtf_terr_qual_all    terr_qual,
         jtf_terr_values_all  terr_val
   WHERE offer_qual.offer_id = p_offer_id
   AND   offer_qual.qualifier_attr_value = terr_qual.terr_id
   AND   terr_qual.qual_usg_id = -1065 -- Pick Country Qualifier only
   AND   terr_qual.terr_qual_id = terr_val.terr_qual_id;

   l_terr_countries_tbl terr_countries_tbl;

  CURSOR c_country_code(p_site_use_id NUMBER) IS
  SELECT hzloc.country
  FROM   hz_cust_site_uses_all hzcsua,
         hz_cust_acct_sites_all hzcasa,
         hz_locations hzloc,
         hz_party_sites hzps
  WHERE  hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id
  AND    hzcasa.party_site_id = hzps.party_site_id
  AND    hzps.location_id = hzloc.location_id
  AND    hzcsua.status = 'A'
  AND    hzcsua.site_use_id = p_site_use_id;

  l_country_code VARCHAR2(60);
  l_new_amount   NUMBER;
  l_date_from_input    DATE;
  l_idsm_line_processed NUMBER := 0;
  --

  --bug 7577311
  l_status            VARCHAR2(5);
  l_industry          VARCHAR2(5);
  l_schema            VARCHAR2(30);
  l_return            BOOLEAN;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT net_accrual_engine;

  RETCODE := '0';

  --bug 7577311 - get schema name
  l_return  := fnd_installation.get_app_info('OZF', l_status, l_industry, l_schema);

  l_sysdate := TRUNC(SYSDATE); --nepanda : fix for bug 8766564 .added variable for sysdate and initialized it to the date the net accrual engine has started.

  -- initialize multi org
  MO_GLOBAL.init('OZF');
  MO_GLOBAL.set_policy_context('M',null);

  ozf_utility_pvt.write_conc_log('-- Start Processing : ' || to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));

  ozf_utility_pvt.write_conc_log('-- Process_Exceptions (+) ');
  --
  process_exceptions();
  --
  ozf_utility_pvt.write_conc_log('-- Process_Exceptions (-) ');
  --
  l_date_from_input := TRUNC(TO_DATE(p_as_of_date, 'YYYY/MM/DD HH24:MI:SS'));
  ozf_utility_pvt.write_conc_log('-- Date Converted : ' || l_date_from_input);

  IF (l_date_from_input IS NULL)
      OR
     (TRUNC(l_date_from_input) >= TRUNC(SYSDATE))
  THEN
    l_as_of_date := SYSDATE;
  ELSE
    -- Set end time to 23:59:59 of the day.
    l_as_of_date := TRUNC(l_date_from_input + 1) - 1/86400;
  END IF;

  l_orig_batch_mode := fnd_profile.value('OZF_PROCESS_NA_BATCH_MODE');
  l_org_id          := fnd_profile.value('QP_ORGANIZATION_ID');

  IF l_orig_batch_mode IS NULL
  THEN
    l_orig_batch_mode := 'NO';
  END IF;

  ozf_utility_pvt.write_conc_log('OZF: Process Net Accrual In Batch Mode: '||l_orig_batch_mode);
  ozf_utility_pvt.write_conc_log('QP: Item Validation Organization: '||l_org_id);

  ozf_utility_pvt.write_conc_log('-- Start Processing Net Accrual Offers (+) ');

  ----------------------------------------------------
  FOR l_net_accrual_offers IN c_net_accrual_offers
  LOOP
     --
     l_return_status := FND_API.g_ret_sts_success;

     ozf_utility_pvt.write_conc_log('-----------------------------------------');
     ozf_utility_pvt.write_conc_log('--');
     ozf_utility_pvt.write_conc_log('-------- Processing Offer: '|| l_net_accrual_offers.offer_name);
     ozf_utility_pvt.write_conc_log(' Offer_Id / List_Header_Id / Custom_Setup_Id / Orig_Org_Id: '
                                     || l_net_accrual_offers.offer_id || ' / '
                                     || l_net_accrual_offers.qp_list_header_id || ' / '
                                     || l_net_accrual_offers.custom_setup_id || ' / '
                                     || l_net_accrual_offers.orig_org_id );
     ozf_utility_pvt.write_conc_log('--');

     -------- Derive Program Start and End Date Range ----------
     l_latest_comp_date    := l_net_accrual_offers.latest_na_completion_date;
     l_start_date          := l_net_accrual_offers.start_date_active;
     l_end_date            := l_net_accrual_offers.end_date_active;
     l_idsm_line_processed := l_net_accrual_offers.resale_line_id_processed;

     IF l_latest_comp_date IS NOT NULL
     THEN
       l_start_date := l_latest_comp_date;
     END IF;

     IF l_end_date IS NULL OR l_end_date > l_as_of_date
     THEN
       l_end_date := l_as_of_date;
     END IF;

     ozf_utility_pvt.write_conc_log('Accrual Start Period: '||to_char(l_start_date,'MM/DD/YY HH:MI:SS AM'));
     ozf_utility_pvt.write_conc_log('Accrual End Date:  '   ||to_char(l_end_date,'MM/DD/YY HH:MI:SS AM'));
     ozf_utility_pvt.write_conc_log('Resale Line Processed:  ' || l_idsm_line_processed);

     IF l_start_date > l_end_date
     THEN
        -- This offer has been completely processed. Skip OM, Continue Process IDSM.
        ozf_utility_pvt.write_conc_log('This Offer has been completely processed for OM. Skipping to IDSM. ');
        GOTO IDSM;
     END IF;
     --------------------------------------------------------------

     IF l_net_accrual_offers.custom_setup_id = 105
     THEN
         -- The batch mode profile does not apply for PRM offers
         l_batch_mode := 'NO';
         l_offer_org_id := NULL;
     ELSE
         l_batch_mode  := l_orig_batch_mode;
         l_offer_org_id := l_net_accrual_offers.orig_org_id;
     END IF;

     --bug 7577311
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.ozf_na_customers_temp';
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.ozf_na_products_temp';

     ----------------- Denrom Customers ------------------
     IF l_net_accrual_offers.custom_setup_id = 105
     THEN
       --
       -- For PRM Offers, populate local table with all qualifying countries
       -- once for each offer in a local PL/SQL table
       -- No need to use LIMIT clause since # of countries will be limited for a terr
       --
       l_terr_countries_tbl.delete;

       OPEN c_terr_countries(l_net_accrual_offers.offer_id);
       FETCH c_terr_countries BULK COLLECT INTO l_terr_countries_tbl;
       CLOSE c_terr_countries;

       IF l_terr_countries_tbl.FIRST IS NULL
       THEN
          -- No countries defined for a PRM Offer
          -- No point processing this offer. Skip it offer
          -- If implementation is correct, this will never happen
          ozf_utility_pvt.write_conc_log('-- No country qualifiers provided for PRM Offer. Not Processing it ..');
          GOTO NEXT_OFFER;
       END IF;
       --
       IF G_DEBUG_LOW
       THEN
          --
          FOR c IN  l_terr_countries_tbl.FIRST..l_terr_countries_tbl.LAST
          LOOP
              ozf_utility_pvt.write_conc_log('Country Code: '|| l_terr_countries_tbl(c) );
          END LOOP;
          --
       END IF;
       --
     ELSE
       --
       -- For all other Offers, populate the ozf_na_customers_temp denom table
       --

       ozf_utility_pvt.write_conc_log('Populate_Customers (+)');

       populate_customers(l_net_accrual_offers.offer_id
                       ,l_return_status
                       ,l_msg_count
                       ,l_msg_data);

       ozf_utility_pvt.write_conc_log('Populate_Customers (-) With Status: ' ||l_return_status);

       IF l_return_status =  Fnd_Api.g_ret_sts_error
       THEN
          RAISE Fnd_Api.g_exc_error;
       ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
       THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
       END IF;
       --
     END IF;
     ------------------------------------------------------

     --------------- Denorm Products ----------------------
     IF l_net_accrual_offers.tier_level = 'LINE'
     THEN
       --
       ozf_utility_pvt.write_conc_log('Populate_Prod_Line (+)');

       populate_prod_line(l_net_accrual_offers.offer_id
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data);

       ozf_utility_pvt.write_conc_log('Populate_Prod_Line (-) With Status: '||l_return_status);
       --
     ELSIF l_net_accrual_offers.tier_level = 'HEADER'
     THEN
       --
       ozf_utility_pvt.write_conc_log('Populate_Prod_Tier (+)');

       populate_prod_tier(l_net_accrual_offers.offer_id
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data);

       ozf_utility_pvt.write_conc_log('Populate_Prod_Tier (-) With Status: '||l_return_status);
      --
     END IF;
     ---------------------------------------------------------

     IF l_return_status =  Fnd_Api.g_ret_sts_error THEN
       RAISE Fnd_Api.g_exc_error;
     ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
       RAISE Fnd_Api.g_exc_unexpected_error;
     END IF;

     --------------- Start Processing Orders ------------------------
     ozf_utility_pvt.write_conc_log('-- Start Processing Orders -- ');

     --------------- Start Processing OM lines ------------------------
   IF l_net_accrual_offers.sales_method_flag IS NULL OR l_net_accrual_offers.sales_method_flag = 'D' THEN
     --
     ozf_utility_pvt.write_conc_log('Processing OM lines');
     ozf_utility_pvt.write_conc_log('l_start_date '|| l_start_date);
     ozf_utility_pvt.write_conc_log('l_end_date '|| l_end_date);
     ozf_utility_pvt.write_conc_log('l_offer_org_id '|| l_offer_org_id);
     l_order_line_tbl.delete;
     l_accrual_amount := 0;

     OPEN c_order_line(l_start_date, l_end_date, l_offer_org_id);

     LOOP
         --
         FETCH c_order_line BULK COLLECT INTO l_order_line_tbl LIMIT l_batch_size;
         --
         -- To handle NO DATA FOUND for c_order_line CURSOR
            IF  l_order_line_tbl.FIRST IS NULL
            THEN
               --
               ozf_utility_pvt.write_conc_log('No Data found in c_order_line CURSOR');
               EXIT;
               --
            END IF;
         --
         -- Logic to exit after all the record have been processed
         -- is just before the END LOOP EXIT WHEN c_order_line%NOTFOUND;

         ---------------------------------------------------------
         FOR i IN l_order_line_tbl.FIRST .. l_order_line_tbl.LAST
         LOOP
         ---------------------------------------------------------
         --

         l_return_status := FND_API.g_ret_sts_success;

         IF G_DEBUG_LOW THEN
            ozf_utility_pvt.write_conc_log('Order Line_Id: '||l_order_line_tbl(i).line_id);
         END IF;

         l_line_amount := ( NVL(l_order_line_tbl(i).shipped_quantity,l_order_line_tbl(i).fulfilled_quantity)
                            * l_order_line_tbl(i).unit_selling_price );
         --
         ------------- Qualify Customer on the Order line ------------------------------
         --

         IF l_net_accrual_offers.custom_setup_id = 105
         THEN
              ----- For PV Net Accrual Offers, do not look at denorm -------
              ----- Get Country code from the Identifying addresss of the Customer
              OPEN  c_country_code(l_order_line_tbl(i).invoice_to_org_id);
              FETCH c_country_code INTO l_country_code;
              CLOSE c_country_code;

              -- l_terr_countries_tbl  has all the countries eligible for this offer
              -- This table is populated in the 'Denorm Customers' section for each PV NA Offer
              l_customer_qualified := 'N';

              FOR j IN l_terr_countries_tbl.FIRST .. l_terr_countries_tbl.LAST
              LOOP
                 --
                 IF l_country_code = l_terr_countries_tbl(j)
                 THEN
                     l_customer_qualified := 'Y';
                     EXIT;
                 END IF;
                 --
              END LOOP;

              IF l_customer_qualified = 'N' THEN
                -- sold_to not qualified. try ship_to
                OPEN  c_country_code(l_order_line_tbl(i).ship_to_org_id);
                FETCH c_country_code INTO l_country_code;
                CLOSE c_country_code;

                FOR j IN l_terr_countries_tbl.FIRST .. l_terr_countries_tbl.LAST
                LOOP
                   --
                   IF l_country_code = l_terr_countries_tbl(j)
                   THEN
                     l_customer_qualified := 'Y';
                     EXIT;
                   END IF;
                   --
                END LOOP;
                --
              END IF;
              --
          ELSE
              ----- For all other Net Accrual offers, look at denorm -------
              l_customer_qualified := validate_customer(p_invoice_to_org_id => l_order_line_tbl(i).invoice_to_org_id
                                                       ,p_ship_to_org_id    => l_order_line_tbl(i).ship_to_org_id
                                                       ,p_sold_to_org_id    => l_order_line_tbl(i).sold_to_org_id);
              --
          END IF; -- Done qualfiying the customer

          IF G_DEBUG_LOW THEN
            ozf_utility_pvt.write_conc_log('Did Customer qualify: '||l_customer_qualified);
          END IF;

          -- Fetch Currency Code on the Order
          l_order_curr_code := l_order_line_tbl(i).transactional_curr_code ;
          ozf_utility_pvt.write_conc_log('l_order_curr_code: '|| l_order_curr_code);
          ozf_utility_pvt.write_conc_log('l_net_accrual_offers.fund_request_curr_code: '|| l_net_accrual_offers.fund_request_curr_code);

          IF l_customer_qualified = 'Y'
          THEN
              --
              IF l_net_accrual_offers.fund_request_curr_code <> l_order_curr_code
              THEN
                  --
                  l_new_amount := 0;

                 --Added for bug 7030415
                 ozf_utility_pvt.write_conc_log('l_order_line_tbl(i).org_id: '|| l_order_line_tbl(i).org_id);
                 IF l_batch_mode = 'NO' THEN
                 OPEN c_get_conversion_type(l_order_line_tbl(i).org_id);
                 FETCH c_get_conversion_type INTO l_exchange_rate_type;
                 CLOSE c_get_conversion_type;
                 ozf_utility_pvt.write_conc_log('l_exchange_rate_type: '|| l_exchange_rate_type);
                 ozf_utility_pvt.write_conc_log('l_line_amount: '|| l_line_amount);
                 END IF;

                  ozf_utility_pvt.convert_currency(x_return_status => l_return_status
                                          ,p_from_currency => l_order_curr_code
                                          ,p_to_currency   => l_net_accrual_offers.fund_request_curr_code
                                          ,p_conv_type     => l_exchange_rate_type
                                          --,p_conv_date   => l_order_line_tbl(i).conv_date
                                          ,p_conv_date     => sysdate
                                          ,p_from_amount   => l_line_amount
                                          ,x_to_amount     => l_new_amount
                                          ,x_rate          => l_rate);
                  --nirprasa,12.2 nirprasa ER 8399135. Use the amount in order currency for batch mode NO
                  --Converted amount will be used later for batch mode YES or Arrow's case when
                  --offer and order currencies are different.
                  IF l_batch_mode = 'YES' OR l_net_accrual_offers.transaction_currency_code IS NOT NULL THEN
                     l_line_amount := l_new_amount;
                  END IF;
                  ozf_utility_pvt.write_conc_log('l_line_amount converted : '|| l_line_amount);

                  IF l_return_status =  Fnd_Api.g_ret_sts_error
                  THEN
                      ozf_utility_pvt.write_conc_log('Exp Error from Convert_Currency: ' || l_return_status);
                      RAISE Fnd_Api.g_exc_error;
                  ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                  THEN
                      ozf_utility_pvt.write_conc_log('Unexp Error from Convert_Currency: ' || l_return_status);
                      RAISE Fnd_Api.g_exc_unexpected_error;
                  END IF;
                  --
              END IF;

              ------------------------------ Derive Benificiary -----------------------
              IF l_net_accrual_offers.custom_setup_id = 105
              THEN
                  --
                  IF G_DEBUG_LOW THEN
                    ozf_utility_pvt.write_conc_log('Pv_Referral_Comp_Pub.Get_Beneficiary (+)');
                  END IF;
                  pv_referral_comp_pub.get_beneficiary (p_api_version      => 1.0,
                                                  p_init_msg_list    => FND_API.g_true,
                                                  p_commit           => FND_API.g_false,
                                                  p_validation_level => FND_API.g_valid_level_full,
                                                  p_order_header_id  => l_order_line_tbl(i).header_id,
                                                  p_order_line_id    => l_order_line_tbl(i).line_id,
                                                  p_offer_id         => l_net_accrual_offers.offer_id,
                                                  x_beneficiary_id   => l_beneficiary_id,
                                                  x_referral_id      => l_referral_id,
                                                  x_return_status    => l_return_status,
                                                  x_msg_count        => l_msg_count,
                                                  x_msg_data         => l_msg_data);
                  IF G_DEBUG_LOW THEN
                    ozf_utility_pvt.write_conc_log('Pv_Referral_Comp_Pub.Get_Beneficiary (-) With Status: '||l_return_status);
                    ozf_utility_pvt.write_conc_log('l_benificiary_id / l_referral_id: '||l_beneficiary_id || ' / ' || l_referral_id);
                  END IF;

                  IF l_return_status =  Fnd_Api.g_ret_sts_error
                  THEN
                      ozf_utility_pvt.write_conc_log('Exp Error from Get_Beneficiary: ' || l_return_status);
                      RAISE Fnd_Api.g_exc_error;
                  ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                  THEN
                      ozf_utility_pvt.write_conc_log('Unexp Error from Get_Beneficiary: ' || l_return_status);
                      RAISE Fnd_Api.g_exc_unexpected_error;
                  END IF;
                  --

                  IF ( l_beneficiary_id IS NOT NULL )
                  THEN
                     --------------------------- Derive Accrual Amount -------------------------
                     IF G_DEBUG_LOW THEN
                       ozf_utility_pvt.write_conc_log('Get_Pv_Accrual_Amount (+)');
                     END IF;

                     l_line_acc_amount := get_pv_accrual_amount(p_product_id   => l_order_line_tbl(i).inventory_item_id
                                                               ,p_line_amt     => l_line_amount
                                                               ,p_offer_id     => l_net_accrual_offers.offer_id
                                                               ,p_org_id       => l_org_id
                                                               ,p_list_hdr_id  => l_net_accrual_offers.qp_list_header_id
                                                               ,p_referral_id  => l_referral_id
                                                               ,p_order_hdr_id => l_order_line_tbl(i).header_id);
                     IF G_DEBUG_LOW THEN
                       ozf_utility_pvt.write_conc_log('Get_Pv_Accrual_Amount (-) With l_line_acc_amount: '|| l_line_acc_amount);
                     END IF;
                     --
                  ELSE
                     --
                     ozf_utility_pvt.write_conc_log('No Beneficiary derived from PV_Referral_Comp_Pub. Utilization will not be created');
                     --
                  END IF;
                  --
                  l_utilization_type := 'LEAD_ACCRUAL';
                  l_reference_type   := 'LEAD_REFERRAL';
                  --
              ELSE
                  --
                  --------------------------- Derive Accrual Amount -------------------------
                 -- IF G_DEBUG_LOW THEN
                    ozf_utility_pvt.write_conc_log('Get_Accrualed_Amount (+)');
                --  END IF;
                  l_line_acc_amount := get_accrualed_amount(p_product_id => l_order_line_tbl(i).inventory_item_id
                                                          ,p_line_amt   => l_line_amount
                                                          ,p_quantity   => l_order_line_tbl(i).pricing_quantity
                                                          ,p_uom        => l_order_line_tbl(i).pricing_quantity_uom);
                 -- IF G_DEBUG_LOW THEN
                    ozf_utility_pvt.write_conc_log('Get_Accrualed_Amount (-) With l_line_acc_amount: '|| l_line_acc_amount);
                -- END IF;
                  --

                  --
                  l_utilization_type := 'ACCRUAL';
                  l_reference_type   := NULL;
                  l_beneficiary_id   := l_net_accrual_offers.qualifier_id;
                  l_referral_id      := NULL;
                  --
              END IF; -- End custom_setup_id 105

              IF l_batch_mode = 'NO'
              THEN
                  --
                  IF ( l_beneficiary_id IS NULL
                       OR
                       l_beneficiary_id = fnd_api.g_miss_num )
                  THEN
                      --
                      -- Benificiay Id can be NULL only for PV Net Accrual Offers
                      -- If PV decides not to accrue for this customer, it returns NULL
                      --
                      NULL;
                  ELSE
                     --
                     l_act_budgets_rec.act_budget_used_by_id  := l_net_accrual_offers.qp_list_header_id;
                     l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                     l_act_budgets_rec.budget_source_type     := 'OFFR';
                     l_act_budgets_rec.budget_source_id       := l_net_accrual_offers.qp_list_header_id;
                     l_act_budgets_rec.request_amount         := l_line_acc_amount;
                     --nirprasa,12.2 ER 8399135.
                     --l_act_budgets_rec.request_currency     := l_net_accrual_offers.fund_request_curr_code;
                     IF l_net_accrual_offers.transaction_currency_code IS NULL THEN
                        l_act_budgets_rec.request_currency       := l_order_line_tbl(i).transactional_curr_code;
                     ELSE
                        l_act_budgets_rec.request_currency       := l_net_accrual_offers.fund_request_curr_code;
                     END IF;
                     l_act_budgets_rec.request_date           := l_sysdate;--nepanda : fix for bug 8766564
                     l_act_budgets_rec.status_code            := 'APPROVED';
                     l_act_budgets_rec.approved_amount        := l_line_acc_amount;
                     --nirprasa,12.2 ER 8399135.
                     --l_act_budgets_rec.approved_in_currency   := l_net_accrual_offers.fund_request_curr_code;
                     l_act_budgets_rec.approved_in_currency   := l_act_budgets_rec.request_currency;
                     l_act_budgets_rec.approval_date          := l_sysdate;--nepanda : fix for bug 8766564
                     l_act_budgets_rec.approver_id            := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
                     l_act_budgets_rec.justification          := 'NA: ' || TO_CHAR(l_sysdate, 'MM/DD/YYYY');
                     l_act_budgets_rec.transfer_type          := 'UTILIZED';
                     l_act_budgets_rec.requester_id           := l_net_accrual_offers.owner_id;

                     l_act_util_rec.object_type            := 'ORDER';
                     l_act_util_rec.object_id              := l_order_line_tbl(i).header_id;
                     l_act_util_rec.product_level_type     := 'PRODUCT';
                     l_act_util_rec.product_id             := l_order_line_tbl(i).inventory_item_id;
                     l_act_util_rec.cust_account_id        := l_beneficiary_id;
                     l_act_util_rec.utilization_type       := l_utilization_type;
                     l_act_util_rec.adjustment_date        := l_sysdate;--nepanda : fix for bug 8766564
                     l_act_util_rec.gl_date                := l_sysdate;--nepanda : fix for bug 8766564
                     l_act_util_rec.billto_cust_account_id := l_order_line_tbl(i).invoice_to_org_id;
                     l_act_util_rec.reference_type         := l_reference_type;
                     l_act_util_rec.reference_id           := l_referral_id;
                     l_act_util_rec.order_line_id          := l_order_line_tbl(i).line_id;
                     l_act_util_rec.org_id                 := l_order_line_tbl(i).org_id;
                     --nirprasa,12.2 ER 8399135.
                     l_act_util_rec.plan_currency_code             := l_act_budgets_rec.request_currency;
                     l_act_util_rec.fund_request_currency_code     := l_net_accrual_offers.fund_request_curr_code;
                     --nirprasa,12.2

                     -- Bug 3463302. Do not create utilization if amount is zero
                     IF l_act_budgets_rec.request_amount <> 0
                     THEN
                         --
                         ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => l_return_status
                                                                    ,x_msg_count       => l_msg_count
                                                                    ,x_msg_data        => l_msg_data
                                                                    ,p_act_budgets_rec => l_act_budgets_rec
                                                                    ,p_act_util_rec    => l_act_util_rec
                                                                    ,x_act_budget_id   => l_act_budget_id
                                                                    ,x_utilized_amount => l_utilized_amount);
                         --
                         IF G_DEBUG_LOW THEN
                           ozf_utility_pvt.write_conc_log('Req Curr/Req Amt/Util Amt: ' || l_act_budgets_rec.request_currency || '/' || l_act_budgets_rec.request_amount || '/' || l_utilized_amount);
                         END IF;

                         IF l_return_status =  Fnd_Api.g_ret_sts_error
                         THEN
                              ozf_utility_pvt.write_conc_log('Exp Error: Process_Act_Budgets: line_id ( '||l_order_line_tbl(i).line_id
                                                                                                   || ' ) Error: '||l_msg_data);
                              log_exception(l_act_budgets_rec, l_act_util_rec);
                         ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                         THEN
                              ozf_utility_pvt.write_conc_log('UnExp Error: Process_Act_Budgets: line_id ( '||l_order_line_tbl(i).line_id
                                                                                                     || ' ) Error: '||l_msg_data);
                              log_exception(l_act_budgets_rec, l_act_util_rec);
                         END IF;

                         l_utilized_amount := 0;
                         --
                     END IF; -- end amount <> 0

                     l_act_budgets_rec := NULL;
                     l_act_util_rec    := NULL;
                     --
                  END IF; -- End beneficiary is Not Null

                  -- End Batch Mode = NO
              ELSE
                  -- If Batch Mode = YES, accumulate accrual.
                  l_accrual_amount := l_accrual_amount + l_line_acc_amount;
                  --
              END IF; --  End Batch Mode Check
              --
         END IF; -- Customer Qualfied = 'Y'

         -----------------------------------------------------
         END LOOP; -- l_order_line_tbl
         -----------------------------------------------------
         --
         EXIT WHEN c_order_line%NOTFOUND;
         --
     END LOOP; -- Order lines Cursor

     CLOSE c_order_line;

     IF l_batch_mode = 'YES'
     THEN
        --
        IF l_accrual_amount <> 0
        THEN
           --
           l_beneficiary_id   := l_net_accrual_offers.qualifier_id;
           l_utilization_type := 'ACCRUAL';
           l_reference_type   := NULL;
           l_referral_id      := NULL;

           IF l_beneficiary_id IS NULL OR l_beneficiary_id = fnd_api.g_miss_num
           THEN
             -- This condition will never occur.
             -- For PV offers, the Batch Mode is always NO and Beneficiary is always required
             -- for a Net Accrual Offer.
             NULL;
             --
           ELSE
             --
             l_act_budgets_rec.act_budget_used_by_id    := l_net_accrual_offers.qp_list_header_id;
             l_act_budgets_rec.arc_act_budget_used_by   := 'OFFR';
             l_act_budgets_rec.budget_source_type       := 'OFFR';
             l_act_budgets_rec.budget_source_id         := l_net_accrual_offers.qp_list_header_id;
             l_act_budgets_rec.request_amount           := l_accrual_amount;
             l_act_budgets_rec.request_currency         := l_net_accrual_offers.fund_request_curr_code;
             l_act_budgets_rec.request_date             := l_sysdate;--nepanda : fix for bug 8766564
             l_act_budgets_rec.status_code              := 'APPROVED';
             l_act_budgets_rec.approved_amount          := l_accrual_amount;
             l_act_budgets_rec.approved_in_currency     := l_net_accrual_offers.fund_request_curr_code;
             l_act_budgets_rec.approval_date            := l_sysdate;--nepanda : fix for bug 8766564
             l_act_budgets_rec.approver_id              := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
             l_act_budgets_rec.justification            := 'NA: ' || TO_CHAR(l_sysdate, 'MM/DD/YYYY');
             l_act_budgets_rec.transfer_type            := 'UTILIZED';
             l_act_budgets_rec.requester_id             := l_net_accrual_offers.owner_id;

             l_act_util_rec.cust_account_id        := l_beneficiary_id;
             l_act_util_rec.utilization_type       := l_utilization_type;
             l_act_util_rec.adjustment_date        := l_sysdate;--nepanda : fix for bug 8766564
             l_act_util_rec.gl_date                := l_sysdate;--nepanda : fix for bug 8766564
             l_act_util_rec.reference_type         := l_reference_type;
             l_act_util_rec.reference_id           := l_referral_id;
             --nirprasa,12.2 ER 8399135.
             l_act_util_rec.plan_currency_code             := l_net_accrual_offers.fund_request_curr_code;
             l_act_util_rec.fund_request_amount            := l_accrual_amount;
             l_act_util_rec.fund_request_amount_remaining  := l_accrual_amount;
             l_act_util_rec.fund_request_currency_code     := l_net_accrual_offers.fund_request_curr_code;
             --nirprasa,12.2

             ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => l_return_status
                                                        ,x_msg_count       => l_msg_count
                                                        ,x_msg_data        => l_msg_data
                                                        ,p_act_budgets_rec => l_act_budgets_rec
                                                        ,p_act_util_rec    => l_act_util_rec
                                                        ,x_act_budget_id   => l_act_budget_id
                                                        ,x_utilized_amount => l_utilized_amount);

             IF G_DEBUG_LOW THEN
                ozf_utility_pvt.write_conc_log('Req Curr/Req Amt/Util Amt: ' || l_act_budgets_rec.request_currency || '/' || l_act_budgets_rec.request_amount || '/' || l_utilized_amount);
             END IF;

             IF l_return_status =  Fnd_Api.g_ret_sts_error
             THEN
                 ozf_utility_pvt.write_conc_log('Exp Error: Process_Act_Budgets Error: '||l_msg_data );
                 ozf_utility_pvt.write_conc_log('Exp Error: Process_Act_Budgets Error: '|| SQLERRM );
                 log_exception(l_act_budgets_rec, l_act_util_rec);
             ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
             THEN
                 ozf_utility_pvt.write_conc_log('UnExp Error: Process_Act_Budgets Error: '||l_msg_data );
                 log_exception(l_act_budgets_rec, l_act_util_rec);
             END IF;

             l_utilized_amount := 0;
             l_act_budgets_rec := NULL;
             l_act_util_rec    := NULL;
             --
           END IF; -- End check beneficiary id
           --
       END IF; -- end l_accrual_amount <> 0
       --
     END IF; -- end l_batch_mode = 'YES'
     --
   END IF; -- End OM lines

     ozf_utility_pvt.write_conc_log('-- Done Processing Orders -- ');

     --------------- Done Processing Orders ------------------------

    ozf_utility_pvt.write_conc_log('-- Start Processing Deduction Rules -- ');

    FOR l_na_rule_line IN c_na_rule_lines(l_net_accrual_offers.na_rule_header_id)
    LOOP
       --
       l_return_status := FND_API.g_ret_sts_success; -- bug 3655853

       OPEN  c_na_deduction_rule(l_na_rule_line.na_deduction_rule_id);
       FETCH c_na_deduction_rule INTO l_na_deduction_rule;
       CLOSE c_na_deduction_rule;

       ozf_utility_pvt.write_conc_log('Name / Type / Id / Org : '||
                                                             l_na_deduction_rule.name || ' / ' ||
                                                             l_na_deduction_rule.transaction_type_code || ' / ' ||
                                                             l_na_deduction_rule.deduction_identifier_id || ' / ' ||
                                                             l_na_deduction_rule.deduction_identifier_org_id );

       ---------------------------------------------------------------
       IF l_na_deduction_rule.transaction_source_code = 'AR' THEN
       ---------------------------------------------------------------
          --
          l_ar_dedu_amount := 0;
          l_ar_trx_line_tbl.delete;

          l_return_status := FND_API.g_ret_sts_success; -- bug 3655853

          -- Always set Start Date to offer start date for AR transactions because
          -- A transaction "A" can be created on Date1
          -- Net Accrual Engine could have run on Date2.It will not pick "A"
          -- Transaction "A" could have been completed on Date3
          -- Net Accrual Engine is run on Date4. It will still not pick "A" because Date1 is before Date3

          -- So, always pick all the completed transaction during the Offer period.
          -- Check utilizations table if it has been already processed

          l_ar_start_date := l_net_accrual_offers.start_date_active;

          OPEN  c_ar_trx_line_details(l_na_deduction_rule.deduction_identifier_id,
                                      l_ar_start_date,
                                      l_end_date,
                                      l_na_deduction_rule.deduction_identifier_org_id );

          LOOP
             --
             FETCH c_ar_trx_line_details BULK COLLECT INTO l_ar_trx_line_tbl LIMIT l_batch_size;
             --
             -- To handle NO DATA FOUND for c_ar_trx_line CURSOR
             IF  l_ar_trx_line_tbl.FIRST IS NULL
             THEN
                --
                ozf_utility_pvt.write_conc_log('No Data found in c_ar_trx_line_details CURSOR');
                EXIT;
                --
             END IF;
             -- Exit after finishing processing is before END LOOP
             --
             ---------------------------------------------------------
             FOR i IN l_ar_trx_line_tbl.FIRST .. l_ar_trx_line_tbl.LAST
             LOOP
                --
                l_customer_qualified := validate_customer(l_ar_trx_line_tbl(i).bill_to_site_use_id,
                                                          l_ar_trx_line_tbl(i).ship_to_site_use_id,
                                                          l_ar_trx_line_tbl(i).sold_to_customer_id);

                ozf_utility_pvt.write_conc_log('Cust_Trx_Line_Id / Customer Qualifier ? : ' ||
                                                l_ar_trx_line_tbl(i).customer_trx_line_id || '/' ||l_customer_qualified );

                IF l_customer_qualified = 'Y'
                THEN
                   --

                      --
                      IF ( l_ar_trx_line_tbl(i).invoice_currency_code
                           <> l_net_accrual_offers.fund_request_curr_code)
                      THEN
                         --
                         l_new_amount := 0;
                         --Added for bug 7030415
                         --only those records are picked for which the org_id=l_na_deduction_rule.deduction_identifier_org_id
                           OPEN c_get_conversion_type(l_na_deduction_rule.deduction_identifier_org_id);
                           FETCH c_get_conversion_type INTO l_exchange_rate_type;
                           CLOSE c_get_conversion_type;
                         ozf_utility_pvt.convert_currency(
                                                 x_return_status => l_return_status
                                                ,p_from_currency => l_ar_trx_line_tbl(i).invoice_currency_code
                                                ,p_to_currency   => l_net_accrual_offers.fund_request_curr_code
                                                ,p_conv_type     => l_exchange_rate_type
                                                --,p_conv_date     => l_ar_trx_line_tbl(i).conv_date
                                                ,p_conv_date     => sysdate
                                                ,p_from_amount   => l_ar_trx_line_tbl(i).extended_amount
                                                ,x_to_amount     => l_new_amount
                                                ,x_rate          => l_rate);
                         --nirprasa,12.2 ER 8399135. Use the amount in order currency for batch mode NO
                         --Comment out the assignment only. Converted amount will be used
                         --later for batch mode YES
                         --nirprasa,12.2
                         IF l_net_accrual_offers.transaction_currency_code IS NOT NULL
                         OR l_batch_mode = 'YES' THEN
                         l_ar_trx_line_tbl(i).extended_amount := l_new_amount;
                         END IF;

                         IF l_return_status =  Fnd_Api.g_ret_sts_error
                         THEN
                            ozf_utility_pvt.write_conc_log('Convert currency ' || l_return_status);
                            RAISE Fnd_Api.g_exc_error;
                         ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                         THEN
                            ozf_utility_pvt.write_conc_log('Convert currency ' || l_return_status);
                            RAISE Fnd_Api.g_exc_unexpected_error;
                         END IF;
                         --
                      END IF;

                      IF ( l_na_deduction_rule.transaction_type_code = 'CM' )
                      THEN
                          -- Old calculation
                          -- l_sign := -1;
                          -- l_quantity := -1 * NVL(l_ar_trx_line_tbl(i).quantity_credited, -1);

                          -- New Calculation
                          -- Record the Sign of the Credit Memo
                          l_sign     := SIGN(l_ar_trx_line_tbl(i).extended_amount);

                          -- Always send positive value for the quantity, for calculation
                          l_quantity := NVL(ABS(l_ar_trx_line_tbl(i).quantity_credited), 1);
                          --
                      ELSIF ( l_na_deduction_rule.transaction_type_code = 'DM' )
                      THEN
                          --
                          l_sign := 1;
                          l_quantity := l_ar_trx_line_tbl(i).quantity_invoiced;
                          --
                      END IF;

                      IF G_DEBUG_LOW
                      THEN
                         ozf_utility_pvt.write_conc_log('Sign of the Credit Memo : '||l_sign);
                         ozf_utility_pvt.write_conc_log('quantity_credited : '||l_ar_trx_line_tbl(i).quantity_credited );
                      END IF;

                      -- Always send positive values for calculation
                      l_ar_dedu_line_amt := get_accrualed_amount(
                                                   p_product_id => l_ar_trx_line_tbl(i).inventory_item_id
                                                  ,p_line_amt   => l_sign * l_ar_trx_line_tbl(i).extended_amount
                                                  ,p_quantity   => l_quantity
                                                  ,p_uom        => l_ar_trx_line_tbl(i).uom_code);

                      -- Convert the accrual amount back to the actual CM sign
                      l_ar_dedu_line_amt := l_sign * l_ar_dedu_line_amt;


                      -- Check if a utilization has already been created for this transaction
                      -- for this Offer
                      -- If Yes, then
                      --    Check if the existing accrual and current accrual are the same
                      --    If not, post the difference
                      -- If No, Create utilization

                      OPEN c_get_util_amt (l_ar_trx_line_tbl(i).customer_trx_line_id,
                                           l_ar_trx_line_tbl(i).inventory_item_id,
                                           l_net_accrual_offers.qp_list_header_id);
                      FETCH c_get_util_amt INTO l_existing_util_amt;
                      CLOSE c_get_util_amt;

                      -- l_existing_util_amt will return as 0 if no utilziations already exist
                      -- since the cursor c_get_util_amt has a NVL

                      IF G_DEBUG_LOW THEN
                         ozf_utility_pvt.write_conc_log('l_ar_dedu_line_amt  (A) : '||l_ar_dedu_line_amt);
                         ozf_utility_pvt.write_conc_log('l_existing_util_amt (B) : '||l_existing_util_amt);
                         ozf_utility_pvt.write_conc_log('(A) - (B) : '|| (l_ar_dedu_line_amt - l_existing_util_amt));
                      END IF;

                      -- If utilizations do not exist l_existing_util_amt will be 0
                      -- A - B will be = A
                      -- If utilzations do exist for the same customer_trx_line_id
                      -- A - B will be 0 in case of no change. Utilzation will not be created
                      -- OR
                      -- A - B will be the correct utilzation amount

                      l_ar_dedu_line_amt := l_ar_dedu_line_amt - l_existing_util_amt;
                      --nirprasa,12.2 ER 8399135. Moved the condition here since it was restricting the conversion
                      --only for batch mode NO
                      IF l_batch_mode = 'NO' THEN

                      l_act_budgets_rec.act_budget_used_by_id  := l_net_accrual_offers.qp_list_header_id;
                      l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                      l_act_budgets_rec.budget_source_type     := 'OFFR';
                      l_act_budgets_rec.budget_source_id       := l_net_accrual_offers.qp_list_header_id;
                      l_act_budgets_rec.request_amount         := l_ar_dedu_line_amt;
                      --nirprasa,12.2 ER 8399135. l_act_budgets_rec.request_currency       := l_net_accrual_offers.fund_request_curr_code;
                      IF l_net_accrual_offers.transaction_currency_code is NULL THEN
                         l_act_budgets_rec.request_currency       := l_ar_trx_line_tbl(i).invoice_currency_code;
                      ELSE
                         l_act_budgets_rec.request_currency       := l_net_accrual_offers.transaction_currency_code;
                      END IF;
                      l_act_budgets_rec.request_date           := l_sysdate;--nepanda : fix for bug 8766564
                      l_act_budgets_rec.status_code            := 'APPROVED';
                      l_act_budgets_rec.approved_amount        := l_ar_dedu_line_amt;
                      --nirprasa,12.2 ER 8399135.l_act_budgets_rec.approved_in_currency   := l_net_accrual_offers.fund_request_curr_code;
                      l_act_budgets_rec.approved_in_currency   := l_act_budgets_rec.request_currency;
                      l_act_budgets_rec.approval_date          := l_sysdate;--nepanda : fix for bug 8766564
                      l_act_budgets_rec.approver_id            := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
                      l_act_budgets_rec.justification          := 'NA: AR DEDUCTION' || TO_CHAR(l_sysdate, 'MM/DD/YYYY');
                      l_act_budgets_rec.transfer_type          := 'UTILIZED';
                      l_act_budgets_rec.requester_id           := l_net_accrual_offers.owner_id;

                      l_act_util_rec.object_type        := l_na_deduction_rule.transaction_type_code;
                      l_act_util_rec.object_id          := l_ar_trx_line_tbl(i).customer_trx_id;
                      l_act_util_rec.product_level_type := 'PRODUCT';
                      l_act_util_rec.product_id         := l_ar_trx_line_tbl(i).inventory_item_id;
                      l_act_util_rec.cust_account_id    := l_net_accrual_offers.qualifier_id;
                      l_act_util_rec.utilization_type   := 'ACCRUAL';
                      l_act_util_rec.adjustment_date    := l_sysdate;--nepanda : fix for bug 8766564
                      l_act_util_rec.gl_date            := l_sysdate;--nepanda : fix for bug 8766564
                      l_act_util_rec.reference_type     := 'TRX_LINE';
                      l_act_util_rec.reference_id       := l_ar_trx_line_tbl(i).customer_trx_line_id;
                     --nirprasa,12.2 ER 8399135.
                     l_act_util_rec.plan_currency_code             := l_act_budgets_rec.request_currency;
                     l_act_util_rec.fund_request_currency_code     := l_net_accrual_offers.fund_request_curr_code;
                     --nirprasa,12.2

                     -- Bug 3463302. dont create utilization if zero amount
                     IF ( l_act_budgets_rec.request_amount <> 0 )
                     THEN
                         --
                         ozf_fund_adjustment_pvt.process_act_budgets(
                                                          x_return_status   => l_return_status
                                                         ,x_msg_count       => l_msg_count
                                                         ,x_msg_data        => l_msg_data
                                                         ,p_act_budgets_rec => l_act_budgets_rec
                                                         ,p_act_util_rec    => l_act_util_rec
                                                         ,x_act_budget_id   => l_act_budget_id
                                                         ,x_utilized_amount => l_utilized_amount);

                         IF G_DEBUG_LOW THEN
                           ozf_utility_pvt.write_conc_log('Req Curr/Req Amt/Util Amt: ' || l_act_budgets_rec.request_currency || '/' || l_act_budgets_rec.request_amount || '/' || l_utilized_amount);
                         END IF;

                        l_utilized_amount := 0;

                        IF l_return_status =  Fnd_Api.g_ret_sts_error
                        THEN
                           ozf_utility_pvt.write_conc_log('Msg from Budget API: '||l_msg_data);
                           log_exception(l_act_budgets_rec, l_act_util_rec);
                        ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                        THEN
                            ozf_utility_pvt.write_conc_log('Msg from Budget API: '||l_msg_data);
                            log_exception(l_act_budgets_rec, l_act_util_rec);
                        END IF;
                        --
                     END IF; -- End Amount <> 0

                     l_act_budgets_rec := NULL;
                     l_act_util_rec    := NULL;
                     --
                  ELSE
                     --
                     l_ar_dedu_amount := l_ar_dedu_amount + l_ar_dedu_line_amt;
                     --
                  END IF; -- End Batch Mode
                  --
               END IF; -- End Customer Qualified
               --
             END LOOP; -- End l_ar_trx_line_tbl
             ----------------------------------------
             EXIT WHEN c_ar_trx_line_details%NOTFOUND;
             ----------------------------------------
          END LOOP; --  AR Trx Lines Cursor

          CLOSE c_ar_trx_line_details;

          IF l_batch_mode = 'YES'
          THEN
             --
             IF l_ar_dedu_amount <> 0
             THEN
                --
                l_act_budgets_rec.act_budget_used_by_id  := l_net_accrual_offers.qp_list_header_id;
                l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                l_act_budgets_rec.budget_source_type     := 'OFFR';
                l_act_budgets_rec.budget_source_id       := l_net_accrual_offers.qp_list_header_id;
                l_act_budgets_rec.request_amount         := l_ar_dedu_amount;
                l_act_budgets_rec.request_currency       := l_net_accrual_offers.fund_request_curr_code;
                l_act_budgets_rec.request_date           := l_sysdate;--nepanda : fix for bug 8766564
                l_act_budgets_rec.status_code            := 'APPROVED';
                l_act_budgets_rec.approved_amount        := l_ar_dedu_amount;
                l_act_budgets_rec.approved_in_currency   := l_net_accrual_offers.fund_request_curr_code;
                l_act_budgets_rec.approval_date          := l_sysdate;--nepanda : fix for bug 8766564
                l_act_budgets_rec.approver_id            := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
                l_act_budgets_rec.justification          := 'NA: AR DEDUCTION' || TO_CHAR(l_sysdate, 'MM/DD/YYYY');
                l_act_budgets_rec.transfer_type          := 'UTILIZED';
                l_act_budgets_rec.requester_id           := l_net_accrual_offers.owner_id;

                l_act_util_rec.cust_account_id  := l_net_accrual_offers.qualifier_id;
                l_act_util_rec.utilization_type := 'ACCRUAL';
                l_act_util_rec.adjustment_date  := l_sysdate;--nepanda : fix for bug 8766564
                l_act_util_rec.gl_date          := l_sysdate;--nepanda : fix for bug 8766564
                --nirprasa,12.2 ER 8399135.
                l_act_util_rec.plan_currency_code             := l_net_accrual_offers.fund_request_curr_code;
                l_act_util_rec.fund_request_amount            := l_ar_dedu_amount;
                l_act_util_rec.fund_request_amount_remaining  := l_ar_dedu_amount;
                l_act_util_rec.fund_request_currency_code     := l_net_accrual_offers.fund_request_curr_code;
                --nirprasa,12.2

                IF G_DEBUG_LOW THEN
                   ozf_utility_pvt.write_conc_log('Accrual log: AR Deduction BATCH_MODE = Y');
                   ozf_utility_pvt.write_conc_log('Offer PK: '||l_net_accrual_offers.qp_list_header_id);
                   ozf_utility_pvt.write_conc_log('Custom Setup Id: '||l_net_accrual_offers.custom_setup_id);
                   ozf_utility_pvt.write_conc_log('Deduction Curr Code: '||l_net_accrual_offers.fund_request_curr_code);
                   ozf_utility_pvt.write_conc_log('Deduction Amount: '||l_act_budgets_rec.request_amount);
                   ozf_utility_pvt.write_conc_log('Cust Acct Id: '||l_act_util_rec.cust_account_id);
                END IF;

                ozf_fund_adjustment_pvt.process_act_budgets(
                                                        x_return_status   => l_return_status
                                                       ,x_msg_count       => l_msg_count
                                                       ,x_msg_data        => l_msg_data
                                                       ,p_act_budgets_rec => l_act_budgets_rec
                                                       ,p_act_util_rec    => l_act_util_rec
                                                       ,x_act_budget_id   => l_act_budget_id
                                                       ,x_utilized_amount => l_utilized_amount);

                IF G_DEBUG_LOW THEN
                  ozf_utility_pvt.write_conc_log('Req Curr/Req Amt/Util Amt: ' || l_act_budgets_rec.request_currency || '/' || l_act_budgets_rec.request_amount || '/' || l_utilized_amount);
                END IF;

               l_utilized_amount := 0;

               IF l_return_status =  Fnd_Api.g_ret_sts_error
               THEN
                   log_exception(l_act_budgets_rec, l_act_util_rec);
               ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                   log_exception(l_act_budgets_rec, l_act_util_rec);
               END IF;

               l_act_budgets_rec := NULL;
               l_act_util_rec    := NULL;
               --
            END IF; -- end amount <> 0
            --
         END IF; -- end batch mode = Y
         --
         -----------------------------------------------------------------
         ELSIF l_na_deduction_rule.transaction_source_code = 'OM' THEN
         -----------------------------------------------------------------
            --
            l_om_dedu_amount := 0;
            l_return_line_tbl.delete;

            OPEN c_return_line( l_na_deduction_rule.deduction_identifier_id,
                                l_start_date,
                                l_end_date);

            LOOP
               --
               FETCH c_return_line BULK COLLECT INTO l_return_line_tbl LIMIT l_batch_size;
               --
               -- To handle NO DATA FOUND for c_return_line CURSOR
               IF  l_return_line_tbl.FIRST IS NULL
               THEN
                  --
                  ozf_utility_pvt.write_conc_log('No Data found in c_return_line CURSOR');
                  EXIT;
                  --
               END IF;
               --
               ---------------------------------------------------------
               FOR i IN l_return_line_tbl.FIRST .. l_return_line_tbl.LAST
               LOOP
               ---------------------------------------------------------
                  --
                  l_return_status := FND_API.g_ret_sts_success; -- bug 3655853

                  -- Original value is negtive
                  l_return_line_tbl(i).invoiced_quantity := -1 * l_return_line_tbl(i).invoiced_quantity;
                  l_line_amount := l_return_line_tbl(i).invoiced_quantity * l_return_line_tbl(i).unit_selling_price;

                  IF l_net_accrual_offers.custom_setup_id = 105
                  THEN
                     ----- For PV Net Accrual Offers, do not look at denorm -------
                     ----- Get Country code from the Identifying addresss of the Customer
                     OPEN  c_country_code(l_return_line_tbl(i).invoice_to_org_id);
                     FETCH c_country_code INTO l_country_code;
                     CLOSE c_country_code;

                     -- l_terr_countries_tbl  has all the countries eligible for this offer
                     -- This table is populated in the 'Denorm Customers' section for each PV NA Offer
                     l_customer_qualified := 'N';

                     FOR j IN l_terr_countries_tbl.FIRST .. l_terr_countries_tbl.LAST
                     LOOP
                         --
                         IF l_country_code = l_terr_countries_tbl(j)
                         THEN
                              l_customer_qualified := 'Y';
                              EXIT;
                         END IF;
                         --
                     END LOOP;

                     IF l_customer_qualified = 'N' THEN
                       -- sold_to not qualified. try ship_to
                       OPEN  c_country_code(l_return_line_tbl(i).ship_to_org_id);
                       FETCH c_country_code INTO l_country_code;
                       CLOSE c_country_code;

                       FOR j IN l_terr_countries_tbl.FIRST .. l_terr_countries_tbl.LAST
                       LOOP
                         --
                         IF l_country_code = l_terr_countries_tbl(j)
                         THEN
                              l_customer_qualified := 'Y';
                              EXIT;
                         END IF;
                         --
                       END LOOP;
                       --
                     END IF;
                     --
                  ELSE
                     --
                     l_customer_qualified := validate_customer(
                                                    p_invoice_to_org_id => l_return_line_tbl(i).invoice_to_org_id
                                                   ,p_ship_to_org_id    => l_return_line_tbl(i).ship_to_org_id
                                                   ,p_sold_to_org_id    => l_return_line_tbl(i).sold_to_org_id);
                  END IF;

                  l_order_curr_code := l_return_line_tbl(i).transactional_curr_code;

                  IF l_customer_qualified = 'Y'
                  THEN
                     --
                     IF l_net_accrual_offers.fund_request_curr_code <> l_order_curr_code
                     THEN
                        --
                        l_new_amount := 0;

                        --Added for bug 7030415
                        OPEN c_get_conversion_type(l_return_line_tbl(i).org_id);
                        FETCH c_get_conversion_type INTO l_exchange_rate_type;
                        CLOSE c_get_conversion_type;

                        ozf_utility_pvt.convert_currency(
                                               x_return_status => l_return_status
                                              ,p_from_currency => l_order_curr_code
                                              ,p_to_currency   => l_net_accrual_offers.fund_request_curr_code
                                              ,p_conv_type     => l_exchange_rate_type
                                              --,p_conv_date     => l_return_line_tbl(i).conv_date
                                              ,p_conv_date     => sysdate
                                              ,p_from_amount   => l_line_amount
                                              ,x_to_amount     => l_new_amount
                                              ,x_rate          => l_rate);
                        --nirprasa,12.2 ER 8399135.
                        IF l_net_accrual_offers.transaction_currency_code IS NOT NULL
                         OR l_batch_mode = 'YES' THEN
                            l_line_amount := l_new_amount;
                        END IF;

                        IF l_return_status =  Fnd_Api.g_ret_sts_error
                        THEN
                             ozf_utility_pvt.write_conc_log('Convert currency ' || l_return_status);
                             RAISE Fnd_Api.g_exc_error;
                        ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                        THEN
                             ozf_utility_pvt.write_conc_log('Convert currency ' || l_return_status);
                             RAISE Fnd_Api.g_exc_unexpected_error;
                        END IF;
                        --
                     END IF;
                     --
                     l_om_dedu_line_amt := get_accrualed_amount(
                                                       p_product_id => l_return_line_tbl(i).inventory_item_id
                                                      ,p_line_amt   => l_line_amount
                                                      ,p_quantity   => l_return_line_tbl(i).invoiced_quantity
                                                      ,p_uom        => l_return_line_tbl(i).pricing_quantity_uom);

                     -- return needs to be deducted, make it negative
                     l_om_dedu_line_amt := -1 * l_om_dedu_line_amt;

                     IF l_batch_mode = 'NO'
                     THEN
                         --
                         IF l_net_accrual_offers.custom_setup_id = 105
                         THEN
                             --
                              pv_referral_comp_pub.get_beneficiary (p_api_version      => 1.0,
                                                      p_init_msg_list    => FND_API.g_false,
                                                      p_commit           => FND_API.g_false,
                                                      p_validation_level => FND_API.g_valid_level_full,
                                                      p_order_header_id  => l_return_line_tbl(i).header_id,
                                                      p_order_line_id    => l_return_line_tbl(i).line_id,
                                                      p_offer_id         => l_net_accrual_offers.offer_id,
                                                      x_beneficiary_id   => l_beneficiary_id,
                                                      x_referral_id      => l_referral_id,
                                                      x_return_status    => l_return_status,
                                                      x_msg_count        => l_msg_count,
                                                      x_msg_data         => l_msg_data);

                              l_utilization_type := 'LEAD_ACCRUAL';
                              l_reference_type := 'LEAD_REFERRAL';
                             --
                          ELSE
                             --
                             l_beneficiary_id := l_net_accrual_offers.qualifier_id;
                             l_utilization_type := 'ACCRUAL';
                             l_reference_type := NULL;
                             l_referral_id := NULL;
                             --
                          END IF;

                          IF l_beneficiary_id IS NULL OR l_beneficiary_id = fnd_api.g_miss_num THEN
                              NULL;
                          ELSE
                              l_act_budgets_rec.act_budget_used_by_id  := l_net_accrual_offers.qp_list_header_id;
                              l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                              l_act_budgets_rec.budget_source_type     := 'OFFR';
                              l_act_budgets_rec.budget_source_id       := l_net_accrual_offers.qp_list_header_id;
                              l_act_budgets_rec.request_amount         := l_om_dedu_line_amt;
                              --nirprasa,12.2 ER 8399135.  l_act_budgets_rec.request_currency       := l_net_accrual_offers.fund_request_curr_code;
                              IF l_net_accrual_offers.transaction_currency_code IS NULL THEN
                                 l_act_budgets_rec.request_currency       := l_order_curr_code;
                              ELSE
                                 l_act_budgets_rec.request_currency       := l_net_accrual_offers.transaction_currency_code;
                              END IF;
                              l_act_budgets_rec.request_currency       := l_order_curr_code;
                              l_act_budgets_rec.request_date           := l_sysdate;--nepanda : fix for bug 8766564
                              l_act_budgets_rec.status_code            := 'APPROVED';
                              l_act_budgets_rec.approved_amount        := l_om_dedu_line_amt;
                              --nirprasa,12.2 ER 8399135.  l_act_budgets_rec.approved_in_currency   := l_net_accrual_offers.fund_request_curr_code;
                              l_act_budgets_rec.approved_in_currency   := l_act_budgets_rec.request_currency;
                              l_act_budgets_rec.approval_date          := l_sysdate;--nepanda : fix for bug 8766564
                              l_act_budgets_rec.approver_id            := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
                              l_act_budgets_rec.justification          := 'NA: OM Deduction' || TO_CHAR(l_sysdate, 'MON-DD-YYYY');
                              l_act_budgets_rec.transfer_type          := 'UTILIZED';
                              l_act_budgets_rec.requester_id           := l_net_accrual_offers.owner_id;

                              l_act_util_rec.object_type            := 'ORDER';
                              l_act_util_rec.object_id              := l_return_line_tbl(i).header_id;
                              l_act_util_rec.product_level_type     := 'PRODUCT';
                              l_act_util_rec.product_id             := l_return_line_tbl(i).inventory_item_id;
                              l_act_util_rec.cust_account_id        := l_beneficiary_id;
                              l_act_util_rec.utilization_type       := l_utilization_type;
                              l_act_util_rec.adjustment_date        := l_sysdate;--nepanda : fix for bug 8766564
                              l_act_util_rec.gl_date                := l_sysdate;--nepanda : fix for bug 8766564
                              l_act_util_rec.billto_cust_account_id := l_return_line_tbl(i).invoice_to_org_id;
                              l_act_util_rec.reference_type         := l_reference_type;
                              l_act_util_rec.reference_id           := l_referral_id;
                              l_act_util_rec.order_line_id          := l_return_line_tbl(i).line_id;
                              l_act_util_rec.org_id                 := l_return_line_tbl(i).org_id;
                              --nirprasa,12.2 ER 8399135.
                              l_act_util_rec.plan_currency_code             := l_act_budgets_rec.request_currency;
                              l_act_util_rec.fund_request_currency_code     := l_net_accrual_offers.fund_request_curr_code;
                              --nirprasa,12.2

                              IF l_act_budgets_rec.request_amount <> 0
                              THEN
                                   -- bug 3463302. dont create utilization if zero amount
                                   ozf_fund_adjustment_pvt.process_act_budgets(
                                                            x_return_status   => l_return_status
                                                           ,x_msg_count       => l_msg_count
                                                           ,x_msg_data        => l_msg_data
                                                           ,p_act_budgets_rec => l_act_budgets_rec
                                                           ,p_act_util_rec    => l_act_util_rec
                                                           ,x_act_budget_id   => l_act_budget_id
                                                           ,x_utilized_amount => l_utilized_amount);

                                  IF G_DEBUG_LOW THEN
                                    ozf_utility_pvt.write_conc_log('Req Curr/Req Amt/Util Amt: ' || l_act_budgets_rec.request_currency || '/' || l_act_budgets_rec.request_amount || '/' || l_utilized_amount);
                                  END IF;

                                    l_utilized_amount := 0;

                                    IF l_return_status =  Fnd_Api.g_ret_sts_error THEN
                                         ozf_utility_pvt.write_conc_log('Msg from Budget API: '||l_msg_data);
                                         log_exception(l_act_budgets_rec, l_act_util_rec);
                                    ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                                         ozf_utility_pvt.write_conc_log('Msg from Budget API: '||l_msg_data);
                                         log_exception(l_act_budgets_rec, l_act_util_rec);
                                    END IF;
                                    --
                              END IF; -- end amount <> 0

                              l_act_budgets_rec := NULL;
                              l_act_util_rec    := NULL;
                        END IF;
                        --
                     ELSE
                        --
                        l_om_dedu_amount := l_om_dedu_amount + l_om_dedu_line_amt;
                        --
                     END IF; -- end batch mode
                     --
                 END IF; -- end validate customer
                 --
             ---------------------------------------
             END LOOP; -- end return order lines
             ---------------------------------------
             --
             EXIT WHEN c_return_line%NOTFOUND;
             --
         END LOOP; -- Return lines Cursor

         CLOSE c_return_line;

         IF l_batch_mode = 'YES'
         THEN
            --
            IF l_om_dedu_amount <> 0
            THEN
               --
               l_act_budgets_rec.act_budget_used_by_id  := l_net_accrual_offers.qp_list_header_id;
               l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
               l_act_budgets_rec.budget_source_type     := 'OFFR';
               l_act_budgets_rec.budget_source_id       := l_net_accrual_offers.qp_list_header_id;
               l_act_budgets_rec.request_amount         := l_om_dedu_amount;
               l_act_budgets_rec.request_currency       := l_net_accrual_offers.fund_request_curr_code;
               l_act_budgets_rec.request_date           := l_sysdate;--nepanda : fix for bug 8766564
               l_act_budgets_rec.status_code            := 'APPROVED';
               l_act_budgets_rec.approved_amount        := l_om_dedu_amount;
               l_act_budgets_rec.approved_in_currency   := l_net_accrual_offers.fund_request_curr_code;
               l_act_budgets_rec.approval_date          := l_sysdate;--nepanda : fix for bug 8766564
               l_act_budgets_rec.approver_id            := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
               l_act_budgets_rec.justification          := 'NA: ' || TO_CHAR(l_sysdate, 'MON-DD-YYYY');
               l_act_budgets_rec.transfer_type          := 'UTILIZED';
               l_act_budgets_rec.requester_id           := l_net_accrual_offers.owner_id;

               l_act_util_rec.cust_account_id  := l_net_accrual_offers.qualifier_id;
               l_act_util_rec.utilization_type := 'ACCRUAL';
               l_act_util_rec.adjustment_date  := l_sysdate;--nepanda : fix for bug 8766564
               l_act_util_rec.gl_date          := l_sysdate;--nepanda : fix for bug 8766564
               --nirprasa,12.2 ER 8399135.
                l_act_util_rec.plan_currency_code             := l_net_accrual_offers.fund_request_curr_code;
                l_act_util_rec.fund_request_amount            := l_om_dedu_amount;
                l_act_util_rec.fund_request_amount_remaining  := l_om_dedu_amount;
                l_act_util_rec.fund_request_currency_code     := l_net_accrual_offers.fund_request_curr_code;
                --nirprasa,12.2

               ozf_fund_adjustment_pvt.process_act_budgets(
                                                        x_return_status   => l_return_status
                                                       ,x_msg_count       => l_msg_count
                                                       ,x_msg_data        => l_msg_data
                                                       ,p_act_budgets_rec => l_act_budgets_rec
                                                       ,p_act_util_rec    => l_act_util_rec
                                                       ,x_act_budget_id   => l_act_budget_id
                                                       ,x_utilized_amount => l_utilized_amount);

                IF G_DEBUG_LOW THEN
                  ozf_utility_pvt.write_conc_log('Req Curr/Req Amt/Util Amt: ' || l_act_budgets_rec.request_currency || '/' || l_act_budgets_rec.request_amount || '/' || l_utilized_amount);
                END IF;

               l_utilized_amount := 0;

               IF l_return_status =  Fnd_Api.g_ret_sts_error THEN
                   ozf_utility_pvt.write_conc_log('Msg from Budget API: '||l_msg_data);
                   log_exception(l_act_budgets_rec, l_act_util_rec);
               ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                  ozf_utility_pvt.write_conc_log('Msg from Budget API: '||l_msg_data);
                  log_exception(l_act_budgets_rec, l_act_util_rec);
               END IF;

               l_act_budgets_rec := NULL;
               l_act_util_rec    := NULL;
               --
            END IF; -- end l_om_dedu_amount > 0
            --
         END IF; -- end l_batch_mode = 'YES'
         --
      --------------------------------------------------------------
      ELSIF l_na_deduction_rule.transaction_source_code = 'TM' THEN
      --------------------------------------------------------------

         -- Bug 3483348 julou validate market and product eligibility for tm deduction
         l_tm_dedu_amount := 0; -- total of tm deduction

         FOR l_tm_line IN c_tm_lines(l_na_deduction_rule.deduction_identifier_id
                                    ,l_start_date
                                    ,l_end_date
                                    ,l_net_accrual_offers.qp_list_header_id)
         LOOP
            --
            l_return_status := FND_API.g_ret_sts_success; -- bug 3655853

            l_customer_qualified := validate_customer(NULL, NULL, l_tm_line.cust_account_id);

            IF l_customer_qualified = 'Y'
            THEN
               --
               IF l_net_accrual_offers.fund_request_curr_code <> l_tm_line.currency_code
               THEN

                   l_new_amount := 0;
                   --Added for bug 7030415
                   OPEN c_get_conversion_type(l_tm_line.org_id);
                   FETCH c_get_conversion_type INTO l_exchange_rate_type;
                   CLOSE c_get_conversion_type;
                   ozf_utility_pvt.convert_currency(
                                               x_return_status => l_return_status
                                              ,p_from_currency => l_tm_line.currency_code
                                              ,p_to_currency   => l_net_accrual_offers.fund_request_curr_code
                                              ,p_conv_type     => l_exchange_rate_type
                                              --,p_conv_date     => l_tm_line.conv_date
                                              ,p_conv_date     => sysdate
                                              ,p_from_amount   => l_tm_line.line_amount
                                              ,x_to_amount     => l_tm_dedu_line_amt
                                              ,x_rate          => l_rate);
                   --
                   IF l_return_status =  Fnd_Api.g_ret_sts_error
                   THEN
                      --
                      ozf_utility_pvt.write_conc_log('Convert currency ' || l_return_status);
                      RAISE Fnd_Api.g_exc_error;
                      --
                   ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                   THEN
                      --
                      ozf_utility_pvt.write_conc_log('Convert currency ' || l_return_status);
                      RAISE Fnd_Api.g_exc_unexpected_error;
                      --
                   END IF;
                   --
            END IF;

            IF l_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
            ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;

            IF l_tm_dedu_line_amt <> 0
            THEN
               --
               l_tm_dedu_amount := l_tm_dedu_amount + l_tm_dedu_line_amt; -- add up total tm deduction
               --
            END IF;
            --
          END IF; -- end cust acct qualified

       END LOOP;

       IF l_tm_dedu_amount <> 0
       THEN
          --
          l_act_budgets_rec.act_budget_used_by_id  := l_net_accrual_offers.qp_list_header_id;
          l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
          l_act_budgets_rec.budget_source_type     := 'OFFR';
          l_act_budgets_rec.budget_source_id       := l_net_accrual_offers.qp_list_header_id;
          l_act_budgets_rec.request_amount         := -1 * l_tm_dedu_amount;
          l_act_budgets_rec.request_currency       := l_net_accrual_offers.fund_request_curr_code;
          l_act_budgets_rec.request_date           := l_sysdate;--nepanda : fix for bug 8766564
          l_act_budgets_rec.status_code            := 'APPROVED';
          l_act_budgets_rec.approved_amount        := -1 * l_tm_dedu_amount;
          l_act_budgets_rec.approved_in_currency   := l_net_accrual_offers.fund_request_curr_code;
          l_act_budgets_rec.approval_date          := l_sysdate;--nepanda : fix for bug 8766564
          l_act_budgets_rec.approver_id            := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
          l_act_budgets_rec.justification          := 'NA: TM DEDUCTION' || TO_CHAR(l_sysdate, 'MON-DD-YYYY');
          l_act_budgets_rec.transfer_type          := 'UTILIZED';
          l_act_budgets_rec.requester_id           := l_net_accrual_offers.owner_id;

          l_act_util_rec.object_type      := l_na_deduction_rule.transaction_type_code; -- OFFR
          l_act_util_rec.object_id        := l_na_deduction_rule.deduction_identifier_id; -- activity_media_id
          l_act_util_rec.cust_account_id  := l_net_accrual_offers.qualifier_id;
          l_act_util_rec.utilization_type := 'ACCRUAL';
          l_act_util_rec.adjustment_date  := l_sysdate;--nepanda : fix for bug 8766564
          l_act_util_rec.gl_date          := l_sysdate;--nepanda : fix for bug 8766564

          ozf_utility_pvt.write_conc_log('Accrual log: TM Deduction BATCH_MODE = Y');
          ozf_utility_pvt.write_conc_log('Offer PK: '||l_net_accrual_offers.qp_list_header_id);
          ozf_utility_pvt.write_conc_log('Custom Setup Id: '||l_net_accrual_offers.custom_setup_id);
          ozf_utility_pvt.write_conc_log('Deduction Curr Code: '||l_net_accrual_offers.fund_request_curr_code);
          ozf_utility_pvt.write_conc_log('Deduction Amount: '||l_act_budgets_rec.request_amount);
          ozf_utility_pvt.write_conc_log('Cust Acct Id: '||l_act_util_rec.cust_account_id);
          --nirprasa,12.2 ER 8399135.
          l_act_util_rec.plan_currency_code             := l_net_accrual_offers.fund_request_curr_code;
          l_act_util_rec.fund_request_currency_code     := l_net_accrual_offers.fund_request_curr_code;
          l_act_util_rec.fund_request_amount            := -1 * l_tm_dedu_amount;
          l_act_util_rec.fund_request_amount_remaining  := -1 * l_tm_dedu_amount;
          --nirprasa,12.2

          IF l_act_budgets_rec.request_amount <> 0
          THEN -- bug 3463302. dont create utilization if zero amount
          ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => l_return_status
                                                     ,x_msg_count       => l_msg_count
                                                     ,x_msg_data        => l_msg_data
                                                     ,p_act_budgets_rec => l_act_budgets_rec
                                                     ,p_act_util_rec    => l_act_util_rec
                                                     ,x_act_budget_id   => l_act_budget_id
                                                     ,x_utilized_amount => l_utilized_amount);

            IF G_DEBUG_LOW THEN
              ozf_utility_pvt.write_conc_log('Req Curr/Req Amt/Util Amt: ' || l_act_budgets_rec.request_currency || '/' || l_act_budgets_rec.request_amount || '/' || l_utilized_amount);
            END IF;
          l_utilized_amount := 0;
          ozf_utility_pvt.write_conc_log('Msg from Budget API: '||l_msg_data);
          IF l_return_status =  Fnd_Api.g_ret_sts_error THEN
            log_exception(l_act_budgets_rec, l_act_util_rec);
          ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            log_exception(l_act_budgets_rec, l_act_util_rec);
          END IF;
          END IF; -- end amount <> 0

          l_act_budgets_rec := NULL;
          l_act_util_rec    := NULL;
        END IF;
      END IF;
    END LOOP; -- end l_na_rule_line

    ozf_utility_pvt.write_conc_log('-- Done Processing Deduction Rules -- ');
    ozf_utility_pvt.write_conc_log('--------------------------------------');

    IF l_net_accrual_offers.latest_na_completion_date IS NULL OR l_net_accrual_offers.latest_na_completion_date < l_as_of_date THEN
      UPDATE ozf_offers
      SET    latest_na_completion_date = l_as_of_date
      WHERE  offer_id = l_net_accrual_offers.offer_id;
    END IF;

   <<IDSM>>
     --------------- Start Processing IDSM lines ------------------------
   IF l_net_accrual_offers.sales_method_flag IS NULL OR l_net_accrual_offers.sales_method_flag = 'I' THEN
     --
     ozf_utility_pvt.write_conc_log('Start Processing IDSM Lines');
     l_idsm_line_tbl.delete;
     l_accrual_amount := 0;

     OPEN c_idsm_line(l_net_accrual_offers.start_date_active, l_net_accrual_offers.end_date_active, l_offer_org_id, l_net_accrual_offers.resale_line_id_processed);

     LOOP
         --
         FETCH c_idsm_line BULK COLLECT INTO l_idsm_line_tbl LIMIT l_batch_size;
         --
         -- To handle NO DATA FOUND for c_idsm_line CURSOR
            IF  l_idsm_line_tbl.FIRST IS NULL
            THEN
               --
               ozf_utility_pvt.write_conc_log('No Data found in c_idsm_line CURSOR');
               EXIT;
               --
            END IF;
         --
         -- Logic to exit after all the record have been processed
         -- is just before the END LOOP EXIT WHEN c_idsm_line%NOTFOUND;

         ---------------------------------------------------------
         FOR i IN l_idsm_line_tbl.FIRST .. l_idsm_line_tbl.LAST
         LOOP
         ---------------------------------------------------------
         --

         l_return_status := FND_API.g_ret_sts_success;

         l_idsm_line_processed := l_idsm_line_tbl(i).line_id;

         IF G_DEBUG_LOW THEN
            ozf_utility_pvt.write_conc_log('Resale Line_Id: ' || l_idsm_line_tbl(i).line_id);
         END IF;

         l_line_amount := ( NVL(l_idsm_line_tbl(i).shipped_quantity,l_idsm_line_tbl(i).fulfilled_quantity)
                            * l_idsm_line_tbl(i).unit_selling_price );
         --
         ------------- Qualify Customer on the IDSM line ------------------------------
         --

         IF l_net_accrual_offers.custom_setup_id = 105
         THEN
              ----- For PV Net Accrual Offers, do not look at denorm -------
              ----- Get Country code from the Identifying addresss of the Customer
              OPEN  c_country_code(l_idsm_line_tbl(i).invoice_to_org_id);
              FETCH c_country_code INTO l_country_code;
              CLOSE c_country_code;

              -- l_terr_countries_tbl  has all the countries eligible for this offer
              -- This table is populated in the 'Denorm Customers' section for each PV NA Offer
              l_customer_qualified := 'N';

              FOR j IN l_terr_countries_tbl.FIRST .. l_terr_countries_tbl.LAST
              LOOP
                 --
                 IF l_country_code = l_terr_countries_tbl(j)
                 THEN
                     l_customer_qualified := 'Y';
                     EXIT;
                 END IF;
                 --
              END LOOP;

              IF l_customer_qualified = 'N' THEN
                -- sold_to not qualified. try ship_to
                OPEN  c_country_code(l_idsm_line_tbl(i).ship_to_org_id);
                FETCH c_country_code INTO l_country_code;
                CLOSE c_country_code;

                FOR j IN l_terr_countries_tbl.FIRST .. l_terr_countries_tbl.LAST
                LOOP
                   --
                   IF l_country_code = l_terr_countries_tbl(j)
                   THEN
                     l_customer_qualified := 'Y';
                     EXIT;
                   END IF;
                   --
                END LOOP;
                --
              END IF;
              --
          ELSE
              ----- For all other Net Accrual offers, look at denorm -------
              l_customer_qualified := validate_customer(p_invoice_to_org_id => l_idsm_line_tbl(i).invoice_to_org_id
                                                       ,p_ship_to_org_id    => l_idsm_line_tbl(i).ship_to_org_id
                                                       ,p_sold_to_org_id    => l_idsm_line_tbl(i).sold_to_org_id);
              --
          END IF; -- Done qualfiying the customer

          IF G_DEBUG_LOW THEN
            ozf_utility_pvt.write_conc_log('Did Customer qualify: ' || l_customer_qualified);
          END IF;

          -- Fetch Currency Code on the IDSM
          l_order_curr_code := l_idsm_line_tbl(i).transactional_curr_code ;

          IF l_customer_qualified = 'Y'
          THEN
              --
              IF l_net_accrual_offers.fund_request_curr_code <> l_order_curr_code
              THEN
                  --
                  l_new_amount := 0;
                  --Added for bug 7030415
                  OPEN c_get_conversion_type(l_idsm_line_tbl(i).org_id);
                  FETCH c_get_conversion_type INTO l_exchange_rate_type;
                  CLOSE c_get_conversion_type;
                  ozf_utility_pvt.convert_currency(x_return_status => l_return_status
                                          ,p_from_currency => l_order_curr_code
                                          ,p_to_currency   => l_net_accrual_offers.fund_request_curr_code
                                          ,p_conv_type     => l_exchange_rate_type
                                          --,p_conv_date     => l_idsm_line_tbl(i).conv_date
                                          ,p_conv_date     => sysdate
                                          ,p_from_amount   => l_line_amount
                                          ,x_to_amount     => l_new_amount
                                          ,x_rate          => l_rate);
                  --nirprasa,12.2 ER 8399135.
                  IF l_net_accrual_offers.transaction_currency_code IS NOT NULL
                  OR l_batch_mode = 'YES' THEN
                     l_line_amount := l_new_amount;
                  END IF;

                  IF l_return_status =  Fnd_Api.g_ret_sts_error
                  THEN
                      ozf_utility_pvt.write_conc_log('Exp Error from Convert_Currency: ' || l_return_status);
                      RAISE Fnd_Api.g_exc_error;
                  ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                  THEN
                      ozf_utility_pvt.write_conc_log('Unexp Error from Convert_Currency: ' || l_return_status);
                      RAISE Fnd_Api.g_exc_unexpected_error;
                  END IF;
                  --
              END IF;

              ------------------------------ Derive Benificiary -----------------------
              IF l_net_accrual_offers.custom_setup_id = 105
              THEN
                  --
                  IF G_DEBUG_LOW THEN
                    ozf_utility_pvt.write_conc_log('Pv_Referral_Comp_Pub.Get_Beneficiary (+)');
                  END IF;
                  pv_referral_comp_pub.get_beneficiary (p_api_version      => 1.0,
                                                  p_init_msg_list    => FND_API.g_true,
                                                  p_commit           => FND_API.g_false,
                                                  p_validation_level => FND_API.g_valid_level_full,
                                                  p_order_header_id  => l_idsm_line_tbl(i).header_id,
                                                  p_order_line_id    => l_idsm_line_tbl(i).line_id,
                                                  p_offer_id         => l_net_accrual_offers.offer_id,
                                                  x_beneficiary_id   => l_beneficiary_id,
                                                  x_referral_id      => l_referral_id,
                                                  x_return_status    => l_return_status,
                                                  x_msg_count        => l_msg_count,
                                                  x_msg_data         => l_msg_data);
                  IF G_DEBUG_LOW THEN
                    ozf_utility_pvt.write_conc_log('Pv_Referral_Comp_Pub.Get_Beneficiary (-) With Status: ' || l_return_status);
                    ozf_utility_pvt.write_conc_log('l_benificiary_id / l_referral_id: ' || l_beneficiary_id || ' / ' || l_referral_id);
                  END IF;

                  IF l_return_status =  Fnd_Api.g_ret_sts_error
                  THEN
                      ozf_utility_pvt.write_conc_log('Exp Error from Get_Beneficiary: ' || l_return_status);
                      RAISE Fnd_Api.g_exc_error;
                  ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                  THEN
                      ozf_utility_pvt.write_conc_log('Unexp Error from Get_Beneficiary: ' || l_return_status);
                      RAISE Fnd_Api.g_exc_unexpected_error;
                  END IF;
                  --

                  IF ( l_beneficiary_id IS NOT NULL )
                  THEN
                     --------------------------- Derive Accrual Amount -------------------------
                     IF G_DEBUG_LOW THEN
                       ozf_utility_pvt.write_conc_log('Get_Pv_Accrual_Amount (+)');
                     END IF;

                     l_line_acc_amount := get_pv_accrual_amount(p_product_id   => l_idsm_line_tbl(i).inventory_item_id
                                                               ,p_line_amt     => l_line_amount
                                                               ,p_offer_id     => l_net_accrual_offers.offer_id
                                                               ,p_org_id       => l_org_id
                                                               ,p_list_hdr_id  => l_net_accrual_offers.qp_list_header_id
                                                               ,p_referral_id  => l_referral_id
                                                               ,p_order_hdr_id => l_idsm_line_tbl(i).header_id);
                     IF G_DEBUG_LOW THEN
                       ozf_utility_pvt.write_conc_log('Get_Pv_Accrual_Amount (-) With l_line_acc_amount: ' || l_line_acc_amount);
                     END IF;
                     --
                  ELSE
                     --
                     ozf_utility_pvt.write_conc_log('No Beneficiary derived from PV_Referral_Comp_Pub. Utilization will not be created');
                     --
                  END IF;
                  --
                  l_utilization_type := 'LEAD_ACCRUAL';
                  l_reference_type   := 'LEAD_REFERRAL';
                  --
              ELSE
                  --
                  --------------------------- Derive Accrual Amount -------------------------
                  IF G_DEBUG_LOW THEN
                    ozf_utility_pvt.write_conc_log('Get_Accrualed_Amount (+)');
                  END IF;
                  l_line_acc_amount := get_accrualed_amount(p_product_id => l_idsm_line_tbl(i).inventory_item_id
                                                          ,p_line_amt   => l_line_amount
                                                          ,p_quantity   => l_idsm_line_tbl(i).pricing_quantity
                                                          ,p_uom        => l_idsm_line_tbl(i).pricing_quantity_uom);
                  IF G_DEBUG_LOW THEN
                    ozf_utility_pvt.write_conc_log('Get_Accrualed_Amount (-) With l_line_acc_amount: ' || l_line_acc_amount);
                  END IF;
                  --

                  --
                  l_utilization_type := 'ACCRUAL';
                  l_reference_type   := NULL;
                  l_beneficiary_id   := l_net_accrual_offers.qualifier_id;
                  l_referral_id      := NULL;
                  --
              END IF; -- End custom_setup_id 105

              IF l_batch_mode = 'NO'
              THEN
                  --
                  IF ( l_beneficiary_id IS NULL
                       OR
                       l_beneficiary_id = fnd_api.g_miss_num )
                  THEN
                      --
                      -- Benificiay Id can be NULL only for PV Net Accrual Offers
                      -- If PV decides not to accrue for this customer, it returns NULL
                      --
                      NULL;
                  ELSE
                     --
                     l_act_budgets_rec.act_budget_used_by_id  := l_net_accrual_offers.qp_list_header_id;
                     l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                     l_act_budgets_rec.budget_source_type     := 'OFFR';
                     l_act_budgets_rec.budget_source_id       := l_net_accrual_offers.qp_list_header_id;
                     l_act_budgets_rec.request_amount         := l_line_acc_amount;
                     --nirprasa,12.2 ER 8399135. l_act_budgets_rec.request_currency       := l_net_accrual_offers.fund_request_curr_code;
                     IF l_net_accrual_offers.transaction_currency_code IS NULL THEN
                        l_act_budgets_rec.request_currency       := l_idsm_line_tbl(i).transactional_curr_code;
                     ELSE
                        l_act_budgets_rec.request_currency       := l_net_accrual_offers.transaction_currency_code;
                     END IF;
                     l_act_util_rec.plan_currency_code         := l_act_budgets_rec.request_currency;
                     l_act_util_rec.fund_request_currency_code := l_net_accrual_offers.fund_request_curr_code;
                     --nirprasa,12.2 ER 8399135.
                     l_act_budgets_rec.request_date           := l_sysdate;--nepanda : fix for bug 8766564
                     l_act_budgets_rec.status_code            := 'APPROVED';
                     l_act_budgets_rec.approved_amount        := l_line_acc_amount;
                     l_act_budgets_rec.approved_in_currency   := l_net_accrual_offers.fund_request_curr_code;
                     l_act_budgets_rec.approval_date          := l_sysdate;--nepanda : fix for bug 8766564
                     l_act_budgets_rec.approver_id            := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
                     l_act_budgets_rec.justification          := 'NA: ' || TO_CHAR(l_sysdate, 'MM/DD/YYYY');
                     l_act_budgets_rec.transfer_type          := 'UTILIZED';
                     l_act_budgets_rec.requester_id           := l_net_accrual_offers.owner_id;

                     l_act_util_rec.object_type            := 'TP_ORDER';
                     l_act_util_rec.object_id              := l_idsm_line_tbl(i).line_id;
                     l_act_util_rec.product_level_type     := 'PRODUCT';
                     l_act_util_rec.product_id             := l_idsm_line_tbl(i).inventory_item_id;
                     l_act_util_rec.cust_account_id        := l_beneficiary_id;
                     l_act_util_rec.utilization_type       := l_utilization_type;
                     l_act_util_rec.adjustment_date        := l_sysdate;--nepanda : fix for bug 8766564
                     l_act_util_rec.gl_date                := l_sysdate;--nepanda : fix for bug 8766564
                     l_act_util_rec.billto_cust_account_id := l_idsm_line_tbl(i).invoice_to_org_id;
                     l_act_util_rec.reference_type         := l_reference_type;
                     l_act_util_rec.reference_id           := l_referral_id;
                     l_act_util_rec.order_line_id          := l_idsm_line_tbl(i).line_id;
                     l_act_util_rec.org_id                 := l_idsm_line_tbl(i).org_id;

                     -- Bug 3463302. Do not create utilization if amount is zero
                     IF l_act_budgets_rec.request_amount <> 0
                     THEN
                         --
                         ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => l_return_status
                                                                    ,x_msg_count       => l_msg_count
                                                                    ,x_msg_data        => l_msg_data
                                                                    ,p_act_budgets_rec => l_act_budgets_rec
                                                                    ,p_act_util_rec    => l_act_util_rec
                                                                    ,x_act_budget_id   => l_act_budget_id
                                                                    ,x_utilized_amount => l_utilized_amount);
                         --
                         IF G_DEBUG_LOW THEN
                           ozf_utility_pvt.write_conc_log('Req Curr/Req Amt/Util Amt: ' || l_act_budgets_rec.request_currency || '/' || l_act_budgets_rec.request_amount || '/' || l_utilized_amount);
                         END IF;

                         IF l_return_status =  Fnd_Api.g_ret_sts_error
                         THEN
                              ozf_utility_pvt.write_conc_log('Exp Error: Process_Act_Budgets: Resale line_id ( ' || l_idsm_line_tbl(i).line_id
                                                                                                   || ' ) Error: ' || l_msg_data);
                              log_exception(l_act_budgets_rec, l_act_util_rec);
                         ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
                         THEN
                              ozf_utility_pvt.write_conc_log('UnExp Error: Process_Act_Budgets: Resale line_id ( ' || l_idsm_line_tbl(i).line_id
                                                                                                     || ' ) Error: ' || l_msg_data);
                              log_exception(l_act_budgets_rec, l_act_util_rec);
                         END IF;

                         l_utilized_amount := 0;
                         --
                     END IF; -- end amount <> 0

                     l_act_budgets_rec := NULL;
                     l_act_util_rec    := NULL;
                     --
                  END IF; -- End beneficiary is Not Null

                  -- End Batch Mode = NO
              ELSE
                  -- If Batch Mode = YES, accumulate accrual.
                  l_accrual_amount := l_accrual_amount + l_line_acc_amount;
                  --
              END IF; --  End Batch Mode Check
              --
         END IF; -- Customer Qualfied = 'Y'

         -----------------------------------------------------
         END LOOP; -- l_idsm_line_tbl
         -----------------------------------------------------
         --
         EXIT WHEN c_idsm_line%NOTFOUND;
         --
     END LOOP; -- IDSM lines Cursor

     CLOSE c_idsm_line;

     IF l_batch_mode = 'YES'
     THEN
        --
        IF l_accrual_amount <> 0
        THEN
           --
           l_beneficiary_id   := l_net_accrual_offers.qualifier_id;
           l_utilization_type := 'ACCRUAL';
           l_reference_type   := NULL;
           l_referral_id      := NULL;

           IF l_beneficiary_id IS NULL OR l_beneficiary_id = fnd_api.g_miss_num
           THEN
             -- This condition will never occur.
             -- For PV offers, the Batch Mode is always NO and Beneficiary is always required
             -- for a Net Accrual Offer.
             NULL;
             --
           ELSE
             --
             l_act_budgets_rec.act_budget_used_by_id    := l_net_accrual_offers.qp_list_header_id;
             l_act_budgets_rec.arc_act_budget_used_by   := 'OFFR';
             l_act_budgets_rec.budget_source_type       := 'OFFR';
             l_act_budgets_rec.budget_source_id         := l_net_accrual_offers.qp_list_header_id;
             l_act_budgets_rec.request_amount           := l_accrual_amount;
             l_act_budgets_rec.request_currency         := l_net_accrual_offers.fund_request_curr_code;
             l_act_budgets_rec.request_date             := l_sysdate;--nepanda : fix for bug 8766564
             l_act_budgets_rec.status_code              := 'APPROVED';
             l_act_budgets_rec.approved_amount          := l_accrual_amount;
             l_act_budgets_rec.approved_in_currency     := l_net_accrual_offers.fund_request_curr_code;
             l_act_budgets_rec.approval_date            := l_sysdate;--nepanda : fix for bug 8766564
             l_act_budgets_rec.approver_id              := ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id);
             l_act_budgets_rec.justification            := 'NA: ' || TO_CHAR(l_sysdate, 'MM/DD/YYYY');
             l_act_budgets_rec.transfer_type            := 'UTILIZED';
             l_act_budgets_rec.requester_id             := l_net_accrual_offers.owner_id;

             l_act_util_rec.cust_account_id        := l_beneficiary_id;
             l_act_util_rec.utilization_type       := l_utilization_type;
             l_act_util_rec.adjustment_date        := l_sysdate;--nepanda : fix for bug 8766564
             l_act_util_rec.gl_date                := l_sysdate;--nepanda : fix for bug 8766564
             l_act_util_rec.reference_type         := l_reference_type;
             l_act_util_rec.reference_id           := l_referral_id;
             --nirprasa,12.2 ER 8399135.
             l_act_util_rec.plan_currency_code             := l_net_accrual_offers.fund_request_curr_code;
             l_act_util_rec.fund_request_amount            := l_accrual_amount;
             l_act_util_rec.fund_request_amount_remaining  := l_accrual_amount;
             l_act_util_rec.fund_request_currency_code     := l_net_accrual_offers.fund_request_curr_code;
             --nirprasa,12.2

             ozf_fund_adjustment_pvt.process_act_budgets(x_return_status   => l_return_status
                                                        ,x_msg_count       => l_msg_count
                                                        ,x_msg_data        => l_msg_data
                                                        ,p_act_budgets_rec => l_act_budgets_rec
                                                        ,p_act_util_rec    => l_act_util_rec
                                                        ,x_act_budget_id   => l_act_budget_id
                                                        ,x_utilized_amount => l_utilized_amount);

             IF G_DEBUG_LOW THEN
                ozf_utility_pvt.write_conc_log('Req Curr/Req Amt/Util Amt: ' || l_act_budgets_rec.request_currency || '/' || l_act_budgets_rec.request_amount || '/' || l_utilized_amount);
             END IF;

             IF l_return_status =  Fnd_Api.g_ret_sts_error
             THEN
                 ozf_utility_pvt.write_conc_log('Exp Error: Process_Act_Budgets Error: ' || l_msg_data );
                 log_exception(l_act_budgets_rec, l_act_util_rec);
             ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error
             THEN
                 ozf_utility_pvt.write_conc_log('UnExp Error: Process_Act_Budgets Error: ' || l_msg_data );
                 log_exception(l_act_budgets_rec, l_act_util_rec);
             END IF;

             l_utilized_amount := 0;
             l_act_budgets_rec := NULL;
             l_act_util_rec    := NULL;
             --
           END IF; -- End check beneficiary id
           --
       END IF; -- end l_accrual_amount <> 0
       --
     END IF; -- end l_batch_mode = 'YES'

     UPDATE ozf_offers
     SET    resale_line_id_processed = l_idsm_line_processed
     WHERE  offer_id = l_net_accrual_offers.offer_id;
     --
   END IF; -- End IDSM lines

    <<NEXT_OFFER>>

    --bug 7577311
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.ozf_na_customers_temp';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.ozf_na_products_temp';

  END LOOP;

  ozf_utility_pvt.write_conc_log('-- Done --  ' || to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));


  Fnd_Msg_Pub.Count_AND_Get(p_count   => l_msg_count,
                            p_data    => l_msg_data,
                            p_encoded => Fnd_Api.G_FALSE);

  EXCEPTION

    WHEN OZF_Utility_PVT.resource_locked THEN
      OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO net_accrual_engine;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);

      ERRBUF := l_msg_data;
      RETCODE := '2';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO net_accrual_engine;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);

      ERRBUF := l_msg_data;
      RETCODE := '2';

    WHEN OTHERS THEN
      ROLLBACK TO net_accrual_engine;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      --ERRBUF := l_msg_data;
      ERRBUF := SQLERRM;
      RETCODE := '2';

END net_accrual_engine;


/****
 -- Redundate procedure. Remove the call from the accrual engine
****/

PROCEDURE retroactive_offer_adj(
                    p_api_version    IN  NUMBER
                   ,p_init_msg_list  IN  VARCHAR2
                   ,p_commit         IN  VARCHAR2
                   ,x_return_status  OUT NOCOPY VARCHAR2
                   ,x_msg_count      OUT NOCOPY NUMBER
                   ,x_msg_data       OUT NOCOPY VARCHAR2
                   ,p_offer_id       IN  NUMBER
                   ,p_start_date     IN  DATE
                   ,p_end_date       IN  DATE
                   ,x_order_line_tbl OUT NOCOPY order_line_tbl_type)
IS
  --
  CURSOR c_offer_type IS
  SELECT offer_type,
         tier_level,
         qp_list_header_id,
         custom_setup_id
  FROM   ozf_offers
  WHERE  offer_id = p_offer_id;

  CURSOR c_order_line_detail1 IS
  SELECT a.*
  FROM   oe_order_lines_all a
  WHERE  TRUNC(NVL(a.actual_shipment_date,a.fulfillment_date))
             BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date)
  AND    a.flow_status_code IN ('SHIPPED','CLOSED')
  AND    a.cancelled_flag = 'N'
  AND    a.line_category_code <> 'RETURN';

  l_offer_type         VARCHAR2(30);
  l_tier_level         VARCHAR2(30);
  l_country_code       VARCHAR2(60);
  l_qp_list_header_id  NUMBER;
  l_customer_qualified VARCHAR2(1);
  l_product_qualified  VARCHAR2(1);
  l_tbl_index          NUMBER := 1;
  l_api_name           CONSTANT VARCHAR2(30) := 'retroactive_offer_adj';
  l_custom_setup_id    NUMBER;

BEGIN

  SAVEPOINT retroactive_offer_adj;

  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;

  OPEN  c_offer_type;
  FETCH c_offer_type INTO l_offer_type, l_tier_level, l_qp_list_header_id, l_custom_setup_id;
  CLOSE c_offer_type;

    FOR l_order_line_detail1 IN c_order_line_detail1 LOOP
      l_customer_qualified := validate_customer(p_invoice_to_org_id => l_order_line_detail1.invoice_to_org_id
                                               ,p_ship_to_org_id    => l_order_line_detail1.ship_to_org_id
                                               ,p_sold_to_org_id    => l_order_line_detail1.sold_to_org_id
                                               ,p_qp_list_header_id => l_qp_list_header_id);

      l_product_qualified := validate_product(p_inventory_item_id => l_order_line_detail1.inventory_item_id
                                             ,p_qp_list_header_id => l_qp_list_header_id);

      IF l_customer_qualified = 'Y' AND l_product_qualified = 'Y' THEN
        x_order_line_tbl(l_tbl_index).order_header_id := l_order_line_detail1.header_id;
        x_order_line_tbl(l_tbl_index).order_line_id := l_order_line_detail1.line_id;
        l_tbl_index := l_tbl_index + 1;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      ROLLBACK TO retroactive_offer_adj;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO retroactive_offer_adj;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO retroactive_offer_adj;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END retroactive_offer_adj;


PROCEDURE offer_adj_new_product(
   p_api_version    IN  NUMBER
  ,p_init_msg_list  IN  VARCHAR2
  ,p_commit         IN  VARCHAR2
  ,x_return_status  OUT NOCOPY VARCHAR2
  ,x_msg_count      OUT NOCOPY NUMBER
  ,x_msg_data       OUT NOCOPY VARCHAR2
  ,p_offer_id       IN  NUMBER
  ,p_product_id     IN  NUMBER
  ,p_start_date     IN  DATE
  ,p_end_date       IN  DATE
  ,x_order_line_tbl OUT NOCOPY order_line_tbl_type)
IS

  l_header_id_tbl           number_tbl_type;
  l_line_id_tbl             number_tbl_type;
  l_invoice_to_org_id_tbl   number_tbl_type;
  l_ship_to_org_id_tbl      number_tbl_type;
  l_sold_to_org_id_tbl      number_tbl_type;

  CURSOR c_offer_type IS
  SELECT offer_type, tier_level, qp_list_header_id, custom_setup_id
  FROM   ozf_offers
  WHERE  offer_id = p_offer_id;

  CURSOR c_order_line IS
  SELECT a.header_id,
         a.line_id,
         a.invoice_to_org_id,
         a.ship_to_org_id,
         a.sold_to_org_id
  FROM   oe_order_lines_all a
  WHERE  (NVL(a.actual_shipment_date,a.fulfillment_date)) BETWEEN p_start_date AND p_end_date
  -- AND    a.flow_status_code IN ('SHIPPED','CLOSED')
  AND    a.booked_flag = 'Y'
  AND    a.cancelled_flag = 'N'
  AND    a.line_category_code <> 'RETURN'
  AND    a.inventory_item_id = p_product_id;

  l_order_line_tbl  t_order_line_tbl;
  l_batch_size      NUMBER := 1000;

  l_offer_type         VARCHAR2(30);
  l_tier_level         VARCHAR2(30);
  l_qp_list_header_id  NUMBER;
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_customer_qualified VARCHAR2(1);
  l_product_qualified  VARCHAR2(1);
  l_tbl_index          NUMBER := 1;
  l_api_name           CONSTANT VARCHAR2(30) := 'offer_adj_new_product';
  l_custom_setup_id    NUMBER;

BEGIN
  SAVEPOINT offer_adj_new_product;

  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;

  OPEN  c_offer_type;
  FETCH c_offer_type INTO l_offer_type,
                          l_tier_level,
                          l_qp_list_header_id,
                          l_custom_setup_id;
  CLOSE c_offer_type;

  OPEN c_order_line;

  LOOP
     --
     l_header_id_tbl.delete ;
     l_line_id_tbl.delete;
     l_invoice_to_org_id_tbl.delete;
     l_ship_to_org_id_tbl.delete;
     l_sold_to_org_id_tbl.delete;

     FETCH c_order_line BULK COLLECT INTO l_header_id_tbl ,
                                          l_line_id_tbl,
                                          l_invoice_to_org_id_tbl,
                                          l_ship_to_org_id_tbl,
                                          l_sold_to_org_id_tbl
     LIMIT l_batch_size;
     --

     IF l_line_id_tbl.FIRST IS NULL
     THEN
        --
        EXIT;
        --
     END IF;

     FOR i IN l_line_id_tbl.FIRST .. l_line_id_tbl.LAST
     LOOP
        --
         l_customer_qualified := validate_customer(p_invoice_to_org_id => l_invoice_to_org_id_tbl(i)
                                                  ,p_ship_to_org_id    => l_ship_to_org_id_tbl(i)
                                                  ,p_sold_to_org_id    => l_sold_to_org_id_tbl(i)
                                                  ,p_qp_list_header_id => l_qp_list_header_id);

         IF l_customer_qualified = 'Y'
         THEN
            --
            x_order_line_tbl(l_tbl_index).order_header_id := l_header_id_tbl(i);
            x_order_line_tbl(l_tbl_index).order_line_id   := l_line_id_tbl(i);
            l_tbl_index := l_tbl_index + 1;
            --
         END IF;
      END LOOP; -- l_order_line_detail1
      --
      EXIT WHEN c_order_line%NOTFOUND;
      --
  END LOOP;

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      ROLLBACK TO offer_adj_new_product;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO offer_adj_new_product;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      ROLLBACK TO offer_adj_new_product;
      IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );

END offer_adj_new_product;

END ozf_net_accrual_engine_pvt;

/
