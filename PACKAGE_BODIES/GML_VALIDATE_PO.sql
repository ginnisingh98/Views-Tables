--------------------------------------------------------
--  DDL for Package Body GML_VALIDATE_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_VALIDATE_PO" AS
/* $Header: GMLPOVAB.pls 115.7 99/10/26 11:36:32 porting ship $ */

FUNCTION val_orgn_code (v_orgn_code IN SY_ORGN_MST.ORGN_CODE%TYPE)
/*========================================================================
|                                                                        |
| FUNCTION NAME        val_orgn_code                                     |
|                                                                        |
| DESCRIPTION          Function for Orgn code validation.                |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 11/22/97        Ravi Dasani  created                                   |
|                                                                        |
 ========================================================================*/
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR op_orgn_cur IS
  SELECT 1
  FROM sy_orgn_mst
  WHERE orgn_code = v_orgn_code
  AND delete_mark = 0;

BEGIN
  OPEN  op_orgn_cur;
  FETCH op_orgn_cur INTO v_dummy;
  IF op_orgn_cur%FOUND THEN
    CLOSE op_orgn_cur;
    RETURN TRUE;
  ELSE
    CLOSE op_orgn_cur;
    RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_orgn_code;

/*========================================================================
|                                                                        |
| FUNCTION NAME        val_operator_code                                 |
|                                                                        |
| DESCRIPTION          Function for operator code validation.            |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
| 05/20/98        T. Ricci commented Function sy_oper_mst not in         |
|                 GEMMS 5.0                                              |
|                                                                        |
 ========================================================================

FUNCTION val_operator_code (v_op_code IN sy_oper_mst.op_code%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR op_code_cur IS
  SELECT 1
  FROM sy_oper_mst
  WHERE op_code = v_op_code
  AND delete_mark = 0;

BEGIN
  OPEN  op_code_cur;
  FETCH op_code_cur INTO v_dummy;
  IF op_code_cur%FOUND THEN
    CLOSE op_code_cur;
    RETURN TRUE;
  ELSE
    CLOSE op_code_cur;
    RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_operator_code;

========================================================================
|                                                                        |
| FUNCTION NAME        val_doc_assign                                    |
|                                                                        |
| DESCRIPTION          Function for document validation.                 |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |
=========================================================================*/

FUNCTION val_doc_assign (v_orgn_code IN sy_docs_seq.orgn_code%TYPE)
RETURN BOOLEAN

IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR doc_cur IS
  SELECT 1
  FROM sy_docs_seq
  WHERE doc_type = 'PORD'
  AND   orgn_code = v_orgn_code
  AND   delete_mark = 0;

BEGIN
  OPEN  doc_cur;
  FETCH doc_cur INTO v_dummy;
  IF doc_cur%FOUND THEN
    CLOSE doc_cur;
    RETURN TRUE;
  ELSE
    CLOSE doc_cur;
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_doc_assign;

/*========================================================================
|                                                                        |
| FUNCTION NAME        val_warehouse                                     |
|                                                                        |
| DESCRIPTION          Function for warehouse validation.                |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
| 03/18/98        Ravi Dasani  modified to add validation of whse and org|
|                              for the same set of books.                |
|                                                                        |
=========================================================================*/

