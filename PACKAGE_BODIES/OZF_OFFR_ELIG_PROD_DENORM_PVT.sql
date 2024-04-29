--------------------------------------------------------
--  DDL for Package Body OZF_OFFR_ELIG_PROD_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFR_ELIG_PROD_DENORM_PVT" AS
/* $Header: ozfvodeb.pls 120.23.12010000.3 2010/05/26 16:17:13 nirprasa ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='OZF_OFFR_ELIG_PROD_DENORM_PVT';
OZF_DEBUG_LOW CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
--a utl_file.file_type;
--l_out_dir varchar2(100);
--out_dir varchar2(100) := '/sqlcom/crmeco/ozfd1r10/temp';
--l_out_file varchar2(100) := 'debug_denorm.txt';

PROCEDURE write_conc_log
(
        p_text IN VARCHAR2
) IS
BEGIN
     --if OZF_DEBUG_LOW then
        ozf_utility_pvt.write_conc_log(p_text);
     --end if;
     --dbms_output.put_line(p_text);
     --null;
END write_conc_log;

/*
PROCEDURE write_log
(
        p_text IN VARCHAR2
) IS
BEGIN
        utl_file.put(a,p_text );
        utl_file.new_line(a,1);
        utl_file.fflush(a);

END write_log;
*/
---------------------------------------------------------------------
-- FUNCTION
--    get_sql
--
-- PURPOSE
--    Retrieves SQL statment for given context, attribute.
--
-- PARAMETERS
--    p_context: product or qualifier context
--    p_attribute: context attribute
--    p_attr_value: context attribute value
--    p_type: PROD for product; ELIG for eligibity
--
-- NOTES
--   This functions returns SQL statement for the given context, attribute and attribute value.
---------------------------------------------------------------------
FUNCTION get_sql(
  p_context           IN  VARCHAR2,
  p_attribute         IN  VARCHAR2,
  p_attr_value_from   IN  VARCHAR2,
  p_attr_value_to     IN  VARCHAR2,
  p_comparison        IN  VARCHAR2,
  p_type              IN  VARCHAR2,
  p_qualifier_id      IN  NUMBER := NULL,
  p_qualifier_group   IN  NUMBER := NULL
)
RETURN VARCHAR2
IS
  CURSOR c_get_sql IS
  SELECT sql_validation_1,
         sql_validation_2,
         sql_validation_3,
         sql_validation_4,
         sql_validation_5,
         sql_validation_6,
         sql_validation_7,
         sql_validation_8,
         condition_name_column,
         condition_id_column
    FROM ozf_denorm_queries
   WHERE context = p_context
     AND attribute = p_attribute
     AND query_for = p_type
     AND active_flag = 'Y'
     AND LAST_UPDATE_DATE = (
         SELECT MAX(LAST_UPDATE_DATE)
           FROM ozf_denorm_queries
          WHERE context = p_context
            AND attribute = p_attribute
            AND query_for = p_type
            AND active_flag = 'Y');

  l_stmt   VARCHAR2(32000) := NULL;
  l_stmt_1 VARCHAR2(4000) := NULL;
  l_stmt_2 VARCHAR2(4000) := NULL;
  l_stmt_3 VARCHAR2(4000) := NULL;
  l_stmt_4 VARCHAR2(4000) := NULL;
  l_stmt_5 VARCHAR2(4000) := NULL;
  l_stmt_6 VARCHAR2(4000) := NULL;
  l_stmt_7 VARCHAR2(4000) := NULL;
  l_stmt_8 VARCHAR2(4000) := NULL;
  l_cond_name VARCHAR2(40);
  l_cond_id   VARCHAR2(40);
  l_category number := null;
  n_attr_value_from  NUMBER;
  l_start_position NUMBER ;
  l_distinct_position NUMBER;
  l_qualifier_id NUMBER := NULL;
  l_qualifier_group NUMBER := NULL;

BEGIN
--FND_DSQL.init;

  if p_qualifier_id is null then
     l_qualifier_id := -1;
  else
     l_qualifier_id := p_qualifier_id;
  end if;

  if p_qualifier_group is null then
     l_qualifier_group := -1;
  else
     l_qualifier_group := p_qualifier_group;
  end if;

  OPEN c_get_sql;
  FETCH c_get_sql INTO l_stmt_1, l_stmt_2,l_stmt_3, l_stmt_4, l_stmt_5, l_stmt_6, l_stmt_7, l_stmt_8, l_cond_name, l_cond_id;
  CLOSE c_get_sql;
  if p_context = 'ITEM' AND p_attribute = 'PRICING_ATTRIBUTE2' then
     l_category := p_attr_value_from;
  else
     l_category := null;
  end if;
  --ozf_utility_pvt.write_conc_log ('In getSQL : p_attribute is ' || p_attribute);
  --ozf_utility_pvt.write_conc_log ('In getSQL : l_category is ' || l_category);
  -- special case, for item only.
  IF l_stmt_1 is not null then
     IF INSTR(l_stmt_1, '*') > 0 OR INSTR(l_stmt_1, '?') > 0 THEN
        FND_DSQL.add_text('SELECT null items_category, TO_NUMBER(');
        FND_DSQL.add_bind(p_attr_value_from);
        --FND_DSQL.add_text(') product_id FROM DUAL');
        FND_DSQL.add_text(') product_id,''PRICING_ATTRIBUTE1'' product_type FROM DUAL');
     ELSE
          IF p_context = 'ITEM' then
             IF l_category is null then
                --ozf_utility_pvt.write_conc_log ('In getSQL : l_category is null condition ');
                l_stmt_1 := 'select null  items_category, ' || substr(l_stmt_1,7);
             else
                --ozf_utility_pvt.write_conc_log ('In getSQL : l_category is not null and is equal to:' || l_category ||':');
                l_stmt_1 := 'select '|| l_category || ' items_category, ' || substr(l_stmt_1,7);
             end if;
          ELSIF l_qualifier_id is not null then
                l_distinct_position := INSTR(l_stmt_1,' distinct ');
                if l_distinct_position > 0 then
                   l_start_position := l_distinct_position+9;
                else
                   l_start_position := 7;
                end if;
                l_stmt_1 := 'select '||
                       l_qualifier_id ||
                       ' qp_qualifier_id, ' ||
                       l_qualifier_group||
                       ' qp_qualifier_group, ' ||
                       substr(l_stmt_1,l_start_position);
          END IF;
        FND_DSQL.add_text(' '||l_stmt_1);
     END IF;

     FND_DSQL.add_text(l_stmt_2);
     FND_DSQL.add_text(l_stmt_3);
     FND_DSQL.add_text(l_stmt_4);
     FND_DSQL.add_text(l_stmt_5);
     FND_DSQL.add_text(l_stmt_6);
     FND_DSQL.add_text(l_stmt_7);
     FND_DSQL.add_text(l_stmt_8);


     IF l_cond_name IS NOT NULL OR l_cond_id IS NOT NULL THEN
        IF INSTR(UPPER(l_stmt_1),'WHERE') > 0 OR INSTR(UPPER(l_stmt_2),'WHERE') > 0
        OR INSTR(UPPER(l_stmt_3),'WHERE') > 0 OR INSTR(UPPER(l_stmt_4),'WHERE') > 0
        OR INSTR(UPPER(l_stmt_5),'WHERE') > 0 OR INSTR(UPPER(l_stmt_6),'WHERE') > 0
        OR INSTR(UPPER(l_stmt_7),'WHERE') > 0 OR INSTR(UPPER(l_stmt_8),'WHERE') > 0 THEN
           IF p_type = 'PROD' THEN
              FND_DSQL.add_text(' AND ');
              FND_DSQL.add_text(l_cond_id);
              FND_DSQL.add_text(' = ');
              FND_DSQL.add_bind(p_attr_value_from);
           ELSE
              IF p_comparison = 'BETWEEN' THEN
                 FND_DSQL.add_text(' AND ');
                 FND_DSQL.add_text(l_cond_name);
                 FND_DSQL.add_text(' BETWEEN ');
                 FND_DSQL.add_bind(p_attr_value_from);
                 FND_DSQL.add_text(' AND ');
                 FND_DSQL.add_bind(p_attr_value_to);
              ELSIF p_comparison = '=' THEN
                 FND_DSQL.add_text(' AND ');
                 FND_DSQL.add_text(l_cond_id);
                 FND_DSQL.add_text(' = ');
                 FND_DSQL.add_bind(p_attr_value_from);
              ELSIF p_comparison = 'NOT =' THEN
                 FND_DSQL.add_text(' AND ');
                 FND_DSQL.add_text(l_cond_id);
                 FND_DSQL.add_text(' <> ');
                 FND_DSQL.add_bind(p_attr_value_from);
              END IF;
           END IF;
        ELSE -- no WHERE clause, need to add WHERE
          IF p_type = 'PROD' THEN
             FND_DSQL.add_text(' WHERE ');
             FND_DSQL.add_text(l_cond_id);
             FND_DSQL.add_text(' = ');
             FND_DSQL.add_bind(p_attr_value_from);
          ELSE
            IF p_comparison = 'BETWEEN' THEN
               FND_DSQL.add_text(' WHERE ');
               FND_DSQL.add_text(l_cond_name);
               FND_DSQL.add_text(' BETWEEN ');
               FND_DSQL.add_bind(p_attr_value_from);
               FND_DSQL.add_text(' AND ');
               FND_DSQL.add_bind(p_attr_value_to);
            ELSIF p_comparison = '=' THEN
               FND_DSQL.add_text(' WHERE ');
               FND_DSQL.add_text(l_cond_id);
               FND_DSQL.add_text(' = ');
               FND_DSQL.add_bind(p_attr_value_from);
            ELSIF p_comparison = 'NOT =' THEN
               FND_DSQL.add_text(' WHERE ');
               FND_DSQL.add_text(l_cond_id);
               FND_DSQL.add_text(' <> ');
               FND_DSQL.add_bind(p_attr_value_from);
            END IF;
          END IF;
        END IF;
     END IF;
     l_stmt := FND_DSQL.get_text(FALSE);
  else
    l_stmt := NULL;
  end if;

  RETURN l_stmt;

END get_sql;


