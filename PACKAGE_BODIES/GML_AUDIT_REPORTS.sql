--------------------------------------------------------
--  DDL for Package Body GML_AUDIT_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_AUDIT_REPORTS" AS
/* $Header: GMLOGMCB.pls 120.1 2005/09/30 13:41:02 pbamb noship $ */

FUNCTION get_ofi_line_count(p_hid NUMBER)
  RETURN NUMBER
IS
  l_linecnt NUMBER;

  CURSOR lcnt_cur IS
    SELECT count(*)
    FROM   po_line_locations_all
    WHERE  po_header_id = p_hid;

BEGIN
  OPEN  lcnt_cur;
  FETCH lcnt_cur
  INTO  l_linecnt;

  IF lcnt_cur%NOTFOUND THEN
    l_linecnt:=0;
  END IF;

  CLOSE lcnt_cur;

  RETURN l_linecnt;

END get_ofi_line_count;

FUNCTION get_ofi_bline_count(p_hid NUMBER)
  RETURN NUMBER
IS
  l_linecnt NUMBER;

  CURSOR lcnt_cur IS
    SELECT count(*)
    FROM   po_line_locations_all
    WHERE  po_header_id = p_hid
    AND    nvl(po_release_id, 0) > 0;

BEGIN

  OPEN  lcnt_cur;
  FETCH lcnt_cur
  INTO  l_linecnt;

  IF lcnt_cur%NOTFOUND THEN
    l_linecnt:=0;
  END IF;

  CLOSE lcnt_cur;

  RETURN l_linecnt;

END get_ofi_bline_count;

FUNCTION get_ofi_total_cost(p_hid NUMBER)
  RETURN NUMBER