FUNCTION val_warehouse (v_whse_code IN ic_whse_mst.whse_code%TYPE,
                        v_orgn_code IN ic_whse_mst.orgn_code%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;
  v_whse_sob NUMBER;
  v_org_sob  NUMBER;

  CURSOR whse_cur IS
  SELECT distinct sob_id
  from   gl_plcy_mst
  where  co_code = (select co_code
                    from   sy_orgn_mst
                    where  orgn_code = (select orgn_code
                                        from   ic_whse_mst
                                        where  whse_code=v_whse_code));

  CURSOR org_cur IS
  SELECT distinct sob_id
  from   gl_plcy_mst
  where  co_code = (select co_code
                    from   sy_orgn_mst
                    where  orgn_code = v_orgn_code);

BEGIN
  OPEN  whse_cur;
  FETCH whse_cur into v_whse_sob;
  OPEN  org_cur;
  FETCH org_cur into v_org_sob;

  IF whse_cur%NOTFOUND THEN
    CLOSE whse_cur;
    CLOSE org_cur;
    RETURN FALSE;
  END IF;

  IF (v_whse_sob = v_org_sob) THEN
    CLOSE whse_cur;
    CLOSE org_cur;
    RETURN TRUE;
  ELSE
    CLOSE whse_cur;
    CLOSE org_cur;
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_warehouse;

/*========================================================================
|                                                                        |
| FUNCTION NAME        val_vendor                                        |
|                                                                        |
| DESCRIPTION          Function for vendor validation.                   |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |
=========================================================================*/

FUNCTION val_vendor
(v_of_vendor_site_id IN po_vend_mst.of_vendor_site_id%TYPE,
 v_co_code IN po_vend_mst.co_code%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR vendor_cur IS
  SELECT 1
  FROM po_vend_mst
  WHERE of_vendor_site_id = v_of_vendor_site_id
  AND ship_ind > 0
  /* B#972240 Begin */
  /*AND co_code = v_co_code; */
  AND ((co_code = v_co_code) OR(co_code is NULL));
  /* B#972240 end */

BEGIN
  OPEN vendor_cur;
  FETCH vendor_cur into v_dummy;
  IF vendor_cur%FOUND THEN
    CLOSE vendor_cur;
    RETURN TRUE;
  ELSE
    CLOSE vendor_cur;
    RETURN FALSE;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_vendor;

/*========================================================================
|                                                                        |
| FUNCTION NAME        val_item                                          |
|                                                                        |
| DESCRIPTION          Function for item validation.                     |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |
=========================================================================*/

FUNCTION val_item (v_item_no IN ic_item_mst.item_no%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR item_cur IS
  SELECT 1
  FROM   ic_item_mst
  WHERE  item_no = v_item_no;

BEGIN
  OPEN item_cur;
  FETCH item_cur into v_dummy;
  IF item_cur%FOUND THEN
    CLOSE item_cur;
    RETURN TRUE;
  ELSE
    CLOSE item_cur;
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_item;


/*========================================================================
|                                                                        |
| FUNCTION NAME        val_currency                                      |
|                                                                        |
| DESCRIPTION          Function for currency validation.                 |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
|  10/22/97        Kenny Jiang  created                                  |
|                                                                        |
=========================================================================*/

FUNCTION val_currency (v_currency_code IN gl_curr_mst.currency_code%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR currency_cur IS
  SELECT 1
  FROM gl_curr_mst
  WHERE currency_code = v_currency_code;

BEGIN
  OPEN currency_cur;
  FETCH currency_cur into v_dummy;
  IF currency_cur%FOUND THEN
    CLOSE currency_cur;
    RETURN TRUE;
  ELSE
    CLOSE currency_cur;
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_currency;


/*========================================================================
|                                                                        |
| FUNCTION NAME        val_aqui_cost_code                                |
|                                                                        |
| DESCRIPTION          Function for cost code validation.                |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |
=========================================================================*/

FUNCTION val_aqui_cost_code
(v_aqui_cost_code IN po_cost_mst.aqui_cost_code%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR cost_cur IS
  SELECT 1
  FROM    po_cost_mst
  WHERE   aqui_cost_code = v_aqui_cost_code;

BEGIN
  OPEN cost_cur;
  FETCH cost_cur into v_dummy;
  IF cost_cur%FOUND THEN
    CLOSE cost_cur;
    RETURN TRUE;
  ELSE
    CLOSE cost_cur;
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_aqui_cost_code;


/*========================================================================
|                                                                        |
| FUNCTION NAME        val_uom                                           |
|                                                                        |
| DESCRIPTION          Function for unit of measure validation.          |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
|  10/22/97        Kenny Jiang  created                                  |
|                                                                        |
 ========================================================================*/

FUNCTION val_uom
(v_um_code IN sy_uoms_mst.um_code%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR uom_cur IS
  SELECT 1
  FROM    sy_uoms_mst
  WHERE   um_code = v_um_code;

BEGIN
  OPEN uom_cur;
  FETCH uom_cur INTO v_dummy;
  IF uom_cur%FOUND THEN
    CLOSE uom_cur;
    RETURN TRUE;
  ELSE
    CLOSE uom_cur;
    RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_uom;


/*========================================================================
|                                                                        |
| FUNCTION NAME        val_shipper_code                                  |
|                                                                        |
| DESCRIPTION          Function for shipper code validation.             |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |
=========================================================================*/

FUNCTION val_shipper_code
(v_shipper_code IN op_ship_mst.shipper_code%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR shipper_cur IS
  SELECT 1
  FROM    op_ship_mst
  WHERE   shipper_code = v_shipper_code;

BEGIN
  OPEN shipper_cur;
  FETCH  shipper_cur INTO v_dummy;
  IF shipper_cur%FOUND THEN
    CLOSE shipper_cur;
    RETURN TRUE;
  ELSE
    CLOSE shipper_cur;
    RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_shipper_code;

/*========================================================================
|                                                                        |
| FUNCTION NAME        val_frtbill_mthd                                  |
|                                                                        |
| DESCRIPTION          Function for frtbill method validation.           |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
| 11/10/98        Tony Ricci   changed to use of_frtbill_mthd            |
|                                                                        |
=========================================================================*/

FUNCTION val_frtbill_mthd
(v_frtbill_mthd IN op_frgt_mth.of_frtbill_mthd%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR frtbill_cur IS
  SELECT 1
  FROM    op_frgt_mth
  WHERE   of_frtbill_mthd = v_frtbill_mthd;

BEGIN
  OPEN frtbill_cur;
  FETCH frtbill_cur INTO v_dummy;
  IF frtbill_cur%FOUND THEN
    CLOSE frtbill_cur;
    RETURN TRUE;
  ELSE
    CLOSE frtbill_cur;
    RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_frtbill_mthd;

/*========================================================================
|                                                                        |
| FUNCTION NAME        val_terms_code                                    |
|                                                                        |
| DESCRIPTION          Function for terms code validation.               |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
| 06/11/99        Tony Ricci use of_terms_code instead of terms_code     |
|                                                                        |
========================================================================*/

FUNCTION val_terms_code
(v_of_terms_code IN op_term_mst.of_terms_code%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR terms_cur IS
  SELECT 1
  FROM    op_term_mst
  WHERE   of_terms_code = v_of_terms_code;

BEGIN
  OPEN terms_cur;
  FETCH terms_cur INTO v_dummy;
  IF terms_cur%FOUND THEN
    CLOSE terms_cur;
    RETURN TRUE;
  ELSE
    CLOSE terms_cur;
    RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_terms_code;


/*========================================================================
|                                                                        |
| FUNCTION NAME        val_qc_grade_wanted                               |
|                                                                        |
| DESCRIPTION          Function for qc_grade validation.                 |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 12/11/97        Rajeshwari Chellam     created                         |
|                                                                        |
========================================================================*/

FUNCTION val_qc_grade_wanted
(v_qc_grade_wanted IN qc_grad_mst.qc_grade%TYPE)
RETURN BOOLEAN
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_dummy NUMBER;

  CURSOR qc_grade_cur IS
  SELECT 1
  FROM   qc_grad_mst
  WHERE  qc_grade = v_qc_grade_wanted;

BEGIN
  OPEN qc_grade_cur;
  FETCH qc_grade_cur INTO v_dummy;
  IF qc_grade_cur%FOUND THEN
    CLOSE qc_grade_cur;
    RETURN TRUE;
  ELSE
    CLOSE qc_grade_cur;
    RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END val_qc_grade_wanted;

/*========================================================================
|                                                                        |
| PROCEDURE NAME       get_gl_source                                     |
|                                                                        |
| DESCRIPTION          Procedure to get gl source.                       |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |
=========================================================================*/

PROCEDURE get_gl_source
(v_trans_source_type OUT gl_srce_mst.trans_source_type%TYPE)
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);

  CURSOR gl_cur IS
  SELECT  trans_source_type
  FROM    gl_srce_mst
  WHERE   trans_source_code = 'PO';

BEGIN
  OPEN gl_cur;
  FETCH gl_cur INTO v_trans_source_type;
  CLOSE gl_cur;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);
END get_gl_source;

/*========================================================================
|                                                                        |
| PROCEDURE NAME       get_base_currency                                 |
|                                                                        |
| DESCRIPTION          Procedure to get base currency.                   |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |     =========================================================================*/

PROCEDURE get_base_currency
(v_base_currency_code OUT gl_plcy_mst.base_currency_code%TYPE,
 v_orgn_code IN sy_orgn_mst.orgn_code%TYPE)
IS
  err_num NUMBER;
  err_msg VARCHAR2(100);

  CURSOR base_currency_cur IS
  SELECT  plcy.base_currency_code
  FROM    sy_orgn_mst orgn,
          gl_plcy_mst plcy
  WHERE   orgn.orgn_code = v_orgn_code AND
          orgn.co_code = plcy.co_code;

BEGIN
  OPEN base_currency_cur;
  FETCH base_currency_cur  INTO v_base_currency_code;
  CLOSE base_currency_cur;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END get_base_currency;

/*========================================================================
|                                                                        |
| PROCEDURE NAME       get_exchange_rate                                 |
|                                                                        |
| DESCRIPTION          Procedure to get exchange rate.                   |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |
========================================================================*/

PROCEDURE get_exchange_rate
(v_exchange_rate OUT gl_xchg_rte.exchange_rate%TYPE,
 v_mul_div_sign OUT gl_xchg_rte.mul_div_sign%TYPE,
 v_exchange_rate_date OUT gl_xchg_rte.exchange_rate_date%TYPE,
 v_to_currency IN gl_xchg_rte.to_currency_code%TYPE,
 v_from_currency IN gl_xchg_rte.from_currency_code%TYPE,
 v_trans_source_type IN gl_srce_mst.trans_source_type%TYPE)

IS
  err_num NUMBER;
  err_msg VARCHAR2(100);

  CURSOR exchange_cur IS
  SELECT  ex.exchange_rate,
          ex.mul_div_sign,
          ex.exchange_rate_date
  FROM    gl_xchg_rte ex,
          gl_srce_mst src
  WHERE   ex.to_currency_code = v_to_currency  AND
          ex.from_currency_code = v_from_currency  AND
          ex.exchange_rate_date <= SYSDATE  AND
          ex.rate_type_code = src.rate_type_code  AND
          src.trans_source_type = v_trans_source_type AND
          ex.delete_mark =0;

BEGIN
  OPEN exchange_cur;
  FETCH exchange_cur  INTO  v_exchange_rate,
                            v_mul_div_sign,
                            v_exchange_rate_date;
  CLOSE exchange_cur;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    raise_application_error(-20000, err_msg);

END get_exchange_rate;


END GML_VALIDATE_PO;

/