PROCEDURE insert_excl_prod(
  p_api_version   IN  NUMBER,
  p_init_msg_list IN  VARCHAR2  := FND_API.g_false,
  p_commit        IN  VARCHAR2  := FND_API.g_false,
  p_context       IN  VARCHAR2,
  p_attribute     IN  VARCHAR2,
  p_attr_value    IN  VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_prod_stmt IS
  SELECT sql_validation_1 || sql_validation_2 || sql_validation_3 || sql_validation_4 || sql_validation_5 || sql_validation_6 || sql_validation_7 || sql_validation_8, condition_id_column
    FROM ozf_denorm_queries
   WHERE context = p_context
     AND attribute = p_attribute
     AND query_for = 'PROD'
     AND active_flag = 'Y'
     AND LAST_UPDATE_DATE = (
         SELECT MAX(LAST_UPDATE_DATE)
           FROM ozf_denorm_queries
          WHERE context = p_context
            AND attribute = p_attribute
            AND query_for = 'PROD'
            AND active_flag = 'Y');

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'insert_excl_prod';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_prod_stmt   VARCHAR2(32000) := NULL;
  l_cond_id     VARCHAR2(40);
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

  IF p_attribute = 'PRICING_ATTRIBUTE1' THEN
    INSERT INTO ozf_search_selections_t(attribute_value, attribute_id) VALUES(p_attr_value, p_attribute);
  ELSE
    OPEN  c_prod_stmt;
    FETCH c_prod_stmt INTO l_prod_stmt, l_cond_id;
    CLOSE c_prod_stmt;

    l_prod_stmt := 'INSERT INTO ozf_search_selections_t(attribute_value, attribute_id) ' || l_prod_stmt;

    IF l_cond_id IS NOT NULL THEN
       IF INSTR(UPPER(l_prod_stmt),'WHERE') > 0 THEN
          l_prod_stmt := l_prod_stmt || ' AND ' || l_cond_id || ' = :1 ';
       ELSE -- no WHERE clause, need to add WHERE
          l_prod_stmt := l_prod_stmt || ' WHERE ' || l_cond_id || ' = :1 ';
       END IF;
    END IF;

    EXECUTE IMMEDIATE l_prod_stmt USING p_attr_value;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      write_conc_log('-- insert_excl_prod failed - '|| SQLERRM || ' ' );
      x_return_status := FND_API.g_ret_sts_unexp_error;

      write_conc_log('1:' || SUBSTR(l_prod_stmt, 1, 250));
      write_conc_log('2:' || SUBSTR(l_prod_stmt, 251, 250));
      write_conc_log('3:' || SUBSTR(l_prod_stmt, 501, 250));
      write_conc_log('4:' || SUBSTR(l_prod_stmt, 751, 250));

      FND_MESSAGE.set_name('OZF', 'OZF_OFFER_PRODUCT_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END insert_excl_prod;


---------------------------------------------------------------------
-- FUNCTION
--    get_sql_new
--
-- PURPOSE
--    Retrieves SQL statment for given context, attribute.
--
-- PARAMETERS
--    p_context: product or qualifier context
--    p_attribute: context attribute
--    p_attr_value: context attribute value
--    p_type: PROD for product; ELIG for eligibity
--
-- NOTES
--   This functions returns SQL statement for the given context, attribute and attribute value.
---------------------------------------------------------------------
FUNCTION get_sql_new(
  p_context           IN  VARCHAR2,
  p_attribute         IN  VARCHAR2,
  p_attr_value_from   IN  VARCHAR2,
  p_attr_value_to     IN  VARCHAR2,
  p_comparison        IN  VARCHAR2,
  p_type              IN  VARCHAR2,
  p_qualifier_id      IN  NUMBER,
  p_qualifier_group   IN  NUMBER,
  p_discount_prod_id  IN  NUMBER,
  p_discount_line_id  IN  NUMBER,
  p_apply_discount    IN  VARCHAR2,
  p_include_volume    IN  VARCHAR2
)
RETURN VARCHAR2
IS

  CURSOR c_get_sql IS
  SELECT sql_validation_1,
         sql_validation_2,
         sql_validation_3,
         sql_validation_4,
         sql_validation_5,
         sql_validation_6,
         sql_validation_7,
         sql_validation_8,
         condition_name_column,
         condition_id_column
    FROM ozf_denorm_queries
   WHERE context = p_context
     AND attribute = p_attribute
     AND query_for = p_type
     AND active_flag = 'Y'
     AND LAST_UPDATE_DATE = (
         SELECT MAX(LAST_UPDATE_DATE)
           FROM ozf_denorm_queries
          WHERE context = p_context
            AND attribute = p_attribute
            AND query_for = p_type
            AND active_flag = 'Y');

  l_stmt   VARCHAR2(32000) := NULL;
  l_stmt_1 VARCHAR2(4000) := NULL;
  l_stmt_2 VARCHAR2(4000) := NULL;
  l_stmt_3 VARCHAR2(4000) := NULL;
  l_stmt_4 VARCHAR2(4000) := NULL;
  l_stmt_5 VARCHAR2(4000) := NULL;
  l_stmt_6 VARCHAR2(4000) := NULL;
  l_stmt_7 VARCHAR2(4000) := NULL;
  l_stmt_8 VARCHAR2(4000) := NULL;
  l_cond_name VARCHAR2(40);
  l_cond_id   VARCHAR2(40);
  l_category NUMBER := null;
  n_attr_value_from  NUMBER;


BEGIN
--FND_DSQL.init;

  OPEN c_get_sql;
  FETCH c_get_sql INTO l_stmt_1, l_stmt_2,l_stmt_3, l_stmt_4, l_stmt_5, l_stmt_6, l_stmt_7, l_stmt_8, l_cond_name, l_cond_id;
  CLOSE c_get_sql;
  -- special case, for item only.
  if p_context = 'ITEM' AND p_attribute = 'PRICING_ATTRIBUTE2' then
     l_category := p_attr_value_from;
  else
     l_category := null;
  end if;

  IF l_stmt_1 is not null then

     IF INSTR(l_stmt_1, '*') > 0 OR INSTR(l_stmt_1, '?') > 0 THEN
        FND_DSQL.add_text('SELECT TO_NUMBER(');
        FND_DSQL.add_bind(p_attr_value_from);
        --FND_DSQL.add_text(') product_id FROM DUAL');
        FND_DSQL.add_text(') product_id,''PRICING_ATTRIBUTE1'' product_type FROM DUAL');
     ELSE
        IF p_qualifier_id is not null then
           l_stmt_1 := 'select '||
                       p_qualifier_id ||
                       ' qp_qualifier_id ' ||
                       p_qualifier_group||
                       ' qp_qualifier_group ' ||
                       substr(l_stmt_1,7);
        ELSIF p_discount_line_id is not null then
           l_stmt_1 := 'select '||
                       p_discount_line_id ||
                       ' discount_line_id ' ||
                       p_apply_discount||
                       ' apply_discount ' ||
                       p_include_volume||
                       ' include_volume ' ||
                       l_category || 'items_category' ||
                       substr(l_stmt_1,7);
        END IF;
        FND_DSQL.add_text(' '||l_stmt_1);
     END IF;

     FND_DSQL.add_text(l_stmt_2);
     FND_DSQL.add_text(l_stmt_3);
     FND_DSQL.add_text(l_stmt_4);
     FND_DSQL.add_text(l_stmt_5);
     FND_DSQL.add_text(l_stmt_6);
     FND_DSQL.add_text(l_stmt_7);
     FND_DSQL.add_text(l_stmt_8);

     IF l_cond_name IS NOT NULL OR l_cond_id IS NOT NULL THEN
        IF INSTR(UPPER(l_stmt_1),'WHERE') > 0 OR INSTR(UPPER(l_stmt_2),'WHERE') > 0
        OR INSTR(UPPER(l_stmt_3),'WHERE') > 0 OR INSTR(UPPER(l_stmt_4),'WHERE') > 0
        OR INSTR(UPPER(l_stmt_5),'WHERE') > 0 OR INSTR(UPPER(l_stmt_6),'WHERE') > 0
        OR INSTR(UPPER(l_stmt_7),'WHERE') > 0 OR INSTR(UPPER(l_stmt_8),'WHERE') > 0 THEN
           IF p_type = 'PROD' THEN
              FND_DSQL.add_text(' AND ');
              FND_DSQL.add_text(l_cond_id);
              FND_DSQL.add_text(' = ');
              FND_DSQL.add_bind(p_attr_value_from);
           ELSE
              IF p_comparison = 'BETWEEN' THEN
                 FND_DSQL.add_text(' AND ');
                 FND_DSQL.add_text(l_cond_name);
                 FND_DSQL.add_text(' BETWEEN ');
                 FND_DSQL.add_bind(p_attr_value_from);
                 FND_DSQL.add_text(' AND ');
                 FND_DSQL.add_bind(p_attr_value_to);
              ELSIF p_comparison = '=' THEN
                 FND_DSQL.add_text(' AND ');
                 FND_DSQL.add_text(l_cond_id);
                 FND_DSQL.add_text(' = ');
                 FND_DSQL.add_bind(p_attr_value_from);
              ELSIF p_comparison = 'NOT =' THEN
                 FND_DSQL.add_text(' AND ');
                 FND_DSQL.add_text(l_cond_id);
                 FND_DSQL.add_text(' <> ');
                 FND_DSQL.add_bind(p_attr_value_from);
              END IF;
           END IF;
        ELSE -- no WHERE clause, need to add WHERE
          IF p_type = 'PROD' THEN
             FND_DSQL.add_text(' WHERE ');
             FND_DSQL.add_text(l_cond_id);
             FND_DSQL.add_text(' = ');
             FND_DSQL.add_bind(p_attr_value_from);
          ELSE
            IF p_comparison = 'BETWEEN' THEN
               FND_DSQL.add_text(' WHERE ');
               FND_DSQL.add_text(l_cond_name);
               FND_DSQL.add_text(' BETWEEN ');
               FND_DSQL.add_bind(p_attr_value_from);
               FND_DSQL.add_text(' AND ');
               FND_DSQL.add_bind(p_attr_value_to);
            ELSIF p_comparison = '=' THEN
               FND_DSQL.add_text(' WHERE ');
               FND_DSQL.add_text(l_cond_id);
               FND_DSQL.add_text(' = ');
               FND_DSQL.add_bind(p_attr_value_from);
            ELSIF p_comparison = 'NOT =' THEN
               FND_DSQL.add_text(' WHERE ');
               FND_DSQL.add_text(l_cond_id);
               FND_DSQL.add_text(' <> ');
               FND_DSQL.add_bind(p_attr_value_from);
            END IF;
          END IF;
        END IF;
     END IF;
     l_stmt := FND_DSQL.get_text(FALSE);
  else
    l_stmt := NULL;
  end if;

  RETURN l_stmt;

END get_sql_new;


---------------------------------------------------------------------
-- PROCEDURE
--   refresh_netaccrual_parties
--
-- PURPOSE
--    Refreshes offer and party denorm table ozf_activity_customers.
--
-- PARAMETERS
--    p_list_header_id: qp_list_header_id of the offer
--
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for parties and refresh ozf_activity_customers
---------------------------------------------------------------------
PROCEDURE refresh_netaccrual_parties(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_party_stmt       OUT NOCOPY VARCHAR2,
  p_qnum             IN NUMBER :=NULL
)
IS

  CURSOR c_offer_id IS
  SELECT offer_id
    FROM ozf_offers
   WHERE qp_list_header_id = p_list_header_id;

  CURSOR c_no_groups(l_offer_id NUMBER) IS
  SELECT COUNT(*)
  FROM   ozf_offer_qualifiers
  WHERE  offer_id = l_offer_id
  AND    qualifier_id = nvl(p_qnum,qualifier_id)
  AND    active_flag = 'Y';

  CURSOR c_groups(l_offer_id NUMBER) IS
  SELECT qualifier_id
  FROM   ozf_offer_qualifiers
  WHERE  offer_id = l_offer_id
  AND    qualifier_id = nvl(p_qnum,qualifier_id)
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

  l_api_name      CONSTANT VARCHAR2(30) := 'refresh_netaccrual_parties';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_stmt_temp     VARCHAR2(32000)        := NULL;
  l_no_query_flag VARCHAR2(1)            := 'N';
  l_no_groups     NUMBER;
  l_no_lines      NUMBER;
  l_group_index   NUMBER;
  l_line_index    NUMBER;
  l_offer_id      NUMBER;

BEGIN

  ozf_utility_pvt.write_conc_log(l_full_name ||
                                 ': Start refresh netaccrual parties' ||
                                 '-'||to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));

  x_return_status := FND_API.g_ret_sts_success;

  OPEN  c_offer_id;
  FETCH c_offer_id INTO l_offer_id;
  CLOSE c_offer_id;

  OPEN  c_no_groups(l_offer_id);
  FETCH c_no_groups INTO l_no_groups;
  CLOSE c_no_groups;

  ozf_utility_pvt.write_conc_log('l_elig_exists:'||l_no_groups);
  IF l_no_groups > 0 THEN
    l_group_index := 1;

    FOR i IN c_groups(l_offer_id) LOOP
      l_line_index := 1;
      l_no_lines := 1; -- currently NA qualifier does not support grouping, each group has only 1 line

      FND_DSQL.add_text('(');
      FOR j IN c_qualifiers(i.qualifier_id) LOOP
        l_stmt_temp := NULL;

      l_stmt_temp := get_sql(p_context  => j.qualifier_context,
                                           p_attribute       => j.qualifier_attribute,
                                           p_attr_value_from => j.qualifier_attr_value,
                                           p_attr_value_to   => NULL,--j.qualifier_attr_value_to,
                                           p_comparison      => j.comparison_operator_code,
                                           p_type            => 'ELIG',
                                           p_qualifier_id    => i.qualifier_id,
                                           p_qualifier_group => NULL
                            );

        IF l_stmt_temp IS NULL THEN
           l_no_query_flag := 'Y';
           EXIT;
        ELSE
          IF l_line_index < l_no_lines THEN
            FND_DSQL.add_text(' INTERSECT ');
            l_line_index := l_line_index + 1;
          END IF;
        END IF;
      END LOOP;
      FND_DSQL.add_text(')');

      IF l_group_index < l_no_groups THEN
        FND_DSQL.add_text(' UNION ');
        l_group_index := l_group_index + 1;
      END IF;
    END LOOP;
  ELSE
    FND_DSQL.add_text('(SELECT  -1 qp_qualifier_id, -1 qp_qualifier_group, -1 party_id,-1 cust_account_id, -1 cust_acct_site_id, -1 site_use_id,'' '' site_use_code FROM DUAL)');
  END IF;

  IF p_calling_from_den = 'N' OR l_no_query_flag = 'N' THEN
    x_party_stmt := FND_DSQL.get_text(FALSE);
  ELSE
    x_party_stmt := NULL;
  END IF;
  --ozf_utility_pvt.write_conc_log('1:'||substr(x_party_stmt,945,250));
  --ozf_utility_pvt.write_conc_log('2:'||substr(x_party_stmt,1195,250));
  --ozf_utility_pvt.write_conc_log('3:'||substr(x_party_stmt,1445,250));

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

END refresh_netaccrual_parties;

--------------------------------------------------------------------
-- PROCEDURE
--    refresh_netaccrual_products
--
-- PURPOSE
--    Refreshes offer and product denorm table ozf_activity_products
--    for NETACCRUAL offers.
--
-- PARAMETERS
--    p_list_header_id: qp_list_header_id of the offer
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for product and refresh ozf_activity_products
----------------------------------------------------------------------
PROCEDURE refresh_netaccrual_products(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_product_stmt     OUT NOCOPY VARCHAR2,
  p_lline_id         IN NUMBER := NULL
)
IS

  CURSOR c_products(l_used_by_id NUMBER) IS
  SELECT off_discount_product_id,
         product_id,
         product_level
    FROM ozf_offer_discount_products
   WHERE offer_id = l_used_by_id
     AND off_discount_product_id = nvl(p_lline_id, off_discount_product_id)
     AND excluder_flag = 'N';

  CURSOR c_excluded_products(l_used_by_id NUMBER,l_product_id NUMBER) IS
  SELECT off_discount_product_id,
         product_id,
         product_level
    FROM ozf_offer_discount_products
   WHERE offer_id = l_used_by_id
     AND parent_off_disc_prod_id = l_product_id
     AND excluder_flag = 'Y';

  CURSOR c_no_products(l_used_by_id NUMBER) IS
  SELECT COUNT(*)
    FROM ozf_offer_discount_products
   WHERE offer_id = l_used_by_id
     AND off_discount_product_id = nvl(p_lline_id, off_discount_product_id)
     AND excluder_flag = 'N';

  CURSOR c_no_excl_products(l_used_by_id NUMBER,l_product_id NUMBER) IS
  SELECT COUNT(*)
    FROM ozf_offer_discount_products
   WHERE offer_id = l_used_by_id
     AND parent_off_disc_prod_id = l_product_id
     AND excluder_flag = 'Y';

  CURSOR c_offer_id IS
  SELECT offer_id
    FROM ozf_offers
   WHERE qp_list_header_id = p_list_header_id;

  l_api_version    CONSTANT NUMBER       := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'refresh_netaccrual_products';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_no_query_flag  VARCHAR2(1)           := 'N';
  l_org_id         NUMBER ;
  l_context        VARCHAR2(30);
  l_context_attr   VARCHAR2(30);
  l_prod_attr_val  VARCHAR2(240);

  l_stmt_temp      VARCHAR2(32000) := NULL;
  l_stmt_product1  VARCHAR2(32000) := NULL;
  l_stmt_product2  VARCHAR2(32000) := NULL;
  l_stmt_product   VARCHAR2(32000) := NULL;

  l_no_products    NUMBER;
  l_no_excl_products NUMBER;
  l_prod_index     NUMBER;
  l_excl_index     NUMBER;
  l_offer_id       NUMBER;

BEGIN

  ozf_utility_pvt.write_conc_log(l_full_name || ': start refresh_products_netaccrual');

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
  l_org_id := FND_PROFILE.VALUE('QP_ORGANIZATION_ID');
  l_context := 'ITEM';

  OPEN  c_offer_id;
  FETCH c_offer_id INTO l_offer_id;
  CLOSE c_offer_id;


  OPEN c_no_products(l_offer_id);
  FETCH c_no_products INTO l_no_products;
  CLOSE c_no_products;

  l_prod_index := 1;

  IF l_no_products > 0 THEN
     FOR i IN c_products(l_offer_id)
     LOOP
       IF i.product_level = 'FAMILY' THEN
          OPEN c_no_excl_products(l_offer_id,i.off_discount_product_id);
          FETCH c_no_excl_products INTO l_no_excl_products;
          CLOSE c_no_excl_products;
       END IF;

       l_excl_index := 1;
       l_stmt_temp := null;

       IF i.product_level = 'PRODUCT' THEN
         l_context_attr := 'PRICING_ATTRIBUTE1';
         l_prod_attr_val := i.product_id;
       ELSIF i.product_level = 'FAMILY' THEN
         l_context_attr := 'PRICING_ATTRIBUTE2';
         l_prod_attr_val := i.product_id;
       END IF;

       FND_DSQL.add_text('(');
       l_stmt_temp := get_sql(p_context         => l_context,
                              p_attribute       => l_context_attr,
                              p_attr_value_from => l_prod_attr_val,
                              p_attr_value_to   => NULL,
                              p_comparison      => '=',
                              p_type            => 'PROD'
                             );

       IF l_stmt_temp IS NULL THEN
         l_no_query_flag := 'Y';
       ELSE
         IF l_no_excl_products > 0 THEN
           EXECUTE IMMEDIATE 'TRUNCATE TABLE ozf_search_selections_t';
           FOR j IN c_excluded_products(l_offer_id,i.off_discount_product_id)
           LOOP
              IF j.product_level = 'PRODUCT' THEN
                l_context_attr := 'PRICING_ATTRIBUTE1';
                l_prod_attr_val := j.product_id;
              ELSIF j.product_level = 'FAMILY' THEN
                l_context_attr := 'PRICING_ATTRIBUTE2';
                l_prod_attr_val := j.product_id;
              END IF;

                      insert_excl_prod(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       p_commit        => p_commit,
                                       p_context       => l_context,
                                       p_attribute     => l_context_attr,
                                       p_attr_value    => l_prod_attr_val,
                                       x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data);
           END LOOP;
           FND_DSQL.add_text(' MINUS select attribute_value product_id, attribute_id product_type from ozf_search_selections_t ');
         END IF;
       END IF;

       FND_DSQL.add_text(')');

       IF l_prod_index < l_no_products THEN
           FND_DSQL.add_text(' UNION ');
           l_prod_index := l_prod_index + 1;
       END IF;
     END LOOP;
  ELSE
    l_no_query_flag := 'Y';
  END IF;

  IF p_calling_from_den = 'N' OR l_no_query_flag = 'N' THEN
    x_product_stmt := FND_DSQL.get_text(FALSE);
  ELSE
    x_product_stmt := NULL;
  END IF;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('AMS', 'AMS_OFFER_PRODUCT_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END refresh_netaccrual_products;

--------------------------------------------------------------------
-- PROCEDURE
--    refresh_volume_products
--
-- PURPOSE
--    Refreshes offer and product denorm table ozf_activity_products
--    for NETACCRUAL offers.
--
-- PARAMETERS
--    p_list_header_id: qp_list_header_id of the offer
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for product and refresh ozf_activity_products
----------------------------------------------------------------------
PROCEDURE refresh_volume_products(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_product_stmt     OUT NOCOPY VARCHAR2,
  p_lline_id         IN NUMBER := NULL
)
IS

-- The assumption is that all the product in a discount table(tier) would have the same discount_line_id
-- ie the line belonging to the PBH header line

  CURSOR c_lines(l_offer_id NUMBER) IS
  SELECT offer_discount_line_id
    FROM ozf_offer_discount_lines
   WHERE offer_id = l_offer_id
     AND offer_discount_line_id = NVL(p_lline_id, offer_discount_line_id)
     AND tier_type = 'PBH';

  CURSOR c_no_lines(l_offer_id NUMBER) IS
  SELECT COUNT(*)
    FROM ozf_offer_discount_lines
   WHERE offer_id = l_offer_id
     AND offer_discount_line_id = NVL(p_lline_id, offer_discount_line_id)
     AND tier_type = 'PBH';

  CURSOR c_products(l_offer_id NUMBER,l_offer_discount_line_id NUMBER) IS
  SELECT off_discount_product_id,
         product_context,
         product_attribute,
         product_attr_value,
         offer_discount_line_id
    FROM ozf_offer_discount_products
   WHERE offer_id = l_offer_id
     AND offer_discount_line_id = l_offer_discount_line_id
     AND excluder_flag = 'N';

  CURSOR c_excluded_products(l_offer_id NUMBER,l_offer_discount_line_id NUMBER) IS
  SELECT off_discount_product_id,
         product_context,
         product_attribute,
         product_attr_value,
         offer_discount_line_id
    FROM ozf_offer_discount_products
   WHERE offer_id = l_offer_id
     AND offer_discount_line_id = l_offer_discount_line_id
     AND excluder_flag = 'Y';

  CURSOR c_no_products(l_offer_id NUMBER,l_offer_discount_line_id NUMBER) IS
  SELECT COUNT(*)
    FROM ozf_offer_discount_products
   WHERE offer_id = l_offer_id
     AND offer_discount_line_id = l_offer_discount_line_id
     AND excluder_flag = 'N';

  CURSOR c_no_excl_products(l_offer_id NUMBER,l_offer_discount_line_id NUMBER) IS
  SELECT COUNT(*)
    FROM ozf_offer_discount_products
   WHERE offer_id = l_offer_id
     AND offer_discount_line_id = l_offer_discount_line_id
     AND excluder_flag = 'Y';

  CURSOR c_offer_id(l_list_header_id NUMBER) IS
  SELECT offer_id
    FROM ozf_offers
   WHERE qp_list_header_id = l_list_header_id;


  l_api_version    CONSTANT NUMBER       := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'refresh_volume_products';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_no_query_flag  VARCHAR2(1)           := 'N';
  l_org_id         NUMBER ;
  l_context        VARCHAR2(30);
  l_context_attr   VARCHAR2(30);
  l_prod_attr_val  VARCHAR2(240);

  l_stmt_temp      VARCHAR2(32000) := NULL;
  l_stmt_product1  VARCHAR2(32000) := NULL;
  l_stmt_product2  VARCHAR2(32000) := NULL;
  l_stmt_product   VARCHAR2(32000) := NULL;

  l_no_products    NUMBER;
  l_no_excl_products NUMBER;
  l_prod_index     NUMBER;
  l_excl_index     NUMBER;
  l_no_lines       NUMBER;
  l_line_index     NUMBER;
  l_offer_id       NUMBER;

BEGIN
  ozf_utility_pvt.write_conc_log(l_full_name || ': start refresh_products_volume');

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
  l_org_id := FND_PROFILE.VALUE('QP_ORGANIZATION_ID');
  l_context := 'ITEM';

  OPEN c_offer_id(p_list_header_id);
  FETCH c_offer_id INTO l_offer_id;
  CLOSE c_offer_id;

  OPEN c_no_lines(l_offer_id);
  FETCH c_no_lines INTO l_no_lines;
  CLOSE c_no_lines;

  l_line_index := 1;

  IF l_no_lines > 0 THEN
     FOR i in c_lines(l_offer_id)
     LOOP
         OPEN c_no_products(l_offer_id,i.offer_discount_line_id);
         FETCH c_no_products INTO l_no_products;
         CLOSE c_no_products;
         l_prod_index := 1;

         OPEN c_no_excl_products(l_offer_id,i.offer_discount_line_id);
         FETCH c_no_excl_products INTO l_no_excl_products;
         CLOSE c_no_excl_products;

         FND_DSQL.add_text('(');

         IF l_no_products > 0 THEN
             FOR j in c_products(l_offer_id,i.offer_discount_line_id)
             LOOP
--                IF j.product_context = 'PRICING_ATTRIBUTE2' THEN
--                END IF;

                l_excl_index := 1;
                l_stmt_temp := null;

                l_stmt_temp := get_sql(p_context  => j.product_context,
                              p_attribute       => j.product_attribute,
                              p_attr_value_from => j.product_attr_value,
                              p_attr_value_to   => NULL,
                              p_comparison      => '=',
                              p_type            => 'PROD'
                             );
/*
                l_stmt_temp := get_sql(p_context  => j.context,
                              p_attribute       => j.attribute,
                              p_attr_value_from => j.attribute_value,
                              p_attr_value_to   => NULL,
                              p_comparison      => '=',
                              p_type            => 'PROD',
                              p_qualifier_id    => NULL,
                              p_qualifier_group => NULL,
                              p_discount_line_id => j.offer_discount_line_id,
                              p_apply_discount => j.apply_discount,
                              p_include_volume => j.include_volume
                             );
*/
                IF l_stmt_temp IS NULL THEN
                   l_no_query_flag := 'Y';
                   EXIT;
                END IF;

                IF l_prod_index < l_no_products THEN
                    FND_DSQL.add_text(' UNION ');
                    l_prod_index := l_prod_index + 1;
                END IF;
            END LOOP; -- j loop

            IF l_no_excl_products > 0 THEN
              EXECUTE IMMEDIATE 'TRUNCATE TABLE ozf_search_selections_t';
              FOR k IN c_excluded_products(l_offer_id,i.offer_discount_line_id) LOOP
                insert_excl_prod(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 p_commit        => p_commit,
                                 p_context       => k.product_context,
                                 p_attribute     => k.product_attribute,
                                 p_attr_value    => k.product_attr_value,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data);
              END LOOP; -- k loop
              FND_DSQL.add_text(' MINUS select attribute_value product_id, attribute_id product_type from ozf_search_selections_t ');
            END IF;

            l_no_query_flag := 'N';
         ELSE
            l_no_query_flag := 'Y';
         END IF;

         FND_DSQL.add_text(')');

         IF l_line_index < l_no_lines THEN
            FND_DSQL.add_text(' UNION ');
            l_line_index := l_line_index + 1;
         END IF;

     END LOOP; -- i loop
  ELSE
     l_no_query_flag := 'Y';
  END IF;

  IF p_calling_from_den = 'N' OR l_no_query_flag = 'N' THEN
    x_product_stmt := FND_DSQL.get_text(FALSE);
  ELSE
    x_product_stmt := NULL;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MESSAGE.set_name('AMS', 'AMS_OFFER_PRODUCT_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END refresh_volume_products;

PROCEDURE refresh_lumpsum_parties(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_party_stmt       OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_qualifier_exists IS
  SELECT 'Y'
  FROM   ozf_offers
  WHERE  qualifier_type IS NOT NULL
  AND    qualifier_id IS NOT NULL
  AND    qp_list_header_id = p_list_header_id;

  CURSOR c_qualifiers IS
  SELECT DECODE(qualifier_type, 'BUYER', 'CUSTOMER_GROUP',
                                'CUSTOMER', 'CUSTOMER',
                                'CUSTOMER_BILL_TO', 'CUSTOMER',
                                'SHIP_TO', 'CUSTOMER') qualifier_context,
         DECODE(qualifier_type, 'BUYER', 'QUALIFIER_ATTRIBUTE3',
                                'CUSTOMER', 'QUALIFIER_ATTRIBUTE2',
                                'CUSTOMER_BILL_TO', 'QUALIFIER_ATTRIBUTE14',
                                'SHIP_TO', 'QUALIFIER_ATTRIBUTE11') qualifier_attribute,
         qualifier_id qualifier_attr_value
   FROM  ozf_offers
  WHERE  qp_list_header_id = p_list_header_id;

  l_api_name      CONSTANT VARCHAR2(30) := 'refresh_lumpsum_parties';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_stmt_temp            VARCHAR2(32000)        := NULL;
  l_no_query_flag        VARCHAR2(1)            := 'N';
  l_qualifier_context    VARCHAR2(30);
  l_qualifier_attribute  VARCHAR2(30);
  l_qualifier_attr_value NUMBER;
  l_qualifier_exists     VARCHAR2(1) := NULL;

BEGIN

  ozf_utility_pvt.write_conc_log(l_full_name ||
                                 ': Start refresh lumpsum parties' ||
                                 '-'||to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));

  x_return_status := FND_API.g_ret_sts_success;

  OPEN  c_qualifier_exists;
  FETCH c_qualifier_exists INTO l_qualifier_exists;
  CLOSE c_qualifier_exists;

  IF l_qualifier_exists = 'Y' THEN
    OPEN  c_qualifiers;
    FETCH c_qualifiers INTO l_qualifier_context, l_qualifier_attribute, l_qualifier_attr_value;
    CLOSE c_qualifiers;

    FND_DSQL.add_text('(');
    l_stmt_temp := NULL;
    l_stmt_temp := get_sql(p_context         => l_qualifier_context,
                           p_attribute       => l_qualifier_attribute,
                           p_attr_value_from => l_qualifier_attr_value,
                           p_attr_value_to   => NULL,
                           p_comparison      => '=',
                           p_type            => 'ELIG',
                           p_qualifier_id     => NULL,
                           p_qualifier_group  => NULL);
/*
    l_stmt_temp := get_sql(p_context         => l_qualifier_context,
                           p_attribute       => l_qualifier_attribute,
                           p_attr_value_from => l_qualifier_attr_value,
                           p_attr_value_to   => NULL,
                           p_comparison      => '=',
                           p_type            => 'ELIG',
                           p_qualifier_id     => NULL,
                           p_qualifier_group  => NULL,
                           p_discount_prod_id => NULL,
                           p_discount_line_id => NULL,
                           p_apply_discount   => NULL,
                           p_include_volume   => NULL);
*/
    IF l_stmt_temp IS NULL THEN
      l_no_query_flag := 'Y';
    END IF;

    FND_DSQL.add_text(')');
  ELSE
    FND_DSQL.add_text('(SELECT -1 qp_qualifier_id, -1 qp_qualifier_group, -1 party_id,-1 cust_account_id, -1 cust_acct_site_id, -1 site_use_id,'' '' site_use_code FROM DUAL)');
  END IF;

  IF p_calling_from_den = 'N' OR l_no_query_flag = 'N' THEN
    x_party_stmt := FND_DSQL.get_text(FALSE);
  ELSE
    x_party_stmt := NULL;
  END IF;
  --ozf_utility_pvt.write_conc_log('1:'||substr(x_party_stmt,945,250));
  --ozf_utility_pvt.write_conc_log('2:'||substr(x_party_stmt,1195,250));
  --ozf_utility_pvt.write_conc_log('3:'||substr(x_party_stmt,1445,250));

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

END refresh_lumpsum_parties;

---------------------------------------------------------------------
-- PROCEDURE
--   refresh_volume_parties
--
-- PURPOSE
--    Refreshes offer and party denorm table ozf_activity_customers.
--
-- PARAMETERS
--    p_list_header_id: qp_list_header_id of the offer
--
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for parties and refresh ozf_activity_customers
---------------------------------------------------------------------
PROCEDURE refresh_volume_parties(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_party_stmt       OUT NOCOPY VARCHAR2,
  p_qnum             IN  NUMBER := NULL
)
IS

-- fix for bug no. 6058819
  CURSOR c_no_groups IS
  SELECT COUNT(*)
    FROM qp_qualifiers a,
             ozf_denorm_queries b
   WHERE a.list_header_id = p_list_header_id
     --AND a.active_flag = 'Y'
     AND a.qualifier_grouping_no = NVL(p_qnum, a.qualifier_grouping_no)
     AND a.qualifier_context   = b.context
     AND a.qualifier_attribute = b.attribute
     AND b.query_for           = 'ELIG';


  CURSOR c_groups IS
  SELECT a.qualifier_id,
         a.qualifier_grouping_no
    FROM qp_qualifiers a,
             ozf_denorm_queries b
   WHERE a.list_header_id = p_list_header_id
     --AND a.active_flag = 'Y'
     AND a.qualifier_grouping_no = NVL(p_qnum, a.qualifier_grouping_no)
     AND a.qualifier_context   = b.context
     AND a.qualifier_attribute = b.attribute
     AND b.query_for           = 'ELIG';

  CURSOR c_qualifiers(l_grouping_no NUMBER) IS
  SELECT a.qualifier_context,
         a.qualifier_attribute,
         a.qualifier_attr_value,
         a.comparison_operator_code,
                 a.qualifier_id
    FROM qp_qualifiers a,
             ozf_denorm_queries b
   WHERE a.list_header_id = p_list_header_id
     AND a.qualifier_grouping_no = l_grouping_no
     AND a.qualifier_context = b.context
     AND a.qualifier_attribute = b.attribute
     AND a.qualifier_context <> 'SOLD_BY'
     AND b.query_for = 'ELIG';

  CURSOR c_soldby_qualifiers(l_grouping_no NUMBER) IS
  SELECT a.qualifier_context,
         a.qualifier_attribute,
         a.qualifier_attr_value,
         a.comparison_operator_code,
         a.qualifier_id
    FROM qp_qualifiers a,
             ozf_denorm_queries b
   WHERE a.list_header_id = p_list_header_id
     AND a.qualifier_grouping_no = l_grouping_no
     AND a.qualifier_context = b.context
     AND a.qualifier_attribute = b.attribute
     AND a.qualifier_context = 'SOLD_BY'
     AND a.qualifier_attribute <> 'QUALIFIER_ATTRIBUTE1'
     AND b.query_for = 'ELIG';

  CURSOR c_no_lines(l_grouping_no NUMBER) IS
  SELECT COUNT(*)
  FROM   qp_qualifiers a, ozf_denorm_queries b
  WHERE  a.list_header_id = p_list_header_id
  AND    a.qualifier_context <> 'SOLD_BY'
  AND    a.qualifier_grouping_no = l_grouping_no
  AND    a.qualifier_context = b.context
  AND    a.qualifier_attribute = b.attribute
  AND    b.query_for = 'ELIG';

  CURSOR c_no_soldby_lines(l_grouping_no NUMBER) IS
  SELECT COUNT(*)
  FROM   qp_qualifiers a, ozf_denorm_queries b
  WHERE  a.list_header_id = p_list_header_id
  AND    a.qualifier_context = 'SOLD_BY'
  AND    a.qualifier_grouping_no = l_grouping_no
  AND    a.qualifier_context = b.context
  AND    a.qualifier_attribute = b.attribute
  AND    a.qualifier_attribute <> 'QUALIFIER_ATTRIBUTE1'
  AND    b.query_for = 'ELIG';


  l_api_name      CONSTANT VARCHAR2(30) := 'refresh_volume_parties';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_stmt_temp     VARCHAR2(32000)       := NULL;
  l_no_query_flag VARCHAR2(1)           := 'N';
  l_no_groups     NUMBER;
  l_no_lines      NUMBER;
  l_group_index   NUMBER;
  l_line_index    NUMBER;
  l_offer_id      NUMBER;
  l_qual_line_ct  NUMBER;
  l_direct_indirect_flag VARCHAR2(1) := 'N';
BEGIN

  ozf_utility_pvt.write_conc_log(l_full_name ||
                                 ': Start refresh volume parties' ||
                                 '-'||to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));

  x_return_status := FND_API.g_ret_sts_success;

  OPEN  c_no_groups;
  FETCH c_no_groups INTO l_no_groups;
  CLOSE c_no_groups;

  ozf_utility_pvt.write_conc_log('l_elig_exists:'||l_no_groups);

  IF l_no_groups > 0 THEN
     l_group_index := 1;

     FOR i IN c_groups LOOP
       l_line_index := 1;
       l_no_lines := 1;

       OPEN c_no_lines(i.qualifier_grouping_no);
       FETCH c_no_lines INTO l_no_lines;
       CLOSE c_no_lines;

       l_qual_line_ct := 0;
       FND_DSQL.add_text('(');
       FOR j IN c_qualifiers(i.qualifier_grouping_no) LOOP
         l_stmt_temp := NULL;

         l_stmt_temp := get_sql(p_context          => j.qualifier_context,
                                p_attribute        => j.qualifier_attribute,
                                p_attr_value_from  => j.qualifier_attr_value,
                                p_attr_value_to    => NULL,--j.qualifier_attr_value_to,
                                p_comparison       => j.comparison_operator_code,
                                p_type             => 'ELIG',
                                p_qualifier_id     => i.qualifier_id,
                                p_qualifier_group  => i.qualifier_grouping_no);
         IF l_stmt_temp IS NULL THEN
            l_no_query_flag := 'Y';
            EXIT;
         ELSE
            IF l_line_index < l_no_lines THEN
               FND_DSQL.add_text(' INTERSECT ');
               l_line_index := l_line_index + 1;
            END IF;
         END IF;
         l_qual_line_ct := l_qual_line_ct + 1;
       END LOOP;
       FND_DSQL.add_text(')');

       /*
       IF l_qual_line_ct > 0 THEN
          FND_DSQL.add_text(' UNION');
       END IF;
       */
       l_line_index := 1;
       l_no_lines := 1;

       OPEN c_no_soldby_lines(i.qualifier_grouping_no);
       FETCH c_no_soldby_lines INTO l_no_lines;
       CLOSE c_no_soldby_lines;

       IF l_no_lines > 0 then
          IF l_qual_line_ct > 0 THEN
             FND_DSQL.add_text(' UNION');
          END IF;
          FND_DSQL.add_text('(');

          FOR j IN c_soldby_qualifiers(i.qualifier_grouping_no) LOOP
            l_stmt_temp := NULL;

           /* No need for this check as the conditions can be put in the cursor */
           /*
            IF  l_qual_line_ct = 0 AND
                j.qualifier_context = 'SOLD_BY' AND
                j.qualifier_attribute = 'QUALIFIER_ATTRIBUTE1' THEN
                l_direct_indirect_flag := 'Y';
            END IF;
            */
            IF l_direct_indirect_flag = 'N' THEN
               l_stmt_temp := get_sql(p_context         => j.qualifier_context,
                                   p_attribute       => j.qualifier_attribute,
                                   p_attr_value_from => j.qualifier_attr_value,
                                   p_attr_value_to   => NULL,--j.qualifier_attr_value_to,
                                   p_comparison      => j.comparison_operator_code,
                                   p_type            => 'ELIG',
                                   p_qualifier_id    => i.qualifier_id,
                                   p_qualifier_group => i.qualifier_grouping_no
                                   );
            END IF;

            IF l_stmt_temp IS NULL THEN
               l_no_query_flag := 'Y';
               EXIT;
            ELSE
               IF l_line_index < l_no_lines THEN
                  FND_DSQL.add_text(' INTERSECT');
                  l_line_index := l_line_index + 1;
               END IF;
            END IF;
          END LOOP;
          FND_DSQL.add_text(')');
       END IF;
       IF l_group_index < l_no_groups THEN
          FND_DSQL.add_text(' UNION ');
          l_group_index := l_group_index + 1;
       END IF;
     END LOOP;
  ELSE
     FND_DSQL.add_text('(SELECT  -1 qp_qualifier_id, -1 qp_qualifier_group, -1 party_id,-1 cust_account_id, -1 cust_acct_site_id, -1 site_use_id,'' '' site_use_code FROM DUAL)');
  END IF;

  IF p_calling_from_den = 'N' OR l_no_query_flag = 'N' THEN
     x_party_stmt := FND_DSQL.get_text(FALSE);
  ELSE
     x_party_stmt := NULL;
  END IF;
  --ozf_utility_pvt.write_conc_log('1:'||substr(x_party_stmt,945,250));
  --ozf_utility_pvt.write_conc_log('2:'||substr(x_party_stmt,1195,250));
  --ozf_utility_pvt.write_conc_log('3:'||substr(x_party_stmt,1445,250));

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

END refresh_volume_parties;

---------------------------------------------------------------------
-- PROCEDURE
--   refresh_parties
--
-- PURPOSE
--    Refreshes offer and party denorm table ozf_activity_customers.
--
-- PARAMETERS
--    p_list_header_id: qp_list_header_id of the offer
--
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for parties and refresh ozf_activity_customers
---------------------------------------------------------------------
PROCEDURE refresh_parties(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_party_stmt       OUT NOCOPY VARCHAR2,
  p_qnum             IN  NUMBER := NULL
)
IS


  /* Changing to join with denorm_queries as only those would be denormed */
  CURSOR c_groups IS
  SELECT DISTINCT a.qualifier_grouping_no
    FROM qp_qualifiers a, ozf_denorm_queries b
   WHERE a.list_header_id      = p_list_header_id
     AND a.qualifier_grouping_no = NVL(p_qnum, a.qualifier_grouping_no)
     AND a.list_line_id        = -1
     AND a.qualifier_context   = b.context
     AND a.qualifier_attribute = b.attribute
     AND b.query_for           = 'ELIG';

  CURSOR c_qualifiers(l_grouping_no NUMBER) IS
  SELECT a.qualifier_context,
         a.qualifier_attribute,
         a.qualifier_attr_value,
         a.qualifier_attr_value_to,
         a.comparison_operator_code,
         a.qualifier_id
    FROM qp_qualifiers a,ozf_denorm_queries b
   WHERE a.list_header_id = p_list_header_id
     AND a.qualifier_grouping_no = l_grouping_no
     AND a.list_line_id = -1 -- dont pick up line level qualifier
     AND a.qualifier_context = b.context
     AND a.qualifier_attribute = b.attribute
     AND b.query_for = 'ELIG';

  CURSOR c_offer_type IS
  SELECT offer_type
    FROM ozf_offers
   WHERE qp_list_header_id = p_list_header_id;


  CURSOR c_elig_exists IS
  SELECT 'Y'
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM qp_qualifiers
                  WHERE list_header_id = p_list_header_id
                    AND list_line_id = -1
                    AND (qualifier_context,qualifier_attribute) IN
                        (SELECT DISTINCT context,attribute
                         FROM   ozf_denorm_queries
                         WHERE  query_for = 'ELIG'
                         AND    active_flag = 'Y'));


  CURSOR c_no_groups IS
  SELECT COUNT(DISTINCT a.qualifier_grouping_no)
    FROM qp_qualifiers a, ozf_denorm_queries b
   WHERE a.list_header_id      = p_list_header_id
     AND a.qualifier_grouping_no = NVL(p_qnum,a.qualifier_grouping_no)
     AND a.list_line_id        = -1
     AND a.qualifier_context   = b.context
     AND a.qualifier_attribute = b.attribute
     AND b.query_for           = 'ELIG';


  /* Removed the date restriction */
  CURSOR c_no_lines(l_grouping_no NUMBER) IS
  SELECT COUNT(*)
  FROM   qp_qualifiers a, ozf_denorm_queries b
  WHERE  list_header_id = p_list_header_id
  AND    qualifier_grouping_no = l_grouping_no
  AND    list_line_id = -1
  AND    a.qualifier_context = b.context
  AND    a.qualifier_attribute = b.attribute
  AND    b.query_for = 'ELIG';


  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'refresh_parties';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_denormed      VARCHAR2(1);

  l_stmt_temp     VARCHAR2(32000)        := NULL;
  l_stmt_group    VARCHAR2(32000)        := NULL;
  l_stmt_offer    VARCHAR2(32000)        := NULL;
  l_no_query_flag VARCHAR2(1)            := 'N';
  l_elig_exists   VARCHAR2(1);
  l_no_groups     NUMBER;
  l_no_lines      NUMBER;
  l_group_index   NUMBER;
  l_line_index    NUMBER;
  l_offer_type    VARCHAR2(100);


BEGIN

  ozf_utility_pvt.write_conc_log(l_full_name || ': Start refresh parties' || '-'||to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));
  --write_log(l_full_name || ': Start refresh parties');

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


  OPEN c_offer_type;
  FETCH c_offer_type INTO l_offer_type;
  CLOSE c_offer_type;
  ozf_utility_pvt.write_conc_log(' -- Offer Type : '|| l_offer_type );
  ozf_utility_pvt.write_conc_log(' -- Offer Id   : '|| p_list_header_id );

  IF l_offer_type = 'LUMPSUM' OR l_offer_type = 'SCAN_DATA' THEN
      refresh_lumpsum_parties(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        p_commit           => p_commit,
        p_list_header_id   => p_list_header_id,
        p_calling_from_den => p_calling_from_den,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        x_party_stmt       => x_party_stmt
      );
  ELSIF l_offer_type = 'NET_ACCRUAL'  THEN
      refresh_netaccrual_parties(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        p_commit           => p_commit,
        p_list_header_id   => p_list_header_id,
        p_calling_from_den => p_calling_from_den,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        x_party_stmt       => x_party_stmt,
        p_qnum             => p_qnum
      );
  ELSIF l_offer_type = 'VOLUME_OFFER'  THEN
      refresh_volume_parties(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        p_commit           => p_commit,
        p_list_header_id   => p_list_header_id,
        p_calling_from_den => p_calling_from_den,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        x_party_stmt       => x_party_stmt,
        p_qnum             => p_qnum
      );
  ELSE
     OPEN c_elig_exists;
     FETCH c_elig_exists INTO l_elig_exists;
     CLOSE c_elig_exists;

     IF l_elig_exists = 'Y' THEN

        OPEN c_no_groups;
        FETCH c_no_groups INTO l_no_groups;
        CLOSE c_no_groups;

        l_group_index := 1;

        FOR i IN c_groups
        LOOP
            l_stmt_group := NULL;
            l_line_index := 1;

            OPEN c_no_lines(i.qualifier_grouping_no);
            FETCH c_no_lines INTO l_no_lines;
            CLOSE c_no_lines;

            FND_DSQL.add_text('(');
            FOR j IN c_qualifiers(i.qualifier_grouping_no)
            LOOP
                l_stmt_temp := NULL;
                l_stmt_temp := get_sql(p_context         => j.qualifier_context,
                             p_attribute       => j.qualifier_attribute,
                             p_attr_value_from => j.qualifier_attr_value,
                             p_attr_value_to   => j.qualifier_attr_value_to,
                             p_comparison      => j.comparison_operator_code,
                             p_type            => 'ELIG',
                             p_qualifier_id     => j.qualifier_id,
                             p_qualifier_group  => i.qualifier_grouping_no
                            );

                IF l_stmt_temp IS NULL THEN
                  l_no_query_flag := 'Y';
                  EXIT;
                ELSE
                  IF l_line_index < l_no_lines THEN
                    FND_DSQL.add_text(' INTERSECT ');
                    l_line_index := l_line_index + 1;
                  END IF;
                END IF;
            END LOOP;
            FND_DSQL.add_text(')');
