--------------------------------------------------------
--  DDL for Package Body QP_ITEM_RANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ITEM_RANGE_PVT" AS
/* $Header: QPXITRGB.pls 120.1 2005/06/14 05:22:17 appldev  $ */

PROCEDURE items_in_range
(
 p_segment1_lohi        IN	VARCHAR2,
 p_segment2_lohi        IN	VARCHAR2,
 p_segment3_lohi        IN	VARCHAR2,
 p_segment4_lohi        IN	VARCHAR2,
 p_segment5_lohi        IN	VARCHAR2,
 p_segment6_lohi        IN	VARCHAR2,
 p_segment7_lohi        IN	VARCHAR2,
 p_segment8_lohi        IN	VARCHAR2,
 p_segment9_lohi        IN	VARCHAR2,
 p_segment10_lohi       IN	VARCHAR2,
 p_segment11_lohi       IN	VARCHAR2,
 p_segment12_lohi       IN	VARCHAR2,
 p_segment13_lohi       IN	VARCHAR2,
 p_segment14_lohi       IN	VARCHAR2,
 p_segment15_lohi       IN	VARCHAR2,
 p_segment16_lohi       IN	VARCHAR2,
 p_segment17_lohi       IN	VARCHAR2,
 p_segment18_lohi       IN	VARCHAR2,
 p_segment19_lohi       IN	VARCHAR2,
 p_segment20_lohi       IN	VARCHAR2,
 p_org_id	              IN	NUMBER,
 p_category_set_id      IN    NUMBER,
 p_category_id	         IN	NUMBER,
 p_status_code 	    IN	VARCHAR2,
 p_item_tbl             OUT NOCOPY /* file.sql.39 change */   l_tbl%TYPE
)
IS
  l_items_tbl     DBMS_SQL.VARCHAR2_TABLE;
  l_rows_updated  INTEGER;
  l_cursor_id     INTEGER;
  l_batchsize     CONSTANT INTEGER := 1;
  l_update_stmt   VARCHAR2(4000);
  l_rows_fetched  NUMBER;

  l_orgflag BOOLEAN  := FALSE;
  l_setflag BOOLEAN  := FALSE;
  l_catflag BOOLEAN  := FALSE;
  l_statflag BOOLEAN := FALSE;
l_status      VARCHAR2(1);
l_industry    VARCHAR2(1);
l_application_id       NUMBER := 660;
l_retval      BOOLEAN;




BEGIN

  l_cursor_id := DBMS_SQL.OPEN_CURSOR;

  l_update_stmt := 'SELECT m.inventory_item_id
    		            FROM mtl_system_items m
    		           WHERE m.organization_id = :l_org ';

 l_retval := fnd_installation.get(l_application_id,l_application_id,
                                                 l_status,l_industry);
   IF l_status = 'I' THEN
    l_update_stmt := l_update_stmt || 'AND m.CUSTOMER_ORDER_FLAG = ''Y'' ';
   END IF;



  IF (p_segment1_lohi = ''''' AND ''''') AND
     (p_segment2_lohi = ''''' AND ''''') AND
     (p_segment3_lohi = ''''' AND ''''') AND
     (p_segment4_lohi = ''''' AND ''''') AND
     (p_segment5_lohi = ''''' AND ''''') AND
     (p_segment6_lohi = ''''' AND ''''') AND
     (p_segment7_lohi = ''''' AND ''''') AND
     (p_segment8_lohi = ''''' AND ''''') AND
     (p_segment9_lohi = ''''' AND ''''') AND
     (p_segment10_lohi = ''''' AND ''''') AND
     (p_segment11_lohi = ''''' AND ''''') AND
     (p_segment12_lohi = ''''' AND ''''') AND
     (p_segment13_lohi = ''''' AND ''''') AND
     (p_segment14_lohi = ''''' AND ''''') AND
     (p_segment15_lohi = ''''' AND ''''') AND
     (p_segment16_lohi = ''''' AND ''''') AND
     (p_segment17_lohi = ''''' AND ''''') AND
     (p_segment18_lohi = ''''' AND ''''') AND
     (p_segment19_lohi = ''''' AND ''''') AND
     (p_segment20_lohi = ''''' AND ''''')
  THEN
    l_orgflag := TRUE;
  ELSE

    IF (p_segment1_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment1 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment1   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment1_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment2_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment2 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment2   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment2_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment3_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment3 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment3   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment3_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment4_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment4 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment4   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment4_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment5_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment5 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment5   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment5_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment6_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment6 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment6   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment6_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment7_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment7 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment7   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment7_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment8_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment8 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment8   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment8_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment9_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment9 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment9   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment9_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment10_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment10 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment10   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment10_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment11_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment11 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment11   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment11_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment12_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment12 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment12   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment12_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment13_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment13 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment13   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment13_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment14_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment14 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment14   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment14_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment15_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
		 'AND    (m.segment15 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment15   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment15_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment16_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment16 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment16   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment16_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment17_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment17 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment17   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment17_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment18_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment18 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment18   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment18_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment19_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment19 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment19   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment19_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    IF (p_segment20_lohi = ''''' AND ''''') THEN
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment20 IS NULL) ';
    ELSE
      l_update_stmt := l_update_stmt ||
           'AND    (m.segment20   BETWEEN ';
      l_update_stmt := l_update_stmt ||p_segment20_lohi;
      l_update_stmt := l_update_stmt ||' )';
    END IF;

    l_orgflag := TRUE;

  END IF;


  IF  (p_status_code IS NOT NULL) THEN
    l_update_stmt := l_update_stmt ||
		 'AND    m.inventory_item_status_code =  :l_stat ';
    l_statflag := TRUE;
  END IF;

