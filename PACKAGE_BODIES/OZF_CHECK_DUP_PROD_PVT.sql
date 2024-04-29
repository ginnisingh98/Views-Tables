--------------------------------------------------------
--  DDL for Package Body OZF_CHECK_DUP_PROD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CHECK_DUP_PROD_PVT" AS
/* $Header: ozfvcdpb.pls 120.5 2006/05/25 23:48:54 julou noship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='OZF_CHECK_DUP_PROD_PVT';
---------------------------------------------------------------------
-- FUNCTION
--    get_sql
--
-- PURPOSE
--    Retrieves SQL statment for given context, attribute.
--
-- PARAMETERS
--    p_context: product or qualifier context.
--    p_attribute: context attribute.
--    p_attr_value: context attribute value.
--
-- NOTES
--   This functions returns SQL statement for the given context, attribute and attribute value.
---------------------------------------------------------------------
FUNCTION get_sql(
  p_context    IN  VARCHAR2,
  p_attribute  IN  VARCHAR2,
  p_attr_value IN  VARCHAR2
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
         condition_id_column
  FROM   ozf_denorm_queries
  WHERE  context = p_context
  AND    attribute = p_attribute
  AND    active_flag = 'Y'
  AND    last_update_date =
         (
         SELECT MAX(last_update_date)
         FROM   ozf_denorm_queries
         WHERE  context = p_context
         AND    attribute = p_attribute
         AND    active_flag = 'Y'
         );

  l_stmt    VARCHAR2(32000) := NULL;
  l_stmt_1  VARCHAR2(4000) := NULL;
  l_stmt_2  VARCHAR2(4000) := NULL;
  l_stmt_3  VARCHAR2(4000) := NULL;
  l_stmt_4  VARCHAR2(4000) := NULL;
  l_stmt_5  VARCHAR2(4000) := NULL;
  l_stmt_6  VARCHAR2(4000) := NULL;
  l_stmt_7  VARCHAR2(4000) := NULL;
  l_stmt_8  VARCHAR2(4000) := NULL;
  l_cond_id VARCHAR2(40);
BEGIN

  OPEN c_get_sql;
  FETCH c_get_sql INTO l_stmt_1, l_stmt_2,l_stmt_3, l_stmt_4, l_stmt_5, l_stmt_6, l_stmt_7, l_stmt_8, l_cond_id;
  CLOSE c_get_sql;
  -- special case, for item only.
  IF l_stmt_1 is not null then
    IF INSTR(l_stmt_1, '*') > 0 OR INSTR(l_stmt_1, '?') > 0 THEN
      FND_DSQL.add_text('SELECT TO_NUMBER(');
      FND_DSQL.add_bind(p_attr_value);
      FND_DSQL.add_text(') product_id,''PRICING_ATTRIBUTE1'' product_type FROM DUAL');
    ELSE
      FND_DSQL.add_text(' ' || l_stmt_1);
    END IF;

    FND_DSQL.add_text(' ' || l_stmt_2);
    FND_DSQL.add_text(' ' || l_stmt_3);
    FND_DSQL.add_text(' ' || l_stmt_4);
    FND_DSQL.add_text(' ' || l_stmt_5);
    FND_DSQL.add_text(' ' || l_stmt_6);
    FND_DSQL.add_text(' ' || l_stmt_7);
    FND_DSQL.add_text(' ' || l_stmt_8);

    IF l_cond_id IS NOT NULL THEN
      IF INSTR(UPPER(l_stmt_1),'WHERE') > 0 OR INSTR(UPPER(l_stmt_2),'WHERE') > 0
      OR INSTR(UPPER(l_stmt_3),'WHERE') > 0 OR INSTR(UPPER(l_stmt_4),'WHERE') > 0
      OR INSTR(UPPER(l_stmt_5),'WHERE') > 0 OR INSTR(UPPER(l_stmt_6),'WHERE') > 0
      OR INSTR(UPPER(l_stmt_7),'WHERE') > 0 OR INSTR(UPPER(l_stmt_8),'WHERE') > 0 THEN
        FND_DSQL.add_text(' AND ');
        FND_DSQL.add_text(l_cond_id);
        FND_DSQL.add_text(' = ');
        FND_DSQL.add_bind(p_attr_value);
      ELSE -- no WHERE clause, need to add WHERE
        FND_DSQL.add_text(' WHERE ');
        FND_DSQL.add_text(l_cond_id);
        FND_DSQL.add_text(' = ');
        FND_DSQL.add_bind(p_attr_value);
      END IF;
    END IF;
    l_stmt := FND_DSQL.get_text(FALSE);
  ELSE
    l_stmt := NULL;
  END IF;

  RETURN l_stmt;
END get_sql;


--------------------------------------------------------------------
-- PROCEDURE
--   denorm_vo_products
--
-- PURPOSE
--   Refreshes volume offer product denorm table ozf_vo_products_temp.
--
-- PARAMETERS
--   p_offer_id: identifier of the offer.
--
-- DESCRIPTION
--   This procedure calls get_sql, builds SQL statment for product.
----------------------------------------------------------------------
PROCEDURE denorm_vo_products(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2,
  p_commit           IN  VARCHAR2,
  p_offer_id         IN  NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_product_stmt     OUT NOCOPY VARCHAR2
)
IS

  CURSOR c_pbh_lines IS
  SELECT offer_discount_line_id
  FROM   ozf_offer_discount_lines
  WHERE  offer_id = p_offer_id
  AND    tier_type = 'PBH'
  AND    tier_level = 'HEADER';

  CURSOR c_pbh_lines_count IS
  SELECT COUNT(*)
  FROM   ozf_offer_discount_lines
  WHERE  offer_id = p_offer_id
  AND    tier_type = 'PBH'
  AND    tier_level = 'HEADER';

  CURSOR c_products(p_pbh_line_id NUMBER, p_excluder_flag VARCHAR2) IS
  SELECT product_context,
         product_attribute,
         product_attr_value
  FROM   ozf_offer_discount_products
  WHERE  offer_id = p_offer_id
  AND    offer_discount_line_id = p_pbh_line_id
  AND    excluder_flag = p_excluder_flag;


  CURSOR c_products_count(p_pbh_line_id NUMBER, p_excluder_flag VARCHAR2) IS
  SELECT COUNT(*)
  FROM   ozf_offer_discount_products
  WHERE  offer_id = p_offer_id
  AND    offer_discount_line_id = p_pbh_line_id
  AND    excluder_flag = p_excluder_flag;

  l_api_version     CONSTANT NUMBER       := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'denorm_vo_products';
  l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

  l_stmt_temp       VARCHAR2(32000) := NULL;
/*
  l_pbh_lines_count NUMBER;
  l_products_count  NUMBER;
  l_pbh_index       NUMBER;
  l_prod_index      NUMBER;
  l_excl_index      NUMBER;
  l_no_query_flag   VARCHAR2(1) := 'N';*/
  l_denorm_csr            NUMBER;
  l_ignore                NUMBER;
  l_stmt_denorm           VARCHAR2(32000) := NULL;