/*
            IF l_group_index < l_no_groups THEN
              FND_DSQL.add_text(' UNION ');
              l_group_index := l_group_index + 1;
            END IF;
*/
        END LOOP;
     ELSE
        FND_DSQL.add_text('(SELECT -1 qp_qualifier_id, -1 qp_qualifier_group, -1 party_id,-1 cust_account_id, -1 cust_acct_site_id, -1 site_use_id,'' '' site_use_code FROM DUAL)');
     END IF;
  END IF;
  IF p_calling_from_den = 'N' OR l_no_query_flag = 'N' THEN
    x_party_stmt := FND_DSQL.get_text(FALSE);
  ELSE
    x_party_stmt := NULL;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      write_conc_log ('-- Others - ' || SQLERRM || ' ' || x_party_stmt);
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('AMS', 'AMS_OFFER_PARTY_STMT_FAILED');
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



--------------------------------------------------------------------
-- PROCEDURE
--    refresh_lumpsum_products
--
-- PURPOSE
--    Refreshes offer and product denorm table ozf_activity_products
--    for LUMPSUM and SCAN_DATA offers.
--
-- PARAMETERS
--    p_list_header_id: qp_list_header_id of the offer
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for product and refresh ozf_activity_products
----------------------------------------------------------------------
PROCEDURE refresh_lumpsum_products(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_product_stmt     OUT NOCOPY VARCHAR2,
  p_lline_id         IN NUMBER := NULL
)
IS

  CURSOR c_products(l_used_by_id NUMBER, l_org_id NUMBER) IS
  SELECT activity_product_id,
         inventory_item_id,
         category_id,
         level_type_code
    FROM ams_act_products
   WHERE act_product_used_by_id = l_used_by_id
     AND activity_product_id = NVL(p_lline_id, activity_product_id)
     AND arc_act_product_used_by = 'OFFR'
     AND excluded_flag = 'N'
     AND organization_id = l_org_id;

  CURSOR c_excluded_products(l_used_by_id NUMBER, l_org_id NUMBER) IS
  SELECT inventory_item_id,
         category_id,
         level_type_code
    FROM ams_act_products
   WHERE act_product_used_by_id = l_used_by_id
     AND arc_act_product_used_by = 'PROD'
     AND excluded_flag = 'Y'
     AND organization_id = l_org_id;

  CURSOR c_no_products(l_used_by_id NUMBER, l_org_id NUMBER) IS
  SELECT COUNT(*)
  FROM   ams_act_products
  WHERE  act_product_used_by_id = l_used_by_id
  AND    activity_product_id = NVL(p_lline_id, activity_product_id)
  AND    arc_act_product_used_by = 'OFFR'
  AND    excluded_flag = 'N'
  AND    organization_id = l_org_id;

  CURSOR c_no_excl_products(l_used_by_id NUMBER, l_org_id NUMBER) IS
  SELECT COUNT(*)
  FROM   ams_act_products
  WHERE  act_product_used_by_id = l_used_by_id
  AND    arc_act_product_used_by = 'PROD'
  AND    excluded_flag = 'Y'
  AND    organization_id = l_org_id;

  l_api_version    CONSTANT NUMBER       := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'refresh_lumpsum_products';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_no_query_flag  VARCHAR2(1)           := 'N';
  l_org_id         NUMBER ;
  l_context        VARCHAR2(30);
  l_context_attr   VARCHAR2(30);
  l_prod_attr_val  VARCHAR2(240);

  l_stmt_temp      VARCHAR2(32000) := NULL;
  l_stmt_product1  VARCHAR2(32000) := NULL;
  l_stmt_product2  VARCHAR2(32000) := NULL;
  l_stmt_product   VARCHAR2(32000) := NULL;

  l_no_products    NUMBER;
  l_no_excl_products NUMBER;
  l_prod_index     NUMBER;
  l_excl_index     NUMBER;