IS
  l_cost NUMBER;

  CURSOR cost_cur IS
    SELECT SUM(quantity*unit_price)
    FROM   po_lines_all
    WHERE  po_header_id=p_hid;

  BEGIN
    OPEN cost_cur;
    FETCH cost_cur INTO l_cost;
    IF cost_cur%NOTFOUND
    THEN
      l_cost:=0;
    END IF;
    CLOSE cost_cur;

    RETURN l_cost;

  END get_ofi_total_cost;

  FUNCTION get_ofi_btotal_cost(p_hid NUMBER) RETURN NUMBER IS

    l_cost NUMBER;

    CURSOR cost_cur IS
      SELECT SUM(quantity*price_override)
	FROM po_line_locations_all
       WHERE po_header_id=p_hid
       AND   nvl(po_release_id,0) > 0;

  BEGIN
    OPEN cost_cur;
    FETCH cost_cur INTO l_cost;
    IF cost_cur%NOTFOUND
    THEN
      l_cost:=0;
    END IF;
    CLOSE cost_cur;

    RETURN l_cost;

  END get_ofi_btotal_cost;

  FUNCTION get_gemms_line_count(p_id NUMBER) RETURN NUMBER IS

    l_linecnt NUMBER;

    CURSOR lcnt_cur IS
      SELECT count(*)
	FROM po_ordr_dtl
       WHERE po_id=p_id;

  BEGIN
    OPEN lcnt_cur;
    FETCH lcnt_cur INTO l_linecnt;
    IF lcnt_cur%NOTFOUND
    THEN
      l_linecnt:=0;
    END IF;
    CLOSE lcnt_cur;

    RETURN l_linecnt;

  END get_gemms_line_count;

  FUNCTION get_gemms_bline_count(p_hid NUMBER) RETURN NUMBER IS

    l_linecnt NUMBER;

    CURSOR lcnt_cur IS
      SELECT count(*)
	FROM po_ordr_dtl
       WHERE po_id IN (SELECT po_id
		       FROM   cpg_oragems_mapping f
		       WHERE  f.po_header_id = p_hid
		       AND    nvl(po_release_id,0)>0);

  BEGIN
    OPEN lcnt_cur;
    FETCH lcnt_cur INTO l_linecnt;
    IF lcnt_cur%NOTFOUND
    THEN
      l_linecnt:=0;
    END IF;
    CLOSE lcnt_cur;

    RETURN l_linecnt;

  END get_gemms_bline_count;

  FUNCTION get_gemms_total_cost(p_id NUMBER) RETURN NUMBER IS

    l_cost NUMBER;

    CURSOR cost_cur IS
      SELECT SUM(order_qty1*net_price)
	FROM po_ordr_dtl
       WHERE po_id=p_id
         AND cancellation_code is NULL;

  BEGIN
    OPEN cost_cur;
    FETCH cost_cur INTO l_cost;
    IF cost_cur%NOTFOUND
    THEN
      l_cost:=0;
    END IF;
    CLOSE cost_cur;

    RETURN l_cost;

  END get_gemms_total_cost;

  FUNCTION get_gemms_btotal_cost(p_hid NUMBER) RETURN NUMBER IS

    l_cost NUMBER;

    CURSOR cost_cur IS
      SELECT SUM(order_qty1*net_price)
	FROM po_ordr_dtl
       WHERE po_id IN (SELECT po_id
		       FROM   cpg_oragems_mapping f
		       WHERE  f.po_header_id = p_hid
		       AND    nvl(po_release_id,0)>0);

  BEGIN
    OPEN cost_cur;
    FETCH cost_cur INTO l_cost;
    IF cost_cur%NOTFOUND
    THEN
      l_cost:=0;
    END IF;
    CLOSE cost_cur;

    RETURN l_cost;

  END get_gemms_btotal_cost;

  FUNCTION match_ofi_gms_po_line(p_ohid NUMBER,
				   p_olid NUMBER,
				   p_ollid NUMBER,
				   p_gid NUMBER,
				   p_glid NUMBER) RETURN VARCHAR2 IS
  l_ret  VARCHAR2(1);

  CURSOR ofi_gms_mch_cur IS
    SELECT 'Y'
      FROM cpg_oragems_mapping a
     WHERE a.po_header_id=p_ohid
       AND a.po_line_id = p_olid
       AND a.po_line_location_id=p_ollid
       AND a.po_id=p_gid
       AND a.line_id=p_glid;

  BEGIN

    OPEN ofi_gms_mch_cur;
    FETCH ofi_gms_mch_cur INTO l_ret;
    IF ofi_gms_mch_cur%NOTFOUND
    THEN
      l_ret:='N';
    END IF;
    CLOSE ofi_gms_mch_cur;

    RETURN l_ret;

  END match_ofi_gms_po_line;

  FUNCTION chk_ofi_gms_poln_itm( p_olid NUMBER,
				   p_glid NUMBER) RETURN VARCHAR2 IS

    l_gms_itm    ic_item_mst.item_no%TYPE;
    l_ofi_itm    mtl_system_items.segment1%TYPE;

    CURSOR gms_itm_cur IS
      SELECT a.item_no
	FROM ic_item_mst a,
	     po_ordr_dtl b
       WHERE a.item_id=b.item_id
	 AND b.line_id=p_glid;

    CURSOR ofi_itm_cur IS
      SELECT segment1
	FROM po_lines_all a,
	     mtl_system_items b
       WHERE a.item_id=b.inventory_item_id
	 AND a.po_line_id=p_olid;
  BEGIN
    OPEN gms_itm_cur;
    FETCH gms_itm_cur INTO l_gms_itm;
    CLOSE gms_itm_cur;

    OPEN ofi_itm_cur;
    FETCH ofi_itm_cur INTO l_ofi_itm;
    CLOSE ofi_itm_cur;

    IF l_gms_itm IS NULL OR
       l_ofi_itm IS NULL
    THEN
      RETURN 'Y';
    END IF;

    IF l_gms_itm<>l_ofi_itm
    THEN
      RETURN 'Y';
    END IF;

    RETURN 'N';

  END chk_ofi_gms_poln_itm;

  FUNCTION chk_ofi_gms_poln_sts( p_ollid NUMBER,
				   p_glid NUMBER) RETURN VARCHAR2 IS
    l_gms_stat VARCHAR2(20);
    l_ofi_stat VARCHAR2(20);

    CURSOR gms_sts_cur IS
      SELECT DECODE(po_status,0,'OPEN',1,'CANCEL',20,'CLOSE','X')
	FROM po_ordr_dtl
       WHERE line_id=p_glid;

    CURSOR ofi_sts_cur IS
      SELECT DECODE(closed_code,'OPEN','OPEN','CLOSED','CLOSE',
	     'FINALLY CLOSED','CLOSE','CLOSED FOR RECEIVING','CLOSE','OPEN')
	FROM po_line_locations_all
       WHERE line_location_id=p_ollid;

  BEGIN
    OPEN gms_sts_cur;
    FETCH gms_sts_cur INTO l_gms_stat;
    CLOSE gms_sts_cur;

    OPEN ofi_sts_cur;
    FETCH ofi_sts_cur INTO l_ofi_stat;
    CLOSE ofi_sts_cur;

    IF l_gms_stat IS NULL OR
       l_ofi_stat IS NULL
    THEN
      RETURN 'Y';
    END IF;

    IF l_gms_stat<>l_ofi_stat
    THEN
      RETURN 'Y';
    END IF;

    RETURN 'N';

  END chk_ofi_gms_poln_sts;



FUNCTION get_po_num( p_ponum VARCHAR2)
RETURN VARCHAR2
IS
  position VARCHAR2(500) := 1;
  po_num   VARCHAR2(100);
BEGIN

  SELECT instr(p_ponum, '-', -1)
  INTO   position
  FROM   dual;

 if position = 0 then
   return p_ponum;
 end if;

 po_num := LTRIM(substr(p_ponum, 1, position-1), '0');
 return po_num;

END get_po_num;


FUNCTION get_rel_num( p_ponum VARCHAR2) RETURN NUMBER IS
 position varchar2(500) := 1;
 rel_num varchar2(500);
BEGIN

 select instr(p_ponum, '-', -1) into position
   from dual;

 if position = 0 then
   return null;
 end if;

 rel_num := to_number(substr(p_ponum, position+1));
 return rel_num;

END get_rel_num;

END GML_AUDIT_REPORTS;

/