/* Added by dhgupta for 2068915 */

IF p_category_set_id IS NULL THEN
    l_update_stmt := l_update_stmt ||
                 'AND    m.inventory_item_id IN
                 ( SELECT ic.inventory_item_id
                   FROM   mtl_item_categories ic
                   WHERE  ic.inventory_item_id = m.inventory_item_id
                   AND    ic.organization_id   = m.organization_id
                   AND    ic.organization_id   = :l_org )';
END IF;

/* Added by dhgupta for 2068915 */

IF p_category_set_id IS NOT NULL AND p_category_id IS NULL THEN
    l_update_stmt := l_update_stmt ||
                 'AND    m.inventory_item_id IN
                 ( SELECT ic.inventory_item_id
                   FROM   mtl_item_categories ic
                   WHERE  ic.inventory_item_id = m.inventory_item_id
                   AND    ic.organization_id   = m.organization_id
                   AND    ic.organization_id   = :l_org
                   AND    ic.category_set_id   = :l_set )';
    l_setflag := TRUE;
END IF;

 /* Added by dhgupta for 2068915 */

IF p_category_set_id IS NOT NULL AND p_category_id IS NOT NULL THEN
    l_update_stmt := l_update_stmt ||
                 'AND    m.inventory_item_id IN
                 ( SELECT ic.inventory_item_id
                   FROM   mtl_item_categories ic
                   WHERE  ic.inventory_item_id = m.inventory_item_id
                   AND    ic.organization_id   = m.organization_id
                   AND    ic.organization_id   = :l_org
                   AND    ic.category_set_id   = :l_set
                   AND    ic.category_id       = :l_cat )';
    l_setflag := TRUE;
    l_catflag := TRUE;
END IF;

/*
  IF (p_category_id IS NOT NULL) THEN
    l_update_stmt := l_update_stmt ||
		 'AND    m.inventory_item_id IN
		 ( SELECT ic.inventory_item_id
		   FROM   mtl_item_categories ic
		   WHERE  ic.inventory_item_id = m.inventory_item_id
		   AND    ic.organization_id   = m.organization_id
		   AND    ic.category_set_id   = :l_set
		   AND    ic.category_id       = :l_cat )';
    l_setflag := TRUE;
    l_catflag := TRUE;
  END IF;
*/

--Parse the statement
  DBMS_SQL.PARSE(l_cursor_id, l_update_stmt, DBMS_SQL.V7);

--Bind variables to the placeholders

  IF l_orgflag = TRUE THEN
    DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':l_org' , p_org_id);
  END IF;

  IF l_statflag = TRUE THEN
    DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':l_stat' , p_status_code);
  END IF;

  IF l_setflag = TRUE THEN
    DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':l_set' , p_category_set_id);
  END IF;

  IF l_catflag = TRUE THEN
    DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':l_cat' , p_category_id);
  END IF;

-- Define output variables for the select.

  DBMS_SQL.DEFINE_ARRAY(l_cursor_id, 1, p_item_tbl, l_batchsize, 1);

--Execute the Statement
  l_rows_updated := DBMS_SQL.EXECUTE(l_cursor_id);

--This is the fetch loop.

  LOOP
    l_rows_fetched :=  DBMS_SQL.FETCH_ROWS(l_cursor_id);
    EXIT WHEN l_rows_fetched = 0;
    DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, p_item_tbl);
  END LOOP;

--Close the cursor
  DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

EXCEPTION
  WHEN OTHERS THEN
  DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
  RAISE;

END ITEMS_IN_RANGE;

END QP_ITEM_RANGE_PVT;

/