BEGIN

  write_conc_log(l_full_name || ': start refresh_products_lumpsum');

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
  l_org_id := FND_PROFILE.VALUE('QP_ORGANIZATION_ID');
  l_context := 'ITEM';

  OPEN c_no_products(p_list_header_id, l_org_id);
  FETCH c_no_products INTO l_no_products;
  CLOSE c_no_products;

  l_prod_index := 1;

  IF l_no_products > 0 THEN
  FOR i IN c_products(p_list_header_id, l_org_id) LOOP
    OPEN c_no_excl_products(i.activity_product_id, l_org_id);
    FETCH c_no_excl_products INTO l_no_excl_products;
    CLOSE c_no_excl_products;

    l_excl_index := 1;
    l_stmt_temp := null;

    IF i.level_type_code = 'PRODUCT' THEN
      l_context_attr := 'PRICING_ATTRIBUTE1';
      l_prod_attr_val := i.inventory_item_id;
    ELSIF i.level_type_code = 'FAMILY' THEN
      l_context_attr := 'PRICING_ATTRIBUTE2';
      l_prod_attr_val := i.category_id;
    END IF;

    FND_DSQL.add_text('(');
    l_stmt_temp := get_sql(p_context         => l_context,
                           p_attribute       => l_context_attr,
                           p_attr_value_from => l_prod_attr_val,
                           p_attr_value_to   => NULL,
                           p_comparison      => '=',
                           p_type            => 'PROD'
                          );

    IF l_stmt_temp IS NULL THEN
      l_no_query_flag := 'Y';
    ELSE
      IF l_no_excl_products > 0 THEN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ozf_search_selections_t';
        FOR j IN c_excluded_products(i.activity_product_id, l_org_id) LOOP
          IF j.level_type_code = 'PRODUCT' THEN
            l_context_attr := 'PRICING_ATTRIBUTE1';
            l_prod_attr_val := j.inventory_item_id;
          ELSIF j.level_type_code = 'FAMILY' THEN
            l_context_attr := 'PRICING_ATTRIBUTE2';
            l_prod_attr_val := j.category_id;
          END IF;

          insert_excl_prod(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           p_commit        => p_commit,
                           p_context       => l_context,
                           p_attribute     => l_context_attr,
                           p_attr_value    => l_prod_attr_val,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);
        END LOOP;
        FND_DSQL.add_text(' MINUS select attribute_value product_id, attribute_id product_type from ozf_search_selections_t ');
      END IF;
    END IF;

    FND_DSQL.add_text(')');

    IF l_prod_index < l_no_products THEN
      FND_DSQL.add_text(' UNION ');
      l_prod_index := l_prod_index + 1;
    END IF;
  END LOOP;
  ELSE
    l_no_query_flag := 'Y';
  END IF;

  IF p_calling_from_den = 'N' OR l_no_query_flag = 'N' THEN
    x_product_stmt := FND_DSQL.get_text(FALSE);
  ELSE
    x_product_stmt := NULL;
  END IF;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('AMS', 'AMS_OFFER_PRODUCT_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END refresh_lumpsum_products;

--------------------------------------------------------------------
-- PROCEDURE
--    refresh_products
--
-- PURPOSE
--    Refreshes offer and product denorm table ozf_activity_products.
--
-- PARAMETERS
--    p_list_header_id: qp_list_header_id of the offer
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for product and refresh ozf_activity_products
----------------------------------------------------------------------
PROCEDURE refresh_products(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_product_stmt     OUT NOCOPY VARCHAR2,
  p_lline_id         IN NUMBER := NULL
)
IS

  CURSOR c_list_lines IS
  SELECT DISTINCT list_line_id
    FROM qp_modifier_summary_v
   WHERE list_header_id = p_list_header_id
   AND list_line_id = NVL(p_lline_id , list_line_id)
   AND   (end_date_active IS NULL
      OR end_date_active >= SYSDATE);

  CURSOR c_products(l_list_line_id NUMBER, l_excluder_flag VARCHAR2) IS
  SELECT product_attribute_context,
         product_attribute,
         product_attr_value
    FROM qp_pricing_attributes
   WHERE list_header_id = p_list_header_id
     AND list_line_id = l_list_line_id
     AND excluder_flag = l_excluder_flag;


  CURSOR c_offer_type IS
  SELECT offer_type
    FROM ozf_offers
   WHERE qp_list_header_id = p_list_header_id;

  CURSOR c_na_offer_type IS
  SELECT offer_type
    FROM ozf_offers
   WHERE offer_id = p_list_header_id;

  CURSOR c_no_products IS
  SELECT COUNT(DISTINCT list_line_id)
  FROM   qp_modifier_summary_v
  WHERE  list_header_id = p_list_header_id
    and list_line_id = nvl(p_lline_id, list_line_id)
  AND   (end_date_active IS NULL
      OR end_date_active >= SYSDATE);

  CURSOR c_no_excl_products(l_list_line_id NUMBER) IS
  SELECT COUNT(*)
  FROM   qp_pricing_attributes
  WHERE  list_header_id = p_list_header_id
  AND    list_line_id = l_list_line_id
  AND    excluder_flag = 'Y';

  l_api_version      CONSTANT NUMBER       := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'refresh_products';
  l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_no_query_flag             VARCHAR2(1)  := 'N';
  l_offer_type                VARCHAR2(30);
  l_product_attribute_context VARCHAR2(30);
  l_product_attribute         VARCHAR2(30);
  l_product_attr_value        VARCHAR2(240);

  l_stmt_temp                 VARCHAR2(32000) := NULL;
  l_stmt_product1             VARCHAR2(32000) := NULL;
  l_stmt_product2             VARCHAR2(32000) := NULL;
  l_stmt_product              VARCHAR2(32000) := NULL;

  l_no_products               NUMBER;
  l_no_excl_products          NUMBER;
  l_prod_index                NUMBER;
  l_excl_index                NUMBER;

BEGIN

  ozf_utility_pvt.write_conc_log(l_full_name || ': Start refresh products' || '-'||to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));
  --write_log(l_full_name || ': Start refresh products');

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

  OPEN c_offer_type;
  FETCH c_offer_type INTO l_offer_type;
  CLOSE c_offer_type;

  ozf_utility_pvt.write_conc_log(' -- Offer Type : '|| l_offer_type );
  ozf_utility_pvt.write_conc_log(' -- Offer Id   : '|| p_list_header_id );

  IF l_offer_type = 'LUMPSUM' OR l_offer_type = 'SCAN_DATA'  THEN
      refresh_lumpsum_products(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        p_commit           => p_commit,
        p_list_header_id   => p_list_header_id,
        p_calling_from_den => p_calling_from_den,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        x_product_stmt     => x_product_stmt,
        p_lline_id         => p_lline_id
      );
  ELSIF l_offer_type = 'NET_ACCRUAL'  THEN
      refresh_netaccrual_products(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        p_commit           => p_commit,
        p_list_header_id   => p_list_header_id,
        p_calling_from_den => p_calling_from_den,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        x_product_stmt     => x_product_stmt,
        p_lline_id         => p_lline_id
      );
  ELSIF l_offer_type = 'VOLUME_OFFER'  THEN
      refresh_volume_products(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        p_commit           => p_commit,
        p_list_header_id   => p_list_header_id,
        p_calling_from_den => p_calling_from_den,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        x_product_stmt     => x_product_stmt,
        p_lline_id         => p_lline_id
      );
  ELSE
      OPEN c_no_products;
      FETCH c_no_products INTO l_no_products;
      CLOSE c_no_products;

      l_prod_index := 1;

      ozf_utility_pvt.write_conc_log(' -- Number of Products in this offer : '|| l_no_products );

      IF l_no_products > 0 THEN
         FOR i IN c_list_lines LOOP
             l_stmt_temp := null;

             OPEN c_no_excl_products(i.list_line_id);
             FETCH c_no_excl_products INTO l_no_excl_products;
             CLOSE c_no_excl_products;

             l_excl_index := 1;

             FND_DSQL.add_text('(');
             OPEN c_products(i.list_line_id, 'N');
             FETCH c_products INTO l_product_attribute_context, l_product_attribute, l_product_attr_value;
             CLOSE c_products;

             --fix for bug 9725179
             IF l_offer_type = 'ORDER' AND  l_product_attribute IS NULL THEN
                l_product_attribute_context := 'ITEM';
                l_product_attribute := 'PRICING_ATTRIBUTE3';
                l_product_attr_value := 'ALL';
             END IF;

             l_stmt_temp := get_sql(p_context         => l_product_attribute_context,
                                 p_attribute       => l_product_attribute,
                                 p_attr_value_from => l_product_attr_value,
                                 p_attr_value_to   => NULL,
                                 p_comparison      => NULL,
                                 p_type            => 'PROD'
                                );

            ozf_utility_pvt.write_conc_log(' -- Geting Statement for : '|| l_product_attribute || ':' || l_product_attr_value );
            --write_log(' -- Geting Statement for : '|| l_product_attribute || ':' || l_product_attr_value );

             IF l_stmt_temp IS NULL THEN
                l_no_query_flag := 'Y';
             ELSE
                IF l_no_excl_products > 0 THEN
                   EXECUTE IMMEDIATE 'TRUNCATE TABLE ozf_search_selections_t';
                   FOR j IN c_products(i.list_line_id, 'Y') LOOP
                      insert_excl_prod(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       p_commit        => p_commit,
                                       p_context       => j.product_attribute_context,
                                       p_attribute     => j.product_attribute,
                                       p_attr_value    => j.product_attr_value,
                                       x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data);
                   END LOOP;
                   FND_DSQL.add_text(' MINUS select attribute_value product_id, attribute_id product_type from ozf_search_selections_t ');
                END IF;
             END IF;

             FND_DSQL.add_text(')');

             IF l_prod_index < l_no_products THEN
                FND_DSQL.add_text(' UNION ');
                l_prod_index := l_prod_index + 1;
             END IF;
         END LOOP;
      ELSE
         l_no_query_flag := 'Y';
      END IF;

      IF p_calling_from_den = 'N' OR l_no_query_flag = 'N' THEN
         x_product_stmt := FND_DSQL.get_text(FALSE);
      ELSE
         x_product_stmt := NULL;
      END IF;
  END IF;
     ozf_utility_pvt.write_conc_log(' -- End refresh products --' );
     --write_log(' -- End refresh products --' );


EXCEPTION

    WHEN OTHERS THEN
      ozf_utility_pvt.write_conc_log('-- Others - ' || SQLERRM || ' ' || x_product_stmt);

      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('AMS', 'AMS_OFFER_PRODUCT_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END refresh_products;


PROCEDURE refresh_offers(
  ERRBUF           OUT NOCOPY VARCHAR2,
  RETCODE          OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  p_increment_flag IN  VARCHAR2 := 'N',
  p_latest_comp_date IN DATE,
  p_offer_id       IN NUMBER
)
IS

  CURSOR c_party_denormed(l_date DATE, l_id NUMBER) IS
  SELECT 'Y'
    FROM DUAL
   WHERE EXISTS (
                 SELECT 1
                   FROM ozf_activity_customers
                  WHERE last_update_date > l_date
                    AND object_id = l_id and object_class = 'OFFR'
                 );

  CURSOR c_product_denormed(l_date DATE, l_id NUMBER) IS
  SELECT 'Y'
    FROM DUAL
   WHERE EXISTS (
                 SELECT 1
                   FROM ozf_activity_products
                  WHERE last_update_date > l_date
                    AND object_id = l_id and object_class = 'OFFR'
                 );

  CURSOR  c_refreshed_offers(l_date DATE) IS
  SELECT  distinct object_id offer_id, af.forecast_uom_code, oap.currency_code curr_code
    from ozf_activity_products oap,
         ozf_act_forecasts_all af
   where oap.creation_date > l_date
     and oap.object_class = 'OFFR'
     and af.act_fcast_used_by_id(+) = oap.object_id
     and af.arc_act_fcast_used_by(+) = oap.object_class
     and af.freeze_flag(+) = 'Y';

  /* All Offers are captured here. Not just active and request_only offers as before */
  /* The parent object is captured only for non-reusable offers. The parent would always be a campaign */

  CURSOR  c_all_offers IS
  SELECT  o.qp_list_header_id object_id,
          o.offer_type object_type,
          o.status_code object_status,
          'OFFR' object_class,
          l.description object_desc,
          ao.act_offer_used_by_id parent_id,
          ao.arc_act_offer_used_by parent_class,
          ct.campaign_name parent_desc,
          l.ask_for_flag,
          DECODE(o.status_code, 'ACTIVE', 'Y', 'N') active_flag,--l.active_flag,
          o.offer_code source_code,
          o.activity_media_id,
          l.start_date_active start_date,
          l.end_date_active end_date,
          o.confidential_flag,
          o.custom_setup_id,
          af.forecast_uom_code,
          o.fund_request_curr_code curr_code
    FROM ozf_offers o,
         qp_list_headers l,
         ozf_act_offers ao,
         ams_campaigns_vl ct,
         ozf_act_forecasts_all af
   WHERE o.qp_list_header_id = NVL(p_offer_id,o.qp_list_header_id)
     and o.qp_list_header_id = l.list_header_id
     and ao.qp_list_header_id(+) = decode(o.reusable,'N', o.qp_list_header_id)
     and ao.arc_act_offer_used_by(+) = 'CAMP'
     and ao.act_offer_used_by_id = ct.campaign_id(+)
     and af.act_fcast_used_by_id(+) = l.list_header_id
     and af.arc_act_fcast_used_by(+) = 'OFFR'
     and af.freeze_flag(+) = 'Y';

  CURSOR c_offer_changed(l_list_header_id NUMBER, l_date DATE) IS
  SELECT 'Y'
    FROM ozf_offers
   WHERE qp_list_header_id = l_list_header_id
     AND (last_update_date > l_date OR qualifier_deleted = 'Y');

  CURSOR c_qualifier_changed(l_list_header_id NUMBER, l_date DATE) IS
  SELECT 'Y'
    FROM DUAL
   WHERE EXISTS (
                 SELECT 1
                   FROM qp_qualifiers
                  WHERE list_header_id = l_list_header_id
                    AND (
                         last_update_date > l_date -- changed qualifiers
                         OR ( -- changed lists
                             qualifier_context = 'CUSTOMER_GROUP'
                             AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE1'
                             AND qualifier_attr_value IN (
                                                          SELECT list_header_id
                                                            FROM ams_list_entries
                                                           WHERE last_update_date > l_date
                                                         )
                            )
                         OR ( -- changed segments
                             qualifier_context = 'CUSTOMER_GROUP'
                             AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE2'
                             AND qualifier_attr_value IN (
                                                          SELECT ams_party_market_segment_id
                                                            FROM ams_party_market_segments
                                                           WHERE last_update_date > l_date
                                                         )
                            )
                        )
                );

  CURSOR c_product_changed(l_list_header_id NUMBER, l_date DATE) IS
  SELECT 'Y'
    FROM DUAL
   WHERE EXISTS (
                 SELECT 1
                   FROM qp_pricing_attributes
                  WHERE last_update_date > l_date
                    AND list_header_id = l_list_header_id
                );

/*
  CURSOR c_incremental_actual_values(l_date DATE)
  IS
  select distinct adj.list_header_id offer_id,
                  af.forecast_uom_code
    from oe_price_adjustments adj,
         oe_order_lines line,
         ozf_act_forecasts_all af
   where adj.line_id = line.line_id
     and line.open_flag = 'N'
     and line.cancelled_flag = 'N'
     and line.actual_shipment_date > l_date
     and af.act_fcast_used_by_id(+) = adj.list_header_id
     and af.arc_act_fcast_used_by(+) = 'OFFR'
     and af.freeze_flag(+) = 'Y';
*/
  CURSOR c_incremental_forecast_values(l_date DATE)
  IS
  select act_fcast_used_by_id offer_id,
         forecast_uom_code
    from ozf_act_forecasts_all
   where last_update_date > l_date
     and arc_act_fcast_used_by = 'OFFR'
     and freeze_flag(+) = 'Y';

  CURSOR c_primary_uom (l_inventory_item_id NUMBER,l_org_id NUMBER)
  IS
  select primary_uom_code
    from MTL_SYSTEM_ITEMS_B
   where inventory_item_id = l_inventory_item_id
     and organization_id = l_org_id
     and enabled_flag = 'Y';

/*
  CURSOR c_actual_values ( l_offer_id NUMBER, l_org_id NUMBER)
  IS
  SELECT 'ITEM' product_attribute_context,
         'PRICING_ATTRIBUTE1' product_attribute,
         line.inventory_item_id product_attr_value,
         sum(NVL(line.shipped_quantity, line.ordered_quantity)) actual_units,
         sum(( NVL(line.shipped_quantity, line.ordered_quantity))
               * line.unit_list_price) actual_amount,
         adj.arithmetic_operator,
         adj.operand,
         CST_COST_API.get_item_cost(1, line.inventory_item_id, l_org_id, NULL,NULL) cost,
         line.order_quantity_uom,
         head.transactional_curr_code order_currency,
         NVL(line.actual_shipment_date, line.request_date) trans_date
    FROM oe_price_adjustments adj,
         oe_order_lines_all line,
         oe_order_headers_all head
   WHERE adj.list_header_id = l_offer_id
     AND adj.line_id = line.line_id
     AND line.open_flag = 'N'
     AND line.cancelled_flag = 'N'
     AND line.header_id = head.header_id
  group by line.inventory_item_id,
           adj.arithmetic_operator,
           adj.operand,
           CST_COST_API.get_item_cost(1, line.inventory_item_id, l_org_id, NULL,NULL),
           line.order_quantity_uom,
           head.transactional_curr_code,
           NVL(line.actual_shipment_date, line.request_date);
*/

  CURSOR c_actual_values ( l_offer_id NUMBER, l_org_id NUMBER)
  IS
  SELECT 'ITEM' product_attribute_context,
         'PRICING_ATTRIBUTE1' product_attribute,
         line.inventory_item_id product_attr_value,
         sum(NVL(line.shipped_quantity, line.ordered_quantity)) actual_units,
         sum(( NVL(line.shipped_quantity, line.ordered_quantity))
               * line.unit_list_price) actual_amount,
         adj.arithmetic_operator,
         adj.operand,
         --CST_COST_API.get_item_cost(1, line.inventory_item_id, l_org_id, NULL,NULL) cost,
         line.order_quantity_uom,
         head.transactional_curr_code order_currency,
         NVL(line.actual_shipment_date, line.request_date) trans_date
    FROM oe_price_adjustments adj,
         oe_order_lines_all line,
         oe_order_headers_all head
   WHERE adj.list_header_id = l_offer_id
     AND adj.line_id = line.line_id
     AND line.open_flag = 'N'
     AND line.cancelled_flag = 'N'
     AND line.header_id = head.header_id
  group by line.inventory_item_id,
           adj.arithmetic_operator,
           adj.operand,
           --CST_COST_API.get_item_cost(1, line.inventory_item_id, l_org_id, NULL,NULL),
           line.order_quantity_uom,
           head.transactional_curr_code,
           NVL(line.actual_shipment_date, line.request_date);


  CURSOR c_forecast_values(l_offer_id NUMBER,l_org_id NUMBER) IS
  SELECT fc.price_list_id,
         fm.fact_value forecast_units,
         fp.product_attribute_context,
         fp.product_attribute,
         fp.product_attr_value,
         fc.forecast_uom_code uom,
         CST_COST_API.get_item_cost(1, fp.product_attr_value, l_org_id, NULL,NULL) cost,
         ql.arithmetic_operator,
         ql.operand,
         ao.transaction_currency_code,
         ao.fund_request_curr_code transaction_currency_code
    FROM
         ozf_act_forecasts_all fc,
         ozf_act_metric_facts_all fm,
         ozf_forecast_dimentions fp,
         qp_pricing_attributes qa,
         qp_list_lines ql,
         ozf_offers ao
   WHERE fp.obj_id = l_offer_id
     and fp.obj_type = 'OFFR'
     and fc.act_fcast_used_by_id = fp.obj_id
     and fc.last_scenario_id  = (select max(last_scenario_id)
                                   from ozf_act_forecasts_all
                                  where act_fcast_used_by_id = l_offer_id
                                    and freeze_flag = 'Y')
     and fm.act_metric_used_by_id = fc.forecast_id
     and fm.arc_act_metric_used_by = 'FCST'
     and fm.fact_type = 'PRODUCT'
     and fm.fact_reference = fp.forecast_dimention_id
     and qa.list_header_id = fp.obj_id
     and qa.product_attribute_context = fp.product_attribute_context
     and qa.product_attribute = fp.product_attribute
     and qa.product_attr_value = fp.product_attr_value
     and ql.list_line_id = qa.list_line_id
     and ql.list_header_id = qa.list_header_id
     and ao.qp_list_header_id = fp.obj_id;

   CURSOR c_item_cost(l_inv_item_id NUMBER, l_org_id NUMBER)
   IS
   SELECT CQL.item_cost cost
     FROM cst_quantity_layers CQL,
          mtl_parameters MP
    WHERE CQL.inventory_item_id = l_inv_item_id    AND
          CQL.organization_id   = l_org_id      AND
          CQL.cost_group_id     = MP.default_cost_group_id AND
          MP.organization_id    = CQL.organization_id;


  CURSOR c_list_lines(ll_list_header_id NUMBER) IS
  SELECT DISTINCT list_line_id lline_id
    FROM qp_modifier_summary_v a, ozf_offers b
   WHERE a.list_header_id = ll_list_header_id
     AND b.qp_list_header_id = a.list_header_id
     AND b.offer_type <> 'VOLUME_OFFER'
     AND   (a.end_date_active IS NULL
      OR a.end_date_active >= SYSDATE)
  UNION
  SELECT off_discount_product_id lline_id
    FROM ozf_offer_discount_products a, ozf_offers b
   WHERE b.qp_list_header_id = ll_list_header_id
     AND a.offer_id = b.offer_id
     and b.offer_type = 'NET_ACCRUAL'
     AND a.excluder_flag = 'N'
     AND (a.end_date_active IS NULL
      OR a.end_date_active >= SYSDATE)
  UNION
  SELECT activity_product_id lline_id
    FROM ams_act_products
   WHERE act_product_used_by_id = ll_list_header_id
     AND arc_act_product_used_by = 'OFFR'
     AND excluded_flag = 'N'
  UNION
  SELECT distinct offer_discount_line_id lline_id
    FROM ozf_offer_discount_lines a, ozf_offers b
   WHERE b.qp_list_header_id = ll_list_header_id
     AND a.offer_id = b.offer_id
     AND b.offer_type = 'VOLUME_OFFER'
     and a.tier_type = 'PBH'
     AND (a.end_date_active IS NULL
      OR a.end_date_active >= SYSDATE)
  ;

  CURSOR c_no_products(ll_list_header_id NUMBER) IS
  SELECT COUNT(DISTINCT list_line_id)
  FROM   qp_modifier_summary_v
  WHERE  list_header_id = ll_list_header_id
  AND   (end_date_active IS NULL
      OR end_date_active >= SYSDATE);

  CURSOR c_groups(ll_list_header_id NUMBER) IS
  select qnum from
  (
  SELECT DISTINCT a.qualifier_grouping_no qnum
    FROM qp_qualifiers a, ozf_denorm_queries b
   WHERE a.list_header_id      = ll_list_header_id
     AND a.list_line_id        = -1
     AND a.qualifier_context   = b.context
     AND a.qualifier_attribute = b.attribute
     AND b.query_for           = 'ELIG'
  UNION
  SELECT a.qualifier_id qnum
  FROM   ozf_offer_qualifiers a, ozf_offers b
  WHERE  b.qp_list_header_id = ll_list_header_id
  AND    a.offer_id = b.offer_id
  AND    a.active_flag = 'Y'
  UNION
  SELECT qualifier_id qnum
  FROM ozf_offers
  WHERE qp_list_header_id = ll_list_header_id
  AND   offer_type in ('SCAN_DATA', 'LUMPSUM')
  UNION
  select -99 qnum
  FROM dual
  ) order by qnum desc;


  CURSOR c_no_groups(ll_list_header_id NUMBER) IS
  SELECT COUNT(DISTINCT a.qualifier_grouping_no)
    FROM qp_qualifiers a, ozf_denorm_queries b
   WHERE a.list_header_id      = ll_list_header_id
     AND a.list_line_id        = -1
     AND a.qualifier_context   = b.context
     AND a.qualifier_attribute = b.attribute
     AND b.query_for           = 'ELIG'
  UNION
  SELECT count(a.qualifier_id)
  FROM   ozf_offer_qualifiers a, ozf_offers b
  WHERE  b.qp_list_header_id = ll_list_header_id
  AND    a.offer_id = b.offer_id
  AND    a.active_flag = 'Y';


  CURSOR c_elig_exists(ll_list_header_id NUMBER) IS
  SELECT 'Y'
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM qp_qualifiers
                  WHERE list_header_id = ll_list_header_id
                    AND list_line_id = -1
                    AND (qualifier_context,qualifier_attribute) IN
                        (SELECT DISTINCT context,attribute
                         FROM   ozf_denorm_queries
                         WHERE  query_for = 'ELIG'
                         AND    active_flag = 'Y'));


  l_api_version           CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'refresh_denorm';
  l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_conc_program_id       NUMBER;
  l_app_id                NUMBER;
  l_latest_comp_date      DATE;
  l_offer_changed         VARCHAR2(1);
  l_qualifier_changed     VARCHAR2(1);
  l_product_changed       VARCHAR2(1);
  l_dummy                 VARCHAR2(1);
  l_index_tablespace      VARCHAR2(100);
  l_increment_flag        VARCHAR2(1);

  l_stmt_denorm           VARCHAR2(32000) := NULL;
  l_stmt_offer            VARCHAR2(32000) := NULL;
  l_stmt_product          VARCHAR2(32000) := NULL;
  l_stmt_temp             VARCHAR2(254)   :=NULL;
  l_denorm_csr            NUMBER;
  l_ignore                NUMBER;
  l_org_id                NUMBER;
  l_common_uom            VARCHAR2(3);
  l_uom_code              VARCHAR2(3);
  l_primary_uom           VARCHAR2(3);

  s_forecast_revenue      NUMBER;
  s_forecast_costs        NUMBER;
  s_actual_costs          NUMBER;
  s_actual_revenue        NUMBER;
  s_actual_units          NUMBER;
  s_forecast_units        NUMBER;
  s_actual_ROI            NUMBER;
  s_forecast_ROI          NUMBER;
  l_dis_as_exp            VARCHAR(1);
  sy_actual_revenue       NUMBER;
  sy_actual_costs         NUMBER;
  sy_forecast_revenue     NUMBER;
  sy_forecast_costs       NUMBER;
  l_qual_group_no         NUMBER;
  product_denormed        VARCHAR2(1) := NULL;
  l_group_count           NUMBER;
  l_conv_actual_revenue   NUMBER;
  y_conv_actual_revenue   NUMBER;
  l_conv_actual_costs     NUMBER;
  y_conv_actual_costs     NUMBER;