BEGIN
  SAVEPOINT denorm_vo_products;
  ozf_utility_pvt.debug_message(l_full_name || ': start denorm_vo_products');

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

  FOR l_pbh_line IN c_pbh_lines LOOP
    FOR l_product IN c_products(l_pbh_line.offer_discount_line_id, 'N') LOOP
      l_stmt_temp := NULL;
      FND_DSQL.init;
      FND_DSQL.add_text('INSERT INTO ozf_vo_products_temp(');
      FND_DSQL.add_text('vo_products_temp_id,creation_date,created_by,last_update_date,');
      FND_DSQL.add_text('last_updated_by,last_update_login,');
      FND_DSQL.add_text('product_id,product_type) ');
      FND_DSQL.add_text('SELECT ozf_vo_products_temp_s.NEXTVAL,SYSDATE,FND_GLOBAL.user_id,SYSDATE,');
      FND_DSQL.add_text('FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id,');
      FND_DSQL.add_text('product_id,product_type');
      FND_DSQL.add_text(' FROM (');

      l_stmt_temp := get_sql(p_context    => l_product.product_context
                            ,p_attribute  => l_product.product_attribute
                            ,p_attr_value => l_product.product_attr_value
                            );

      FND_DSQL.add_text(')');

      IF l_stmt_temp IS NULL THEN
        EXIT;
      END IF;

      l_denorm_csr := DBMS_SQL.open_cursor;
      FND_DSQL.set_cursor(l_denorm_csr);
      l_stmt_denorm := FND_DSQL.get_text(FALSE);

      DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
      FND_DSQL.do_binds;
      l_ignore := DBMS_SQL.execute(l_denorm_csr);
      dbms_sql.close_cursor(l_denorm_csr);
    END LOOP;
/*
    OPEN  c_products_count(l_pbh_line.offer_discount_line_id, 'Y');
    FETCH c_products_count INTO l_products_count;
    CLOSE c_products_count;

    l_excl_index := 1;

    IF l_products_count > 0 THEN -- start: sql for exclusions
      FND_DSQL.add_text(' MINUS (');

      FOR l_product IN c_products(l_pbh_line.offer_discount_line_id, 'Y') LOOP
        l_stmt_temp := NULL;

        l_stmt_temp := get_sql(p_context    => l_product.product_context
                              ,p_attribute  => l_product.product_attribute
                              ,p_attr_value => l_product.product_attr_value
                              );

        IF l_stmt_temp IS NULL THEN
          l_no_query_flag := 'Y';
        ELSE
          IF l_excl_index < l_products_count THEN
            FND_DSQL.add_text(' UNION ');
            l_excl_index := l_excl_index + 1;
          END IF;
        END IF;
      END LOOP;

      FND_DSQL.add_text(')');
    END IF; -- end: sql for exclusions

    FND_DSQL.add_text(')');

    IF l_pbh_index < l_pbh_lines_count THEN
      FND_DSQL.add_text(' UNION ');
      l_pbh_index := l_pbh_index + 1;
    END IF;*/
  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO denorm_vo_products;
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_VO_PROD_STMT_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      l_stmt_denorm := FND_DSQL.get_text(TRUE);
  ozf_utility_pvt.debug_message (SUBSTR(l_stmt_denorm, 1, 250));
  ozf_utility_pvt.debug_message (SUBSTR(l_stmt_denorm, 251, 250));
  ozf_utility_pvt.debug_message (SUBSTR(l_stmt_denorm, 501, 250));
  ozf_utility_pvt.debug_message (SUBSTR(l_stmt_denorm, 751, 250));

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END denorm_vo_products;

