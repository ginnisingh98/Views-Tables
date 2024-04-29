--------------------------------------------------------
--  DDL for Package Body ICX_CAT_SQE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_SQE_PVT" AS
/* $Header: ICXVSQEB.pls 120.5.12010000.5 2014/01/21 11:02:58 uchennam ship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'ICX_CAT_SQE_PVT';

-- procedure to create sqes for a given content zone
-- this constructs the intermedia expressions for the content zone, puts
-- them into sqes and returns the sqe sequence
-- we create three expressions, one for each of the allowed item types PURCHASE, INTERNAL, BOTH
-- if any of the expressions is too long, it is an error and x_return_status
-- will be set to 'E'
PROCEDURE create_sqes_for_zone
(
  p_content_zone_id IN NUMBER,
  p_supplier_attr_action_flag IN VARCHAR2,
  p_supplier_ids IN ICX_TBL_NUMBER,
  p_supplier_site_ids IN ICX_TBL_NUMBER,
  p_items_without_supplier_flag IN VARCHAR2,
  p_category_attr_action_flag IN VARCHAR2,
  p_category_ids IN ICX_TBL_NUMBER,
  p_items_without_shop_catg_flag IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_sqe_sequence IN OUT NOCOPY NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'create_sqes_for_zone';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_int_intermedia_expression VARCHAR2(32000);
  l_purch_intermedia_expression VARCHAR2(32000);
  l_both_intermedia_expression VARCHAR2(32000);
  l_int_sqe_name VARCHAR2(15);
  l_purch_sqe_name VARCHAR2(15);
  l_both_sqe_name VARCHAR2(15);
  l_sqe_sequence NUMBER;
  l_db_version NUMBER := ICX_POR_EXT_UTL.getDatabaseVersion; --18108729
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting create_sqes_for_zone: ' || p_content_zone_id;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;
  l_err_loc := 100;

  -- now we will construct the intermedia expressions for the zone
  construct_exprs_for_zone(p_supplier_attr_action_flag, p_supplier_ids,
    p_supplier_site_ids, p_items_without_supplier_flag, p_category_attr_action_flag,
    p_category_ids, p_items_without_shop_catg_flag, l_int_intermedia_expression,
    l_purch_intermedia_expression, l_both_intermedia_expression);
  l_err_loc := 300;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Database version ' || l_db_version;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  -- 18108729 ER to relax the condition on limination of database is 11g

  -- check to see if the intermedia expression is > 2000 bytes
  IF (l_db_version < 11.0 AND (length(l_int_intermedia_expression) > 2000 OR
      length(l_purch_intermedia_expression) > 2000 OR
      length(l_both_intermedia_expression) > 2000)
      ) THEN
    l_err_loc := 400;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_string := 'One of the intermedia expressions for this zone is > 2000 bytes.';
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
    END IF;
    -- length exceeded, cannot create sqes, return status is error(E)
    x_return_status := 'E';
  ELSE
    l_err_loc := 500;
    -- we can fit the expressions into sqes, go ahead and create the sqes
    -- for this we first get the next sequence
    SELECT icx_cat_sqe_name_s.nextval
    INTO l_sqe_sequence
    FROM dual;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_string := 'New sqe sequence is: ' || l_sqe_sequence;
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
    END IF;
    l_err_loc := 600;
    -- and form the sqe names
    l_int_sqe_name := 'icxzi' || l_sqe_sequence;
    l_purch_sqe_name := 'icxzp' || l_sqe_sequence;
    l_both_sqe_name := 'icxzb' || l_sqe_sequence;

    l_err_loc := 700;
    --18108729 call the clob related api to store the sqe_query if the database is 11g or higher
    -- now store the sqes
    IF l_db_version < 11.0 THEN
	    ctx_query.store_sqe(l_int_sqe_name, l_int_intermedia_expression);
	    ctx_query.store_sqe(l_purch_sqe_name, l_purch_intermedia_expression);
	    ctx_query.store_sqe(l_both_sqe_name, l_both_intermedia_expression);
    ELSE
 	    ctx_query.STORE_SQE_CLOB_QUERY(l_int_sqe_name, to_clob(l_int_intermedia_expression));
	    ctx_query.STORE_SQE_CLOB_QUERY(l_purch_sqe_name,to_clob( l_purch_intermedia_expression));
	    ctx_query.STORE_SQE_CLOB_QUERY(l_both_sqe_name, to_clob(l_both_intermedia_expression));
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_string := 'Finished Storing sqes';
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
    END IF;

    l_err_loc := 800;
    -- now if the original content zone had an sqe_sequence, store it in deleted sqes
    IF (x_sqe_sequence IS NOT NULL) THEN
      l_err_loc := 850;
      INSERT INTO icx_cat_deleted_sqes (sqe_sequence, created_by, creation_date,
        last_updated_by, last_update_date, last_update_login)
      VALUES (x_sqe_sequence,  fnd_global.user_id, sysdate, fnd_global.user_id,
          sysdate, fnd_global.login_id);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_string := 'Inserted old sqe sequence into deleted sqes. Old sqe sequence: ' || x_sqe_sequence;
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
      END IF;
    END IF;

    l_err_loc := 900;
    x_sqe_sequence := l_sqe_sequence;

    l_err_loc := 950;
    -- finally we will purge the deleted sqes if any
    purge_deleted_sqes;

    l_err_loc := 1000;
    -- success!
    x_return_status := 'S';
  END IF;

  l_err_loc := 1100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End create_sqes_for_zone: ' || p_content_zone_id || ' return status is ' || x_return_status;
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SQE_PVT.create_sqes_for_zone(' ||
     l_err_loc || '), ' || SQLERRM);
END create_sqes_for_zone;


-- procedure to combine three expressions with the '&' operator
-- depending on which are not null
PROCEDURE combine_exprs
(
  p_expr1 IN VARCHAR2,
  p_expr2 IN VARCHAR2,
  p_expr3 IN VARCHAR2,
  x_result_expr OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'combine_exprs';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_first PLS_INTEGER;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting combine_exprs: expr1 = ' || p_expr1 || ' expr2 = ' || p_expr2
      || ' expr3 = ' || p_expr3;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;
  l_err_loc := 100;
  -- first set first to 1 i.e true
  l_first := 1;

  IF (p_expr1 IS NOT NULL) THEN
    IF (l_first = 1) THEN
      l_first := 0;
      x_result_expr := '(' || p_expr1 || ')';
    ELSE
      x_result_expr := x_result_expr || ' & (' || p_expr1 || ')';
    END IF;
  END IF;

  l_err_loc := 200;
  IF (p_expr2 IS NOT NULL) THEN
    IF (l_first = 1) THEN
      l_first := 0;
      x_result_expr := '(' || p_expr2 || ')';
    ELSE
      x_result_expr := x_result_expr || ' & (' || p_expr2 || ')';
    END IF;
  END IF;

  l_err_loc := 300;
  IF (p_expr3 IS NOT NULL) THEN
    IF (l_first = 1) THEN
      l_first := 0;
      x_result_expr := '(' || p_expr3 || ')';
    ELSE
      x_result_expr := x_result_expr || ' & (' || p_expr3 || ')';
    END IF;
  END IF;

  l_err_loc := 400;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End combine_exprs: result expr is: ' || x_result_expr;
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SQE_PVT.combine_exprs(' ||
     l_err_loc || '), ' || SQLERRM);
END combine_exprs;

-- procedure to construct the intermedia expressions for a given zone
-- takes in all the required parameters and returns the intermedia expressions
-- it returns one intermedia expression for internal only items
-- one for purchasable only items and one for both
PROCEDURE construct_exprs_for_zone
(
  p_supplier_attr_action_flag IN VARCHAR2,
  p_supplier_ids IN ICX_TBL_NUMBER,
  p_supplier_site_ids IN ICX_TBL_NUMBER,
  p_items_without_supplier_flag IN VARCHAR2,
  p_category_attr_action_flag IN VARCHAR2,
  p_category_ids IN ICX_TBL_NUMBER,
  p_items_without_shop_catg_flag IN VARCHAR2,
  x_int_intermedia_expression OUT NOCOPY VARCHAR2,
  x_purch_intermedia_expression OUT NOCOPY VARCHAR2,
  x_both_intermedia_expression OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'construct_exprs_for_zone';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_category_expr VARCHAR2(32000);
  l_supplier_and_site_expr VARCHAR2(32000);
  l_purch_item_type_expr VARCHAR2(50);
  l_int_item_type_expr VARCHAR2(50);
  l_invalid_item_type_expr VARCHAR2(50);
  l_item_type_expr VARCHAR2(2000);
  l_everything_expr VARCHAR2(2000);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting construct_exprs_for_zone';
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;
  l_err_loc := 100;

  -- first we initialize the fixed sqes
  l_purch_item_type_expr := '(''BOTH'',''PURCHASE'') within item_type';
  l_int_item_type_expr := '(''BOTH'',''INTERNAL'') within item_type';
  l_invalid_item_type_expr := '(''INVALID_ITEM_TYPE'') within item_type';
  l_everything_expr := '((''BOTH'',''INTERNAL'',''PURCHASE'') within item_type)';
  x_int_intermedia_expression := '';
  x_purch_intermedia_expression := '';
  x_both_intermedia_expression := '';

  l_err_loc := 200;
  -- then construct intermedia expression for supplier and site
  construct_supp_and_site_expr(p_supplier_attr_action_flag,
    p_supplier_ids, p_supplier_site_ids, p_items_without_supplier_flag,
    l_supplier_and_site_expr);

  l_err_loc := 300;
  -- next construct intermedia expression for category
  construct_category_expr(p_category_attr_action_flag,
    p_category_ids, p_items_without_shop_catg_flag, l_category_expr);

  l_err_loc := 400;
  -- now we will combine the expressions for the three cases

  -- first we will construct the expression for internal
  IF (p_items_without_supplier_flag = 'Y') THEN
    l_err_loc := 500;
    l_item_type_expr := l_int_item_type_expr;
  ELSE
    l_err_loc := 600;
    l_item_type_expr := l_invalid_item_type_expr;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Item Type expr for Internal: ' || l_item_type_expr;
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
  END IF;
  l_err_loc := 700;
  -- now we combine the expressions for internal
  -- note that we pass '' for supplier since this is not needed
  combine_exprs('', l_category_expr, l_item_type_expr, x_int_intermedia_expression);

  l_err_loc := 750;
  -- we cannot have the intermedia expression as null so if it is null we make it everything
  IF (x_int_intermedia_expression IS NULL) THEN
    x_int_intermedia_expression := l_everything_expr;
  END IF;

  l_err_loc := 800;
  -- now we construct the expression for purchase
  IF (p_supplier_attr_action_flag = 'EXCLUDE_ALL') THEN
    l_err_loc := 900;
    IF (p_items_without_supplier_flag = 'Y') THEN
      l_err_loc := 1000;
      l_item_type_expr := l_purch_item_type_expr;
    ELSE
      l_err_loc := 1100;
      l_item_type_expr := l_invalid_item_type_expr;
    END IF;
  ELSE
    l_err_loc := 1200;
    IF (p_items_without_supplier_flag = 'Y') THEN
      l_err_loc := 1300;
      l_item_type_expr := l_purch_item_type_expr;
    ELSE
      l_err_loc := 1400;
      l_item_type_expr := '';
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Item Type expr for Purchase: ' || l_item_type_expr;
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
  END IF;

  l_err_loc := 1500;
  -- now we combine the expressions for purchase
  combine_exprs(l_supplier_and_site_expr, l_category_expr, l_item_type_expr, x_purch_intermedia_expression);

  l_err_loc := 1600;
  -- we cannot have the intermedia expression as null so if it is null we make it everything
  IF (x_purch_intermedia_expression IS NULL) THEN
    l_err_loc := 1700;
    x_purch_intermedia_expression := l_everything_expr;
  END IF;

  l_err_loc := 1800;
  -- now we construct the expression for both
  IF (p_supplier_attr_action_flag = 'EXCLUDE_ALL') THEN
    l_err_loc := 1900;
    IF (p_items_without_supplier_flag = 'Y') THEN
      l_err_loc := 2000;
      l_item_type_expr := '';
    ELSE
      l_err_loc := 2100;
      l_item_type_expr := l_invalid_item_type_expr;
    END IF;
  ELSE
    l_err_loc := 2200;
    l_item_type_expr := '';
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Item Type expr for both: ' || l_item_type_expr;
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
  END IF;
  l_err_loc := 2500;
  -- now we combine the expressions for purchase
  combine_exprs(l_supplier_and_site_expr, l_category_expr, l_item_type_expr, x_both_intermedia_expression);

  l_err_loc := 2600;
  -- we cannot have the intermedia expression as null so if it is null we make it everything
  IF (x_both_intermedia_expression IS NULL) THEN
    l_err_loc := 2700;
    x_both_intermedia_expression := l_everything_expr;
  END IF;

  l_err_loc := 2800;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End construct_exprs_for_zone: Internal String:'
           || x_int_intermedia_expression ;
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
    l_log_string := ' Purchase String: ' || x_purch_intermedia_expression ;
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
    l_log_string :=  ' Both String: ' || x_both_intermedia_expression;
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SQE_PVT.construct_exprs_for_zone(' ||
     l_err_loc || '), ' || SQLERRM);
END construct_exprs_for_zone;

-- procedure to constuct the supplier and site expression for a given zone
-- takes in the required parameters and returns the supplier and site expression
PROCEDURE construct_supp_and_site_expr
(
  p_supplier_attr_action_flag IN VARCHAR2,
  p_supplier_ids IN ICX_TBL_NUMBER,
  p_supplier_site_ids IN ICX_TBL_NUMBER,
  p_items_without_supplier_flag IN VARCHAR2,
  x_supplier_and_site_expr OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'construct_supp_and_site_expr';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_supplier_id_list VARCHAR2(32000);
  l_supplier_site_id_list VARCHAR2(32000);
  l_exclude_expr VARCHAR2(100);
  l_supplier_and_site_expr VARCHAR2(32000);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting construct_supp_and_site_expr';
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;
  l_err_loc := 100;

  -- initialize the expressions to ''
  l_supplier_id_list := '';
  l_supplier_site_id_list := '';
  x_supplier_and_site_expr := '';
  l_exclude_expr := '((''BOTH'',''INTERNAL'',''PURCHASE'') within item_type)';

  l_err_loc := 200;
  -- we only need the supplier and site expr
  -- if it is either include some or exclude some
  IF (p_supplier_attr_action_flag in ('INCLUDE', 'EXCLUDE')) THEN
    l_err_loc := 300;
    -- now loop through the lists and construct the expr
    FOR i in 1..p_supplier_ids.COUNT LOOP
      l_err_loc := 400;
      IF (p_supplier_site_ids(i) IS NULL) THEN
        l_err_loc := 500;
        -- supplier site not provided append supplier_id to the supplier id list
        IF (l_supplier_id_list IS NULL) THEN
          l_err_loc := 600;
          l_supplier_id_list := p_supplier_ids(i);
        ELSE
          l_err_loc := 700;
          l_supplier_id_list := l_supplier_id_list || ',' || p_supplier_ids(i);
        END IF;
      ELSE
        l_err_loc := 800;
        -- supplier site id provided so we just use the site id and append to its list
        IF (l_supplier_site_id_list IS NULL) THEN
          l_err_loc := 900;
          l_supplier_site_id_list := p_supplier_site_ids(i);
        ELSE
          l_err_loc := 1000;
          l_supplier_site_id_list := l_supplier_site_id_list || ',' || p_supplier_site_ids(i);
        END IF;
      END IF;
    END LOOP;
  END IF;

  l_err_loc := 1100;
  IF (p_supplier_attr_action_flag = 'INCLUDE_ALL') THEN
    IF (p_items_without_supplier_flag = 'N') THEN
      -- if we include all but don't check the checkbox then we want to exclude -2
      l_err_loc := 1200;
      l_supplier_id_list := '{-2}';
      l_err_loc := 1300;
      -- supplier id list is -2 here and supplier site id list is null
      x_supplier_and_site_expr := l_exclude_expr || ' ~ ((' || l_supplier_id_list || ') within supid)';
    END IF;
  END IF;

  l_err_loc := 1400;
  IF (p_supplier_attr_action_flag = 'INCLUDE') THEN
    l_err_loc := 1500;
    IF (p_items_without_supplier_flag = 'Y') THEN
      -- if we include some and check the checkbox then we want to include -2
      IF (l_supplier_id_list IS NULL) THEN
        l_err_loc := 1600;
        l_supplier_id_list := '{-2}';
      ELSE
        l_err_loc := 1700;
        l_supplier_id_list := l_supplier_id_list || ',{-2}';
      END IF;
    END IF;

    l_err_loc := 1800;
    IF (l_supplier_site_id_list IS NULL) THEN
      l_err_loc := 1900;
      -- in this case we will have a supplier_id_list
      x_supplier_and_site_expr := '(' || l_supplier_id_list || ') within supid';
    ELSE
      -- here we may or may not have a supplier_id_list
      IF (l_supplier_id_list IS NULL) THEN
        l_err_loc := 1950;
        x_supplier_and_site_expr := '(' || l_supplier_site_id_list || ') within siteid';
      ELSE
        l_err_loc := 2000;
        x_supplier_and_site_expr := '((' || l_supplier_id_list || ') within supid),(('
          || l_supplier_site_id_list || ') within siteid)';
      END IF;
    END IF;

  END IF;

  l_err_loc := 2100;
  IF (p_supplier_attr_action_flag = 'EXCLUDE') THEN
    IF (p_items_without_supplier_flag = 'N') THEN
      -- now if it is exclude and we don't check the checkbox then we want to exclude -2
      l_err_loc := 2200;
      IF (l_supplier_id_list IS NULL) THEN
          l_err_loc := 2300;
        l_supplier_id_list := '{-2}';
      ELSE
        l_err_loc := 2400;
        l_supplier_id_list := l_supplier_id_list || ',{-2}';
      END IF;
    END IF;

    l_err_loc := 2500;
    IF (l_supplier_site_id_list IS NULL) THEN
      -- in this case we will have a supplier_id_list
      l_err_loc := 2600;
      x_supplier_and_site_expr := '(' || l_supplier_id_list || ') within supid';
    ELSE
      -- here we may or may not have a supplier_id_list
      IF (l_supplier_id_list IS NULL) THEN
        l_err_loc := 2650;
        x_supplier_and_site_expr := '(' || l_supplier_site_id_list || ') within siteid';
      ELSE
        l_err_loc := 2700;
        x_supplier_and_site_expr := '((' || l_supplier_id_list || ') within supid),(('
          || l_supplier_site_id_list || ') within siteid)';
      END IF;
    END IF;

    l_err_loc := 2800;
    -- finally we negate it using the fixed exclude expr
    x_supplier_and_site_expr := l_exclude_expr || ' ~ (' || x_supplier_and_site_expr || ')';
  END IF;

  l_err_loc := 2900;
  IF (p_supplier_attr_action_flag = 'EXCLUDE_ALL') THEN
    IF (p_items_without_supplier_flag = 'Y') THEN
      -- if we exclude all and check the checkbox then we want to include -2
      l_err_loc := 3000;
      l_supplier_id_list := '{-2}';
      l_err_loc := 3100;
      -- supplier id list is -2 here and supplier site id list is null
      x_supplier_and_site_expr := '(' || l_supplier_id_list || ') within supid';
    END IF;
  END IF;

  l_err_loc := 3200;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End construct_supp_and_site_expr: Supplier and site expr is:'
        || x_supplier_and_site_expr;
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SQE_PVT.construct_supp_and_site_expr(' ||
     l_err_loc || '), ' || SQLERRM);
END construct_supp_and_site_expr;


-- procedure to constuct the category expression for a given zone
-- takes in the required parameters and returns the category expression
PROCEDURE construct_category_expr
(
  p_category_attr_action_flag IN VARCHAR2,
  p_category_ids IN ICX_TBL_NUMBER,
  p_items_without_shop_catg_flag IN VARCHAR2,
  x_category_expr OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'construct_category_expr';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_exclude_expr VARCHAR2(100);
  l_category_ids ICX_TBL_NUMBER;
  l_category_id_list VARCHAR2(32000);
  l_current_category_id_list VARCHAR2(32000);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting construct_category_expr';
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;
  l_err_loc := 100;
   -- initialize the expressions to ''
  l_category_id_list := '';
  x_category_expr := '';
  l_exclude_expr := '((''BOTH'',''INTERNAL'',''PURCHASE'') within item_type)';

  l_err_loc := 200;
  IF (p_category_attr_action_flag = 'INCLUDE_ALL') THEN
    l_err_loc := 300;
    IF (p_items_without_shop_catg_flag IS NULL OR p_items_without_shop_catg_flag = 'N') THEN
      l_err_loc := 400;
      -- we need to exclude the -2 categories since the checkbox is not checked and it is
      -- include all
      x_category_expr := l_exclude_expr || ' ~ ({-2} within ipcatid)';
    END IF;
  ELSE
    l_err_loc := 500;
    -- now loop through the list and construct the category id list
    FOR i in 1..p_category_ids.COUNT LOOP
      l_err_loc := 600;
      --reset value
      -- bug no 13543091
      l_current_category_id_list := NULL;
      -- now for each category, we have to either get the category itself (if it is an item category)
      -- or get the list of item categories under it
      SELECT distinct rt_category_id
      BULK COLLECT INTO l_category_ids
      FROM icx_cat_categories_tl
      WHERE type = 2
      AND rt_category_id in (SELECT child_category_id
                             FROM icx_cat_browse_trees
                             START WITH parent_category_id = p_category_ids(i)
                             CONNECT BY NOCYCLE PRIOR child_category_id = parent_category_id
                             UNION ALL
                             SELECT p_category_ids(i)
                             FROM dual);

      l_err_loc := 650;
      -- now construct the list for that browsing category or for item category it is just itself
      FOR j in 1..l_category_ids.COUNT LOOP
        IF (j = 1) THEN
          l_err_loc := 700;
           -- if it is the first one then the list is just that
          l_current_category_id_list := l_category_ids(j);
        ELSE
          l_err_loc := 750;
           -- else we append it to the previous one
          l_current_category_id_list := l_current_category_id_list || ',' || l_category_ids(j);
        END IF;
      END LOOP;

      -- now we append the current list to the full list
      l_err_loc := 770;
      -- bug no 13543091
      -- bug no 13542211
      IF (l_category_id_list IS NULL OR l_category_id_list = '') THEN
        l_err_loc := 800;
         -- if it is the first one then the list is just that
        l_category_id_list := l_current_category_id_list;
      ELSE
        l_err_loc := 850;
         -- else we append it to the previous one
        IF( l_current_category_id_list IS NOT NULL) THEN
        l_category_id_list := l_category_id_list || ',' || l_current_category_id_list;
        END IF;
      END IF;
    END LOOP;

    l_err_loc := 900;
    IF (p_category_attr_action_flag = 'INCLUDE') THEN
      l_err_loc := 1000;
      IF (p_items_without_shop_catg_flag = 'Y') THEN
        l_err_loc := 1100;
        -- if it is include and we have checked the checkbox, then we include -2 as well
        IF (l_category_id_list IS NULL) THEN
          l_category_id_list := '{-2}';
        ELSE
          l_category_id_list := l_category_id_list || ',{-2}';
        END IF;
      END IF;
      l_err_loc := 1200;
      -- if category id list is empty then that means we exclude everything
      -- so we put some invalid value into the category id expr, so we put -1
      IF (l_category_id_list IS NULL) THEN
        l_err_loc := 1230;
        l_category_id_list := '{-1}';
      END IF;
      l_err_loc := 1250;
      x_category_expr := '(' || l_category_id_list || ') within ipcatid';
    END IF;

    l_err_loc := 1300;
    IF (p_category_attr_action_flag = 'EXCLUDE') THEN
      l_err_loc := 1400;
      IF (p_items_without_shop_catg_flag IS NULL OR p_items_without_shop_catg_flag = 'N') THEN
        l_err_loc := 1500;
        -- if it is exclude and we have not checked the checkbox, then we exclude -2 as well
        IF (l_category_id_list IS NULL) THEN
          l_category_id_list := '{-2}';
        ELSE
          l_category_id_list := l_category_id_list || ',{-2}';
        END IF;
      END IF;
      l_err_loc := 1600;
      -- if category id list is empty then that means we include everything
      -- so we leave the category expr as null
      IF (l_category_id_list IS NULL) THEN
        l_err_loc := 1630;
        x_category_expr := '';
      ELSE
        l_err_loc := 1650;
        x_category_expr := l_exclude_expr || ' ~ ((' || l_category_id_list || ') within ipcatid)';
      END IF;
    END IF;
    l_err_loc := 1700;
  END IF;
  l_err_loc := 1800;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End construct_category_expr: Category expr is:'
        || x_category_expr;
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SQE_PVT.construct_category_expr(' ||
     l_err_loc || '), ' || SQLERRM);
END construct_category_expr;

-- procedure to purge the deleted sqes
-- this purges all sqes that have been deleted more than a day ago
PROCEDURE purge_deleted_sqes
IS
  l_api_name CONSTANT VARCHAR2(30) := 'purge_deleted_sqes';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_sqe_sequences ICX_TBL_NUMBER;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting purge_deleted_sqes';
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 100;

  -- first select all the sqe sequences that have been deleted more
  -- than a day ago
  SELECT sqe_sequence
  BULK COLLECT INTO l_sqe_sequences
  FROM icx_cat_deleted_sqes
  WHERE creation_date < sysdate - 1;

  l_err_loc := 200;

  -- now delete the three sqes for each of them
  -- we put this in a separate begin end block
  -- and catch the exception since the remove sqe automatically commits
  -- so we may have removed the sqes but not committed the delete from the
  -- deleted sqes table. in this case the next time around we will try to remove
  -- the same sqes which will throw an exception. to avoid this we catch the exception
  -- and do nothing
  BEGIN
    FOR i in 1..l_sqe_sequences.COUNT LOOP
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_string := 'Removing sqes for sqe_sequence: ' || l_sqe_sequences(i);
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
      END IF;
      l_err_loc := 300;
      ctx_query.remove_sqe('icxzi' || l_sqe_sequences(i));
      ctx_query.remove_sqe('icxzp' || l_sqe_sequences(i));
      ctx_query.remove_sqe('icxzb' || l_sqe_sequences(i));
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  l_err_loc := 400;
  -- now remove the sqe sequences from the table
  FORALL i in 1..l_sqe_sequences.COUNT
    DELETE FROM icx_cat_deleted_sqes
    WHERE sqe_sequence = l_sqe_sequences(i);

  l_err_loc := 500;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End purge_deleted_sqes';
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SQE_PVT.purge_deleted_sqes(' ||
     l_err_loc || '), ' || SQLERRM);
END purge_deleted_sqes;

-- procedure to sync sqes for all content zones
-- called for hierarchy changes from a concurrent program
-- or from the schema loader
-- this will recreate sqes for all the content zones
-- if some content zones have errors since the expression is too long
-- the job will be errored out with a message specifying which zones failed
-- the successful zones will however be updated
PROCEDURE sync_sqes_hier_change_internal
(
  x_return_status OUT NOCOPY VARCHAR2,
  x_errored_zone_name_list OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'sync_sqes_hier_change_internal';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_content_zone_ids ICX_TBL_NUMBER;
  l_content_zone_names ICX_TBL_VARCHAR240;
  l_supplier_attr_action_flags ICX_TBL_VARCHAR40;
  l_supplier_ids ICX_TBL_NUMBER;
  l_supplier_site_ids ICX_TBL_NUMBER;
  l_items_without_supplier_flags ICX_TBL_FLAG;
  l_category_attr_action_flags ICX_TBL_VARCHAR40;
  l_category_ids ICX_TBL_NUMBER;
  l_items_without_shop_cat_flags ICX_TBL_FLAG;
  l_sqe_sequences ICX_TBL_NUMBER;
  l_return_status VARCHAR2(1);
  l_current_sqe_sequence NUMBER;
  l_first_errored_zone PLS_INTEGER;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting sync_sqes_hier_change_internal';
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;
  l_first_errored_zone := 1;
  x_return_status := 'S';

  l_err_loc := 100;
  -- first query all the content zones for the basic information
  -- we only query those that are local
  -- and have either include or exclude for category
  SELECT zones.zone_id, zonestl.name, supplier_attribute_action_flag, category_attribute_action_flag,
    items_without_supplier_flag, items_without_shop_catg_flag, sqe_sequence
  BULK COLLECT INTO l_content_zone_ids, l_content_zone_names, l_supplier_attr_action_flags,
    l_category_attr_action_flags, l_items_without_supplier_flags, l_items_without_shop_cat_flags, l_sqe_sequences
  FROM icx_cat_content_zones_b zones, icx_cat_content_zones_tl zonestl
  WHERE zones.type = 'LOCAL'
  AND zones.category_attribute_action_flag IN ('INCLUDE', 'EXCLUDE')
  AND zones.zone_id = zonestl.zone_id
  AND zonestl.language = USERENV('LANG');

  l_err_loc := 200;
  -- now loop
  FOR i in 1..l_content_zone_ids.COUNT LOOP
    l_err_loc := 300;
    -- now get all the categories for that zone
    SELECT ip_category_id
    BULK COLLECT INTO l_category_ids
    FROM icx_cat_zone_secure_attributes
    WHERE zone_id = l_content_zone_ids(i)
    AND securing_attribute = 'CATEGORY';

    l_err_loc := 400;
    -- now get all the suppliers and sites for that zone
    SELECT supplier_id, supplier_site_id
    BULK COLLECT INTO l_supplier_ids, l_supplier_site_ids
    FROM icx_cat_zone_secure_attributes
    WHERE zone_id = l_content_zone_ids(i)
    AND securing_attribute = 'SUPPLIER';

    l_err_loc := 450;
    -- set the current sqe sequence
    l_current_sqe_sequence := l_sqe_sequences(i);

    l_err_loc := 500;
    -- now call the API to create sqes for the zone
    create_sqes_for_zone (l_content_zone_ids(i), l_supplier_attr_action_flags(i), l_supplier_ids,
      l_supplier_site_ids, l_items_without_supplier_flags(i), l_category_attr_action_flags(i),
      l_category_ids, l_items_without_shop_cat_flags(i), l_return_status, l_current_sqe_sequence);

    IF (l_return_status = 'S') THEN
      l_err_loc := 600;
      -- success, update the sqe sequence
      l_sqe_sequences(i) := l_current_sqe_sequence;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_string := 'Succesfully updating the sequence for content_zone: ' || l_content_zone_ids(i)
          || ' to sqe_sequence: ' || l_sqe_sequences(i);
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
      END IF;
    ELSE
      l_err_loc := 700;
      x_return_status := 'E';
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_string := 'Error for content_zone: ' || l_content_zone_ids(i) || ' sqe_sequence: ' || l_sqe_sequences(i);
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
      END IF;
      -- error
      IF (l_first_errored_zone = 1) THEN
        l_first_errored_zone := 0;
        x_errored_zone_name_list := l_content_zone_names(i);
      ELSE
        IF (length(x_errored_zone_name_list) + length(l_content_zone_names(i)) < 3950) THEN
          x_errored_zone_name_list := x_errored_zone_name_list || ', ' || l_content_zone_names(i);
        END IF;
      END IF;
    END IF;
  END LOOP;

  l_err_loc := 800;
  -- now update all the content zones with the new sqe sequences
  FORALL i IN 1..l_content_zone_ids.COUNT
    UPDATE icx_cat_content_zones_b
    SET sqe_sequence = l_sqe_sequences(i)
    WHERE zone_id = l_content_zone_ids(i);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End sync_sqes_hier_change_internal';
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SQE_PVT.sync_sqes_hier_change_internal(' ||
     l_err_loc || '), ' || SQLERRM);

END sync_sqes_hier_change_internal;


-- procedure to sync sqes for all content zones
-- called for hierarchy changes from a concurrent program
-- this will call the main api which does the actual sync
-- this api in addition updates the failed line messages
-- and the job status
PROCEDURE sync_sqes_for_hierarchy_change
(
  x_errbuf OUT NOCOPY VARCHAR2,
  x_retcode OUT NOCOPY NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'sync_sqes_for_hierarchy_change';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_request_id NUMBER;
  l_return_status VARCHAR2(1);
  l_errored_zone_name_list VARCHAR2(4000);
  l_token_list VARCHAR2(4000);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting sync_sqes_for_hierarchy_change';
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;
  l_err_loc := 100;

  -- first start off with no error
  x_retcode := 0;
  x_errbuf := '';

  l_err_loc := 200;
  -- get the concurrent request Id
  l_request_id := fnd_global.conc_request_id;

  l_err_loc := 300;
  -- update the job status to running
  ICX_CAT_SCHEMA_UPLOAD_PVT.update_job_status(l_request_id, 'RUNNING');

  l_err_loc := 400;
  -- call the main API to do the sync
  sync_sqes_hier_change_internal(l_return_status, l_errored_zone_name_list);

  l_err_loc := 500;
  -- set job status depending on whether there is an error on not
  IF (l_return_status = 'E') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_string := 'Could not sync sqes for some zones. Updating the job to error.';
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
    END IF;
    l_err_loc := 600;
    -- update the job status to error
    x_retcode := 1;
    ICX_CAT_SCHEMA_UPLOAD_PVT.update_job_status(l_request_id, 'ERROR');

    l_err_loc := 700;
    l_token_list := 'ZONE_NAMES:' || l_errored_zone_name_list;

    l_err_loc := 800;
    INSERT INTO icx_por_failed_line_messages
      (job_number, descriptor_key, message_name, token_list, line_number, request_id, program_id,
      program_application_id, program_login_id)
    VALUES (l_request_id, 'OTHER',  'ICX_CAT_CANNOT_UPDATE_CZS_ERR', l_token_list, 1, l_request_id,
      fnd_global.conc_program_id, fnd_global.prog_appl_id, fnd_global.conc_login_id);
  ELSE
    l_err_loc := 900;
    -- update the job status to completed
    ICX_CAT_SCHEMA_UPLOAD_PVT.update_job_status(l_request_id, 'COMPLETED');
  END IF;

  l_err_loc := 1000;

  COMMIT;

  l_err_loc := 1100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End sync_sqes_for_hierarchy_change';
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;

  x_retcode := 2;
  x_errbuf := 'Exception at ICX_CAT_SQE_PVT.sync_sqes_for_hierarchy_change(' ||
     l_err_loc || '), ' || SQLERRM;

  -- update the job status to error
  ICX_CAT_SCHEMA_UPLOAD_PVT.update_job_status(l_request_id, 'ERROR');

  INSERT INTO icx_por_failed_line_messages
    (job_number, descriptor_key, message_name, token_list, line_number, request_id, program_id,
     program_application_id, program_login_id)
  VALUES (l_request_id, 'OTHER',  'ICX_CAT_HIER_UNEXPECTED_ERR', l_token_list, 1, l_request_id,
    fnd_global.conc_program_id, fnd_global.prog_appl_id, fnd_global.conc_login_id);

  COMMIT;

END sync_sqes_for_hierarchy_change;

-- procedure to sync sqes for all content zones
-- called for hierarchy changes from the schema loader
-- this will call the main api which does the actual sync
-- this api in addition updates the failed line messages
-- and the failed lines table
PROCEDURE sync_sqes_for_hierarchy_change
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'sync_sqes_for_hierarchy_change';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_request_id NUMBER;
  l_errored_zone_name_list VARCHAR2(4000);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting sync_sqes_hier_change';
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;
  l_err_loc := 100;
  -- call the main API to do the sync
  sync_sqes_hier_change_internal(x_return_status, l_errored_zone_name_list);

  l_err_loc := 500;
  -- if there is an error then we insert into failed lines and failed line messages
  IF (x_return_status = 'E') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_string := 'Could not sync sqes for some zones. Returning error.';
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
    END IF;
    l_err_loc := 800;
    INSERT INTO icx_por_failed_line_messages
      (job_number, descriptor_key, message_name, token_list, line_number, request_id, program_id,
      program_application_id, program_login_id)
    VALUES (p_request_id, 'ICX_CAT_CONTENT_ZONES',  'ICX_CAT_CANNOT_UPDATE_ZONES', null, p_line_number, p_request_id,
      fnd_global.conc_program_id, fnd_global.prog_appl_id, fnd_global.conc_login_id);

    l_err_loc := 900;
    INSERT INTO icx_por_failed_lines
      (job_number, line_number, action, row_type, descriptor_key, descriptor_value,
      request_id, program_id, program_application_id, program_login_id)
    VALUES (p_request_id, p_line_number, p_action, 'RELATIONSHIP', 'ICX_CAT_CONTENT_ZONES',
      l_errored_zone_name_list, p_request_id, fnd_global.conc_program_id,
      fnd_global.prog_appl_id, fnd_global.conc_login_id);
  END IF;

  l_err_loc := 1000;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End sync_sqes_hier_change';
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SQE_PVT.sync_sqes_for_hierarchy_change(' ||
     l_err_loc || '), ' || SQLERRM);
END sync_sqes_for_hierarchy_change;

-- procedure to sync the sqes for all the zones
-- this will only be called during upgrade
-- this is also useful for testing purposes and also useful if we
-- want to re-sync all zones on any instance
PROCEDURE sync_sqes_for_all_zones
IS
  l_api_name CONSTANT VARCHAR2(30) := 'sync_sqes_for_all_zones';
  l_log_string VARCHAR2(32000);
  l_err_loc PLS_INTEGER;
  l_content_zone_ids ICX_TBL_NUMBER;
  l_content_zone_names ICX_TBL_VARCHAR240;
  l_supplier_attr_action_flags ICX_TBL_VARCHAR40;
  l_supplier_ids ICX_TBL_NUMBER;
  l_supplier_site_ids ICX_TBL_NUMBER;
  l_items_without_supplier_flags ICX_TBL_FLAG;
  l_category_attr_action_flags ICX_TBL_VARCHAR40;
  l_category_ids ICX_TBL_NUMBER;
  l_items_without_shop_cat_flags ICX_TBL_FLAG;
  l_sqe_sequences ICX_TBL_NUMBER;
  l_return_status VARCHAR2(1);
  l_current_sqe_sequence NUMBER;
  l_request_id NUMBER;
  l_errored_zone_name_list VARCHAR2(4000);
  l_first_errored_zone PLS_INTEGER;
  l_token_list VARCHAR2(4000);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Starting sync_sqes_for_all_zones';
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;
  -- first start off with no error
  l_first_errored_zone := 1;

  l_err_loc := 100;
  -- first query all the content zones for the basic information
  -- we only query those that are local
  -- and have either include or exclude for category
  SELECT zones.zone_id, zonestl.name, supplier_attribute_action_flag, category_attribute_action_flag,
    items_without_supplier_flag, items_without_shop_catg_flag, sqe_sequence
  BULK COLLECT INTO l_content_zone_ids, l_content_zone_names, l_supplier_attr_action_flags,
    l_category_attr_action_flags, l_items_without_supplier_flags, l_items_without_shop_cat_flags, l_sqe_sequences
  FROM icx_cat_content_zones_b zones, icx_cat_content_zones_tl zonestl
  WHERE zones.type = 'LOCAL'
  AND zones.zone_id = zonestl.zone_id
  AND zonestl.language = USERENV('LANG');

  l_err_loc := 200;
  -- now loop
  FOR i in 1..l_content_zone_ids.COUNT LOOP
    l_err_loc := 300;
    -- now get all the categories for that zone
    SELECT ip_category_id
    BULK COLLECT INTO l_category_ids
    FROM icx_cat_zone_secure_attributes
    WHERE zone_id = l_content_zone_ids(i)
    AND securing_attribute = 'CATEGORY';

    l_err_loc := 400;
    -- now get all the suppliers and sites for that zone
    SELECT supplier_id, supplier_site_id
    BULK COLLECT INTO l_supplier_ids, l_supplier_site_ids
    FROM icx_cat_zone_secure_attributes
    WHERE zone_id = l_content_zone_ids(i)
    AND securing_attribute = 'SUPPLIER';

    l_err_loc := 450;
    -- set the current sqe sequence
    l_current_sqe_sequence := l_sqe_sequences(i);

    l_err_loc := 500;
    -- now call the API to create sqes for the zone
    create_sqes_for_zone (l_content_zone_ids(i), l_supplier_attr_action_flags(i), l_supplier_ids,
      l_supplier_site_ids, l_items_without_supplier_flags(i), l_category_attr_action_flags(i),
      l_category_ids, l_items_without_shop_cat_flags(i), l_return_status, l_current_sqe_sequence);

    IF (l_return_status = 'S') THEN
      l_err_loc := 600;
      -- success, update the sqe sequence
      l_sqe_sequences(i) := l_current_sqe_sequence;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_string := 'Succesfully updating the sequence for content_zone: ' || l_content_zone_ids(i)
          || ' to sqe_sequence: ' || l_sqe_sequences(i);
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
      END IF;
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_string := 'Error for content_zone: ' || l_content_zone_ids(i) || ' sqe_sequence: ' || l_sqe_sequences(i);
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name), l_log_string);
      END IF;
      l_err_loc := 700;
      -- error
      IF (l_first_errored_zone = 1) THEN
        l_first_errored_zone := 0;
        l_errored_zone_name_list := l_content_zone_names(i);
      ELSE
        IF (length(l_errored_zone_name_list) + length(l_content_zone_names(i)) < 3950) THEN
          l_errored_zone_name_list := l_errored_zone_name_list || ', ' || l_content_zone_names(i);
        END IF;
      END IF;
    END IF;
  END LOOP;

  l_err_loc := 800;
  -- now update all the content zones with the new sqe sequences
  FORALL i IN 1..l_content_zone_ids.COUNT
    UPDATE icx_cat_content_zones_b
    SET sqe_sequence = l_sqe_sequences(i)
    WHERE zone_id = l_content_zone_ids(i);

  l_err_loc := 900;

  COMMIT;

  l_err_loc := 1000;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'End sync_sqes_for_all_zones';
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, l_log_string);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SQE_PVT.sync_sqes_for_all_zones(' ||
     l_err_loc || '), ' || SQLERRM);

END sync_sqes_for_all_zones;

END ICX_CAT_SQE_PVT;

/