BEGIN
  SAVEPOINT refresh_denorm;
  --a := utl_file.fopen( out_dir ,l_out_file,'w' );
  ozf_utility_pvt.write_conc_log(l_full_name || ': Start Offer refresh denorm');
  --write_log(l_full_name || ': Start Offer refresh denorm');

  ERRBUF := NULL;
  RETCODE := '0';

  -- The following means the default is, incremental refresh.
  IF p_increment_flag = 'N' THEN
    l_increment_flag := 'N' ;
  ELSE
    l_increment_flag := 'Y';
  END IF;
  l_org_id     := FND_PROFILE.VALUE('QP_ORGANIZATION_ID');
  l_common_uom := FND_PROFILE.VALUE('OZF_TP_COMMON_UOM');
  l_dis_as_exp := FND_PROFILE.VALUE('OZF_TREAT_DISCOUNT_AS_EXPENSE');

  ozf_utility_pvt.write_conc_log('-- l_increment_flag is : '|| l_increment_flag );
  --write_log('-- l_increment_flag is : '|| l_increment_flag );
  ozf_utility_pvt.write_conc_log('-- l_org_id is         : '|| l_org_id );
  ozf_utility_pvt.write_conc_log('-- l_latest_comp_date is : '|| p_latest_comp_date );

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     l_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  l_latest_comp_date :=  NVL(p_latest_comp_date, TO_DATE('01/01/1952','MM/DD/YYYY'));
  ozf_utility_pvt.write_conc_log('-- Full Refersh Start --');
  --write_log('-- Full Refersh Start --');

  IF l_increment_flag = 'N' OR l_latest_comp_date IS NULL
     THEN
      -- first time execution or fresh denorm
      -- denorm parties

      write_conc_log('-- Deleting Temp and Denorm Tables --');

      if p_offer_id is not null then
         DELETE FROM ozf_activity_customers
         WHERE object_class = 'OFFR'
         and object_id = p_offer_id;

         DELETE FROM ozf_activity_products
         WHERE object_class = 'OFFR'
         and object_id = p_offer_id;

         DELETE FROM ozf_activity_customers_temp
         WHERE object_class = 'OFFR'
         and object_id = p_offer_id;

         DELETE FROM ozf_activity_products_temp
         WHERE object_class = 'OFFR'
         and object_id = p_offer_id;
      else
         DELETE FROM ozf_activity_customers
         WHERE object_class = 'OFFR';

         DELETE FROM ozf_activity_products
         WHERE object_class = 'OFFR';

         DELETE FROM ozf_activity_customers_temp
         WHERE object_class = 'OFFR';

         DELETE FROM ozf_activity_products_temp
         WHERE object_class = 'OFFR';
      end if;

 end if;

  FOR i IN c_all_offers
  LOOP
    ozf_utility_pvt.write_conc_log('-- Processing Offer_id : '||i.object_id);
    --write_log('-- Processing Offer_id : '||i.object_id);

    IF l_increment_flag = 'N' OR l_latest_comp_date IS NULL
    THEN
      -- first time execution or fresh denorm
      -- denorm parties

      ozf_utility_pvt.write_conc_log('-- Deleting Temp and Denorm Tables --');
/*
      DELETE FROM ozf_activity_customers_temp
      WHERE object_class = 'OFFR'
      AND object_id = i.object_id ;

      DELETE FROM ozf_activity_products_temp
      WHERE object_class = 'OFFR'
      AND object_id = i.object_id ;

      DELETE FROM ozf_activity_customers
      WHERE object_class = 'OFFR'
      AND object_id = i.object_id;

      DELETE FROM ozf_activity_products
      WHERE object_class = 'OFFR'
      AND object_id = i.object_id ;
*/
      IF i.object_status IN ('CANCELLED', 'TERMINATED', 'CLOSED') THEN
         GOTO END_INSERT;
      END IF;
--=========================================================================--
--============================ denorm parties =============================--
--=========================================================================--
  l_group_count :=0;
  FOR z IN c_groups(i.object_id)
    LOOP
       ozf_utility_pvt.write_conc_log('Checking Group:' ||  z.qnum);

      if z.qnum = -99 AND l_group_count > 0 then
          goto GROUP_END1;
      end if;
      FND_DSQL.init;
      FND_DSQL.add_text('INSERT INTO ozf_activity_customers_temp(');
      FND_DSQL.add_text('creation_date,created_by,last_update_date,last_updated_by,last_update_login,');
      FND_DSQL.add_text('confidential_flag,custom_setup_id,');
      FND_DSQL.add_text('object_id,object_type,object_status,object_class,object_desc,');
      FND_DSQL.add_text('parent_id,parent_class,parent_desc,');
      FND_DSQL.add_text('ask_for_flag,active_flag,source_code,currency_code,marketing_medium_id,start_date,end_date,');
--      FND_DSQL.add_text('qp_qualifier_id,qp_qualifier_group,party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code,');
      FND_DSQL.add_text('qp_qualifier_id,qp_qualifier_group,party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code,');
      FND_DSQL.add_text('qualifier_attribute,qualifier_context) ');

      FND_DSQL.add_text('SELECT SYSDATE,FND_GLOBAL.user_id,SYSDATE,');
      FND_DSQL.add_text('FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id,');
      FND_DSQL.add_bind(i.confidential_flag);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.custom_setup_id);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_id);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_type);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_status);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_class);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_desc);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.parent_id);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.parent_class);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.parent_desc);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.ask_for_flag);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.active_flag);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.source_code);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.curr_code);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.activity_media_id);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.start_date);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.end_date);
--      FND_DSQL.add_text(',qp_qualifier_id,qp_qualifier_group,party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code, ');
      FND_DSQL.add_text(',qp_qualifier_id,qp_qualifier_group,party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code, ');
      FND_DSQL.add_text(' decode(site_use_code,''BILL_TO'',''QUALIFIER_ATTRIBUTE14'',''SHIP_TO'',''QUALIFIER_ATTRIBUTE11'',substr(site_use_code,INSTR(site_use_code,'':'')+1)) qualifier_attribute,');
      FND_DSQL.add_text(' decode(site_use_code,''BILL_TO'',''CUSTOMER'',''SHIP_TO'',''CUSTOMER'',substr(site_use_code,0,INSTR(site_use_code,'':'')-1)) qualifier_context');
      FND_DSQL.add_text('  FROM (');

      --ozf_utility_pvt.write_conc_log('Before refresh parties');

      /* refresh parties would get all the parties for the list_header_id and add to FND_DSQL*/
      refresh_parties(p_api_version      => l_api_version,
                      p_init_msg_list    => FND_API.g_false,
                      p_commit           => FND_API.g_false,
                      p_list_header_id   => i.object_id,
                      p_calling_from_den => 'Y',
                      x_return_status    => l_return_status,
                      x_msg_count        => l_msg_count,
                      x_msg_data         => l_msg_data,
                      x_party_stmt       => l_stmt_offer,
                      p_qnum             => z.qnum);

      --write_conc_log('1:' || SUBSTR(l_stmt_offer, 1, 250));
      --write_conc_log('2:' || SUBSTR(l_stmt_offer, 251, 250));
      --write_conc_log('3:' || SUBSTR(l_stmt_offer, 501, 250));
      --write_conc_log('4:' || SUBSTR(l_stmt_offer, 751, 250));
      --write_conc_log('5:' || SUBSTR(l_stmt_offer, 1001, 250));
      --write_conc_log('6:' || SUBSTR(l_stmt_offer, 1251, 250));
      --write_conc_log('7:' || SUBSTR(l_stmt_offer, 1501, 250));

      --ozf_utility_pvt.write_conc_log('After refresh parties');
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF l_stmt_offer IS NOT NULL THEN
         FND_DSQL.add_text(' UNION select -1 qp_qualifier_id, -1 qp_qualifier_group,-1 party_id, -1 cust_account_id, -1 cust_acct_site_id, ');
--         FND_DSQL.add_text(' UNION select -1 party_id, -1 cust_account_id, -1 cust_acct_site_id, ');
         FND_DSQL.add_text(' to_number(qualifier_attr_value) site_use_id, ');
         FND_DSQL.add_text(' qualifier_context||'':''||qualifier_attribute  site_use_code ');
         FND_DSQL.add_text(' FROM qp_qualifiers WHERE list_header_id = ');
         FND_DSQL.add_bind(i.object_id);
         FND_DSQL.add_text(' AND qualifier_grouping_no = ');
         FND_DSQL.add_bind(z.qnum);
         FND_DSQL.add_text(' and qualifier_context||'':''||qualifier_attribute not in ');
         FND_DSQL.add_text(' (''CUSTOMER:QUALIFIER_ATTRIBUTE11'',''CUSTOMER:QUALIFIER_ATTRIBUTE14'')');
         FND_DSQL.add_text(' and qualifier_context not in (''MODLIST'',''ORDER'') ');
         FND_DSQL.add_text(' and qualifier_attribute < ''A'' ');
         FND_DSQL.add_text(')');

         l_denorm_csr := DBMS_SQL.open_cursor;
         FND_DSQL.set_cursor(l_denorm_csr);
         l_stmt_denorm := FND_DSQL.get_text(FALSE);
         DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
         FND_DSQL.do_binds;
         l_ignore := DBMS_SQL.execute(l_denorm_csr);
         dbms_sql.close_cursor(l_denorm_csr);

         UPDATE ozf_offers
         SET    qualifier_deleted = 'N'
         WHERE  qp_list_header_id = i.object_id;
      END IF;
      l_group_count := l_group_count + 1;
      << GROUP_END1 >>
        write_conc_log('end insert party fresh denorm: ' || z.qnum);

   END LOOP;

--=========================================================================================--
--=========================================================================================--
      --write_conc_log('Before insert into activity_products_temp');
      ---===================== denorm products================================---
--=========================================================================================--
--=========================================================================================--
   product_denormed := 'N';
   FOR x IN c_list_lines(i.object_id) LOOP
      FND_DSQL.init;
      FND_DSQL.add_text('INSERT INTO ozf_activity_products_temp(');
      FND_DSQL.add_text('creation_date,created_by,last_update_date,last_updated_by,');
      FND_DSQL.add_text('last_update_login,confidential_flag,custom_setup_id,');
      FND_DSQL.add_text('object_id,object_type,object_status,object_class,object_desc,parent_id,parent_class,');
      FND_DSQL.add_text('parent_desc,ask_for_flag,active_flag,source_code,currency_code,marketing_medium_id,start_date,end_date,');
--      FND_DSQL.add_text('discount_line_id,apply_discount,include_volume,item,item_type) ');
      FND_DSQL.add_text('items_category,item,item_type) ');
      FND_DSQL.add_text('SELECT SYSDATE,FND_GLOBAL.user_id,SYSDATE,');
      FND_DSQL.add_text('FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id,');
      FND_DSQL.add_bind(i.confidential_flag);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.custom_setup_id);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_id);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_type);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_status);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_class);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.object_desc);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.parent_id);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.parent_class);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.parent_desc);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.ask_for_flag);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.active_flag);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.source_code);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.curr_code);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.activity_media_id);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.start_date);
      FND_DSQL.add_text(',');
      FND_DSQL.add_bind(i.end_date);
--      FND_DSQL.add_text(',discount_line_id,apply_discount,include_volume, product_id, product_type FROM (');
      FND_DSQL.add_text(',items_category, product_id, product_type FROM (');

      refresh_products(p_api_version      => l_api_version,
                       p_init_msg_list    => FND_API.g_false,
                       p_commit           => FND_API.g_false,
                       p_list_header_id   => i.object_id,
                       p_calling_from_den => 'Y',
                       x_return_status    => l_return_status,
                       x_msg_count        => l_msg_count,
                       x_msg_data         => l_msg_data,
                       x_product_stmt     => l_stmt_product,
                       p_lline_id         => x.lline_id);

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

     ozf_utility_pvt.write_conc_log ('-- 1 --');

/* the following has to modified to read from ozf_offer_discount_products to handle volume offers */
      IF l_stmt_product IS NOT NULL THEN