PROCEDURE check_dup_prod(
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  p_offer_id      IN  NUMBER
)
IS
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'check_dup_prod';
  l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_denorm_csr            NUMBER;
  l_ignore                NUMBER;
  l_stmt_denorm           VARCHAR2(32000) := NULL;
  l_stmt_product          VARCHAR2(32000) := NULL;
  l_duplicate_prod_exists VARCHAR2(1) := 'N';

  CURSOR c_duplicate_prod_exists IS
  SELECT 'Y' FROM DUAL
  WHERE EXISTS(
               SELECT 1
               FROM   ozf_vo_products_temp
               HAVING COUNT(product_id) > 1
               GROUP BY product_id
              );
BEGIN
  DELETE FROM ozf_vo_products_temp;

  SAVEPOINT check_dup_prod;

  x_return_status := Fnd_Api.g_ret_sts_success;

  ozf_utility_pvt.debug_message(l_full_name || ': Start check_dup_prod' || p_offer_id);

--  ERRBUF := NULL;
--  RETCODE := '0';

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     l_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
/*
  FND_DSQL.init;
  FND_DSQL.add_text('INSERT INTO ozf_vo_products_temp(');
  FND_DSQL.add_text('vo_products_temp_id,creation_date,created_by,last_update_date,');
  FND_DSQL.add_text('last_updated_by,last_update_login,');
  FND_DSQL.add_text('product_id,product_type) ');
  FND_DSQL.add_text('SELECT ozf_vo_products_temp_s.NEXTVAL,SYSDATE,FND_GLOBAL.user_id,SYSDATE,');
  FND_DSQL.add_text('FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id,');
  FND_DSQL.add_text('product_id,product_type');
  FND_DSQL.add_text(' FROM (');
*/
  denorm_vo_products(p_api_version      => l_api_version,
                     p_init_msg_list    => FND_API.g_true,
                     p_commit           => FND_API.g_false,
                     p_offer_id         => p_offer_id,
                     x_return_status    => x_return_status,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => x_msg_data,
                     x_product_stmt     => l_stmt_product);
/*
  FND_DSQL.add_text(')');

  ozf_utility_pvt.debug_message ('Denorm STMT status: ' || x_return_status);

  l_denorm_csr := DBMS_SQL.open_cursor;
  FND_DSQL.set_cursor(l_denorm_csr);
  l_stmt_denorm := FND_DSQL.get_text(FALSE);
ozf_utility_pvt.debug_message ('start STMT--------------------------------------------');
  ozf_utility_pvt.debug_message (SUBSTR(l_stmt_denorm, 1, 250));
  ozf_utility_pvt.debug_message (SUBSTR(l_stmt_denorm, 251, 250));
  ozf_utility_pvt.debug_message (SUBSTR(l_stmt_denorm, 501, 250));
  ozf_utility_pvt.debug_message (SUBSTR(l_stmt_denorm, 751, 250));
ozf_utility_pvt.debug_message ('end STMT--------------------------------------------');
  IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
  FND_DSQL.do_binds;
  l_ignore := DBMS_SQL.execute(l_denorm_csr);
  dbms_sql.close_cursor(l_denorm_csr);
*/
  OPEN  c_duplicate_prod_exists;
  FETCH c_duplicate_prod_exists INTO l_duplicate_prod_exists;
  CLOSE c_duplicate_prod_exists;

  IF l_duplicate_prod_exists = 'Y' THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_DUP_PROD_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  EXCEPTION
/*    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO check_dup_prod;
      ozf_utility_pvt.debug_message('Unexpected Error: ' || SQLERRM);
      ozf_utility_pvt.debug_message('Denorm STMT: ' || l_stmt_denorm);
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      ERRBUF := l_msg_data;
      RETCODE := 2;

    WHEN OTHERS THEN
      ROLLBACK TO check_dup_prod;
      ozf_utility_pvt.debug_message('Other Error: ' || SQLERRM);
      ozf_utility_pvt.debug_message('Denorm STMT: ' || l_stmt_denorm);
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      ERRBUF := SQLERRM || ' - ' || l_stmt_denorm;
      RETCODE := sqlcode;
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO check_dup_prod;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO check_dup_prod;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO check_dup_prod;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data);
END check_dup_prod;

END OZF_CHECK_DUP_PROD_PVT;

/