--         FND_DSQL.add_text(' UNION  SELECT distinct discount_line_id,apply_discount,include_volume, to_number(decode(product_attr_value,''ALL'',''-9999'',product_attr_value)) product_id, ');
         FND_DSQL.add_text(' UNION  ALL SELECT distinct  null items_category, to_number(decode(product_attr_value,''ALL'',''-9999'',product_attr_value)) product_id, ');
         FND_DSQL.add_text(' product_attribute product_type FROM qp_pricing_attributes ');
         FND_DSQL.add_text(' WHERE list_header_id = ');
         FND_DSQL.add_bind(i.object_id);
         FND_DSQL.add_text(' AND list_line_id = ');
         FND_DSQL.add_bind(x.lline_id);
         FND_DSQL.add_text(' and product_attribute <> ''PRICING_ATTRIBUTE1'' AND excluder_flag = ''N'')');

         l_denorm_csr := DBMS_SQL.open_cursor;
         FND_DSQL.set_cursor(l_denorm_csr);
         l_stmt_denorm := FND_DSQL.get_text(FALSE);

         DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
         FND_DSQL.do_binds;
         l_ignore := DBMS_SQL.execute(l_denorm_csr);
         dbms_sql.close_cursor(l_denorm_csr);
       END IF;
     END LOOP; -- one list line processed

--  Maintain a counter for offers processed and check if any products were denormed, if so, have an if condition to do the forecast.

  IF product_denormed = 'Y' then

        /*---------- Start forecast update  ----------------*/
        --ozf_utility_pvt.write_conc_log(' Start forecast');
        s_actual_units      := 0;
        s_actual_revenue    := 0;
        s_actual_costs      := 0;
        sy_actual_revenue   := 0;
        sy_actual_costs     := 0;

        s_forecast_units    := 0;
        s_forecast_revenue  := 0;
        s_forecast_costs    := 0;
        sy_forecast_revenue := 0;
        sy_forecast_costs   := 0;

        if i.forecast_uom_code is not NULL then
           l_uom_code := i.forecast_uom_code;
        else
           l_uom_code := l_common_uom;
        end if;

        -- get actual values
        --Replace#2
        get_actual_values(
          l_uom_code,
          i.object_id,
          l_org_id,
          l_dis_as_exp,
          i.curr_code,
          s_actual_units,
          s_actual_revenue,
          s_actual_costs,
          sy_actual_revenue,
          sy_actual_costs,
          l_return_status,
          l_msg_count,
          l_msg_data);

        s_actual_roi := 0;
        if (l_dis_as_exp = 'N') then
            if s_actual_costs <> 0 then
               s_actual_roi := (s_actual_revenue - s_actual_costs)/s_actual_costs;
            end if;
        else
            if sy_actual_costs <> 0 then
               s_actual_roi := (sy_actual_revenue - sy_actual_costs)/sy_actual_costs;
            end if;
        end if;


        --ozf_utility_pvt.write_conc_log(' Before forecast values loop');
        -- Get Forecast Value

        --ReplaceForecast#2

        get_forecast_values (
            i.forecast_uom_code,
            i.object_id,
            l_org_id,
            l_dis_as_exp,
            s_forecast_units,
            s_forecast_revenue,
            s_forecast_costs,
            sy_forecast_revenue,
            sy_forecast_costs,
            l_return_status,
            l_msg_count,
            l_msg_data);

        s_forecast_roi := 0;
        if (l_dis_as_exp = 'N') then
            if s_forecast_costs <> 0 then
               s_forecast_roi := (s_forecast_revenue - s_forecast_costs)/s_forecast_costs;
            end if;
        else
            if sy_forecast_costs <> 0 then
               s_forecast_roi := (sy_forecast_revenue - sy_forecast_costs)/sy_forecast_costs;
            end if;
        end if;

        -- update offer forecast and offer values.
        update ozf_activity_products_temp
           set forecast_units   = s_forecast_units,
               forecast_revenue = s_forecast_revenue,
               forecast_costs   = s_forecast_costs,
               forecast_roi     = s_forecast_roi,
               forecast_uom     = i.forecast_uom_code,
               actual_units     = s_actual_units,
               actual_revenue   = s_actual_revenue,
               actual_costs     = s_actual_costs,
               actual_roi       = s_actual_roi,
               actual_uom       = l_uom_code
         where object_id    = i.object_id
           and object_class = 'OFFR';

        -- update offer forecast and offer values.
        update ozf_activity_customers_temp
           set forecast_units   = s_forecast_units,
               forecast_revenue = s_forecast_revenue,
               forecast_costs   = s_forecast_costs,
               forecast_roi     = s_forecast_roi,
               forecast_uom     = i.forecast_uom_code,
               actual_units     = s_actual_units,
               actual_revenue   = s_actual_revenue,
               actual_costs     = s_actual_costs,
               actual_roi       = s_actual_roi,
               actual_uom       = l_uom_code
         where object_id    = i.object_id
           and object_class = 'OFFR';


        /*---------- End forecast update  ----------------*/

      END IF;
      << END_INSERT >>
      ozf_utility_pvt.write_conc_log('-- Done for Offer Id : '|| i.object_id );
    ELSE --=================== incremental denorm======================

      ozf_utility_pvt.write_conc_log('-- Incremental Denorm -- ' || '-'||to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));
      --write_log('-- Incremental Denorm -- ');

      -- initialize offer_changed flag
      l_offer_changed := NULL;

      OPEN c_offer_changed(i.object_id, l_latest_comp_date);
      FETCH c_offer_changed INTO l_offer_changed;
      CLOSE c_offer_changed;

      OPEN c_qualifier_changed(i.object_id, l_latest_comp_date);
      FETCH c_qualifier_changed INTO l_qualifier_changed;
      CLOSE c_qualifier_changed;

      OPEN c_product_changed(i.object_id, l_latest_comp_date);
      FETCH c_product_changed INTO l_product_changed;
      CLOSE c_product_changed;

      ozf_utility_pvt.write_conc_log('-- After Change Check -- ' || '-'||to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));

      IF l_offer_changed IS NOT NULL THEN -- offer changed
         --write_log('OCHAN-Offer Id: '|| i.object_id || ' has changed.');
         -- parties have to be denormed as associated offers are changed
      DELETE FROM ozf_activity_customers -- delete rows that will be refreshed
       WHERE       object_id = i.object_id and object_class = 'OFFR';

  l_group_count := 0;
  FOR z IN c_groups(i.object_id)
    LOOP
      if z.qnum = -99 AND l_group_count > 0 then
          goto GROUP_END2;
      end if;

         FND_DSQL.init;
         FND_DSQL.add_text('INSERT INTO ozf_activity_customers(');
         FND_DSQL.add_text('activity_customer_id,creation_date,created_by,last_update_date,last_updated_by,');
         FND_DSQL.add_text('last_update_login,confidential_flag,custom_setup_id,');
         FND_DSQL.add_text('object_id,object_type,object_status,object_class,object_desc,parent_id,parent_class,');
         FND_DSQL.add_text('parent_desc,ask_for_flag,active_flag,source_code,currency_code,marketing_medium_id,start_date,end_date,');
         FND_DSQL.add_text('qp_qualifier_id,qp_qualifier_group,party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code,');
--         FND_DSQL.add_text('party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code,');
         FND_DSQL.add_text('qualifier_attribute,qualifier_context) ');

         FND_DSQL.add_text('SELECT ozf_activity_customers_s.nextval,SYSDATE,FND_GLOBAL.user_id,SYSDATE,');
         FND_DSQL.add_text('FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id,');
         FND_DSQL.add_bind(i.confidential_flag);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.custom_setup_id);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.object_id);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.object_type);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.object_status);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.object_class);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.object_desc);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.parent_id);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.parent_class);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.parent_desc);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.ask_for_flag);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.active_flag);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.source_code);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.curr_code);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.activity_media_id);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.start_date);
         FND_DSQL.add_text(',');
         FND_DSQL.add_bind(i.end_date);
         FND_DSQL.add_text(',qp_qualifier_id,qp_qualifier_group,party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code, ');
--         FND_DSQL.add_text(',party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code, ');
      FND_DSQL.add_text(' decode(site_use_code,''BILL_TO'',''QUALIFIER_ATTRIBUTE14'',''SHIP_TO'',''QUALIFIER_ATTRIBUTE11'',substr(site_use_code,INSTR(site_use_code,'':'')+1)) qualifier_attribute,');
      FND_DSQL.add_text(' decode(site_use_code,''BILL_TO'',''CUSTOMER'',''SHIP_TO'',''CUSTOMER'',substr(site_use_code,0,INSTR(site_use_code,'':'')-1)) qualifier_context');
      FND_DSQL.add_text('  FROM (');

        refresh_parties(p_api_version      => l_api_version,
                        p_init_msg_list    => FND_API.g_false,
                        p_commit           => FND_API.g_false,
                        p_list_header_id   => i.object_id,
                        p_calling_from_den => 'Y',
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        x_party_stmt       => l_stmt_offer,
                        p_qnum             => z.qnum);

        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

          ozf_utility_pvt.write_conc_log('l_stmt_offer '||l_stmt_offer);

        IF l_stmt_offer IS NOT NULL THEN
           --FND_DSQL.add_text(')');
           FND_DSQL.add_text(' UNION select -1 qp_qualifier_id,-1 qp_qualifier_group,-1 party_id, -1 cust_account_id, -1 cust_acct_site_id, ');
--           FND_DSQL.add_text(' UNION select -1 party_id, -1 cust_account_id, -1 cust_acct_site_id, ');
           FND_DSQL.add_text(' to_number(qualifier_attr_value) site_use_id, ');
           FND_DSQL.add_text(' qualifier_context||'':''||qualifier_attribute  site_use_code ');
           FND_DSQL.add_text(' FROM qp_qualifiers WHERE list_header_id = ');
           FND_DSQL.add_bind(i.object_id);
           FND_DSQL.add_text(' AND qualifier_grouping_no = ');
           FND_DSQL.add_bind(z.qnum);
           FND_DSQL.add_text(' and qualifier_context||'':''||qualifier_attribute not in ');
           FND_DSQL.add_text(' (''CUSTOMER:PRICING_ATTRIBUTE11'',''CUSTOMER:QUALIFIER_ATTRIBUTE14'')');
           FND_DSQL.add_text(' and qualifier_context not in (''MODLIST'',''ORDER'') ');
           FND_DSQL.add_text(' and qualifier_attribute < ''A'' ');
           FND_DSQL.add_text(')');

/*
           DELETE FROM ozf_activity_customers -- delete rows that will be refreshed
           WHERE       object_id = i.object_id and object_class = 'OFFR';
*/
           l_denorm_csr := DBMS_SQL.open_cursor;
           FND_DSQL.set_cursor(l_denorm_csr);
           l_stmt_denorm := FND_DSQL.get_text(FALSE);
           DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
           FND_DSQL.do_binds;
           l_ignore := DBMS_SQL.execute(l_denorm_csr);
           dbms_sql.close_cursor(l_denorm_csr);

           UPDATE ozf_offers
           SET    qualifier_deleted = 'N'
           WHERE  qp_list_header_id = i.object_id;
        END IF;
        l_group_count := l_group_count + 1;
        << GROUP_END2 >>
        write_conc_log('end insert party incremental: ' || z.qnum);
    END LOOP;
        -- products have to be denormed as associated offers are changed
    DELETE FROM ozf_activity_products
     WHERE object_id = i.object_id and object_class = 'OFFR';

    FOR x IN c_list_lines(i.object_id) LOOP
        FND_DSQL.init;
        FND_DSQL.add_text('INSERT INTO ozf_activity_products(');
        FND_DSQL.add_text('activity_product_id,creation_date,created_by,last_update_date,last_updated_by,');
        FND_DSQL.add_text('last_update_login,confidential_flag,custom_setup_id,');
        FND_DSQL.add_text('object_id,object_type,object_status,object_class,object_desc,parent_id,parent_class,');
        FND_DSQL.add_text('parent_desc,ask_for_flag,active_flag,source_code,currency_code,marketing_medium_id,start_date,end_date,');
--        FND_DSQL.add_text('discount_line_id,apply_discount,include_volume,item,item_type) ');
        FND_DSQL.add_text('items_category,item,item_type) ');
        FND_DSQL.add_text('SELECT ozf_activity_products_s.nextval,SYSDATE,FND_GLOBAL.user_id,SYSDATE,');
        FND_DSQL.add_text('FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id,');
        FND_DSQL.add_bind(i.confidential_flag);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.custom_setup_id);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.object_id);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.object_type);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.object_status);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.object_class);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.object_desc);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.parent_id);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.parent_class);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.parent_desc);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.ask_for_flag);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.active_flag);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.source_code);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.curr_code);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.activity_media_id);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.start_date);
        FND_DSQL.add_text(',');
        FND_DSQL.add_bind(i.end_date);
--        FND_DSQL.add_text(',discount_line_id,apply_discount,include_volume, product_id, product_type FROM (');
        FND_DSQL.add_text(',items_category, product_id, product_type FROM (');


        refresh_products(p_api_version      => l_api_version,
                         p_init_msg_list    => FND_API.g_false,
                         p_commit           => FND_API.g_false,
                         p_list_header_id   => i.object_id,
                         p_calling_from_den => 'Y',
                         x_return_status    => l_return_status,
                         x_msg_count        => l_msg_count,
                         x_msg_data         => l_msg_data,
                         x_product_stmt     => l_stmt_product,
                         p_lline_id         => x.lline_id);

         --write_log('After Refresh products- offer has changed');

        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

         --write_log('one');
        IF l_stmt_product IS NOT NULL THEN
           --FND_DSQL.add_text(')');
--FND_DSQL.add_text(' UNION  SELECT distinct discount_line_id,apply_discount,include_volume, to_number(decode(product_attr_value,''ALL'',''-9999'',product_attr_value)) product_id, ');
           FND_DSQL.add_text(' UNION  ALL SELECT distinct   null items_category, to_number(decode(product_attr_value,''ALL'',''-9999'',product_attr_value)) product_id, ');
           FND_DSQL.add_text(' product_attribute product_type  FROM qp_pricing_attributes ');
           FND_DSQL.add_text(' WHERE list_header_id = ');
           FND_DSQL.add_bind(x.lline_id);
           FND_DSQL.add_text(' and product_attribute <> ''PRICING_ATTRIBUTE1'' AND excluder_flag = ''N'')');

/*
           DELETE FROM ozf_activity_products -- delete rows that will be refreshed
           WHERE       object_id = i.object_id and object_class = 'OFFR';
*/

           l_denorm_csr := DBMS_SQL.open_cursor;
           FND_DSQL.set_cursor(l_denorm_csr);
           l_stmt_denorm := FND_DSQL.get_text(FALSE);
           DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
           FND_DSQL.do_binds;
           l_ignore := DBMS_SQL.execute(l_denorm_csr);
         --write_log('four');
           dbms_sql.close_cursor(l_denorm_csr);
        END IF;
       END LOOP;
      ELSE -- offer not changed, denorm party and/or product
         --write_log('Offer Id: '|| i.object_id || ' has not changed.');
        IF l_qualifier_changed IS NOT NULL THEN
          OPEN c_party_denormed(l_latest_comp_date,i.object_id);
          FETCH c_party_denormed INTO l_dummy;
          CLOSE c_party_denormed;

          IF l_dummy IS NULL THEN

             DELETE FROM ozf_activity_customers -- delete rows that will be refreshed
             WHERE       object_id = i.object_id and object_class = 'OFFR';

           l_group_count := 0;
           FOR z IN c_groups(i.object_id)
           LOOP
             if z.qnum = -99 AND l_group_count > 0 then
               goto GROUP_END3;
             end if;
             FND_DSQL.init;
             FND_DSQL.add_text('INSERT INTO ozf_activity_customers(');
             FND_DSQL.add_text('activity_customer_id,creation_date,created_by,last_update_date,last_updated_by,');
             FND_DSQL.add_text('last_update_login,confidential_flag,custom_setup_id,');
             FND_DSQL.add_text('object_id,object_type,object_status,object_class,object_desc,parent_id,parent_class,');
             FND_DSQL.add_text('parent_desc,ask_for_flag,active_flag,source_code,currency_code,marketing_medium_id,start_date,end_date,');
             FND_DSQL.add_text('qp_qualifier_id, qp_qualifier_group,party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code,');
--             FND_DSQL.add_text('party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code,');
             FND_DSQL.add_text('qualifier_attribute,qualifier_context) ');
             FND_DSQL.add_text('SELECT ozf_activity_customers_s.nextval,SYSDATE,FND_GLOBAL.user_id,SYSDATE,');
             FND_DSQL.add_text('FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id,');
             FND_DSQL.add_bind(i.confidential_flag);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.custom_setup_id);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_id);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_type);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_status);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_class);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_desc);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.parent_id);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.parent_class);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.parent_desc);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.ask_for_flag);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.active_flag);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.source_code);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.curr_code);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.activity_media_id);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.start_date);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.end_date);
             FND_DSQL.add_text(',qp_qualifier_id, qp_qualifier_group,party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code, ');
--             FND_DSQL.add_text(',party_id,cust_account_id,cust_acct_site_id,site_use_id,site_use_code, ');
      FND_DSQL.add_text(' decode(site_use_code,''BILL_TO'',''QUALIFIER_ATTRIBUTE14'',''SHIP_TO'',''QUALIFIER_ATTRIBUTE11'',substr(site_use_code,INSTR(site_use_code,'':'')+1)) qualifier_attribute,');
      FND_DSQL.add_text(' decode(site_use_code,''BILL_TO'',''CUSTOMER'',''SHIP_TO'',''CUSTOMER'',substr(site_use_code,0,INSTR(site_use_code,'':'')-1)) qualifier_context');
      FND_DSQL.add_text('  FROM (');
            refresh_parties(p_api_version      => l_api_version,
                            p_init_msg_list    => FND_API.g_false,
                            p_commit           => FND_API.g_false,
                            p_list_header_id   => i.object_id,
                            p_calling_from_den => 'Y',
                            x_return_status    => l_return_status,
                            x_msg_count        => l_msg_count,
                            x_msg_data         => l_msg_data,
                            x_party_stmt       => l_stmt_offer,
                            p_qnum => z.qnum);

            IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF l_stmt_offer IS NOT NULL THEN
               --FND_DSQL.add_text(')');
               FND_DSQL.add_text(' UNION select -1 qp_qualifier_id, -1 qp_qualifier_group,-1 party_id, -1 cust_account_id, -1 cust_acct_site_id, ');
--               FND_DSQL.add_text(' UNION select -1 party_id, -1 cust_account_id, -1 cust_acct_site_id, ');
               FND_DSQL.add_text(' to_number(qualifier_attr_value) site_use_id, ');
               FND_DSQL.add_text('qualifier_context||'':''||qualifier_attribute  site_use_code ');
               FND_DSQL.add_text(' FROM qp_qualifiers WHERE list_header_id = ');
               FND_DSQL.add_bind(i.object_id);
               FND_DSQL.add_text(' AND qualifier_grouping_no = ');
               FND_DSQL.add_bind(z.qnum);
               FND_DSQL.add_text(' and qualifier_context||'':''||qualifier_attribute not in ');
               FND_DSQL.add_text(' (''CUSTOMER:PRICING_ATTRIBUTE11'',''CUSTOMER:QUALIFIER_ATTRIBUTE14'')');
               FND_DSQL.add_text(' and qualifier_context not in (''MODLIST'',''ORDER'') ');
               FND_DSQL.add_text(' and qualifier_attribute < ''A'' ');
               FND_DSQL.add_text(')');
/*
               DELETE FROM ozf_activity_customers -- delete rows that will be refreshed
               WHERE       object_id = i.object_id and object_class = 'OFFR';
*/
               l_denorm_csr := DBMS_SQL.open_cursor;
               FND_DSQL.set_cursor(l_denorm_csr);
               l_stmt_denorm := FND_DSQL.get_text(FALSE);
               DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
               FND_DSQL.do_binds;
               l_ignore := DBMS_SQL.execute(l_denorm_csr);
               dbms_sql.close_cursor(l_denorm_csr);
            END IF;
            l_group_count := l_group_count + 1;
            << GROUP_END3 >>
              write_conc_log('end insert party changed qualifier: ' || z.qnum);
           END LOOP;
          END IF; -- l_dummy <> 'Y', party not denormed yet
        END IF; -- qualifier changed

        IF l_product_changed IS NOT NULL THEN
          OPEN c_product_denormed(l_latest_comp_date,i.object_id);
          FETCH c_product_denormed INTO l_dummy;
          CLOSE c_product_denormed;

          IF l_dummy IS NULL THEN
            DELETE FROM ozf_activity_products -- delete rows that will be refreshed
            WHERE       object_id = i.object_id and object_class = 'OFFR';

          FOR x IN c_list_lines(i.object_id) LOOP

             FND_DSQL.init;
             FND_DSQL.add_text('INSERT INTO ozf_activity_products(');
             FND_DSQL.add_text('activity_product_id,creation_date,created_by,last_update_date,last_updated_by,');
             FND_DSQL.add_text('last_update_login,confidential_flag,custom_setup_id,');
             FND_DSQL.add_text('object_id,object_type,object_status,object_class,object_desc,parent_id,parent_class,');
             FND_DSQL.add_text('parent_desc,ask_for_flag,active_flag,source_code,currency_code,marketing_medium_id,start_date,end_date,');
--             FND_DSQL.add_text('discount_line_id,apply_discount,include_volume,item,item_type) ');
             FND_DSQL.add_text('items_category,item,item_type) ');
             FND_DSQL.add_text('SELECT ozf_activity_products_s.nextval,SYSDATE,FND_GLOBAL.user_id,SYSDATE,');
             FND_DSQL.add_text('FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id,');
             FND_DSQL.add_bind(i.confidential_flag);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.custom_setup_id);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_id);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_type);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_status);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_class);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.object_desc);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.parent_id);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.parent_class);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.parent_desc);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.ask_for_flag);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.active_flag);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.source_code);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.curr_code);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.activity_media_id);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.start_date);
             FND_DSQL.add_text(',');
             FND_DSQL.add_bind(i.end_date);
--             FND_DSQL.add_text(',discount_line_id,apply_discount,include_volume, product_id, product_type FROM (');
             FND_DSQL.add_text(',items_category, product_id, product_type FROM (');

             refresh_products(p_api_version      => l_api_version,
                             p_init_msg_list    => FND_API.g_false,
                             p_commit           => FND_API.g_false,
                             p_list_header_id   => i.object_id,
                             p_calling_from_den => 'Y',
                             x_return_status    => l_return_status,
                             x_msg_count        => l_msg_count,
                             x_msg_data         => l_msg_data,
                             x_product_stmt     => l_stmt_product,
                             p_lline_id         => x.lline_id);

            --write_log('After Refresh products- offer has not changed');

            IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF l_stmt_product IS NOT NULL THEN
               --FND_DSQL.add_text(')');
--               FND_DSQL.add_text(' UNION  SELECT distinct discount_line_id,apply_discount,include_volume,to_number(decode(product_attr_value,''ALL'',''-9999'',product_attr_value)) product_id, ');
               FND_DSQL.add_text(' UNION ALL SELECT distinct  null items_category, to_number(decode(product_attr_value,''ALL'',''-9999'',product_attr_value)) product_id, ');
               FND_DSQL.add_text(' product_attribute product_type   FROM qp_pricing_attributes ');
               FND_DSQL.add_text(' WHERE list_header_id = ');
               FND_DSQL.add_bind(i.object_id);
               FND_DSQL.add_text(' AND list_line_id = ');
               FND_DSQL.add_bind(x.lline_id);
               FND_DSQL.add_text(' and product_attribute <> ''PRICING_ATTRIBUTE1'' AND excluder_flag = ''N'')');


               DELETE FROM ozf_activity_products -- delete rows that will be refreshed
               WHERE       object_id = i.object_id and object_class = 'OFFR';

               l_denorm_csr := DBMS_SQL.open_cursor;
               FND_DSQL.set_cursor(l_denorm_csr);
               l_stmt_denorm := FND_DSQL.get_text(FALSE);
               DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
               FND_DSQL.do_binds;
               l_ignore := DBMS_SQL.execute(l_denorm_csr);
               dbms_sql.close_cursor(l_denorm_csr);
            END IF;
           END LOOP;
          END IF; -- l_dummy <> 'Y', product not denormed yet
        END IF; -- product changed
      END IF; -- offer changed or qualifier/product changed
         --write_log('After Offer Change if condition');
    END IF; -- full fresh or incremental denorm
         --write_log('After full or incremental denorm condition');
  END LOOP; -- all active and request_only offers
         --write_log('After looping thru all_offers' );

  IF l_increment_flag = 'Y' then
      --write_log('In increment equals Y for forecasts' );
      --add forecast and actuals for the re-added offer rows.
      --write_log('Before c_refreshed_offers loop' );
      FOR i IN c_refreshed_offers(l_latest_comp_date) LOOP
        s_actual_units      := 0;
        s_actual_revenue    := 0;
        s_actual_costs      := 0;
        sy_actual_revenue   := 0;
        sy_actual_costs     := 0;

        s_forecast_units    := 0;
        s_forecast_revenue  := 0;
        s_forecast_costs    := 0;
        sy_forecast_revenue := 0;
        sy_forecast_costs   := 0;

        if i.forecast_uom_code is not null then
           l_uom_code := i.forecast_uom_code;
        else
           l_uom_code := l_common_uom;
        end if;

        --Replace#1
        get_actual_values(
          l_uom_code,
          i.offer_id,
          l_org_id,
          l_dis_as_exp,
          i.curr_code,
          s_actual_units,
          s_actual_revenue,
          s_actual_costs,
          sy_actual_revenue,
          sy_actual_costs,
          l_return_status,
          l_msg_count,
          l_msg_data);

        s_actual_roi := 0;
        if (l_dis_as_exp = 'N') then
            if s_actual_costs <> 0 then
               s_actual_roi := (s_actual_revenue - s_actual_costs)/s_actual_costs;
            end if;
        else
            if sy_actual_costs <> 0 then
               s_actual_roi := (sy_actual_revenue - sy_actual_costs)/sy_actual_costs;
            end if;
        end if;

        --ReplaceForecast#1
        get_forecast_values (
            i.forecast_uom_code,
            i.offer_id,
            l_org_id,
            l_dis_as_exp,
            s_forecast_units,
            s_forecast_revenue,
            s_forecast_costs,
            sy_forecast_revenue,
            sy_forecast_costs,
            l_return_status,
            l_msg_count,
            l_msg_data);

        s_forecast_roi := 0;
        if (l_dis_as_exp = 'N') then
            if s_forecast_costs <> 0 then
               s_forecast_roi := (s_forecast_revenue - s_forecast_costs)/s_forecast_costs;
            end if;
        else
            if sy_forecast_costs <> 0 then
               s_forecast_roi := (sy_forecast_revenue - sy_forecast_costs)/sy_forecast_costs;
            end if;
        end if;

        update ozf_activity_products
        set forecast_units = s_forecast_units,
            forecast_revenue = s_forecast_revenue,
            forecast_costs = s_forecast_costs,
            forecast_roi = s_forecast_roi,
            forecast_uom = i.forecast_uom_code,
            actual_units = s_actual_units,
            actual_revenue = s_actual_revenue,
            actual_costs = s_actual_costs,
            actual_roi = s_actual_roi,
            actual_uom = l_uom_code
        where object_id = i.offer_id
          and object_class = 'OFFR';

        update ozf_activity_customers
        set forecast_units = s_forecast_units,
            forecast_revenue = s_forecast_revenue,
            forecast_costs = s_forecast_costs,
            forecast_roi = s_forecast_roi,
            forecast_uom = i.forecast_uom_code,
            actual_units = s_actual_units,
            actual_revenue = s_actual_revenue,
            actual_costs = s_actual_costs,
            actual_roi = s_actual_roi,
            actual_uom = l_uom_code
        where object_id = i.offer_id
          and object_class = 'OFFR';
      END LOOP;

         --write_log('After c_refreshed_offers loop' );
         --write_log('Before c_incremental_forecast_values loop' );
         -- update forecast and actuals for those offers not already updated by the earlier line.
          FOR i in c_incremental_forecast_values(l_latest_comp_date) LOOP
              s_actual_units      := 0;
              s_actual_revenue    := 0;
              s_actual_costs      := 0;
              sy_actual_revenue   := 0;
              sy_actual_costs     := 0;

              s_forecast_units    := 0;
              s_forecast_revenue  := 0;
              s_forecast_costs    := 0;
              sy_forecast_revenue := 0;
              sy_forecast_costs   := 0;


              -- ReplaceForecast#3
              get_forecast_values (
                i.forecast_uom_code,
                i.offer_id,
                l_org_id,
                l_dis_as_exp,
                s_forecast_units,
                s_forecast_revenue,
                s_forecast_costs,
                sy_forecast_revenue,
                sy_forecast_costs,
                l_return_status,
                l_msg_count,
                l_msg_data);

             s_forecast_roi :=0;
             if (l_dis_as_exp = 'N') then
                 if s_forecast_costs <> 0 then
                    s_forecast_roi := (s_forecast_revenue - s_forecast_costs)/s_forecast_costs;
                 end if;
             else
                 if sy_forecast_costs <> 0 then
                    s_forecast_roi := (sy_forecast_revenue - sy_forecast_costs)/sy_forecast_costs;
                 end if;
             end if;

             update ozf_activity_products
                set forecast_units = s_forecast_units,
                    forecast_revenue = s_forecast_revenue,
                    forecast_costs = s_forecast_costs,
                    forecast_roi = s_forecast_roi,
                    forecast_uom = i.forecast_uom_code
             where object_id = i.offer_id
              and  object_class = 'OFFR';

             update ozf_activity_customers
                set forecast_units = s_forecast_units,
                    forecast_revenue = s_forecast_revenue,
                    forecast_costs = s_forecast_costs,
                    forecast_roi = s_forecast_roi,
                    forecast_uom = i.forecast_uom_code
             where object_id = i.offer_id
              and  object_class = 'OFFR';

          END LOOP;

         --write_log('After c_incremental_forecast_values loop' );
         --write_log('Before c_incremental_actual_values loop' );
/*
          FOR i in c_incremental_actual_values(l_latest_comp_date)
          LOOP
              if i.forecast_uom_code is not null then
                 l_uom_code := i.forecast_uom_code;
              else
                 l_uom_code := l_common_uom;
              end if;

             --Replace#3
             get_actual_values(
                    l_uom_code,
                    i.offer_id,
                    l_org_id,
                    l_dis_as_exp,
                    i.curr_code,
                    s_actual_units,
                    s_actual_revenue,
                    s_actual_costs,
                    sy_actual_revenue,
                    sy_actual_costs,
                    l_return_status,
                    l_msg_count,
                    l_msg_data);

              s_actual_roi := 0;
              if (l_dis_as_exp = 'N') then
                   if s_actual_costs <> 0 then
                      s_actual_roi := (s_actual_revenue - s_actual_costs)/s_actual_costs;
                   end if;
              else
                   if sy_actual_costs <> 0 then
                      s_actual_roi := (sy_actual_revenue - sy_actual_costs)/sy_actual_costs;
                   end if;
              end if;

              update ozf_activity_products
                set actual_units = s_actual_units,
                    actual_revenue = s_actual_revenue,
                    actual_costs = s_actual_costs,
                    actual_roi = s_actual_roi,
                     actual_uom         = l_uom_code
               where object_id = i.offer_id
                and object_class = 'OFFR';

              update ozf_activity_customers
                 set forecast_units = s_forecast_units,
                     forecast_revenue = s_forecast_revenue,
                     forecast_costs = s_forecast_costs,
                     forecast_roi = s_forecast_roi,
                     forecast_uom = i.forecast_uom_code
               where object_id = i.offer_id
                 and object_class = 'OFFR';

          END LOOP;
*/
         --write_log('After c_incremental_actual_values loop' );
  END IF;

/*
  DELETE FROM ozf_activity_customers
   WHERE object_id IN (
                            SELECT l.list_header_id
                              FROM ozf_offers o, qp_list_headers l
                             WHERE o.status_code IN ('CANCELLED', 'TERMINATED', 'CLOSED')
                               AND o.qp_list_header_id = l.list_header_id
                           )
    AND object_class = 'OFFR';

  DELETE FROM ozf_activity_products
   WHERE object_id IN (
                            SELECT l.list_header_id
                              FROM ozf_offers o, qp_list_headers l
                             WHERE o.status_code IN ('CANCELLED', 'TERMINATED', 'CLOSED')
                               AND o.qp_list_header_id = l.list_header_id
                           )
    AND object_class = 'OFFR';
*/

  DELETE FROM OZF_ACTIVITY_CUSTOMERS b
   WHERE
        exists ( SELECT L.LIST_HEADER_ID
                   FROM OZF_OFFERS O, QP_LIST_HEADERS L
                  WHERE O.STATUS_CODE IN ('CANCELLED', 'TERMINATED', 'CLOSED') AND
                        O.QP_LIST_HEADER_ID = L.LIST_HEADER_ID and
                        b.object_id = l.list_header_id ) AND OBJECT_CLASS = 'OFFR';

  DELETE FROM OZF_ACTIVITY_PRODUCTS b
   WHERE
        exists ( SELECT L.LIST_HEADER_ID
                   FROM OZF_OFFERS O, QP_LIST_HEADERS L
                  WHERE O.STATUS_CODE IN ('CANCELLED', 'TERMINATED', 'CLOSED') AND
                        O.QP_LIST_HEADER_ID = L.LIST_HEADER_ID and
                        b.object_id = l.list_header_id ) AND OBJECT_CLASS = 'OFFR';


  IF l_increment_flag = 'N' THEN
    --full denorm, need to truncate table and populate from _temp tables and re-create index
    --ozf_utility_pvt.write_conc_log('Before the actual Insert into denorm tables for Full Refresh');
/*
    SELECT i.index_tablespace INTO l_index_tablespace
      FROM fnd_product_installations i, fnd_application a
     WHERE a.application_short_name = 'AMS'
       AND a.application_id = i.application_id;
*/

 ozf_utility_pvt.write_conc_log('-- Populating ozf_activity_customers -- ');

    INSERT INTO ozf_activity_customers
          (activity_customer_id,OBJECT_ID,
           OBJECT_TYPE,
           OBJECT_STATUS,
           OBJECT_CLASS,
           PARENT_ID,
           PARENT_CLASS,
           PARENT_DESC,
           ASK_FOR_FLAG,
           ACTIVE_FLAG,
           SOURCE_CODE,
           CURRENCY_CODE,
           MARKETING_MEDIUM_ID,
           START_DATE,
           END_DATE,
           PARTY_ID,
           CUST_ACCOUNT_ID,
           CUST_ACCT_SITE_ID,
           SITE_USE_CODE,
           SITE_USE_ID,
           QUALIFIER_CONTEXT,
           QUALIFIER_ATTRIBUTE,
           FORECAST_UNITS,
           FORECAST_REVENUE,
           FORECAST_COSTS,
           FORECAST_ROI,
           ACTUAL_UNITS,
           ACTUAL_REVENUE,
           ACTUAL_COSTS,
           ACTUAL_ROI,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CONFIDENTIAL_FLAG,
           CUSTOM_SETUP_ID,
           QP_QUALIFIER_ID,
           QP_QUALIFIER_GROUP)
    SELECT ozf_activity_customers_s.nextval,OBJECT_ID,
           OBJECT_TYPE,
           OBJECT_STATUS,
           OBJECT_CLASS,
           PARENT_ID,
           PARENT_CLASS,
           PARENT_DESC,
           ASK_FOR_FLAG,
           ACTIVE_FLAG,
           SOURCE_CODE,
           CURRENCY_CODE,
           MARKETING_MEDIUM_ID,
           START_DATE,
           END_DATE,
           PARTY_ID,
           CUST_ACCOUNT_ID,
           CUST_ACCT_SITE_ID,
           SITE_USE_CODE,
           SITE_USE_ID,
           QUALIFIER_CONTEXT,
           QUALIFIER_ATTRIBUTE,
           FORECAST_UNITS,
           FORECAST_REVENUE,
           FORECAST_COSTS,
           FORECAST_ROI,
           ACTUAL_UNITS,
           ACTUAL_REVENUE,
           ACTUAL_COSTS,
           ACTUAL_ROI,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CONFIDENTIAL_FLAG,
           CUSTOM_SETUP_ID,
           QP_QUALIFIER_ID,
           QP_QUALIFIER_GROUP
      FROM ozf_activity_customers_temp;

 ozf_utility_pvt.write_conc_log('-- Populating ozf_activity_products -- ');

    INSERT INTO ozf_activity_products
          (activity_product_id,
           OBJECT_ID,
           OBJECT_TYPE,
           OBJECT_STATUS,
           OBJECT_CLASS,
           PARENT_ID,
           PARENT_CLASS,
           PARENT_DESC,
           ASK_FOR_FLAG,
           ACTIVE_FLAG,
           SOURCE_CODE,
           CURRENCY_CODE,
           MARKETING_MEDIUM_ID,
           START_DATE,
           END_DATE,
           ITEM,
           ITEM_TYPE,
           FORECAST_UNITS,
           FORECAST_REVENUE,
           FORECAST_COSTS,
           FORECAST_ROI,
           ACTUAL_UNITS,
           ACTUAL_REVENUE,
           ACTUAL_COSTS,
           ACTUAL_ROI,
           FORECAST_PRODUCT_UNITS,
           FORECAST_PRODUCT_REVENUE,
           FORECAST_PRODUCT_COSTS,
           FORECAST_PRODUCT_ROI,
           ACTUAL_PRODUCT_UNITS,
           ACTUAL_PRODUCT_REVENUE,
           ACTUAL_PRODUCT_COSTS,
           ACTUAL_PRODUCT_ROI,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CONFIDENTIAL_FLAG,
           CUSTOM_SETUP_ID,
           FORECAST_UOM,
           ACTUAL_UOM,
           LIST_PRICE,
           DISCOUNT,
           ITEMS_CATEGORY)
    SELECT ozf_activity_products_s.nextval,
           OBJECT_ID,
           OBJECT_TYPE,
           OBJECT_STATUS,
           OBJECT_CLASS,
           PARENT_ID,
           PARENT_CLASS,
           PARENT_DESC,
           ASK_FOR_FLAG,
           ACTIVE_FLAG,
           SOURCE_CODE,
           CURRENCY_CODE,
           MARKETING_MEDIUM_ID,
           START_DATE,
           END_DATE,
           ITEM,
           ITEM_TYPE,
           FORECAST_UNITS,
           FORECAST_REVENUE,
           FORECAST_COSTS,
           FORECAST_ROI,
           ACTUAL_UNITS,
           ACTUAL_REVENUE,
           ACTUAL_COSTS,
           ACTUAL_ROI,
           FORECAST_PRODUCT_UNITS,
           FORECAST_PRODUCT_REVENUE,
           FORECAST_PRODUCT_COSTS,
           FORECAST_PRODUCT_ROI,
           ACTUAL_PRODUCT_UNITS,
           ACTUAL_PRODUCT_REVENUE,
           ACTUAL_PRODUCT_COSTS,
           ACTUAL_PRODUCT_ROI,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CONFIDENTIAL_FLAG,
           CUSTOM_SETUP_ID,
           FORECAST_UOM,
           ACTUAL_UOM,
           LIST_PRICE,
           DISCOUNT,
           ITEMS_CATEGORY
      FROM ozf_activity_products_temp;

  END IF;
 --utl_file.fflush( a );
 --utl_file.fclose( a );

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ozf_utility_pvt.write_conc_log('-- Expected Error - '|| SQLERRM || ' ' || l_stmt_denorm);
          x_return_status := FND_API.g_ret_sts_error ;
          ERRBUF := l_msg_data;
          RETCODE := 2;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ozf_utility_pvt.write_conc_log('-- Unexpected Error - '|| SQLERRM || ' ' || l_stmt_denorm);
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          ERRBUF := l_msg_data;
          RETCODE := 2;

     WHEN OTHERS THEN
          ROLLBACK TO refresh_denorm;
          ozf_utility_pvt.write_conc_log('-- Others - '|| SQLERRM || ' ' || l_stmt_denorm);
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          ERRBUF := SQLERRM || ' ' || l_stmt_denorm;
          RETCODE := sqlcode;


END refresh_offers;


PROCEDURE get_actual_values(
  p_uom_code         IN  VARCHAR2,
  p_offer_id         IN  NUMBER,
  p_org_id           IN  NUMBER,
  p_dis_as_exp       IN  VARCHAR2,
  p_curr_code        IN  VARCHAR2,
  x_actual_units     OUT NOCOPY NUMBER,
  x_actual_revenue   OUT NOCOPY NUMBER,
  x_actual_costs     OUT NOCOPY NUMBER,
  xy_actual_revenue  OUT NOCOPY NUMBER,
  xy_actual_costs    OUT NOCOPY NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_actual_values ( l_offer_id NUMBER, l_org_id NUMBER)
  IS
  SELECT 'ITEM' product_attribute_context,
         'PRICING_ATTRIBUTE1' product_attribute,
         line.inventory_item_id product_attr_value,
         sum(NVL(line.shipped_quantity, line.ordered_quantity)) actual_units,
         sum(( NVL(line.shipped_quantity, line.ordered_quantity))* line.unit_list_price) actual_amount,
         adj.arithmetic_operator,
         adj.operand,
         CST_COST_API.get_item_cost(1, line.inventory_item_id, l_org_id, NULL,NULL) cost,
         line.order_quantity_uom,
         head.transactional_curr_code order_currency,
         NVL(line.actual_shipment_date,line.request_date) trans_date
    FROM oe_price_adjustments adj,
         oe_order_lines_all line,
       oe_order_headers_all head
   WHERE adj.list_header_id  = l_offer_id
     AND adj.line_id         = line.line_id
     AND line.open_flag      = 'N'
     AND line.cancelled_flag = 'N'
     AND line.header_id = head.header_id
   GROUP BY line.inventory_item_id,
            adj.arithmetic_operator,
            adj.operand,
            CST_COST_API.get_item_cost(1, line.inventory_item_id, l_org_id, NULL,NULL),
            line.order_quantity_uom,
            head.transactional_curr_code,
            NVL(line.actual_shipment_date,line.request_date);

  CURSOR c_primary_uom (l_inventory_item_id NUMBER,l_org_id NUMBER)
  IS
  select primary_uom_code
    from MTL_SYSTEM_ITEMS_B
   where inventory_item_id = l_inventory_item_id
     and organization_id = l_org_id
     and enabled_flag = 'Y';


   CURSOR c_item_cost(l_inv_item_id NUMBER, l_org_id NUMBER)
   IS
   SELECT CQL.item_cost cost
     FROM cst_quantity_layers CQL,
          mtl_parameters MP
    WHERE CQL.inventory_item_id = l_inv_item_id    AND
          CQL.organization_id   = l_org_id      AND
          CQL.cost_group_id     = MP.default_cost_group_id AND
          MP.organization_id    = CQL.organization_id;

  l_primary_uom           VARCHAR2(3);
  l_fc_conv_factor        NUMBER;
  l_comm_conv_factor      NUMBER;
  t_actual_units          NUMBER;
  t_conv_actual_units     NUMBER;
  t_actual_amount         NUMBER;
  t_operand               NUMBER;
  t_cost                  NUMBER;
  t_conv_cost             NUMBER;
  t_arithmetic_operator   VARCHAR2(30);
  l_discount              NUMBER;
  l_actual_revenue        NUMBER;
  l_actual_costs          NUMBER;
  l_actual_roi            NUMBER;
  y_actual_revenue        NUMBER;
  y_actual_costs          NUMBER;
  l_return_status         VARCHAR2(1);
  l_conv_actual_revenue   NUMBER;
  y_conv_actual_revenue   NUMBER;
  l_conv_actual_costs     NUMBER;
  y_conv_actual_costs     NUMBER;

BEGIN
       /* Initializing the offer level value */
        x_actual_units := 0;
        x_actual_revenue := 0;
        x_actual_costs := 0;
        xy_actual_revenue := 0;
        xy_actual_costs := 0;

        FOR j IN c_actual_values(p_offer_id,p_org_id)
        LOOP
            l_fc_conv_factor  := inv_convert.inv_um_convert(j.product_attr_value,
                                                         NULL,
                                                         1,
                                                         j.order_quantity_uom,
                                                         p_uom_code,
                                                         NULL,
                                                         NULL);

            OPEN c_primary_uom(j.product_attr_value, p_org_id);
                 FETCH c_primary_uom INTO l_primary_uom;
            CLOSE c_primary_uom;

            l_comm_conv_factor  := inv_convert.inv_um_convert(j.product_attr_value,
                                                         NULL,
                                                         1,
                                                         j.order_quantity_uom,
                                                         l_primary_uom,
                                                         NULL,
                                                         NULL);


            t_actual_units        := nvl(j.actual_units,0);
            t_conv_actual_units   := nvl(j.actual_units,0)*l_fc_conv_factor;
            t_actual_amount       := nvl(j.actual_amount,0);
            t_operand             := nvl(j.operand,0);
            t_arithmetic_operator := j.arithmetic_operator;
            --t_cost                := nvl(j.cost,0);

            OPEN c_item_cost(j.product_attr_value, p_org_id);
            FETCH c_item_cost into t_cost;
            CLOSE c_item_cost;

            if t_cost is not null then
               if l_comm_conv_factor < 0 then
                  t_conv_cost := t_cost;
               else
                  t_conv_cost := t_cost/l_comm_conv_factor;
               end if;
            else
               t_conv_cost := 0;
            end if;

            If t_arithmetic_operator is not NULL then
               If t_arithmetic_operator = 'AMT' then
                  l_discount := t_actual_units * t_operand;
               elsif t_arithmetic_operator = '%' then
                  l_discount := (t_actual_amount * t_operand)/100;
               end if;
            end if;

            l_actual_revenue := t_actual_amount - l_discount;
            l_actual_costs   := t_actual_units * t_conv_cost;

            if (p_dis_as_exp = 'N') then
               if l_actual_costs <> 0 then
                  l_actual_roi := (l_actual_revenue - l_actual_costs)/l_actual_costs;
               end if;
            else
               y_actual_revenue := t_actual_amount;
               y_actual_costs := t_actual_units * (t_conv_cost + l_discount);
               if (y_actual_costs <> 0) then
                  l_actual_roi := (y_actual_revenue - y_actual_costs)/y_actual_costs;
               end if;
            end if;



            if p_curr_code <> j.order_currency then
               ozf_utility_pvt.convert_currency(x_return_status => l_return_status
                                          ,p_from_currency => j.order_currency
                                          ,p_to_currency   => p_curr_code
                                          ,p_conv_date     => j.trans_date
                                          ,p_from_amount   => l_actual_revenue
                                          ,x_to_amount     => l_conv_actual_revenue);

               ozf_utility_pvt.convert_currency(x_return_status => l_return_status
                                          ,p_from_currency => j.order_currency
                                          ,p_to_currency   => p_curr_code
                                          ,p_conv_date     => j.trans_date
                                          ,p_from_amount   => y_actual_revenue
                                          ,x_to_amount     => y_conv_actual_revenue);

               ozf_utility_pvt.convert_currency(x_return_status => l_return_status
                                          ,p_from_currency => j.order_currency
                                          ,p_to_currency   => p_curr_code
                                          ,p_conv_date     => j.trans_date
                                          ,p_from_amount   => l_actual_costs
                                          ,x_to_amount     => l_conv_actual_costs);

               ozf_utility_pvt.convert_currency(x_return_status => l_return_status
                                          ,p_from_currency => j.order_currency
                                          ,p_to_currency   => p_curr_code
                                          ,p_conv_date     => j.trans_date
                                          ,p_from_amount   => y_actual_costs
                                          ,x_to_amount     => y_conv_actual_costs);
               if l_conv_actual_revenue is not null then
                  l_actual_revenue := l_conv_actual_revenue;
               end if;

               if y_conv_actual_revenue is not null then
                  y_actual_revenue := y_conv_actual_revenue;
               end if;

               if l_conv_actual_costs is not null then
                  l_actual_costs := l_conv_actual_costs;
               end if;

               if y_conv_actual_costs is not null then
                  y_actual_costs := y_conv_actual_costs;
               end if;

            end if;


            x_actual_units    := x_actual_units + t_conv_actual_units;
            x_actual_revenue  := x_actual_revenue + l_actual_revenue;
            x_actual_costs    := x_actual_costs + l_actual_costs;
            xy_actual_revenue := xy_actual_revenue + y_actual_revenue;
            xy_actual_costs   := xy_actual_costs + y_actual_costs;

            -- update the actual values for the offer/product
            update ozf_activity_products_temp
                   set actual_product_units   = t_conv_actual_units,
                       actual_product_revenue = l_actual_revenue,
                       actual_product_costs   = l_actual_costs,
                       actual_product_roi     = l_actual_roi,
                       actual_uom             = p_uom_code,
                       discount               = l_discount
             where object_id    = p_offer_id
               and object_class = 'OFFR'
               and item         = j.product_attr_value
               and item_type    = j.product_attribute;
        END LOOP;

END;

PROCEDURE get_forecast_values (
  p_forecast_uom_code IN  VARCHAR2,
  p_offer_id          IN  NUMBER,
  p_org_id            IN  NUMBER,
  p_dis_as_exp        IN  VARCHAR2,
  x_forecast_units      OUT NOCOPY NUMBER,
  x_forecast_revenue    OUT NOCOPY NUMBER,
  x_forecast_costs      OUT NOCOPY NUMBER,
  xy_forecast_revenue   OUT NOCOPY NUMBER,
  xy_forecast_costs     OUT NOCOPY NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
)
IS

  CURSOR c_forecast_values(l_offer_id NUMBER,l_org_id NUMBER) IS
  SELECT fc.price_list_id,
         fm.fact_value forecast_units,
         fp.product_attribute_context,
         fp.product_attribute,
         fp.product_attr_value,
         fc.forecast_uom_code uom,
         CST_COST_API.get_item_cost(1, fp.product_attr_value, l_org_id, NULL,NULL) cost,
         ql.arithmetic_operator,
         ql.operand,
         ao.transaction_currency_code,
         fc.forecast_id
    FROM
         ozf_act_forecasts_all fc,
         ozf_act_metric_facts_all fm,
         ozf_forecast_dimentions fp,
         qp_pricing_attributes qa,
         qp_list_lines ql,
         ozf_offers ao
   WHERE fp.obj_id = l_offer_id
     and fp.obj_type = 'OFFR'
     and fc.act_fcast_used_by_id = fp.obj_id
     and fc.last_scenario_id  = (select max(last_scenario_id)
                                   from ozf_act_forecasts_all
                                  where act_fcast_used_by_id = l_offer_id
                                    and freeze_flag = 'Y')
     and fm.act_metric_used_by_id = fc.forecast_id
     and fm.arc_act_metric_used_by = 'FCST'
     and fm.fact_type = 'PRODUCT'
     and fm.fact_reference = fp.forecast_dimention_id
     and qa.list_header_id = fp.obj_id
     and qa.product_attribute_context = fp.product_attribute_context
     and qa.product_attribute = fp.product_attribute
     and qa.product_attr_value = fp.product_attr_value
     and ql.list_line_id = qa.list_line_id
     and ql.list_header_id = qa.list_header_id
     and ao.qp_list_header_id = fp.obj_id;

CURSOR c_primary_uom (l_inventory_item_id NUMBER,l_org_id NUMBER)
  IS
  select primary_uom_code
    from MTL_SYSTEM_ITEMS_B
   where inventory_item_id = l_inventory_item_id
     and organization_id = l_org_id
     and enabled_flag = 'Y';

l_list_price            NUMBER;
l_discount              NUMBER;
l_primary_uom           VARCHAR2(3);
l_comm_conv_factor      NUMBER;
l_selling_price         NUMBER;
l_forecast_revenue      NUMBER;
l_forecast_costs        NUMBER;
l_forecast_roi          NUMBER;
y_discount              NUMBER;
y_forecast_revenue      NUMBER;
y_forecast_costs        NUMBER;

t_forecast_units        NUMBER;
t_operand               NUMBER;
t_cost                  NUMBER;
t_conv_cost             NUMBER;
t_arithmetic_operator   VARCHAR2(30);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_api_version    CONSTANT NUMBER       := 1.0;
BEGIN
       /* Initializing the offer level value */
        x_forecast_units := 0;
        x_forecast_revenue := 0;
        x_forecast_costs := 0;
        xy_forecast_revenue := 0;
        xy_forecast_costs := 0;

        FOR j IN c_forecast_values(p_offer_id,p_org_id)
        LOOP
            OPEN c_primary_uom(j.product_attr_value, p_org_id);
            FETCH c_primary_uom INTO l_primary_uom;
            CLOSE c_primary_uom;

            l_comm_conv_factor  := inv_convert.inv_um_convert(j.product_attr_value,
                                                         NULL,
                                                         1,
                                                         j.uom,
                                                         l_primary_uom,
                                                         NULL,
                                                         NULL);

            t_forecast_units      := nvl(j.forecast_units,0);
            t_operand             := nvl(j.operand,0);
            t_cost                := nvl(j.cost,0);
            t_arithmetic_operator := j.arithmetic_operator;
            l_list_price          := 0;
            l_discount            := 0;
            if j.cost is not null then
               if l_comm_conv_factor < 0 then
                  t_conv_cost := j.cost;
               else
                  t_conv_cost := j.cost/l_comm_conv_factor;
               end if;
            else
               t_conv_cost := 0;
            end if;

            ozf_forecast_util_pvt.get_list_price(
                    p_api_version          => l_api_version,
                    p_init_msg_list        => FND_API.g_false,
                    p_commit               => FND_API.g_false,
                    p_obj_type             => 'OFFR',
                    p_obj_id               => p_offer_id,
                    p_forecast_id          => j.forecast_id,
                    p_product_attribute    => j.product_attribute,
                    p_product_attr_value   => j.product_attr_value,
                    p_fcst_uom             => j.uom,
                    p_currency_code        => j.transaction_currency_code,
                    p_price_list_id        => j.price_list_id,
                    x_list_price           => l_list_price,
                    x_return_status        => l_return_status,
                    x_msg_count            => l_msg_count,
                    x_msg_data             => l_msg_data
            );
            If t_arithmetic_operator is not NULL then
               if t_arithmetic_operator = '%' then
                  l_selling_price := (l_list_price - (l_list_price*t_operand)/100);
                  l_discount      := (l_list_price*t_operand)/100;
               elsif t_arithmetic_operator = 'AMT' then
                  l_selling_price := l_list_price - t_operand;
                  l_discount      := t_operand;
               end if;
            end if;

            l_forecast_revenue := t_forecast_units * l_selling_price;
            l_forecast_costs   := t_forecast_units * t_conv_cost;
            if (p_dis_as_exp = 'N') then
               if l_forecast_costs <> 0 then
                  l_forecast_roi := (l_forecast_revenue - l_forecast_costs)/l_forecast_costs;
               end if;
            else
               If t_arithmetic_operator is not NULL then
                  if t_arithmetic_operator = '%' then
                     y_discount := (l_list_price*t_operand)/100;
                  elsif t_arithmetic_operator = 'AMT' then
                     y_discount := t_operand;
                  end if;
               end if;
               y_forecast_revenue := t_forecast_units * l_list_price;
               y_forecast_costs   := t_forecast_units * (t_conv_cost+y_discount);
               if y_forecast_costs <> 0 then
                  l_forecast_roi := (y_forecast_revenue - y_forecast_costs)/y_forecast_costs;
               end if;
            end if;

            x_forecast_units    := x_forecast_units + t_forecast_units;
            x_forecast_revenue  := x_forecast_revenue + l_forecast_revenue;
            x_forecast_costs    := x_forecast_costs + l_forecast_costs;
            xy_forecast_revenue := xy_forecast_revenue + y_forecast_revenue;
            xy_forecast_costs   := xy_forecast_costs + y_forecast_costs;

            -- update the forecast values for the offer/product
            update ozf_activity_products_temp
               set forecast_product_units   = t_forecast_units,
                   forecast_product_revenue = l_forecast_revenue,
                   forecast_product_costs   = l_forecast_costs,
                   forecast_product_roi     = l_forecast_roi,
                   forecast_uom             = p_forecast_uom_code,
                   list_price               = l_list_price,
                   discount                 = l_discount
             where object_id    = p_offer_id
               and object_class = 'OFFR'
               and item         = j.product_attr_value
               and item_type    = j.product_attribute;
        END LOOP;
        --ReplaceForecast#2

END;

-------------------------------------------------------------------
-- PROCEDURE
--    find_party_elig
--
-- PURPOSE
--    Find eligible offer for given party and offers.
--    This would return only active and request_only offers
--
-- PARAMETERS
--   p_offers_tbl: Input, table of qp_list_header_id of offers
--   p_party_id:   Input, party id
--   x_offers_tbl: Output, table of qp_list_header_id of offers
-- NOTES
--
--------------------------------------------------------------------
PROCEDURE find_party_elig(
  p_offers_tbl       IN  num_tbl_type,
  p_party_id         IN  NUMBER,
  p_cust_acct_id     IN  NUMBER := NULL,
  p_cust_site_id     IN  NUMBER := NULL,

  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_offers_tbl       OUT NOCOPY num_tbl_type
)
IS

 CURSOR c_offer(l_party NUMBER, l_offer NUMBER) IS
  SELECT distinct(1)
    FROM ozf_activity_customers
   WHERE (party_id = l_party
         OR party_id = -1)
     AND object_id = l_offer
     AND object_class = 'OFFR'
     AND active_flag = 'Y'
     AND ask_for_flag = 'Y'
     AND (start_date <= TRUNC(SYSDATE)
         OR start_date IS NULL)
     AND (end_date >= TRUNC(SYSDATE)
         OR end_date IS NULL);

  l_dummy      NUMBER;
  l_counter    NUMBER := 0;

BEGIN

  FOR i IN 1..p_offers_tbl.COUNT LOOP
    l_dummy := NULL;
    OPEN c_offer(p_party_id, p_offers_tbl(i));
    FETCH c_offer INTO l_dummy;
    CLOSE c_offer;

    IF l_dummy = 1 THEN
      l_counter := l_counter + 1;
      x_offers_tbl(l_counter) := p_offers_tbl(i);
    END IF;
  END LOOP;
END find_party_elig;


-------------------------------------------------------------------
-- PROCEDURE
--    find_products_elig
--
-- PURPOSE
--    Find eligible offer for given party and products.
--
-- PARAMETERS
--   p_products_tbl: Input, table of product_id of products
--   p_party_id:   Input, party id
--   x_offers_tbl: Output, table of qp_list_header_id of offers
--
-- NOTES
--
--------------------------------------------------------------------
PROCEDURE find_product_elig(
  p_products_tbl     IN  num_tbl_type,
  p_party_id         IN  NUMBER,
  p_cust_acct_id     IN  NUMBER := NULL,
  p_cust_site_id     IN  NUMBER := NULL,

  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_offers_tbl       OUT NOCOPY num_tbl_type
)
IS

  CURSOR c_offer(l_party NUMBER, l_product NUMBER) IS
  SELECT object_id
    FROM (SELECT distinct object_id
            FROM ozf_activity_customers
           WHERE (party_id = l_party OR party_id = -1)
             AND active_flag = 'Y'
             AND ask_for_flag = 'Y'
             AND object_class = 'OFFR'
          INTERSECT
          SELECT object_id
            FROM ozf_activity_products
           WHERE item = l_product
             --AND item_type = 'PRODUCT'  --fixed bug 7289857
             AND object_class = 'OFFR'
             AND active_flag = 'Y'
             AND ask_for_flag = 'Y');

  l_counter    NUMBER := 0;

BEGIN

  FOR i IN 1..p_products_tbl.COUNT LOOP
    FOR j IN c_offer(p_party_id, p_products_tbl(i)) LOOP
      l_counter := l_counter + 1;
      x_offers_tbl(l_counter) := j.object_id;
    END LOOP;
  END LOOP;

END find_product_elig;


--------------------------------------------------------------------
-- PROCEDURE
--    get_party_product_stmt
--
-- PURPOSE
--    Generates denorm statement for budget validation.
--
-- PARAMETERS
--    p_list_header_id: list_header_id of the offer
--    x_party_stmt:     party statement for the offer
--    x_product_stmt:   product statement for the offer
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for product and refresh ozf_activity_products
----------------------------------------------------------------------
PROCEDURE get_party_product_stmt(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_party_stmt       OUT NOCOPY VARCHAR2,
  x_product_stmt     OUT NOCOPY VARCHAR2
)
IS

BEGIN

  refresh_parties(p_api_version      => p_api_version,
                  p_init_msg_list    => p_init_msg_list,
                  p_commit           => p_commit,
                  p_list_header_id   => p_list_header_id,
                  p_calling_from_den => 'N',
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_count,
                  x_party_stmt       => x_party_stmt);

  x_party_stmt := 'select distinct(party_id) from ('||x_party_stmt||' )';

  refresh_products(p_api_version      => p_api_version,
                   p_init_msg_list    => p_init_msg_list,
                   p_commit           => p_commit,
                   p_list_header_id   => p_list_header_id,
                   p_calling_from_den => 'N',
                   x_return_status    => x_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_count,
                   x_product_stmt     => x_product_stmt);

  x_product_stmt := 'select distinct(product_id) from ('||x_product_stmt||' )';

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

END get_party_product_stmt;


END OZF_OFFR_ELIG_PROD_DENORM_PVT;

/
